require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- ── NÚMEROS DE LÍNEA Y COLOR NARANJA ─────────────────────────────
o.number         = true    
o.relativenumber = false    
o.cursorline     = true     
o.cursorlineopt  = "both"   

-- Colores personalizados de alto contraste
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFA500", bold = true })
    vim.api.nvim_set_hl(0, "Comment", { fg = "#00FF00", italic = true, bold = true })
    
    -- Puntitos inactivos con un gris plata elegante
    vim.api.nvim_set_hl(0, "Whitespace", { fg = "#4b5263" })
    vim.api.nvim_set_hl(0, "NonText", { fg = "#4b5263" })
  end,
})

vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFA500", bold = true })
vim.api.nvim_set_hl(0, "Comment", { fg = "#00FF00", italic = true, bold = true })
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#4b5263" })
vim.api.nvim_set_hl(0, "NonText", { fg = "#4b5263" })

-- ── INDENTACIÓN (Puntitos solo en la sangría) ────────────────────
o.tabstop    = 4
o.shiftwidth = 4
o.expandtab  = true
o.smartindent = true

opt.list = true
opt.listchars = { 
  lead = "·",  
  tab = "  ",  
  trail = "·", 
  nbsp = "␣" 
}

-- ── DIAGNÓSTICOS ─────────────────────────────────────────────────
vim.diagnostic.config({
  virtual_text = {
    prefix = "● ", 
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded" },
})

vim.cmd([[
  hi DiagnosticUnderlineError gui=undercurl cterm=undercurl
  hi DiagnosticUnderlineWarn gui=undercurl cterm=undercurl
  hi DiagnosticUnderlineInfo gui=undercurl cterm=undercurl
  hi DiagnosticUnderlineHint gui=undercurl cterm=undercurl
]])

-- ── ASESINO DE CRLF (Adiós error de 0 spaces) ────────────────────
vim.api.nvim_create_autocmd({ "BufReadPre", "BufWritePre" }, {
  pattern = "*",
  callback = function()
    vim.bo.fileformat = "unix"
  end,
})

-- ── UI Y MISCELÁNEOS ─────────────────────────────────────────────
o.ignorecase = true 
o.smartcase  = true 
o.scrolloff     = 8    
o.signcolumn    = "yes" 
o.updatetime    = 250  
o.timeoutlen    = 400  
o.splitbelow = true    
o.splitright = true    
opt.clipboard  = "unnamedplus"  
o.undofile     = true           
opt.fileformats = { "unix", "dos" }
