# Shared LLM provider switching.
#
# Do not put secrets in this file.
# Keep private keys in ~/.config/fish/llm.local.fish instead.
# A placeholder template is available in:
#   dotfiles/.config/fish/llm.local.example.fish

# Non-secret defaults
set -q MOONSHOT_API_BASE; or set -gx MOONSHOT_API_BASE "https://api.moonshot.cn/v1"

# Load private local keys or overrides before selecting defaults.
if test -f ~/.config/fish/llm.local.fish
    source ~/.config/fish/llm.local.fish
end

function __llm_set_or_erase --argument-names name value
    if test -n "$value"
        set -gx $name $value
    else
        set -e $name 2>/dev/null
    end
end

function __llm_maybe_echo --argument-names message
    if not set -q __llm_quiet
        echo $message
    end
end

# ========== OPENAI Compatible Configurations ==========
# Note: There are multiple OPENAI configurations - only one can be active at a time.

function use_openai_qwen
    __llm_set_or_erase OPENAI_API_KEY "$DASHSCOPE_API_KEY"
    set -gx OPENAI_BASE_URL "https://dashscope.aliyuncs.com/compatible-mode/v1"
    set -gx OPENAI_MODEL "qwen3-coder-plus"
    __llm_maybe_echo "Switched to OpenAI-compatible Qwen"
end

function use_openai_zhipu
    __llm_set_or_erase OPENAI_API_KEY "$ZAI_API_KEY"
    set -gx OPENAI_BASE_URL "https://open.bigmodel.cn/api/coding/paas/v4/"
    set -gx OPENAI_MODEL "glm-4.6"
    __llm_maybe_echo "Switched to OpenAI-compatible Zhipu"
end

function use_openai_openrouter
    __llm_set_or_erase OPENAI_API_KEY "$OPENROUTER_API_KEY"
    set -gx OPENAI_BASE_URL "https://openrouter.ai/api/v1"
    set -gx OPENAI_MODEL "qwen/qwen-2.5-coder-32b-instruct:free"
    __llm_maybe_echo "Switched to OpenAI-compatible OpenRouter"
end

# ========== Anthropic Compatible Configurations ==========

function use_anthropic_kimi
    set -gx ANTHROPIC_BASE_URL https://api.moonshot.cn/anthropic
    __llm_set_or_erase ANTHROPIC_API_KEY "$MOONSHOT_API_KEY"
    set -e ANTHROPIC_AUTH_TOKEN 2>/dev/null
    __llm_maybe_echo "Switched to Anthropic-compatible Kimi"
end

function use_anthropic_zai
    set -gx ANTHROPIC_BASE_URL https://open.bigmodel.cn/api/anthropic
    set -e ANTHROPIC_API_KEY 2>/dev/null
    __llm_set_or_erase ANTHROPIC_AUTH_TOKEN "$ZAI_API_KEY"
    __llm_maybe_echo "Switched to Anthropic-compatible Z.ai"
end

function use_anthropic_qwen
    set -gx ANTHROPIC_BASE_URL https://dashscope.aliyuncs.com/api/v2/apps/claude-code-proxy
    __llm_set_or_erase ANTHROPIC_API_KEY "$DASHSCOPE_API_KEY"
    set -e ANTHROPIC_AUTH_TOKEN 2>/dev/null
    __llm_maybe_echo "Switched to Anthropic-compatible Qwen"
end

# Load default provider selections quietly during shell startup.
set -g __llm_quiet 1
use_openai_qwen
use_anthropic_zai
set -e __llm_quiet

# ========== Model Selection Helper Functions ==========
function llm_status
    echo "=== Current LLM Configuration ==="
    echo "OpenAI API: $OPENAI_BASE_URL"
    echo "OpenAI Model: $OPENAI_MODEL"
    echo "Anthropic Base: $ANTHROPIC_BASE_URL"
    echo ""
    echo "Available providers:"
    echo "  OpenAI: qwen, zhipu, openrouter"
    echo "  Anthropic: kimi, zai, qwen"
end

function set_openai_provider
    switch $argv[1]
        case qwen
            use_openai_qwen
        case zhipu
            use_openai_zhipu
        case openrouter
            use_openai_openrouter
        case "*"
            echo "Unknown provider. Available: qwen, zhipu, openrouter"
    end
end

function set_anthropic_provider
    switch $argv[1]
        case kimi
            use_anthropic_kimi
        case zai
            use_anthropic_zai
        case qwen
            use_anthropic_qwen
        case "*"
            echo "Unknown provider. Available: kimi, zai, qwen"
    end
end

# ========== API Key Validation ==========
function validate_api_keys
    echo "=== API Key Status ==="

    function check_key --argument-names key_name
        if test -n "$$key_name"
            echo "✅ $key_name: Set"
        else
            echo "❌ $key_name: Not set"
        end
    end

    check_key GROQ_API_KEY
    check_key DEEPSEEK_API_KEY
    check_key MOONSHOT_API_KEY
    check_key DASHSCOPE_API_KEY
    check_key ZAI_API_KEY
    check_key OPENROUTER_API_KEY
    check_key GEMINI_API_KEY
    check_key CEREBRAS_API_KEY
end

# ========== Quick Provider Switching ==========
abbr -a openai-qwen 'use_openai_qwen'
abbr -a openai-zhipu 'use_openai_zhipu'
abbr -a openai-or 'use_openai_openrouter'
abbr -a anthropic-kimi 'use_anthropic_kimi'
abbr -a anthropic-zai 'use_anthropic_zai'
abbr -a anthropic-qwen 'use_anthropic_qwen'
abbr -a llm-status 'llm_status'
abbr -a check-keys 'validate_api_keys'
