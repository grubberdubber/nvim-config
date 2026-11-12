-- ═══════════════════════════════════════════════════════════════
-- FLUORODARK — Fluoromachine fork (equalized luminance)
-- ═══════════════════════════════════════════════════════════════

local M = {}

local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Base text and punctuation
    darker_black = "#020104", -- Darker panels
    black = "#050308", -- Fondo principal (SIN CAMBIOS)
    black2 = "#0A0612", -- Cursor line
    one_bg = "#0D0817", -- Statusline
    one_bg2 = "#140C24", -- Tabs inactivas
    one_bg3 = "#1C1133", -- Bordes

    -- ── COMMENTS AND LINE NUMBERS (UNCHANGED) ──
    grey = "#00AABB",
    grey_fg = "#0088cc", -- Comentarios suave
    grey_fg2 = "#00CCFF",
    light_grey = "#FF007F", -- Line numbers in neon pink

    -- ── SINTAXIS FLUOROMACHINE (MISMO NIVEL DE BRILLO RGB) ──
    red = "#FF0055", -- Laser red (balanced brightness)
    baby_pink = "#FF00AA", -- Pure neon pink
    pink = "#FF00FF", -- Magenta Puro (100% Brillo)
    line = "#0A0612",
    green = "#00FF00", -- Pure acid green (100% brightness)
    vibrant_green = "#00FF00",
    nord_blue = "#00FFFF",
    blue = "#00FFFF", -- Neon cyan Puro (100% Brillo)
    yellow = "#FFFF00", -- Amarillo Puro (100% Brillo)
    sun = "#FFFF00",
    purple = "#AA00FF", -- Morado Fluor (Elevado al 100% de brillo)
    dark_purple = "#8800CC",
    teal = "#00FFAA", -- Neon mint/aqua
    orange = "#FF8000", -- Neon orange (Ecualizado con el Amarillo y Magenta)
    cyan = "#00FFFF",

    -- ── INTERFAZ ──
    statusline_bg = "#020104",
    lightbg = "#0D0817",
    pmenu_bg = "#FF00FF", -- Floating menus in magenta
    folder_bg = "#FFFF00", -- Carpetas a juego con Amarillo
}

-- ═══ COLORES DE TERMINAL INTEGRADA (IGUAL NIVEL DE BRILLO) ═════════
M.base_16 = {
    base00 = "#050308", -- Background (SIN CAMBIOS)
    base01 = "#0A0612",
    base02 = "#140C24",
    base03 = "#0088FF", -- Comments (SIN CAMBIOS)
    base04 = "#0088cc",
    base05 = "#FFFFFF", -- Default Foreground
    base06 = "#FFFFFF",
    base07 = "#FFFFFF",
    base08 = "#FFFF00", -- Variables (Amarillo Puro 100% Brillo)
    base09 = "#FF8000", -- Naranja (Ecualizado)
    base0A = "#00FFAA", -- Menta
    base0B = "#00FF00", -- Acid green (100% brightness)
    base0C = "#00FFFF", -- Cyan
    base0D = "#00FFFF", -- Funciones (Cyan)
    base0E = "#FF00FF", -- Keywords (Magenta)
    base0F = "#FF0055", -- Rosa/Rojo
}

M.type = "dark"
vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

-- ── REGLAS ESTRICTAS PARA TREE-SITTER ──
M.hl_add = {
    ["@variable"] = { fg = M.base_16.base08 },
    ["@variable.parameter"] = { fg = M.base_16.base08 },
    ["@variable.builtin"] = { fg = M.base_16.base09, italic = true },
    ["@punctuation.delimiter"] = { fg = M.base_30.white },
    ["@punctuation.bracket"] = { fg = M.base_30.white },
    ["@function.call"] = { fg = M.base_16.base0D, bold = true },
    ["@method.call"] = { fg = M.base_16.base0D, bold = true },
    ["@property"] = { fg = M.base_30.baby_pink },

    ["MatchParen"] = { bg = "#16304F", fg = M.base_30.white, bold = true },
    ["MatchWord"] = { bg = "#16304F", fg = M.base_30.white, bold = true },
}

M = require("base46").override_theme(M, "fluorodark")
return M
