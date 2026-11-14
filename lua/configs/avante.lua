-- ── AVANTE PROVIDERS: NVIDIA NIM + OPENROUTER ────────────────────
-- Both endpoints are OpenAI-compatible, so they inherit Avante's OpenAI
-- provider. Keep the model list here so the plugin config and the
-- <leader>ag picker cannot drift apart.
local M = {}

M.models = {
    -- NVIDIA NIM
    { label = "NVIDIA · Nemotron 3 Super 120B", provider = "nvidia", model = "nvidia/nemotron-3-super-120b-a12b" },
    {
        label = "NVIDIA · Nemotron 3.5 Lightning 30B",
        provider = "nvidia",
        model = "nvidia/nemotron-3.5-lightning-30b-a3b",
    },
    {
        label = "NVIDIA · Nemotron 70B",
        provider = "nvidia",
        model = "nvidia/llama-3.1-nemotron-70b-instruct",
    },
    {
        label = "NVIDIA · Nemotron Ultra 253B",
        provider = "nvidia",
        model = "nvidia/llama-3.1-nemotron-ultra-253b-v1",
    },
    { label = "NVIDIA · GLM 5.3 Flash", provider = "nvidia", model = "z-ai/glm-5.3-flash" },
    { label = "NVIDIA · GPT-OSS 20B", provider = "nvidia", model = "openai/gpt-oss-20b" },
    { label = "NVIDIA · DeepSeek V4.1 Flash", provider = "nvidia", model = "deepseek-ai/deepseek-v4.1-flash" },

    -- OpenRouter
    { label = "OpenRouter · Auto", provider = "openrouter", model = "openrouter/auto" },
    { label = "OpenRouter · Claude Sonnet 4.5", provider = "openrouter", model = "anthropic/claude-sonnet-4.5" },
    { label = "OpenRouter · GPT-5", provider = "openrouter", model = "openai/gpt-5" },
    { label = "OpenRouter · DeepSeek Chat 3.1", provider = "openrouter", model = "deepseek/deepseek-chat-v3.1" },
    {
        label = "OpenRouter · Llama 3.3 70B",
        provider = "openrouter",
        model = "meta-llama/llama-3.3-70b-instruct",
    },
}

M.providers = {
    nvidia = {
        __inherited_from = "openai",
        endpoint = "https://integrate.api.nvidia.com/v1",
        model = "nvidia/nemotron-3-super-120b-a12b",
        model_names = {
            "nvidia/nemotron-3-super-120b-a12b",
            "nvidia/nemotron-3.5-lightning-30b-a3b",
            "nvidia/llama-3.1-nemotron-70b-instruct",
            "nvidia/llama-3.1-nemotron-ultra-253b-v1",
            "z-ai/glm-5.3-flash",
            "openai/gpt-oss-20b",
            "deepseek-ai/deepseek-v4.1-flash",
        },
        api_key_name = "NVIDIA_API_KEY",
        timeout = 60000,
        context_window = 131072,
        extra_request_body = { temperature = 0.3, max_tokens = 8192 },
    },
    openrouter = {
        __inherited_from = "openai",
        endpoint = "https://openrouter.ai/api/v1",
        model = "openrouter/auto",
        model_names = {
            "openrouter/auto",
            "anthropic/claude-sonnet-4.5",
            "openai/gpt-5",
            "deepseek/deepseek-chat-v3.1",
            "meta-llama/llama-3.3-70b-instruct",
        },
        api_key_name = "OPENROUTER_API_KEY",
        timeout = 60000,
        context_window = 200000,
        extra_request_body = { temperature = 0.3, max_tokens = 8192 },
    },
}

M.opts = {
    provider = "nvidia",
    providers = M.providers,
    behaviour = {
        auto_suggestions = false,
        enable_fastapply = false,
    },
    repo_map = {
        ignore_patterns = { ".git", "node_modules" },
    },
}

local function apply(choice)
    require("avante.config").override {
        provider = choice.provider,
        providers = { [choice.provider] = { model = choice.model } },
    }
    require("avante.providers").refresh(choice.provider)
    vim.notify("Avante: " .. choice.label, vim.log.levels.INFO)
end

function M.select_model()
    vim.ui.select(M.models, {
        prompt = "Avante model (NVIDIA / OpenRouter):",
        format_item = function(item)
            return item.label
        end,
    }, function(choice)
        if choice then
            apply(choice)
        end
    end)
end

function M.reset()
    apply { label = "NVIDIA · Nemotron 3 Super 120B", provider = "nvidia", model = "nvidia/nemotron-3-super-120b-a12b" }
end

return M
