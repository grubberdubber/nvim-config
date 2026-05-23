require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- ── Números de línea ─────────────────────────────────────────────
o.number         = true    -- número absoluto en línea actual
o.relativenumber = true    -- relativos para el resto (esencial para motions)
o.cursorlineopt  = "both"  -- resalta número + línea completa

-- ── Indentación ──────────────────────────────────────────────────
o.tabstop    = 2
o.shiftwidth = 2
o.expandtab  = true
o.smartindent = true

-- ── Búsqueda ─────────────────────────────────────────────────────
o.ignorecase = true
o.smartcase  = true    -- si escribes mayúscula, distingue

-- ── UI y scroll ──────────────────────────────────────────────────
o.scrolloff     = 8    -- mantiene 8 líneas de contexto al scrollear
o.signcolumn    = "yes" -- siempre visible para no saltar con LSP
o.updatetime    = 250  -- respuesta de CursorHold más rápida (LSP hints)
o.timeoutlen    = 400  -- tiempo para secuencias de teclas (which-key)

-- ── Splits ───────────────────────────────────────────────────────
o.splitbelow = true    -- :split abre abajo
o.splitright = true    -- :vsplit abre a la derecha

-- ── Misceláneos ──────────────────────────────────────────────────
opt.clipboard  = "unnamedplus"  -- integración con clipboard del sistema
o.undofile     = true           -- undo persistente entre sesiones
