-- ── DISABLE CODEIUM DEFAULT KEYBINDINGS BEFORE IT LOADS ──────────
vim.g.codeium_disable_bindings = 1

require "nvchad.options"

local o = vim.o
local opt = vim.opt
vim.g.editorconfig = false

-- ── LINE NUMBERS AND VISUAL SETTINGS ─────────────────────────────
o.number = true
o.relativenumber = false
o.cursorline = true
o.cursorlineopt = "both"

-- ── COLOR ENGINE (fixes blink.cmp and diagnostics contrast) ──────
local function apply_custom_colors()
    -- Base UI
    vim.api.nvim_set_hl(0, "Comment", { fg = "#6272a4", italic = true, bold = false })
    vim.api.nvim_set_hl(0, "Whitespace", { fg = "#4b5263" })
    vim.api.nvim_set_hl(0, "NonText", { fg = "#4b5263" })

    -- Diagnostic palette
    local err = "#ff7a93"
    local warn = "#ffc27d"
    local info = "#78dce8"
    local hint = "#a9b1d6"

    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = err, bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = warn, bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = info, bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = hint, bg = "NONE" })

    vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = err })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = warn })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = info })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = hint })
    vim.api.nvim_set_hl(0, "Error", { fg = err, bg = "NONE", bold = true })

    -- Pin blink.cmp colors to the NvChad palette
    vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Pmenu", force = true })
    vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "FloatBorder", force = true })
    vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { link = "PmenuSel", force = true })
    vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", { link = "PmenuThumb", force = true })
    vim.api.nvim_set_hl(0, "BlinkCmpDoc", { link = "NormalFloat", force = true })
    vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "FloatBorder", force = true })
    vim.api.nvim_set_hl(0, "BlinkCmpLabel", { link = "Pmenu", force = true })
end

-- 1. Apply on startup
apply_custom_colors()

-- 2. Re-apply when the theme changes
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = apply_custom_colors,
})

-- 3. Re-apply right when lazy.nvim loads blink.cmp
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(args)
        if args.data == "blink.cmp" then
            apply_custom_colors()
        end
    end,
})

-- ── INDENTATION ──────────────────────────────────────────────────
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

-- Whitespace markers stay on by default; <leader>ul toggles them per window.
opt.list = true
opt.listchars = {
    lead = "·",
    tab = "··",
    trail = "·",
    nbsp = "␣",
}

-- ── DIAGNOSTICS (no gutter icons, counts live in the statusline) ──
vim.diagnostic.config {
    virtual_text = { prefix = "● ", spacing = 4 },
    signs = false,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded" },
}

-- ── WRITE-TIME CLEANUP: LF LINE ENDINGS AND NBSP ─────────────────
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = "*",
    desc = "Force Unix line endings and replace non-breaking spaces",
    callback = function()
        vim.bo.fileformat = "unix"
        vim.cmd [[%s/\%u00a0/ /ge]]
    end,
})

-- ── UI AND MISC ──────────────────────────────────────────────────
o.ignorecase = true
o.smartcase = true
o.scrolloff = 8
o.signcolumn = "auto:2"
o.updatetime = 250
o.timeoutlen = 400
o.splitbelow = true
o.splitright = true
opt.clipboard = ""
o.undofile = true
opt.fileformats = { "unix", "dos" }
opt.cmdheight = 1 -- Keep one row for the command line instead of hiding it
