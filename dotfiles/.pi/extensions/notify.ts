/**
 * Notify on task completion.
 *
 * Runs the `notify` shell command when the pi agent finishes a task,
 * so you get alerted and can jump back to the terminal or tmux pane.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { execFile } from "child_process";

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async () => {
		execFile("notify", [], (error) => {
			if (error) {
				// fallback: just ring the terminal bell
				process.stdout.write("\x07");
			}
		});
	});
}
