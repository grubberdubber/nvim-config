local plugins = {
    -- ── DESACTIVA nvim-cmp (viene de NvChad base) ───────────────────
    { "hrsh7th/nvim-cmp", enabled = false },

    -- ── BLINK.CMP — Motor de autocompletado ─────────────────────────
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "rafamadriz/friendly-snippets",
            {
                "saghen/blink.compat",
                version = "*",
                lazy = true,
                opts = {},
            },
        },
        event = "InsertEnter",
        opts = require "configs.blink",
        opts_extend = { "sources.default" },
    },

    -- ── AUTOPAIRS (integrado con blink.cmp) ──────────────────────────
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup {
                check_ts = true,
                ts_config = {
                    lua = { "string" },
                    python = { "string" },
                },
                fast_wrap = { map = "<M-e>" },
            }
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        event = { "BufReadPre", "BufNewFile" },
        ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "php", "vue", "svelte" },
        opts = {},
    },
    -- ── 1. HERRAMIENTAS GIT ────────────────────────────────────────
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        opts = {},
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
        },
        cmd = "Neogit",
        opts = {
            integrations = { diffview = true },
        },
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufWritePost", "BufReadPost", "InsertLeave" },
        config = function()
            require "configs.lint"
        end,
    },

    -- ── 2. COLOR PICKER PARA CSS ───────────────────────────────────
    {
        "uga-rosa/ccc.nvim",
        cmd = { "CccPick", "CccConvert" },
        keys = {
            { "<leader>cp", "<cmd>CccPick<cr>", desc = "Selector de Color Visual" },
        },
        config = function()
            require("ccc").setup {
                highlighter = { auto_enable = true, lsp = true },
            }
        end,
    },

    -- ── 3. INDENT BLANKLINE (Líneas │ siempres visibles + Puntos ·)
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPre", "BufNewFile" },
        main = "ibl",
        config = function()
            local hooks = require "ibl.hooks"
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "IblIndentOpaque", { fg = "#4b5263" })
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75", bold = true })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B", bold = true })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF", bold = true })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66", bold = true })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379", bold = true })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD", bold = true })
            end)
            require("ibl").setup {
                indent = {
                    char = "│",
                    tab_char = "│",
                    highlight = "IblIndentOpaque",
                },
                scope = {
                    enabled = true,
                    char = "│",
                    show_start = false,
                    show_end = false,
                    highlight = {
                        "RainbowRed",
                        "RainbowYellow",
                        "RainbowBlue",
                        "RainbowOrange",
                        "RainbowGreen",
                        "RainbowViolet",
                    },
                    include = {
                        node_type = {
                            ["*"] = {
                                -- Python
                                "if_statement",
                                "elif_clause",
                                "else_clause",
                                "for_statement",
                                "while_statement",
                                "with_statement",
                                "try_statement",
                                "except_clause",
                                "match_statement",
                                "function_definition",
                                "class_definition",
                                -- Lua
                                "for_in_statement",
                                "repeat_statement",
                                "function_declaration",
                                "local_function",
                                -- JS/TS
                                "do_statement",
                                "switch_statement",
                                "function_expression",
                                "arrow_function",
                                "class_declaration",
                                "method_definition",
                                "interface_declaration",
                                -- PHP
                                "foreach_statement",
                                "method_declaration",
                                -- C/C++
                                "struct_specifier",
                                "class_specifier",
                                "namespace_definition",
                                "for_range_loop",
                                -- Rust
                                "if_expression",
                                "for_expression",
                                "while_expression",
                                "loop_expression",
                                "match_expression",
                                "function_item",
                                "impl_item",
                                "trait_item",
                                "mod_item",
                                "struct_item",
                                "enum_item",
                                -- Go
                                "expression_switch_statement",
                                "type_switch_statement",
                                "select_statement",
                                "struct_type",
                                -- Kotlin
                                "when_expression",
                                -- Java
                                "enhanced_for_statement",
                                "switch_expression",
                                -- Bash
                                "case_statement",
                                -- Ruby
                                "unless",
                                "until",
                                "case",
                                "method",
                                "class",
                                "module",
                                "do_block",
                                "block",
                                -- Dart
                                "function_signature",
                                "method_signature",
                                -- Swift
                                "guard_statement",
                                "protocol_declaration",
                                -- PowerShell
                                "function_statement",
                                -- Perl
                                "unless_statement",
                                "sub_definition",
                                "package_statement",
                            },
                        },
                    },
                },
            }
        end,
    },

    -- ── 4. BÚSQUEDA Y REEMPLAZO GLOBAL (Spectre) ───────────────────
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        keys = {
            { "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', desc = "Buscar y reemplazar globalmente" },
        },
    },

    -- ── 5. MASON Y LSPs ────────────────────────────────────────────
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
        opts = {},
        config = function(_, opts)
            require("mason").setup(opts)
            local tools = {
                "stylua",
                "black",
                "prettier",
                "shfmt",
                "clang-format",
                "google-java-format",
                "php-cs-fixer",
                "rubyfmt",
                "ktlint",
                "scalafmt",
                "sql-formatter",
                "sqlfluff",
                "js-debug-adapter",
                "java-debug-adapter",
                "java-test",
                "stylelint",
            }
            local ok, mr = pcall(require, "mason-registry")
            if not ok then
                return
            end
            mr.refresh(function()
                for _, tool in ipairs(tools) do
                    local ok_pkg, pkg = pcall(mr.get_package, tool)
                    if ok_pkg and not pkg:is_installed() then
                        pkg:install()
                    end
                end
            end)
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            ensure_installed = {
                "lua_ls",
                "html",
                "cssls",
                "ts_ls",
                "pyright",
                "rust_analyzer",
                "bashls",
                "clangd",
                "gopls",
                "intelephense",
                "jdtls",
                "omnisharp",
                "sqlls",
                "kotlin_language_server",
            },
            automatic_installation = false,
            automatic_enable = {
                exclude = { "jdtls" }, -- jdtls arranca vía ftplugin/java.lua (con bundles de debug), no acá
            },
        },
    },

    -- ── VISTA PREVIA WEB EN VIVO (LIVE SERVER) ───────────────────────
    {
        "barrett-ruth/live-server.nvim",
        build = "npm install -g live-server",
        cmd = { "LiveServerStart", "LiveServerStop" },
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.lspconfig"
        end,
    },

    {
        "b0o/schemastore.nvim",
        lazy = true,
    },

    -- ── ÁRBOL DE SINTAXIS UNIFICADO (TREESITTER + TEXTOBJECTS) ─────
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        lazy = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = {
                    "vim",
                    "lua",
                    "vimdoc",
                    "html",
                    "css",
                    "javascript",
                    "typescript",
                    "php",
                    "c",
                    "cpp",
                    "rust",
                    "go",
                    "c_sharp",
                    "kotlin",
                    "java",
                    "objc",
                    "asm",
                    "python",
                    "bash",
                    "powershell",
                    "ruby",
                    "perl",
                    "r",
                    "julia",
                    "matlab",
                    "sql",
                    "scala",
                    "dart",
                    "terraform",
                    "gotmpl",
                    "json",
                    "yaml",
                    "toml",
                    "markdown",
                    "markdown_inline",
                    "dockerfile",
                    "graphql",
                    "ini",
                    "hcl",
                    "gitignore",
                    "git_config",
                },
                highlight = { enable = true },
                indent = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["aq"] = "@statement.outer",
                        },
                    },
                },
            }
        end,
    },

    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = require "configs.conform",
    },

    {
        "NvChad/nvim-colorizer.lua",
        event = "User FilePost",
        config = function()
            require("colorizer").setup()
        end,
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("harpoon"):setup()
        end,
    },

    {
        "aca/emmet-ls",
        ft = { "html", "css", "javascript", "typescript", "php" },
    },

    {
        "Exafunction/codeium.vim",
        event = "BufRead",
        config = function()
            vim.keymap.set("i", "<C-g>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true, silent = true })

            vim.keymap.set("i", "<C-]>", function()
                return vim.fn["codeium#Clear"]()
            end, { expr = true, silent = true })
        end,
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = { preset = "modern", delay = 400 },
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = { delay = 500 },
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "▁" },
                topdelete = { text = "▔" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function bmap(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                bmap("n", "]c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return "<Ignore>"
                end, "Git: Siguiente hunk")

                bmap("n", "[c", function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return "<Ignore>"
                end, "Git: Hunk anterior")

                bmap("n", "<leader>ph", gs.preview_hunk, "Git: Preview hunk")
                bmap("n", "<leader>gs", gs.stage_hunk, "Git: Stage hunk")
                bmap("n", "<leader>gr", gs.reset_hunk, "Git: Reset hunk")
            end,
        },
    },

    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {},
    },

    {
        "michaelb/sniprun",
        branch = "master",
        build = "sh ./install.sh",
        cmd = { "SnipRun", "SnipReset" },
        config = function()
            require("sniprun").setup { display = { "VirtualTextOk", "Terminal" }, live_display = { "VirtualTextOk" } }
        end,
    },

    {
        "hkupty/iron.nvim",
        cmd = { "IronRepl", "IronFocus", "IronSend" },
        config = function()
            require("iron.core").setup {
                config = {
                    scratch_repl = true,
                    repl_definition = {
                        sh = { command = { "bash" } },
                        python = { command = { "python3" } },
                        lua = { command = { "lua" } },
                        node = { command = { "node" } },
                    },
                    repl_open_cmd = "vsplit",
                },
            }
        end,
    },

    {
        "tpope/vim-dadbod",
        dependencies = { "kristijanhusak/vim-dadbod-ui", "kristijanhusak/vim-dadbod-completion" },
        cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
        init = function()
            vim.g.db_ui_save_location = vim.fn.stdpath "config" .. "/db_ui"
        end,
    },

    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "Trouble", "TroubleToggle" },
        config = function()
            require("trouble").setup { position = "bottom", use_diagnostic_signs = true }
        end,
    },

    {
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- ── NAVEGACIÓN COMO BUFFER (OIL) ───────────────────────────────
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = "Oil",
        config = function()
            require("oil").setup {
                columns = { "icon" },
                view_options = {
                    show_hidden = true,
                },
            }
        end,
    },

    -- ── 9. PRODUCTIVIDAD Y UI (NUEVOS) ─────────────────────────────
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
    },

    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },
    -- ── DEBUG JAVA (requiere setup propio, distinto al resto) ───────
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
    },

    -- ── DEBUG PYTHON MEJORADO (venv-aware, debug de tests con pytest) ──
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = { "mfussenegger/nvim-dap" },
    },

    -- ── VALORES DE VARIABLES INLINE AL DEBUGGEAR (todos los lenguajes) ──
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
        opts = {
            commented = true, -- Muestra los valores como comentario al final de la línea
        },
    },
    -- ── 6. DAP DEBUGGER ────────────────────────────────────────────
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "williamboman/mason.nvim",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "jay-babu/mason-nvim-dap.nvim",
        },
        config = function()
            require("mason-nvim-dap").setup {
                ensure_installed = { "debugpy", "delve", "codelldb", "netcoredbg" },
                automatic_installation = true,
            }
            require "configs.dap"
        end,
    },
    {
        "nanotee/sqls.nvim",
        ft = { "sql", "mysql", "plsql" },
    },
    -- ── TODO/FIXME/BUG EN COMENTARIOS (integrado con Trouble) ────────
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            signs = true,
            keywords = {
                FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            },
        },
    },

    -- ── NOTA RÁPIDA POR PROYECTO (ventana flotante) ──────────────────
    {
        "backdround/global-note.nvim",
        cmd = { "GlobalNote", "ProjectNote" },
        opts = {
            filename = "global.md",
            directory = vim.fn.stdpath "data" .. "/global-note/",
            title = "Notas globales",
            window_config = function()
                local h = vim.api.nvim_list_uis()[1].height
                local w = vim.api.nvim_list_uis()[1].width
                return {
                    relative = "editor",
                    border = "rounded",
                    title = "Notas",
                    title_pos = "center",
                    width = math.floor(0.7 * w),
                    height = math.floor(0.75 * h),
                    row = math.floor(0.1 * h),
                    col = math.floor(0.15 * w),
                }
            end,
            autosave = true,
            additional_presets = {
                project = {
                    filename = function()
                        local git_root =
                            vim.fn.systemlist("git -C " .. vim.fn.expand "%:p:h" .. " rev-parse --show-toplevel")[1]
                        local name = git_root and vim.fn.fnamemodify(git_root, ":t") or "sin-proyecto"
                        return name .. ".md"
                    end,
                    directory = vim.fn.stdpath "data" .. "/global-note/projects/",
                    title = "Notas del proyecto",
                    command_name = "ProjectNote",
                },
            },
        },
    },

    -- ── 10. SQL STAFF & NAVEGADOR DE ESTRUCTURAS ───────────────────
    {
        "stevearc/aerial.nvim",
        lazy = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("aerial").setup {
                backends = { "treesitter", "lsp", "markdown", "man" },
                layout = { default_direction = "prefer_right", min_width = 28 },
                show_guides = false,
                filter_kind = false,
            }
        end,
    },
}

return plugins
