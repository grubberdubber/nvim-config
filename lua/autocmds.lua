require "nvchad.autocmds"

-- ── FIX PERMISOS MASON ───────────────────────────────────────────
-- Segunda y tercera capa de seguridad (la primera está en init.lua)
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  desc = "Fix permisos Mason bin al arrancar",
  callback = function()
    if vim.fn.isdirectory(mason_bin) == 1 then
      vim.fn.system { "chmod", "-R", "+x", mason_bin }
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern  = "MasonToolInstalled",
  desc     = "Fix permisos tras instalar herramienta Mason",
  callback = function()
    if vim.fn.isdirectory(mason_bin) == 1 then
      vim.fn.system { "chmod", "-R", "+x", mason_bin }
    end
  end,
})

-- ── HIGHLIGHT ON YANK ────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  desc  = "Resalta brevemente el texto copiado con yank",
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 }
  end,
})

-- ── RESTAURAR POSICIÓN AL ABRIR ARCHIVO ─────────────────────────
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restaura el cursor a la última posición conocida",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── QUITAR ESPACIOS AL FINAL AL GUARDAR ──────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
  desc     = "Elimina trailing whitespace al guardar",
  pattern  = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd [[%s/\s\+$//e]]
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})
