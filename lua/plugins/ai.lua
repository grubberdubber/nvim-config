-- ── AI: INLINE COMPLETION (MINUET) + AGENT (AVANTE) ──────────────
-- Both talk to NVIDIA NIM through OpenAI-compatible endpoints, but they are
-- separate frontends: Minuet draws inline virtual text, Avante opens a panel.
-- Neither one goes through blink's completion menu.
return {
    -- ── MINUET: inline completion through NVIDIA NIM ──────────────
    -- Manual only: the user asks for a suggestion with <M-]>, so typing
    -- never fires a request. Minuet's virtual-text frontend stays separate
    -- from blink's completion menu.
    {
        "milanglacier/minuet-ai.nvim",
        event = "InsertEnter",
        config = function()
            require("minuet").setup {
                provider = "openai_compatible",
                request_timeout = 5,
                throttle = 0,
                debounce = 0,
                n_completions = 1,
                notify = "error",
                -- Keep Minuet out of blink's menu: inline suggestions are a
                -- separate frontend and accept only with <C-g>.
                blink = {
                    enable_auto_complete = false,
                },
                virtualtext = {
                    auto_trigger_ft = {},
                    show_on_completion_menu = false,
                    keymap = {
                        accept = "<C-g>",
                        accept_line = "<M-a>",
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                },
                provider_options = {
                    openai_compatible = {
                        api_key = "NVIDIA_API_KEY",
                        end_point = "https://integrate.api.nvidia.com/v1/chat/completions",
                        model = "nvidia/nemotron-3.5-lightning-30b-a3b",
                        name = "NVIDIA NIM",
                        optional = {
                            max_tokens = 128,
                            temperature = 0.2,
                            top_p = 0.9,
                            chat_template_kwargs = { enable_thinking = false },
                        },
                    },
                },
            }

            -- Minuet renders its suggestion before blink opens. Its own
            -- show_on_completion_menu check does not clear that existing
            -- extmark, so dismiss it whenever blink's menu opens or closes.
            vim.api.nvim_create_autocmd("User", {
                pattern = { "BlinkCmpMenuOpen", "BlinkCmpMenuClose" },
                group = vim.api.nvim_create_augroup("MinuetBlinkMenu", { clear = true }),
                callback = function()
                    local ok, virtualtext = pcall(require, "minuet.virtualtext")
                    if ok then
                        virtualtext.action.dismiss()
                    end
                end,
                desc = "Hide Minuet suggestion while blink menu is active",
            })

            -- Never let the AI act while blink's menu is open: the suggestion
            -- is intentionally hidden there, so accepting it blindly would
            -- insert text the user cannot see.
            local function minuet_action(name)
                return function()
                    local ok, blink = pcall(require, "blink.cmp")
                    local menu_open = false
                    if ok and blink.is_menu_visible then
                        local visible_ok, visible = pcall(blink.is_menu_visible)
                        menu_open = visible_ok and visible
                    end
                    if menu_open then
                        return
                    end
                    require("minuet.virtualtext").action[name]()
                end
            end

            vim.keymap.set("i", "<C-g>", minuet_action "accept", { desc = "Minuet: accept suggestion", silent = true })
            vim.keymap.set("i", "<M-a>", minuet_action "accept_line", { desc = "Minuet: accept line", silent = true })
            vim.keymap.set("i", "<M-]>", minuet_action "next", { desc = "Minuet: next suggestion", silent = true })
            vim.keymap.set("i", "<M-[>", minuet_action "prev", { desc = "Minuet: previous suggestion", silent = true })
        end,
    },

    -- ── AVANTE.NVIM: agentic AI with NVIDIA NIM / OpenRouter ──────
    -- Avante is a Cursor-style assistant: ask in natural language and it
    -- edits, explains or generates code with full project context.
    {
        "yetone/avante.nvim",
        version = false, -- Track the latest release instead of a fixed tag
        build = "make",
        event = "VeryLazy",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            -- Required by avante's command parser (mega.cmdparse).
            { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
            {
                "MeanderingProgrammer/render-markdown.nvim",
                opts = { file_types = { "markdown", "Avante" } },
                ft = { "markdown", "Avante" },
            },
        },
        opts = require("configs.avante").opts,
    },
}
