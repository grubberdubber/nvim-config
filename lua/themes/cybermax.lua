-- ═══════════════════════════════════════════════════════════════
-- CYBERMAX — The absolute limit of saturation and brightness.
--
-- 100% black background. Every syntax color is a pure
-- laser. The purple was removed from comments and line
-- numbers to avoid opacity.
-- ═══════════════════════════════════════════════════════════════

local M = {}

local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Texto general en blanco puro
    darker_black = "#000000", -- Negro puro
    black = "#000000", -- Fondo absoluto, cero gris
    black2 = "#000000", -- Cero paneles oscuros
    one_bg = "#050505", -- Statusline, barely visible
    one_bg2 = "#0A0A0A",
    one_bg3 = "#0F0F0F",

    -- ── COMMENT AND LINE-NUMBER OVERRIDES ──
    grey = "#FF007F", -- Comments in ultra-bright neon pink (no more purple)
    grey_fg = "#FF00FF", -- Texto secundario en Magenta puro
    grey_fg2 = "#FF00AA",
    light_grey = "#FFFF00", -- Line numbers in 100% electric yellow

    -- ── SINTAXIS ULTRA CHILLONA ──
    red = "#FF0000", -- Rojo puro (Peligro/Errores)
    baby_pink = "#FF0077",
    pink = "#FF00FF", -- Magenta puro
    line = "#111111", -- Separadores casi invisibles
    green = "#00FF00", -- Verde puro 100% (Strings)
    vibrant_green = "#39FF14", -- Verde radiactivo
    nord_blue = "#00FFFF", -- Azul claro cambiado a Cyan puro
    blue = "#0066FF", -- Intense electric blue (functions)
    yellow = "#FFFF00", -- Amarillo puro
    sun = "#FFFF00",
    purple = "#D500FF", -- Blinding neon purple ONLY for keywords
    dark_purple = "#AA00FF",
    teal = "#00FFCC", -- Menta/Cyan radiactivo para tipos
    orange = "#FF5500", -- Naranja fuego puro al 100%
    cyan = "#00FFFF", -- Cyan puro al 100%

    -- ── INTERFAZ ──
    statusline_bg = "#000000", -- Fondo de barra invisible
    lightbg = "#0A0A0A",
    pmenu_bg = "#00FFFF", -- Floating menus in bright cyan
    folder_bg = "#00FF00", -- Carpetas en Verde puro
}

-- ═══ COLORES DE TERMINAL INTEGRADA ═════════════════════════════════
M.base_16 = {
    base00 = "#000000", -- Background
    base01 = "#050505", -- Lighter Background
    base02 = "#0F0F0F", -- Selection Background
    base03 = "#FF007F", -- Comments (neon pink)
    base04 = "#FFFF00", -- Dark Foreground (Amarillo)
    base05 = "#FFFFFF", -- Default Foreground (Blanco)
    base06 = "#FFFFFF", -- Light Foreground
    base07 = "#FFFFFF", -- Light Background
    base08 = "#FF0000", -- Rojo Puro
    base09 = "#FF5500", -- Naranja Fuego
    base0A = "#FFFF00", -- Amarillo Puro
    base0B = "#00FF00", -- Verde Puro
    base0C = "#00FFFF", -- Cyan Puro
    base0D = "#0066FF", -- Electric blue
    base0E = "#D500FF", -- Blinding neon purple
    base0F = "#FF00FF", -- Magenta Puro
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "cybermax")
return M
