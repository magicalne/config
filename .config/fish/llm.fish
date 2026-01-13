# LLM API Keys and configurations
# Separated from general environment variables for better organization

# ========== Individual API Keys ==========
set -gx GROQ_API_KEY ""
set -gx DEEPSEEK_API_KEY ""
set -gx QWEN_API_KEY ""
set -gx MISTRAL_API_KEY ""
set -gx GOOGLE_API_KEY ""
set -gx HYPERBOLIC_API_KEY ""
set -gx OPENROUTER_API_KEY ""
set -gx FAST_API_KEY ""
set -gx CO_API_KEY ""
set -gx CEREBRAS_API_KEY ""
set -gx GEMINI_API_KEY ""

# Kimi (Moonshot)
set -gx MOONSHOT_API_BASE "https://api.moonshot.cn/v1"
set -gx MOONSHOT_API_KEY ""

# Qwen (DashScope)
set -gx DASHSCOPE_API_KEY ""

# Zhipu (Z.ai)
set -gx ZAI_API_KEY ""

# ========== OPENAI Compatible Configurations ==========
# Note: There are multiple OPENAI configurations - only one can be active at a time

# Option 1: Using Qwen with DashScope as OpenAI
function use_openai_qwen
    set -gx OPENAI_API_KEY $DASHSCOPE_API_KEY
    set -gx OPENAI_BASE_URL "https://dashscope.aliyuncs.com/compatible-mode/v1"
    set -gx OPENAI_MODEL "qwen3-coder-plus"
    echo "Switched to OpenAI-compatible Qwen"
end

# Option 2: Using Zhipu as OpenAI
function use_openai_zhipu
    set -gx OPENAI_API_KEY $ZAI_API_KEY
    set -gx OPENAI_BASE_URL "https://open.bigmodel.cn/api/coding/paas/v4/"
    set -gx OPENAI_MODEL "glm-4.6"
    echo "Switched to OpenAI-compatible Zhipu"
end

# Option 3: Using OpenRouter as OpenAI
function use_openai_openrouter
    set -gx OPENAI_API_KEY $OPENROUTER_API_KEY
    set -gx OPENAI_BASE_URL "https://openrouter.ai/api/v1"
    set -gx OPENAI_MODEL "qwen/qwen-2.5-coder-32b-instruct:free"
    echo "Switched to OpenAI-compatible OpenRouter"
end

# Default: Use Qwen as OpenAI
use_openai_qwen

# ========== Anthropic Compatible Configurations ==========
# Option 1: Kimi (Moonshot) as Anthropic
function use_anthropic_kimi
    set -gx ANTHROPIC_BASE_URL https://api.moonshot.cn/anthropic
    set -gx ANTHROPIC_API_KEY $MOONSHOT_API_KEY
    echo "Switched to Anthropic-compatible Kimi"
end

# Option 2: Z.ai (Zhipu) as Anthropic
function use_anthropic_zai
    set -gx ANTHROPIC_BASE_URL https://open.bigmodel.cn/api/anthropic
    set -gx ANTHROPIC_AUTH_TOKEN $ZAI_API_KEY
    echo "Switched to Anthropic-compatible Z.ai"
end

# Option 3: Qwen as Anthropic
function use_anthropic_qwen
    set -gx ANTHROPIC_API_KEY $DASHSCOPE_API_KEY
    set -gx ANTHROPIC_BASE_URL https://dashscope.aliyuncs.com/api/v2/apps/claude-code-proxy
    echo "Switched to Anthropic-compatible Qwen"
end

# Default: Use Z.ai as Anthropic
use_anthropic_zai

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
    
    # Check if key is set and not empty
    function check_key
        if test -n "$$argv[1]"
            echo "✅ $argv[1]: Set"
        else
            echo "❌ $argv[1]: Not set"
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
# Alias for quick switching
abbr -a openai-qwen 'use_openai_qwen'
abbr -a openai-zhipu 'use_openai_zhipu'
abbr -a openai-or 'use_openai_openrouter'
abbr -a anthropic-kimi 'use_anthropic_kimi'
abbr -a anthropic-zai 'use_anthropic_zai'
abbr -a anthropic-qwen 'use_anthropic_qwen'
abbr -a llm-status 'llm_status'
abbr -a check-keys 'validate_api_keys'
