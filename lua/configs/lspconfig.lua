local nvchad_lsp = require "nvchad.configs.lspconfig"

local on_attach = nvchad_lsp.on_attach
local on_init = nvchad_lsp.on_init
local capabilities = require("blink.cmp").get_lsp_capabilities(nvchad_lsp.capabilities)

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  CONFIG BASE PARA TODOS LOS SERVIDORES                       ║
-- ╚══════════════════════════════════════════════════════════════╝
vim.lsp.config("*", {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
})

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  LISTA MAESTRA — Servidores LSP                              ║
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
}

-- ── Pyright: análisis avanzado ────────────────────────────────
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

-- ── sqls: LSP multi-motor (MySQL, PostgreSQL, SQLite3, MSSQL, H2, Vertica) ──
vim.lsp.config("sqls", {
    cmd = { "sqls" },
    filetypes = { "sql", "mysql", "plsql" },
    on_attach = function(client, bufnr)
        require("sqls").on_attach(client, bufnr) -- habilita comandos de sqls (ejecutar query, cambiar conexión)
    end,
    settings = {
        sqls = {
            connections = {
                -- Editá estos con tus credenciales reales, o dejalos de ejemplo
                -- y usá el comando "Switch Connection" de sqls.nvim para elegir.
                { driver = "mysql", dataSourceName = "root:root@tcp(127.0.0.1:3306)/dbname" },
                {
                    driver = "postgresql",
                    dataSourceName = "host=127.0.0.1 port=5432 user=postgres password=postgres dbname=dbname sslmode=disable",
                },
                { driver = "sqlite3", dataSourceName = "/ruta/a/tu/archivo.sqlite3" },
                { driver = "mssql", dataSourceName = "sqlserver://usuario:password@127.0.0.1:1433?database=dbname" },
            },
        },
    },
})

-- ── Lua: desarrollo de Neovim ──────────────────────────────────
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

-- ── yamlls: validación de esquemas (Kubernetes, Docker Compose, GitHub Actions) ──
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

-- ── jsonls: validación de esquemas vía SchemaStore ──────────────
vim.lsp.config("jsonls", {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
})

vim.lsp.enable(servers)
