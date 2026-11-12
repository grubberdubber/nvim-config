local nvchad_lsp = require "nvchad.configs.lspconfig"

local on_attach = nvchad_lsp.on_attach
local on_init = nvchad_lsp.on_init
local capabilities = require("blink.cmp").get_lsp_capabilities(nvchad_lsp.capabilities)

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  BASE CONFIG FOR EVERY SERVER                                ║
-- ╚══════════════════════════════════════════════════════════════╝
vim.lsp.config("*", {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
})

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  MASTER LIST — LSP servers                                   ║
-- ╚══════════════════════════════════════════════════════════════╝
local servers = {
    "html",
    "cssls",
    "ts_ls",
    "intelephense",
    "emmet_ls",
    "clangd",
    "rust_analyzer",
    "gopls",
    "omnisharp",
    "asm_lsp",
    "kotlin_language_server",
    "dartls",
    "pyright",
    "bashls",
    "powershell_es",
    "solargraph",
    "perlnavigator",
    "julials",
    "sqlls",
    "metals",
    "lua_ls",
    "nim_langserver",
    "texlab",
    "marksman",
    "tailwindcss",
    "eslint",
    "svelte",
}

-- ── Pyright: advanced analysis ────────────────────────────────
vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "basic",
                reportUnknownMemberType = "none",
                reportUnknownArgumentType = "none",
                reportUnknownVariableType = "none",
            },
        },
    },
})

-- ── omnisharp: support standalone .cs files (no .sln/.csproj) ──
vim.lsp.config("omnisharp", {
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(fname, { "*.sln", "*.csproj", ".git" })
        on_dir(root or vim.fn.fnamemodify(fname, ":h"))
    end,
    single_file_support = true,
})

-- ── emmet_ls: extend coverage beyond the default (HTML/CSS/JSX/Vue/Svelte) ──
vim.lsp.config("emmet_ls", {
    filetypes = {
        -- Already provided by nvim-lspconfig defaults:
        "html",
        "css",
        "scss",
        "sass",
        "less",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
        "pug",
        "eruby",
        "htmldjango",
        "htmlangular",
        "templ",
        -- Added manually:
        "xml",
        "xsl",
        "stylus",
        "haml",
        "slim",
    },
})

-- ── sqls: multi-engine LSP (MySQL, PostgreSQL, SQLite3, MSSQL, H2, Vertica) ──
vim.lsp.config("sqls", {
    cmd = { "sqls" },
    filetypes = { "sql", "mysql", "plsql" },
    on_attach = function(client, bufnr)
        require("sqls").on_attach(client, bufnr) -- enables sqls commands (run query, switch connection)
    end,
    settings = {
        sqls = {
            connections = {
                -- Replace these with real credentials, or keep them as examples
                -- and use sqls.nvim's "Switch Connection" command.
                { driver = "mysql", dataSourceName = "root:root@tcp(127.0.0.1:3306)/dbname" },
                {
                    driver = "postgresql",
                    dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=postgres dbname=dbname sslmode=disable",
                },
                { driver = "sqlite3", dataSourceName = "/path/to/your/file.sqlite3" },
                { driver = "mssql", dataSourceName = "sqlserver://user:password@127.0.0.1:1433?database=dbname" },
            },
        },
    },
})

-- ── Lua: Neovim development ─────────────────────────────────────
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

-- ── texlab: LaTeX LSP (command completion, references, build) ──
vim.lsp.config("texlab", {
    settings = {
        texlab = {
            build = {
                onSave = true,
                forwardSearchAfter = true,
            },
            forwardSearch = {
                executable = "zathura",
                args = { "--synctex-forward", "%l:1:%f", "%p" },
            },
        },
    },
})
-- ── yamlls: schema validation (Kubernetes, Docker Compose, GitHub Actions) ──
vim.lsp.config("yamlls", {
    settings = {
        yaml = {
            schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
            schemas = {
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.29.0-standalone-strict/all.json"] = "/*.k8s.yaml",
                kubernetes = "*.k8s.yaml",
            },
            validate = true,
            format = { enable = true },
        },
    },
})

-- ── jsonls: schema validation through SchemaStore ───────────────
vim.lsp.config("jsonls", {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
})

vim.lsp.config("cssls", {
    settings = {
        css = { lint = { unknownAtRules = "ignore" } },
        scss = { lint = { unknownAtRules = "ignore" } },
        less = { lint = { unknownAtRules = "ignore" } },
    },
})

vim.lsp.enable(servers)
