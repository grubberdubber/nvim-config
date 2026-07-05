local nvchad_lsp = require "nvchad.configs.lspconfig"

local on_attach = nvchad_lsp.on_attach
local on_init = nvchad_lsp.on_init
local capabilities = nvchad_lsp.capabilities

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
    "jdtls",
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

-- ── sqlls: dialecto MySQL, sin diagnostics ────────────────────
-- El parser interno de sql-language-server es demasiado frágil para SQL
-- real (falla con CTEs, window functions, dialectos, multi-statement).
-- Descartamos sus diagnostics por completo en vez de filtrarlos.
vim.lsp.config("sqlls", {
    settings = {
        sqlLanguageServer = {
            adapter = "mysql",
        },
    },
    handlers = {
        ["textDocument/publishDiagnostics"] = function() end,
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

vim.lsp.enable(servers)
