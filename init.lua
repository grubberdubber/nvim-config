-- FIX PERMISOS — corre PRIMERO, antes de cualquier plugin
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 then
  vim.fn.jobstart({ "chmod", "-R", "+x", mason_bin })
end

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy     = false,
    branch   = "v2.5",
    import   = "nvchad.plugins",
    priority = 1000,
  },
  { import = "plugins" },
}, {
  defaults = { lazy = true },
  install  = { colorscheme = { "nvchad" } },
  ui       = { icons = { ft = "", lazy = "󰂠 ", loaded = "", not_loaded = "" } },
})

vim.g.autopairs_enabled = false

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◉", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk" })

dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"
vim.schedule(function()
  require "mappings"
end)
