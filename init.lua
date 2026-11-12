-- ╔══════════════════════════════════════════════════════════════╗
-- ║          NEOVIM STAFF ENGINEER — init.lua                    ║
-- ║          NvChad v2.5 + 30 languages + DAP + Git + DB         ║
-- ╚══════════════════════════════════════════════════════════════╝

-- High-resolution start timestamp used by the dashboard to report real
-- startup time (measured from this line to the first dashboard render).
vim.g.nvim_start_hrtime = (vim.uv or vim.loop).hrtime()

-- ── MASON PERMISSION FIX (runs first, before any plugin) ─────────
-- Resolves EACCES on Mason binaries on Kali/Debian/Ubuntu without any
-- manual post-install chmod. Synchronous on purpose: it must finish
-- before the first LSP process starts.
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 then
    vim.fn.system { "chmod", "-R", "+x", mason_bin }
end

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- ── LAZY.NVIM BOOTSTRAP ──────────────────────────────────────────
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- ── PLUGIN LOADING ───────────────────────────────────────────────
-- NvChad uses priority=1000 so nvconfig is on the runtimepath before
-- mappings.lua requires it.
require("lazy").setup({
    {
        "NvChad/NvChad",
        lazy = false,
        branch = "v2.5",
        import = "nvchad.plugins",
        priority = 1000,
    },
    { import = "plugins" },
}, {
    defaults = { lazy = true },
    git = { timeout = 900 }, -- 15 min: avante compiles several Rust crates
    install = { colorscheme = { "nvchad" } },
    ui = { icons = { ft = "", lazy = "󰂠 ", loaded = "", not_loaded = "" } },
    performance = {
        rtp = {
            -- Disable unused Vim runtime plugins (faster startup)
            disabled_plugins = {
                "2html_plugin",
                "tohtml",
                "getscript",
                "getscriptPlugin",
                "gzip",
                "logipat",
                "netrw",
                "netrwPlugin",
                "netrwSettings",
                "netrwFileHandlers",
                "matchit",
                "tar",
                "tarPlugin",
                "rrhelper",
                "spellfile_plugin",
                "vimball",
                "vimballPlugin",
                "zip",
                "zipPlugin",
                "tutor",
                "rplugin",
                "syntax",
                "synmenu",
                "optwin",
                "compiler",
                "bugreport",
            },
        },
    },
})

-- ── DISABLE AUTOPAIRS (no automatic closers, full control) ───────
vim.g.autopairs_enabled = false

-- ── DAP BREAKPOINT GLYPHS ────────────────────────────────────────
--   ●  red    = regular breakpoint (IntelliJ / VS Code convention)
--   ◉  orange = conditional breakpoint
--   ◆  blue   = log point (prints without pausing)
--   ▶  green  = current debugger line
vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DiagnosticError",
    linehl = "",
    numhl = "DiagnosticError",
})
vim.fn.sign_define("DapBreakpointCondition", {
    text = "◉",
    texthl = "DiagnosticWarn",
    linehl = "",
    numhl = "DiagnosticWarn",
})
vim.fn.sign_define("DapBreakpointRejected", {
    text = "●",
    texthl = "DiagnosticHint",
    linehl = "",
    numhl = "DiagnosticHint",
})
vim.fn.sign_define("DapLogPoint", {
    text = "◆",
    texthl = "DiagnosticInfo",
    linehl = "",
    numhl = "DiagnosticInfo",
})
vim.fn.sign_define("DapStopped", {
    text = "▶",
    texthl = "DiagnosticOk",
    linehl = "DiffAdd",
    numhl = "DiagnosticOk",
})

-- ── BASE THEMES ──────────────────────────────────────────────────
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- ── REMAINING MODULES ────────────────────────────────────────────
require "options"
require "autocmds"
require("dashboard").setup()
vim.schedule(function()
    require "mappings"
end)

-- ── LINTER DEPENDENCY BOOTSTRAP (STYLELINT) ──────────────────────
local nvim_dir = vim.fn.stdpath "config"
local node_modules = nvim_dir .. "/node_modules"

if vim.fn.isdirectory(node_modules) == 0 then
    vim.notify("Installing linter dependencies in ~/.config/nvim...", vim.log.levels.INFO)
    vim.fn.jobstart({ "npm", "install" }, { cwd = nvim_dir })
end
