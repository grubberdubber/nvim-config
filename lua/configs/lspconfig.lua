local lspconfig = require("lspconfig")
local nvchad_lsp = require("nvchad.configs.lspconfig")

local on_attach = nvchad_lsp.on_attach
local on_init = nvchad_lsp.on_init
local capabilities = nvchad_lsp.capabilities

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  LISTA MAESTRA — Servidores LSP                              ║
-- ╚══════════════════════════════════════════════════════════════╝
local servers = {
  "html", "cssls", "ts_ls", "intelephense", "emmet_ls",
  "clangd", "rust_analyzer", "gopls", "omnisharp", "jdtls", "asm_lsp",
  "sourcekit", "kotlin_language_server", "dartls",
  "pyright", "bashls", "powershell_es", "solargraph", "perlnavigator",
  "r_language_server", "julials", "sqlls", "metals",
}

for _, lsp in ipairs(servers) do
  local opts = {
    on_attach    = on_attach,
    on_init      = on_init,
    capabilities = capabilities,
  }

  -- Configuración avanzada para Python (Pyright)
  if lsp == "pyright" then
    opts.settings = {
      python = {
        analysis = {
          diagnosticMode = "workspace",
          typeCheckingMode = "basic",
        },
      },
    }
  end

  lspconfig[lsp].setup(opts)
end

-- ── LUA: configuración especial para desarrollo de Neovim ────────
lspconfig.lua_ls.setup {
  on_attach    = on_attach,
  on_init      = on_init,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics  = { globals = { "vim" } },
      workspace    = { checkThirdParty = false },
      telemetry    = { enable = false },
    },
  },
}
