-- ═══════════════════════════════════════════════════════════════
-- MY THEME — custom NvChad (base46) theme: HYPER KAWAI edition 🎀✨
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
local TRANSPARENT = true

-- ═══ MAIN PALETTE (30 colors, controls the whole UI) ═════════════
M.base_30 = {
    white = "#FFF0F8", -- Pure, bright cotton-candy white
    darker_black = "#1E0A15", -- Secondary panels: near-black dark strawberry
    black = "#290D1C", -- Fondo principal: Frambuesa/Ciruela profundo (Ultra femenino)
    black2 = "#3D1429", -- Cursor line: dark wine pink
    one_bg = "#4A1832", -- Fondo de statusline: Magenta apagado
    one_bg2 = "#5C1E3E", -- Inactive tabs
    one_bg3 = "#6E244A", -- Bordes sutiles
    grey = "#995C7A", -- Comentarios: Rosa viejo/Polvo de rosas
    grey_fg = "#B37092", -- Secondary text: metallic pink
    grey_fg2 = "#CC85A9", -- Variante de texto secundario
    light_grey = "#E69EC0", -- Inactive line numbers en rosa chicle suave
    red = "#FF004D", -- Intense cherry red (the perfect Hello Kitty bow) 🎀
    baby_pink = "#FFB3D9", -- Super-sweet pastel baby pink for icons
    pink = "#FF4D94", -- Rosa Barbie vibrante para acentos principales
    line = "#5C1E3E", -- Separator lines in plum
    green = "#80FFB2", -- Neon pastel mint for strings (beautiful contrast with the pink)
    vibrant_green = "#33FF85", -- Verde hada saturado
    nord_blue = "#B3D1FF", -- Azul nube pastel
    blue = "#80BFFF", -- Azul cenicienta para funciones
    yellow = "#FFF280", -- Amarillo pollito/estrellita para warnings
    sun = "#FFEB3B", -- Amarillo sol brillante
    purple = "#D280FF", -- Vibrant magic lilac for keywords
    dark_purple = "#B34DFF", -- Purple uva
    teal = "#80FFEA", -- Cyan sirena pastel para clases
    orange = "#FF9966", -- Strong peach/coral for numbers
    cyan = "#80E5FF", -- Celeste hielo
    statusline_bg = "#1F0A15", -- High-contrast statusline background
    lightbg = "#4A1832", -- Active menu line
    pmenu_bg = "#FF4D94", -- Selected menu item: neon Barbie pink
    folder_bg = "#FFB3D9", -- Folders in baby pink
}

-- ═══ COLORES DE TERMINAL INTEGRADA (:terminal, toggleterm) ════════
M.base_16 = {
    base00 = "#290D1C", -- Fondo de terminal (= black)
    base01 = "#3D1429", -- Fondo secundario (= black2)
    base02 = "#5C1E3E", -- Visual selection (= line)
    base03 = "#995C7A", -- Comentarios / gris apagado (= grey)
    base04 = "#E69EC0", -- Texto oscuro secundario (= light_grey)
    base05 = "#FFF0F8", -- Texto por defecto (= white)
    base06 = "#FFF0F8", -- Texto claro
    base07 = "#FFFFFF", -- Brightest text (pure white)
    base08 = "#FF004D", -- Bow red (errors, variables)
    base09 = "#FF9966", -- Coral (numbers, constants)
    base0A = "#FFF280", -- Amarillo estrellita (warnings, clases)
    base0B = "#80FFB2", -- Pastel mint (strings, success)
    base0C = "#80E5FF", -- Celeste hielo (soporte, regex)
    base0D = "#80BFFF", -- Azul cenicienta (funciones)
    base0E = "#D280FF", -- Lila vibrante (keywords)
    base0F = "#FF4D94", -- Rosa Barbie (deprecated, tags)
}

-- ═══ THEME TYPE (required; the theme will not compile without it) ═
M.type = "dark"

vim.opt.bg = "dark"

-- ═══ TRANSPARENCIA ═════════════════════════════════════════════════
if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "mitema")
return M
