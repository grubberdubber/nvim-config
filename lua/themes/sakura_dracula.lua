-- ═══════════════════════════════════════════════════════════════
-- SAKURA DRACULA — Dracula background + pastel palette (pink, lavender, mint)
-- File: ~/.config/nvim/lua/themes/sakura_dracula.lua
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- true = let the terminal background show through (like fluorodark)
-- false = use the theme's Dracula background #282A36
local TRANSPARENT = false

-- ═══ MAIN PALETTE ═════════════════════════════════════════════════
M.base_30 = {
    white = "#F8F8F2", -- Base text (Dracula's warm white)
    darker_black = "#21222C", -- Darker panels
    black = "#282A36", -- Fondo principal (Dracula)
    black2 = "#2F3142", -- Cursor line
    one_bg = "#2C2E3B", -- Statusline
    one_bg2 = "#343746", -- Tabs inactivas
    one_bg3 = "#3D4054", -- Bordes

    -- ── COMMENTS AND LINE NUMBERS ──
    grey = "#6B769F",
    grey_fg = "#8B96C4", -- Comentarios: lavanda azulada, legible sobre #282A36
    grey_fg2 = "#A3AED8",
    light_grey = "#C48BB8", -- Line numbers: dusty pink

    -- ── SINTAXIS PASTEL ──
    red = "#FF9AA2", -- Coral suave
    baby_pink = "#FFC1DC", -- Cotton pink
    pink = "#F7A8D8", -- Rosa sakura
    line = "#343746",
    green = "#B5EAC2", -- Menta
    vibrant_green = "#9BE8B0",
    nord_blue = "#A9D6F5", -- Celeste
    blue = "#A5CCF7",
    yellow = "#F8E8A0", -- Pastel lemon
    sun = "#FBE7A1",
    purple = "#C9B1F5", -- Lavanda
    dark_purple = "#A98BE0",
    teal = "#9FE6D8", -- Aqua suave
    orange = "#FFC8A2", -- Durazno
    cyan = "#9DE7F5",

    -- ── INTERFAZ ──
    statusline_bg = "#21222C",
    lightbg = "#2C2E3B",
    pmenu_bg = "#C9B1F5", -- Floating menus in lavender
    folder_bg = "#A5CCF7", -- Carpetas en celeste
}

-- ═══ BASE16 (terminal integrada y resaltado general) ══════════════
M.base_16 = {
    base00 = "#282A36", -- Background
    base01 = "#2F3142",
    base02 = "#3A3D4F", -- Visual selection
    base03 = "#8B96C4", -- Comentarios
    base04 = "#A3AED8",
    base05 = "#F8F8F2", -- Foreground
    base06 = "#F8F8F2",
    base07 = "#FFFFFF",
    base08 = "#F6EBB5", -- Variables (crema)
    base09 = "#FFC8A2", -- Numbers/constants (peach)
    base0A = "#9FE6D8", -- Tipos (aqua)
    base0B = "#B5EAC2", -- Strings (menta)
    base0C = "#9DE7F5", -- Cyan
    base0D = "#A9D6F5", -- Funciones (celeste)
    base0E = "#F7A8D8", -- Keywords (rosa sakura)
    base0F = "#FF9AA2", -- Coral
}

M.type = "dark"
vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

-- ── TREE-SITTER RULES (same structure as fluorodark) ────────────
M.hl_add = {
    ["@variable"] = { fg = M.base_16.base08 },
    ["@variable.parameter"] = { fg = M.base_30.orange, italic = true },
    ["@variable.builtin"] = { fg = M.base_16.base09, italic = true },
    ["@punctuation.delimiter"] = { fg = M.base_30.white },
    ["@punctuation.bracket"] = { fg = M.base_30.white },
    ["@function.call"] = { fg = M.base_16.base0D, bold = true },
    ["@method.call"] = { fg = M.base_16.base0D, bold = true },
    ["@property"] = { fg = M.base_30.baby_pink },
    ["Comment"] = { fg = M.base_16.base03, italic = true },

    ["MatchParen"] = { bg = "#44475A", fg = M.base_30.white, bold = true },
    ["MatchWord"] = { bg = "#44475A", fg = M.base_30.white, bold = true },
}

M = require("base46").override_theme(M, "sakura_dracula")
return M
