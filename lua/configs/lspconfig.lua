local lspconfig = require("lspconfig")

-- Definición manual de capacidades
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local servers = {
  "html", "cssls", "ts_ls", "intelephense", "emmet_ls",
  "clangd", "rust_analyzer", "gopls", "omnisharp", "jdtls", "asm_lsp",
  "sourcekit", "kotlin_language_server", "dartls", "pyright", "bashls",
  "powershell_es", "solargraph", "perlnavigator", "r_language_server",
  "julials", "sqlls", "metals"
}

for _, lsp in ipairs(servers) do
  -- 1. Verificación absoluta: si ya hay un cliente con este nombre, salta al siguiente
  local active_clients = vim.lsp.get_clients()
  local already_running = false
  for _, client in ipairs(active_clients) do
    if client.name == lsp then already_running = true break end
  end
  
  if not already_running then
    local opts = { capabilities = capabilities }

    -- Configuración específica y agresiva para Pyright
    if lsp == "pyright" then
      opts.settings = {
        python = {
          analysis = {
            diagnosticMode = "workspace", -- Agresivo: analiza todo el proyecto
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      }
    end

    -- Configuración especial para emmet-ls
    if lsp == "emmet_ls" then
      local bin = vim.fn.stdpath("data") .. "/mason/bin/emmet-ls"
      if vim.fn.filereadable(bin) == 1 and vim.fn.executable(bin) == 0 then
        vim.fn.system({"chmod", "+x", bin})
      end
    end

    lspconfig[lsp].setup(opts)
  end
end

-- Configuración especial Lua
lspconfig.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}
