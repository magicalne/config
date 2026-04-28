/**
 * Loop Extension - Run a prompt or slash command on a recurring interval.
 *
 * Usage:
 *   /loop 5m check if tests pass             - Run prompt every 5 minutes
 *   /loop /compact                            - Run /compact every 10 minutes (default)
 *   /loop 30s check build status              - Run prompt every 30 seconds
 *   /loop 1h /compact                         - Run /compact every 1 hour
 *   /loop stop                                - Stop the active loop
 *   /loop stop 2                              - Stop loop #2
 *   /loop pause                               - Pause the active loop
 *   /loop resume                              - Resume the most recently paused loop
 *   /loop list                                - List all loops
 *
 * Interval format: <number><unit> where unit is s/m/h (seconds/minutes/hours).
 * Default interval: 10m. No iteration limit — runs until you stop it.
 *
 * After each iteration, the loop waits for the agent to finish before
 * scheduling the next one. This prevents prompts from piling up.
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

// ── Types ──────────────────────────────────────────────────────────────────

interface Loop {
	id: number;
	prompt: string;
	intervalMs: number;
	timer: ReturnType<typeof setTimeout> | null;
	iteration: number;
	createdAt: Date;
	running: boolean;
	paused: boolean;
	waitingForAgent: boolean; // true when we've fired an iteration and are waiting for agent_end
}

// ── Helpers ────────────────────────────────────────────────────────────────

const INTERVAL_RE = /^(\d+)(s|m|h)$/;

function parseInterval(input: string): number | null {
	const match = input.match(INTERVAL_RE);
	if (!match) return null;
	const n = parseInt(match[1], 10);
	if (n <= 0) return null;
	const unit = match[2];
	if (unit === "s") return n * 1000;
	if (unit === "m") return n * 60 * 1000;
	if (unit === "h") return n * 60 * 60 * 1000;
	return null;
}

function formatInterval(ms: number): string {
	if (ms < 60_000) return `${ms / 1000}s`;
	if (ms < 3_600_000 && ms % 60_000 === 0) return `${ms / 60_000}m`;
	if (ms % 3_600_000 === 0) return `${ms / 3_600_000}h`;
	const minutes = Math.round(ms / 60_000);
	return `${minutes}m`;
}

// ── State ──────────────────────────────────────────────────────────────────

let loops: Loop[] = [];
let nextId = 1;
let activeLoopId: number | null = null;
let piRef: ExtensionAPI | null = null;
let ctxRef: ExtensionContext | null = null;
let statusUpdateInterval: ReturnType<typeof setInterval> | null = null;

function getActiveLoop(): Loop | undefined {
	return loops.find((l) => l.id === activeLoopId);
}

function updateStatus(ctx: ExtensionContext) {
	if (!ctx.hasUI) return;
	const theme = ctx.ui.theme;
	const active = getActiveLoop();
	if (!active) {
		ctx.ui.setStatus("loop", "");
		return;
	}

	const spinner = active.running && !active.paused ? theme.fg("accent", "⟳") : theme.fg("dim", "○");
	const label = theme.fg("muted", ` loop:${active.id}`);
	const detail = theme.fg(
		"dim",
		` ${formatInterval(active.intervalMs)} · #${active.iteration}`,
	);
	ctx.ui.setStatus("loop", spinner + label + detail);
}

function clearStatus(ctx: ExtensionContext) {
	if (!ctx.hasUI) return;
	ctx.ui.setStatus("loop", "");
}

function startStatusTicker(ctx: ExtensionContext) {
	if (statusUpdateInterval) clearInterval(statusUpdateInterval);
	if (ctx.hasUI) {
		statusUpdateInterval = setInterval(() => updateStatus(ctx), 30_000);
	}
}

function stopStatusTicker() {
	if (statusUpdateInterval) {
		clearInterval(statusUpdateInterval);
		statusUpdateInterval = null;
	}
}

// ── Loop lifecycle ─────────────────────────────────────────────────────────

function stopLoop(loop: Loop, ctx: ExtensionContext) {
	if (loop.timer) {
		clearTimeout(loop.timer);
		loop.timer = null;
	}
	loop.running = false;
	loop.paused = false;
	loop.waitingForAgent = false;
	if (activeLoopId === loop.id) {
		activeLoopId = null;
		stopStatusTicker();
	}
	updateStatus(ctx);
}

function pauseLoop(loop: Loop, ctx: ExtensionContext) {
	if (loop.timer) {
		clearTimeout(loop.timer);
		loop.timer = null;
	}
	loop.paused = true;
	loop.waitingForAgent = false;
	updateStatus(ctx);
	ctx.ui.notify(`Loop #${loop.id} paused at iteration ${loop.iteration}`, "info");
}

function resumeLoop(loop: Loop, ctx: ExtensionContext) {
	if (!loop.paused) return;
	loop.paused = false;
	activeLoopId = loop.id;
	startStatusTicker(ctx);
	// If we were mid-iteration, fire one now; otherwise schedule next
	if (loop.waitingForAgent) {
		// Was waiting for agent — schedule next after agent completes
		// The agent_end handler will pick it up
	} else {
		fireIteration(loop, ctx);
	}
	ctx.ui.notify(`Loop #${loop.id} resumed from iteration ${loop.iteration}`, "info");
}

function fireIteration(loop: Loop, ctx: ExtensionContext) {
	if (!loop.running || loop.paused) return;

	loop.iteration++;
	updateStatus(ctx);

	if (piRef) {
		piRef.sendUserMessage(loop.prompt);
	}

	// Mark that we're waiting for the agent to finish before scheduling next
	loop.waitingForAgent = true;
}

function scheduleNext(loop: Loop, ctx: ExtensionContext) {
	if (!loop.running || loop.paused) return;
	loop.waitingForAgent = false;

	loop.timer = setTimeout(() => {
		if (!loop.running || loop.paused) return;
		fireIteration(loop, ctx);
	}, loop.intervalMs);
}

function startLoop(
	prompt: string,
	intervalMs: number,
	ctx: ExtensionContext,
): Loop {
	// If there's an active loop, pause it
	const current = getActiveLoop();
	if (current) {
		pauseLoop(current, ctx);
	}

	const loop: Loop = {
		id: nextId++,
		prompt,
		intervalMs,
		timer: null,
		iteration: 0,
		createdAt: new Date(),
		running: true,
		paused: false,
		waitingForAgent: false,
	};

	loops.push(loop);
	activeLoopId = loop.id;
	startStatusTicker(ctx);

	// Fire first iteration immediately
	fireIteration(loop, ctx);

	ctx.ui.notify(
		`Loop #${loop.id} started: every ${formatInterval(intervalMs)}, press Esc or /loop stop to cancel`,
		"info",
	);

	return loop;
}

// ── Parse arguments ────────────────────────────────────────────────────────

function parseArgs(
	raw: string,
): { intervalMs: number; prompt: string } | string {
	const parts = raw.trim().split(/\s+/);

	if (parts.length === 0 || !parts[0]) {
		return "Usage: /loop [<interval>] <prompt or /command>  (interval: e.g. 5m, 30s, 1h; default: 10m)";
	}

	const defaultIntervalMs = 10 * 60 * 1000; // 10m
	let promptParts: string[];

	// Check if first arg looks like an interval
	const maybeInterval = parseInterval(parts[0]);
	if (maybeInterval !== null) {
		promptParts = parts.slice(1);
	} else {
		promptParts = parts;
	}

	if (promptParts.length === 0) {
		return "Error: no prompt or command specified.\nUsage: /loop [<interval>] <prompt or /command>";
	}

	return {
		intervalMs: maybeInterval ?? defaultIntervalMs,
		prompt: promptParts.join(" "),
	};
}

// ── Cleanup helper ─────────────────────────────────────────────────────────

function cleanupAll(ctx: ExtensionContext) {
	for (const loop of loops) {
		if (loop.timer) clearTimeout(loop.timer);
	}
	loops = [];
	activeLoopId = null;
	nextId = 1;
	stopStatusTicker();
	clearStatus(ctx);
}

// ── Extension ──────────────────────────────────────────────────────────────

export default function loopExtension(pi: ExtensionAPI) {
	piRef = pi;

	// When the agent finishes a turn, schedule the next loop iteration
	// if there's an active loop waiting for the agent to complete.
	pi.on("agent_end", async (_event, ctx) => {
		const active = getActiveLoop();
		if (active && active.running && !active.paused && active.waitingForAgent) {
			scheduleNext(active, ctx);
		}
	});

	// Clean up on shutdown
	pi.on("session_shutdown", async (_event, ctx) => {
		cleanupAll(ctx);
	});

	// Clean up on session switch
	pi.on("session_switch", async (_event, ctx) => {
		cleanupAll(ctx);
	});

	// Register the /loop command with autocomplete
	pi.registerCommand("loop", {
		description:
			"Run a prompt or slash command on a recurring interval (e.g. /loop 5m /foo, defaults to 10m)",
		getArgumentCompletions: (prefix: string) => {
			const subcommands = [
				{ value: "stop", label: "stop       - Stop the active loop" },
				{ value: "list", label: "list       - Show all loops" },
				{ value: "pause", label: "pause      - Pause the active loop" },
				{ value: "resume", label: "resume     - Resume a paused loop" },
			];
			// If prefix matches a subcommand, show those
			const isSubcommand = subcommands.some((s) => s.value.startsWith(prefix));
			if (isSubcommand) {
				return subcommands.filter((s) => s.value.startsWith(prefix));
			}
			// Otherwise show interval + subcommand hints
			const hints = [
				{ value: "10m ", label: "10m        - Every 10 minutes (default)" },
				{ value: "5m ", label: "5m         - Every 5 minutes" },
				{ value: "1m ", label: "1m         - Every 1 minute" },
				{ value: "30s ", label: "30s        - Every 30 seconds" },
				{ value: "1h ", label: "1h         - Every 1 hour" },
				...subcommands,
			];
			return hints.filter((h) => h.value.startsWith(prefix));
		},
		handler: async (args, ctx) => {
			ctxRef = ctx;
			const raw = args.trim();

			// ── Subcommands ──

			if (raw === "list" || raw === "ls") {
				if (loops.length === 0) {
					ctx.ui.notify("No loops.", "info");
					return;
				}
const theme = ctx.ui.theme;
				const items = loops.map((l) => {
					const status = l.running
						? l.paused
							? theme.fg("warning", "paused")
							: theme.fg("success", "active")
						: theme.fg("dim", "stopped");
					const active = l.id === activeLoopId ? theme.fg("accent", " ←") : "";
					return `${theme.fg("accent", `#${l.id}`)} ${status}  ${theme.fg("muted", formatInterval(l.intervalMs))}  #${l.iteration}  ${theme.fg("dim", `"${l.prompt}"`)}${active}`;
				});
				const selected = await ctx.ui.select("Loops", items);
				if (selected) {
					const idMatch = selected.match(/#(\d+)/);
					if (idMatch) {
						const loop = loops.find((l) => l.id === parseInt(idMatch[1]));
						if (loop) {
							const action = await ctx.ui.select(`Loop #${loop.id}`, [
								"Stop",
								loop.paused ? "Resume" : "Pause",
								"Cancel",
							]);
							if (action === "Stop") stopLoop(loop, ctx);
							else if (action === "Pause") pauseLoop(loop, ctx);
							else if (action === "Resume") resumeLoop(loop, ctx);
						}
					}
				}
				return;
			}

			if (raw === "stop" || raw.startsWith("stop ")) {
				const rest = raw.slice(4).trim();
				if (rest) {
					const id = parseInt(rest, 10);
					const loop = loops.find((l) => l.id === id);
					if (!loop) {
						ctx.ui.notify(`Loop #${id} not found`, "error");
						return;
					}
					stopLoop(loop, ctx);
					ctx.ui.notify(`Loop #${id} stopped`, "info");
				} else {
					const active = getActiveLoop();
					if (!active) {
						ctx.ui.notify("No active loop to stop", "warning");
						return;
					}
					stopLoop(active, ctx);
					ctx.ui.notify(`Loop #${active.id} stopped`, "info");
				}
				return;
			}

			if (raw === "pause") {
				const active = getActiveLoop();
				if (!active || !active.running) {
					ctx.ui.notify("No active loop to pause", "warning");
					return;
				}
				pauseLoop(active, ctx);
				return;
			}

			if (raw === "resume" || raw.startsWith("resume ")) {
				const rest = raw.slice(6).trim();
				let loop: Loop | undefined;
				if (rest) {
					const id = parseInt(rest, 10);
					loop = loops.find((l) => l.id === id);
				} else {
					// Resume the most recently paused loop
					loop = [...loops].reverse().find((l) => l.paused);
				}
				if (!loop) {
					ctx.ui.notify("No paused loop to resume", "warning");
					return;
				}
				resumeLoop(loop, ctx);
				return;
			}

			// ── Start a new loop ──

			if (!raw) {
				ctx.ui.notify(
					"Usage: /loop [<interval>] <prompt or /command>\nExamples:\n  /loop 5m check if tests pass\n  /loop /compact\n  /loop 30s !npm test",
					"info",
				);
				return;
			}

			// Wait for agent to be idle before starting
			if (!ctx.isIdle()) {
				ctx.ui.notify("Wait for the agent to finish before starting a loop", "warning");
				return;
			}

			const parsed = parseArgs(raw);
			if (typeof parsed === "string") {
				ctx.ui.notify(parsed, "warning");
				return;
			}

			startLoop(parsed.prompt, parsed.intervalMs, ctx);
		},
	});
}
