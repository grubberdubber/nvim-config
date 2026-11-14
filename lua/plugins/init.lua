local plugins = {
    -- ── DISABLE nvim-cmp (shipped by NvChad) ────────────────────────
    { "hrsh7th/nvim-cmp", enabled = false },

    -- ── BLINK.CMP — completion engine ────────────────────────────────
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "moyiz/blink-emoji.nvim",
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

    -- ── AUTOPAIRS (integrated with blink.cmp) ────────────────────────
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
        "mfussenegger/nvim-lint",
        event = { "BufWritePost", "BufReadPost", "InsertLeave" },
        config = function()
            require "configs.lint"
        end,
    },

    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "User FilePost", -- Lazy-load only when a code file is opened
        config = function()
            require("rainbow-delimiters.setup").setup {
                blacklist = { "html", "xml", "svg", "xhtml", "htmldjango", "blade", "twig" },
            }
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

    -- ── 3. INDENT BLANKLINE (always-visible │ guides)
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
                -- The dashboard is a landing screen: no indent guides there.
                -- Every code buffer keeps the guides enabled.
                exclude = { filetypes = { "dashboard" } },
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
                "markdownlint-cli2",
                "marksman",
                "tailwindcss-language-server",
                "eslint-lsp",
                "svelte-language-server",
                "harper-ls",
                "zls",
                "elixir-ls",
                "vue-language-server",
                "yaml-language-server",
                "json-lsp",
                "ruff",
                "shellcheck",
                "hadolint",
                "yamllint",
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
                "omnisharp",
                "sqlls",
                "kotlin_language_server",
                "solargraph",
                "powershell_es",
                "asm_lsp",
                "nim_langserver",
                "jdtls",
                "texlab",
                "zls",
                "elixirls",
                "vue_ls",
                "yamlls",
                "jsonls",
                "harper_ls",
            },
            automatic_installation = false,
            automatic_enable = {
                -- rustaceanvim and flutter-tools own these two clients.
                exclude = { "jdtls", "rust_analyzer", "dartls" },
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

    -- ── UNIFIED SYNTAX TREE (TREESITTER + TEXTOBJECTS) ─────
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
                    "nim",
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
                    "tsx",
                    "vue",
                    "svelte",
                    "zig",
                    "haskell",
                    "elixir",
                    "swift",
                    "xml",
                    "diff",
                    "regex",
                    "csv",
                    "hurl",
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

    -- ── STICKY CONTEXT (APAGADO POR DEFECTO) ──────────────────────
    -- Pins the current function/class to the top of the window. Loaded only
    -- when `:TSContext` or `<leader>uc` is used, and starts disabled.
    {
        "nvim-treesitter/nvim-treesitter-context",
        cmd = "TSContext",
        opts = {
            enable = false,
            max_lines = 3,
            line_numbers = false,
            separator = "─",
        },
        config = function(_, opts)
            require("treesitter-context").setup(opts)

            -- Neutral separator: midpoint between the theme's text and
            -- background colors (a grey that works on light and dark themes).
            local function tint_separator()
                local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
                if not normal.fg or not normal.bg then
                    vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#808080" })
                    return
                end
                local function ch(c, s)
                    return math.floor(c / s) % 256
                end
                local r = math.floor((ch(normal.fg, 65536) + ch(normal.bg, 65536)) / 2)
                local g = math.floor((ch(normal.fg, 256) + ch(normal.bg, 256)) / 2)
                local b = math.floor((ch(normal.fg, 1) + ch(normal.bg, 1)) / 2)
                vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = r * 65536 + g * 256 + b })
            end
            tint_separator()
            vim.api.nvim_create_autocmd("ColorScheme", { callback = tint_separator })
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

    -- ── WINDSURF (inline AI suggestions) ────────────────────────────
    -- Pin the fix for the nil chunk emitted by the language server. The
    -- upstream main branch still has the crash; this commit adds the nil
    -- check while keeping the same Codeium/Windsurf server and auth.
    {
        "Exafunction/windsurf.nvim",
        commit = "46fe7689aec11cb8ac602a96d27f9441a97e168d",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("codeium").setup {
                config_path = vim.fn.expand "~/.codeium/config.json",
                bin_path = vim.fn.expand "~/.codeium/bin",
                enable_cmp_source = false,
                virtual_text = {
                    enabled = true,
                    map_keys = true,
                    idle_delay = 75,
                    accept_fallback = "",
                    key_bindings = {
                        accept = "<C-g>",
                        clear = "<C-]>",
                        next = "<M-]>",
                        prev = "<M-[>",
                    },
                },
            }
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
        cmd = "Trouble",
        opts = {
            focus = true,
            auto_preview = true,
            auto_refresh = true,
            auto_close = false,
            win = { position = "bottom", size = 16 },
            modes = {
                diagnostics = { win = { position = "bottom", size = 16 } },
                symbols = { win = { position = "right", size = 40 } },
                lsp = { win = { position = "right", size = 44 } },
            },
        },
    },

    -- ── SURROUND (add/change/delete quotes, tags, parentheses) ──
    {
        "kylechui/nvim-surround",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },

    -- ── ILLUMINATE (highlight other occurrences of the symbol) ──
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("illuminate").configure {
                delay = 150,
                filetypes_denylist = { "NvimTree", "TelescopePrompt", "alpha" },
            }
        end,
    },

    -- ── UFO (real folding through Treesitter/LSP) ──────────────────
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            provider_selector = function()
                return { "treesitter", "indent" }
            end,
        },
        init = function()
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
        end,
    },

    -- ── REFACTORING (extract variable/function with real scope) ──────
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
        cmd = { "Refactor" },
        keys = { { "<leader>re", mode = "v" }, { "<leader>rf", mode = "v" } },
        opts = {},
    },

    -- ── MULTI-CURSOR ────────────────────────────────────────────────
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        event = { "BufReadPost", "BufNewFile" },
    },

    -- ── MODO ZEN (foco, oculta UI) ──────────────────────────────────
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        opts = {
            window = { width = 0.85 },
            on_open = function(win)
                -- ZenMode opens a brand-new floating window that inherits the
                -- default local 'fillchars' (+ / - and the fold line) instead
                -- of the statuscol triangles. Copy the GLOBAL value, because
                -- vim.o would read the float's own local value.
                local fillchars = vim.api.nvim_get_option_value("fillchars", { scope = "global" })
                vim.api.nvim_set_option_value("fillchars", fillchars, { win = win })
            end,
        },
    },
    {
        "folke/twilight.nvim",
        cmd = "Twilight",
        opts = {},
    },

    -- ── LATEX (VimTeX + continuous compilation + Zathura) ────────────
    {
        "lervag/vimtex",
        ft = "tex",
        init = function()
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_compiler_latexmk = {
                continuous = 1,
                options = {
                    "-shell-escape",
                    "-verbose",
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                },
            }
            vim.g.vimtex_quickfix_mode = 0 -- Do not open quickfix for every minor warning
            vim.g.vimtex_syntax_conceal = {
                accents = true,
                ligatures = true,
                cites = true,
                fancy = true,
                spacing = true,
                greek = true,
                math_bounds = true,
                math_delimiters = true,
                math_fracs = true,
                math_super_sub = true,
                math_symbols = true,
                sections = false,
                styles = true,
            }
        end,
    },

    {
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- ── BUFFER-LIKE NAVIGATION (OIL) ───────────────────────────────
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
    -- ── JAVA DEBUG (custom setup, unlike the rest) ──────────────────
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
    },

    -- ── IMPROVED PYTHON DEBUG (venv-aware, pytest debugging) ────────
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = { "mfussenegger/nvim-dap" },
    },

    -- ── INLINE VARIABLE VALUES WHILE DEBUGGING (all languages) ──────
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
        opts = {
            commented = true, -- Show values as end-of-line comments
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
                ensure_installed = { "debugpy", "delve", "codelldb", "netcoredbg", "bash-debug-adapter" },
                automatic_installation = true,
            }
            require "configs.dap"
        end,
    },
    {
        "nanotee/sqls.nvim",
        ft = { "sql", "mysql", "plsql" },
    },
    -- ── TODO/FIXME/BUG COMMENTS (integrated with Trouble) ────────────
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

    -- ── QUICK PROJECT NOTE (floating window) ──────────────────
    {
        "backdround/global-note.nvim",
        cmd = { "GlobalNote", "ProjectNote" },
        opts = {
            filename = "global.md",
            directory = vim.fn.stdpath "data" .. "/global-note/",
            title = "Global notes",
            window_config = function()
                local h = vim.api.nvim_list_uis()[1].height
                local w = vim.api.nvim_list_uis()[1].width
                return {
                    relative = "editor",
                    border = "rounded",
                    title = "Notes",
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
                        local git_root = vim.fs.root(vim.fn.expand "%:p:h", { ".git" })
                        local name = git_root and vim.fn.fnamemodify(git_root, ":t") or "sin-proyecto"
                        return name .. ".md"
                    end,
                    directory = vim.fn.stdpath "data" .. "/global-note/projects/",
                    title = "Project notes",
                    command_name = "ProjectNote",
                },
            },
        },
    },

    -- ── CUSTOM LEFT COLUMN: breakpoints > git > line number > fold ──
    {
        "luukvbaal/statuscol.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local builtin = require "statuscol.builtin"

            -- VS Code style triangles instead of Vim's classic arrows, with no
            -- vertical line connecting fold levels.
            vim.opt.fillchars:append {
                foldopen = "▼", -- open fold (expanded): solid triangle, easier to see
                foldclose = "▶", -- closed fold (collapsed): solid triangle, easier to see
                foldsep = " ",
            }
            require("statuscol").setup {
                relculright = true,
                segments = {
                    -- 1. Breakpoints (DAP) — extremo izquierdo
                    {
                        sign = { name = { "Dap" }, maxwidth = 1, colwidth = 1, auto = true },
                        click = "v:lua.ScSa",
                    },
                    -- 2. Git signs — filter by NAMESPACE, not by name
                    -- (modern gitsigns uses extmarks, not the classic :sign define)
                    {
                        sign = {
                            namespace = { "gitsigns" },
                            name = { "gitsigns" },
                            maxwidth = 2,
                            colwidth = 2,
                            auto = true,
                        },
                        click = "v:lua.ScSa",
                    },
                    -- 3. Hybrid numbering (absolute at the cursor, relative elsewhere)
                    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                    -- 4. Fold column: triangles without nesting digits
                    { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                },
            }
        end,
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

    -- ── AVANTE.NVIM: agentic AI with NVIDIA NIM / OpenRouter ──────
    -- Unlike Codeium (inline suggestions while typing), Avante is a
    -- Cursor-style assistant: ask in natural language and it edits,
    -- explains or generates code with project context.
    -- with full project context. They complement each other.
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

return plugins
