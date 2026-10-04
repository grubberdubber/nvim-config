-- ── FAST-FAIL: Si NvChad no cargó, Neovim no explota ─────────────
-- Intentamos usar NvChad primero (trae on_attach con keymaps extra)
-- Si no está disponible, usamos fallbacks nativos de Neovim
local ok_nvchad, nvchad_lsp = pcall(require, "nvchad.configs.lspconfig")

-- on_attach: se ejecuta cada vez que un LSP se conecta a un buffer
local on_attach = function(client, bufnr)
  if ok_nvchad and nvchad_lsp.on_attach then
    nvchad_lsp.on_attach(client, bufnr)
  end
end

-- on_init: desactiva semanticTokens si el cliente no los soporta bien
local on_init = function(client, _)
  if ok_nvchad and nvchad_lsp.on_init then
    nvchad_lsp.on_init(client, _)
    return
  end
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

-- capabilities: anuncia al servidor LSP qué features soporta Neovim
-- Incluye soporte de snippets para autocompletado enriquecido
local capabilities
if ok_nvchad and nvchad_lsp.capabilities then
  capabilities = nvchad_lsp.capabilities
else
  capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
end

-- ── FAST-FAIL: Si nvim-lspconfig no cargó ────────────────────────
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if not ok_lsp then
  vim.notify("[lspconfig] nvim-lspconfig falló. LSP desactivado.", vim.log.levels.ERROR)
  return
end

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  LISTA MAESTRA — 30 servidores LSP                           ║
-- ║  Gestionar con :Mason  /  :MasonInstall <nombre>             ║
-- ╚══════════════════════════════════════════════════════════════╝
local servers = {
  -- Web & Frontend
  "html",          -- HTML
  "cssls",         -- CSS
  "ts_ls",         -- JavaScript / TypeScript
  "intelephense",  -- PHP
  "emmet_ls",      -- Emmet (abreviaciones HTML/CSS — instalar con :Mason)

  -- Sistemas y Compilados
  "clangd",        -- C / C++ / Objective-C
  "rust_analyzer", -- Rust
  "gopls",         -- Go
  "omnisharp",     -- C# (.NET)
  "jdtls",         -- Java
  "asm_lsp",       -- Assembly x86/x64

  -- Ecosistema Móvil
  "sourcekit",               -- Swift (requiere sourcekit-lsp instalado)
  "kotlin_language_server",  -- Kotlin
  "dartls",                  -- Dart / Flutter

  -- Scripting y Automatización
  "pyright",       -- Python (análisis estático avanzado)
  "bashls",        -- Bash / Shell
  "powershell_es", -- PowerShell
  "solargraph",    -- Ruby
  "perlnavigator", -- Perl

  -- Ciencia de Datos e IA
  "r_language_server", -- R
  "julials",           -- Julia
  "sqlls",             -- SQL / PL-SQL / T-SQL

  -- Funcional y Empresarial
  "metals",        -- Scala
}

-- ── BUCLE PROTEGIDO ──────────────────────────────────────────────
-- Un servidor roto (binario no instalado) no rompe los demás
for _, lsp in ipairs(servers) do
  pcall(function()
    local opts = {
      on_attach    = on_attach,
      on_init      = on_init,
      capabilities = capabilities,
    }

    -- Pyright: configuración agresiva para análisis completo del proyecto
    if lsp == "pyright" then
      opts.settings = {
        python = {
          analysis = {
            diagnosticMode      = "workspace",
            typeCheckingMode    = "basic",
            autoSearchPaths     = true,
            useLibraryCodeForTypes = true,
          },
        },
      }
    end

    lspconfig[lsp].setup(opts)
  end)
end

-- ── LUA: configuración especial (elimina warnings de 'vim') ──────
pcall(function()
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
end)
