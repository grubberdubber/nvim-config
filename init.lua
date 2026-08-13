-- ╔══════════════════════════════════════════════════════════════╗
-- ║          NVIM STAFF ENGINEER — init.lua                      ║
-- ║          NvChad v2.5 + 30 lenguajes + DAP + Git + DB         ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ── FIX PERMISOS MASON (corre PRIMERO, antes de cualquier plugin) ──
-- Resuelve EACCES en binarios de Mason en Kali/Debian/Ubuntu
-- sin necesidad de ningún chmod manual post-instalación
-- Usamos system (síncrono) para garantizar que corre ANTES que LSP
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 then
    vim.fn.system { "chmod", "-R", "+x", mason_bin }
end

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- ── BOOTSTRAP LAZY.NVIM ───────────────────────────────────────────
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

-- ── CARGA DE PLUGINS ─────────────────────────────────────────────
-- NvChad con priority=1000 garantiza que nvconfig esté en rtp
-- antes de que mappings.lua lo requiera
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
    install = { colorscheme = { "nvchad" } },
    ui = { icons = { ft = "", lazy = "󰂠 ", loaded = "", not_loaded = "" } },
    performance = {
        rtp = {
            -- Deshabilita plugins de Vim que no necesitamos (mejora tiempo de inicio)
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

-- ── DESACTIVAR AUTOPAIRS (sin cierres automáticos — control total) ─
vim.g.autopairs_enabled = false

-- ── BREAKPOINTS VISUALES DAP ─────────────────────────────────────
--   ●  rojo    = breakpoint normal        (estándar IntelliJ / VS Code)
--   ◉  naranja = breakpoint condicional
--   ◆  azul    = log point (imprime sin pausar)
--   ▶  verde   = línea activa del debugger
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

-- ── TEMAS BASE ───────────────────────────────────────────────────
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- ── CONFIGS RESTANTES ────────────────────────────────────────────
require "options"
require "autocmds"
vim.schedule(function()
    require "mappings"
end)

-- ── AUTO-INSTALACIÓN DE DEPENDENCIAS DE LINTERS (STYLELINT) ──────
local nvim_dir = vim.fn.stdpath "config"
local node_modules = nvim_dir .. "/node_modules"

if vim.fn.isdirectory(node_modules) == 0 then
    vim.notify("Instalando dependencias de linters en ~/.config/nvim...", vim.log.levels.INFO)
    vim.fn.jobstart({ "npm", "install" }, { cwd = nvim_dir })
end
