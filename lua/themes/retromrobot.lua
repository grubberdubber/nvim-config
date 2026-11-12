-- ═══════════════════════════════════════════════════════════════
-- MR. ROBOT / E-CORP HACK (MONOCHROME) — theme for NvChad
-- Purely monochromatic aesthetic (white, black and high-precision greys)
-- inspired by the FBI-hack terminal from the series.
-- ═══════════════════════════════════════════════════════════════

local M = {}
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ══════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Blanco puro terminal para texto principal
    darker_black = "#050505", -- Negro absoluto para paneles oscuros
    black = "#0A0A0A", -- Fondo principal: Negro terminal de alto contraste
    black2 = "#141414", -- Cursor line and subtle popups
    one_bg = "#1F1F1F", -- Fondo de la statusline (gris muy oscuro)
    one_bg2 = "#2E2E2E", -- Inactive tabs
    one_bg3 = "#3D3D3D", -- Bordes y separadores
    grey = "#5C5C5C", -- Comments: classic mid terminal grey
    grey_fg = "#7A7A7A", -- Texto secundario
    grey_fg2 = "#999999", -- Variante de texto secundario
    light_grey = "#B5B5B5", -- Inactive line numbers
    red = "#E0E0E0", -- Errores: En monocromo, los errores usan un blanco de alta intensidad
    baby_pink = "#CCCCCC",
    pink = "#D4D4D4",
    line = "#262626", -- Separator lines
    green = "#EAEAEA", -- Strings: En modo hacker B/W todo se maneja en escala de grises
    vibrant_green = "#FFFFFF",
    nord_blue = "#A6A6A6", -- Cool grey tones for functions or special variables
    blue = "#C2C2C2",
    yellow = "#EDEDED", -- Warnings: Blanco brillante destacado
    sun = "#FFFFFF",
    purple = "#8C8C8C", -- Keywords en gris intermedio
    dark_purple = "#6E6E6E",
    teal = "#B0B0B0",
    orange = "#D9D9D9", -- Numbers and constants in light grey
    cyan = "#DFDFDF",
    statusline_bg = "#080808",
    lightbg = "#1F1F1F",
    pmenu_bg = "#FFFFFF", -- Selected menu item: inverted to pure white
    folder_bg = "#A6A6A6",
}

-- ═══ COLORES DE TERMINAL ═══════════════════════════════════════
M.base_16 = {
    base00 = "#0A0A0A", -- Fondo de terminal (= black)
    base01 = "#141414", -- Fondo secundario (= black2)
    base02 = "#262626", -- Visual selection (= line)
    base03 = "#5C5C5C", -- Comentarios (= grey)
    base04 = "#B5B5B5", -- Texto oscuro secundario (= light_grey)
    base05 = "#FFFFFF", -- Texto por defecto (= white)
    base06 = "#FFFFFF", -- Texto claro
    base07 = "#FFFFFF", -- Brightest text (pure white)
    base08 = "#E0E0E0", -- Blanco alto contraste (errores)
    base09 = "#D9D9D9", -- Light grey (numbers)
    base0A = "#EDEDED", -- Blanco destello (warnings)
    base0B = "#EAEAEA", -- Gris plata (strings)
    base0C = "#DFDFDF", -- (soporte, regex)
    base0D = "#C2C2C2", -- (funciones)
    base0E = "#8C8C8C", -- (keywords)
    base0F = "#CCCCCC", -- (tags)
}

M.type = "dark"
vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "mrrobot_bw")
return M
