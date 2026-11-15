local nvchad_lsp = require "nvchad.configs.lspconfig"

local on_attach = nvchad_lsp.on_attach
local on_init = nvchad_lsp.on_init
local capabilities = require("blink.cmp").get_lsp_capabilities(nvchad_lsp.capabilities)

-- Inlay hints and code lens are opt-in per client: only servers that
-- advertise the capability get them, and the UI toggles can still turn
-- them off per buffer.
local function attach_extras(client, bufnr)
    -- ts_ls reports inlay-hint support in Vue buffers but rejects the
    -- request; it is only a forwarder there, so leave hints to vue_ls.
    local vue_buffer = vim.bo[bufnr].filetype == "vue"
    if not vue_buffer and client.name ~= "ts_ls" and client:supports_method("textDocument/inlayHint", bufnr) then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    if client:supports_method("textDocument/codeLens", bufnr) then
        -- enable() also refreshes in Neovim 0.12; refresh() is deprecated.
        vim.lsp.codelens.enable(true, { bufnr = bufnr })
    end
end

local function on_attach_extended(client, bufnr)
    on_attach(client, bufnr)
    attach_extras(client, bufnr)
end

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  BASE CONFIG FOR EVERY SERVER                                ║
-- ╚══════════════════════════════════════════════════════════════╝
vim.lsp.config("*", {
    on_attach = on_attach_extended,
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
    "gopls",
    "omnisharp",
    "asm_lsp",
    "kotlin_language_server",
    "pyright",
    "bashls",
    "powershell_es",
    "solargraph",
    "perlnavigator",
    "julials",
    "sqls",
    "taplo",
    "lemminx",
    "dockerls",
    "graphql",
    "metals",
    "lua_ls",
    "nim_langserver",
    "texlab",
    "marksman",
    "tailwindcss",
    "eslint",
    "svelte",
    -- Newly enabled language servers (installed through Mason).
    "zls",
    "hls",
    "elixirls",
    "sourcekit",
    "vue_ls",
    "yamlls",
    "jsonls",
    "harper_ls",
}

-- ── ts_ls: also attach to Vue SFCs ────────────────────────────
-- vue_ls runs in hybrid mode and forwards TypeScript requests to
-- ts_ls/vtsls. Without this, opening a .vue file logs that no TS client
-- was found and Vue completions/diagnostics stay empty.
vim.lsp.config("ts_ls", {
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
})

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
        -- Server-specific on_attach replaces the wildcard one, so compose it
        -- explicitly or SQL buffers lose the shared LSP mappings.
        on_attach_extended(client, bufnr)
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

-- ── sourcekit: Swift only (C/C++ stay with clangd) ─────────────
vim.lsp.config("sourcekit", {
    filetypes = { "swift", "objc", "objcpp" },
})

-- ── harper_ls: grammar and spelling for prose only ──────────────
-- Hints, not squiggles in code. The toggle is <leader>uh.
vim.lsp.config("harper_ls", {
    filetypes = { "markdown", "text", "gitcommit" },
    on_attach = function(client, bufnr)
        on_attach_extended(client, bufnr)
        local ns = vim.lsp.diagnostic.get_namespace(client.id)
        vim.diagnostic.config({ virtual_text = false, signs = false }, ns)
    end,
    settings = {
        ["harper-ls"] = {
            diagnosticSeverity = "hint",
            dialect = "American",
            isolateEnglish = true,
            linters = {
                SentenceCapitalization = false,
                LongSentences = false,
            },
            markdown = { IgnoreLinkTitle = true },
            excludePatterns = { "**/node_modules/**", "**/CHANGELOG.md", "**/LICENSE" },
            maxFileLength = 120000,
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
