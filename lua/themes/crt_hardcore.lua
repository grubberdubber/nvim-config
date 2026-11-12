-- ═══════════════════════════════════════════════════════════════
-- CRT HARDCORE — pure #000000 background + maximum-saturation ANSI
-- File: ~/.config/nvim/lua/themes/crt_hardcore.lua
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- false = keep the real #000000 background (no terminal bleed-through)
local TRANSPARENT = false

-- ═══ MAIN PALETTE ═════════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Pure white text
    darker_black = "#000000", -- Panels: absolute black
    black = "#000000", -- Main background: absolute black
    black2 = "#000000", -- Cursor line: absolute black
    one_bg = "#000000", -- Statusline: absolute black
    one_bg2 = "#000000", -- Inactive tabs: absolute black
    one_bg3 = "#003300", -- Borders: dark saturated phosphor green

    -- ── PHOSPHOR "NEUTRALS" (no grey anywhere) ──
    grey = "#00AA00",
    grey_fg = "#00CC00", -- Comments: CRT phosphor green
    grey_fg2 = "#00FF00",
    light_grey = "#00FFFF", -- Line numbers: electric cyan

    -- ── MAXIMUM-SATURATION ANSI PALETTE ──
    red = "#FF0000",
    baby_pink = "#FF0066",
    pink = "#FF00FF",
    line = "#003300",
    green = "#00FF00",
    vibrant_green = "#00FF00",
    nord_blue = "#0000FF",
    blue = "#0000FF",
    yellow = "#FFFF00",
    sun = "#FFFF00",
    purple = "#AA00FF",
    dark_purple = "#8800FF",
    teal = "#00FFAA",
    orange = "#FF8800",
    cyan = "#00FFFF",

    -- ── INTERFACE ──
    statusline_bg = "#000000",
    lightbg = "#002200",
    pmenu_bg = "#00FF00", -- Selected completion item
    folder_bg = "#00FFFF",
}

-- ═══ BASE16 (integrated terminal + general fallbacks) ════════════
M.base_16 = {
    base00 = "#000000", -- Background
    base01 = "#000000",
    base02 = "#003300", -- Visual selection: dark saturated green
    base03 = "#00CC00", -- Comments: phosphor green
    base04 = "#00AA00",
    base05 = "#FFFFFF", -- Default foreground
    base06 = "#FFFFFF",
    base07 = "#FFFFFF",
    base08 = "#FF0000", -- Variables / errors
    base09 = "#FF8800", -- Numbers / constants
    base0A = "#FFFF00", -- Types / warnings
    base0B = "#00FF00", -- Strings
    base0C = "#00FFFF", -- Support / regex
    base0D = "#0000FF", -- Functions: pure RGB blue
    base0E = "#FF00FF", -- Keywords
    base0F = "#FF0066", -- Deprecated / tags
}

M.type = "dark"
vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

-- ── TREE-SITTER RULES (same structure as the other themes) ──────
M.hl_add = {
    ["@variable"] = { fg = M.base_16.base08 },
    ["@variable.parameter"] = { fg = M.base_16.base08 },
    ["@variable.builtin"] = { fg = M.base_16.base09, italic = true },
    ["@punctuation.delimiter"] = { fg = M.base_30.white },
    ["@punctuation.bracket"] = { fg = M.base_30.white },
    ["@function.call"] = { fg = M.base_16.base0D, bold = true },
    ["@method.call"] = { fg = M.base_16.base0D, bold = true },
    ["@property"] = { fg = M.base_30.baby_pink },
    ["Comment"] = { fg = M.base_16.base03, italic = true },

    -- Old CRT "inverse video" highlight
    ["MatchParen"] = { bg = "#000080", fg = M.base_30.white, bold = true },
    ["MatchWord"] = { bg = "#000080", fg = M.base_30.white, bold = true },
}

M = require("base46").override_theme(M, "crt_hardcore")
return M
