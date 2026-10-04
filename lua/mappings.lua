require "nvchad.mappings"

local map = vim.keymap.set

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  MAPEOS BASE                                                  ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", ";", ":",         { desc = "CMD: modo comando" })
map("i", "jk", "<ESC>",   { desc = "ESC rápido desde Insert" })

-- Guardar y salir rápido (estándar de casi cualquier IDE)
map("n", "<C-s>", "<cmd>w<CR>",      { desc = "Guardar archivo" })
map("i", "<C-s>", "<ESC><cmd>w<CR>", { desc = "Guardar desde Insert" })
map("n", "<C-q>", "<cmd>q<CR>",      { desc = "Cerrar ventana" })

-- Mejor navegación con líneas wrapeadas (evita saltar párrafos)
map("n", "j", "gj", { desc = "Bajar (wrap-aware)" })
map("n", "k", "gk", { desc = "Subir (wrap-aware)" })

-- Mover líneas seleccionadas (como VS Code Alt+↑/↓)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })
map("n", "<A-j>", ":m .+1<CR>==",     { desc = "Mover línea abajo" })
map("n", "<A-k>", ":m .-2<CR>==",     { desc = "Mover línea arriba" })

-- Mantener selección tras indentar (como VS Code Tab/Shift+Tab)
map("v", "<", "<gv", { desc = "Indentar izquierda y mantener selección" })
map("v", ">", ">gv", { desc = "Indentar derecha y mantener selección" })

-- Pegar sobre selección sin perder el registro (VS Code behavior)
map("v", "p", '"_dP', { desc = "Pegar sin perder registro" })

-- Limpiar highlight de búsqueda con Escape
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Limpiar highlight de búsqueda" })

-- Navegar entre splits (estándar Vim — Ctrl+hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Ir a split izquierdo" })
map("n", "<C-l>", "<C-w>l", { desc = "Ir a split derecho" })
map("n", "<C-j>", "<C-w>j", { desc = "Ir a split abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ir a split arriba" })

-- Navegar buffers (Tab/Shift+Tab como en VS Code / JetBrains)
map("n", "<Tab>",   "<cmd>bnext<CR>",     { desc = "Siguiente buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Cerrar buffer actual" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  LSP — estándar compartido con VS Code / IntelliJ            ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", "gd",         vim.lsp.buf.definition,     { desc = "LSP: Ir a definición" })
map("n", "gD",         vim.lsp.buf.declaration,    { desc = "LSP: Ir a declaración" })
map("n", "gr",         vim.lsp.buf.references,     { desc = "LSP: Ver referencias" })
map("n", "gi",         vim.lsp.buf.implementation, { desc = "LSP: Ver implementación" })
map("n", "K",          vim.lsp.buf.hover,          { desc = "LSP: Hover docs" })
map("n", "<leader>rn", vim.lsp.buf.rename,         { desc = "LSP: Renombrar símbolo" })
map("n", "<leader>ca", vim.lsp.buf.code_action,    { desc = "LSP: Code actions" })
map("n", "<leader>lf", vim.lsp.buf.format,         { desc = "LSP: Formatear archivo" })
map("n", "[d",         vim.diagnostic.goto_prev,   { desc = "LSP: Diagnóstico anterior" })
map("n", "]d",         vim.diagnostic.goto_next,   { desc = "LSP: Diagnóstico siguiente" })
map("n", "<leader>d",  vim.diagnostic.open_float,  { desc = "LSP: Ver diagnóstico flotante" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ⚡ SNIPRUN — ejecución inline (C, C++, Rust, Go, Asm...)    ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", "<leader>sr", "<cmd>SnipRun<CR>",      { desc = "Sniprun: Ejecutar línea" })
map("v", "<leader>sr", "<cmd>'<,'>SnipRun<CR>", { desc = "Sniprun: Ejecutar bloque" })
map("n", "<leader>sc", "<cmd>SnipReset<CR>",    { desc = "Sniprun: Limpiar output" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🐍 IRON.NVIM — REPL interactivo (Python, Julia, R, Ruby...) ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", "<leader>ro", "<cmd>IronRepl<CR>",                               { desc = "Iron: Abrir REPL" })
map("n", "<leader>rr", "<cmd>IronRestart<CR>",                            { desc = "Iron: Reiniciar REPL" })
map("n", "<leader>rc", function() require("iron.core").close_repl() end,  { desc = "Iron: Cerrar REPL" })
map("n", "<leader>rs", function() require("iron.core").send_line() end,   { desc = "Iron: Enviar línea al REPL" })
map("v", "<leader>rs", function() require("iron.core").visual_send() end, { desc = "Iron: Enviar bloque al REPL" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🗄️  DADBOD — base de datos                                  ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "DB: Toggle UI base de datos" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🚨 TROUBLE — radar de errores y diagnósticos LSP            ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",              { desc = "Trouble: Toggle panel" })
map("n", "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble: Workspace" })
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble: Documento" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                   { desc = "Trouble: Quickfix" })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>",                  { desc = "Trouble: Location list" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🐙 LAZYGIT — control de versiones                           ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", "<leader>gg", "<cmd>LazyGit<CR>",            { desc = "Git: Abrir Lazygit" })
map("n", "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", { desc = "Git: Lazygit archivo actual" })

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🐛 DAP — Debugger (estándar de IDE)                         ║
-- ║                                                              ║
-- ║  F5        → Iniciar / Continuar    (VS Code, IntelliJ)      ║
-- ║  F9        → Toggle Breakpoint      (IntelliJ estándar)      ║
-- ║  F10       → Step Over              (universal)              ║
-- ║  F11       → Step Into              (universal)              ║
-- ║  F12       → Step Out               (universal)              ║
-- ║  Shift+F5  → Detener debugger       (VS Code)                ║
-- ╚══════════════════════════════════════════════════════════════╝
map("n", "<F5>", function()
  -- Si el filetype tiene configuración DAP, úsala
  -- Si no, intenta continuar una sesión ya iniciada
  local dap = require "dap"
  if dap.configurations[vim.bo.filetype] then
    dap.continue()
  else
    -- Fallback: lanza con configuración genérica de python si no hay config
    dap.continue()
  end
end, { desc = "DAP: Iniciar / Continuar" })

map("n", "<F9>",   function() require("dap").toggle_breakpoint() end,  { desc = "DAP: Toggle Breakpoint ●" })
map("n", "<F10>",  function() require("dap").step_over() end,          { desc = "DAP: Step Over" })
map("n", "<F11>",  function() require("dap").step_into() end,          { desc = "DAP: Step Into" })
map("n", "<F12>",  function() require("dap").step_out() end,           { desc = "DAP: Step Out" })
map("n", "<S-F5>", function() require("dap").terminate() end,          { desc = "DAP: Detener debugger" })

-- Breakpoint condicional (IntelliJ: click derecho → Add Conditional Breakpoint)
map("n", "<leader>B", function()
  require("dap").set_breakpoint(vim.fn.input "Condición del breakpoint: ")
end, { desc = "DAP: Breakpoint condicional ◉" })

-- Log point: imprime un valor sin pausar la ejecución
map("n", "<leader>lp", function()
  require("dap").set_breakpoint(nil, nil, vim.fn.input "Log message: ")
end, { desc = "DAP: Log point ◆" })

-- UI y herramientas del debugger
map("n", "<leader>du", function() require("dapui").toggle() end,  { desc = "DAP: Toggle UI" })
map("n", "<leader>dr", function() require("dap").repl.open() end, { desc = "DAP: Abrir REPL" })
map("n", "<leader>dl", function() require("dap").run_last() end,  { desc = "DAP: Re-ejecutar último" })

-- Alias <leader>b → F9 (hábito Vim clásico)
map("n", "<leader>b", function() require("dap").toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint (alias F9)" })
