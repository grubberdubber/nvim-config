-- ═══════════════════════════════════════════════════════════════
-- CYBERNEON ULTRA — maximum-contrast cyberpunk theme for NvChad
--
-- Backgrounds pushed almost to pure black (#050505) so the
-- maximum neon pop. 100% saturated tones.
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Pure white so text stands out as much as possible
    darker_black = "#000000", -- Negro puro absoluto para paneles secundarios
    black = "#050505", -- Fondo principal ultra oscuro, casi abismal
    black2 = "#0A0A0A", -- Subtle cursor line
    one_bg = "#111111", -- Statusline
    one_bg2 = "#181818", -- Tabs inactivas
    one_bg3 = "#222222", -- Bordes
    grey = "#333333", -- Dimmed comments so they do not compete with the neon
    grey_fg = "#666666",
    grey_fg2 = "#888888",
    light_grey = "#AAAAAA",
    red = "#FF003C", -- Pure laser/cyberpunk red
    baby_pink = "#FF007F", -- Rosa radiactivo
    pink = "#FF00FF", -- Magenta puro al 100%
    line = "#1A1A1A",
    green = "#00FF00", -- Pure green (classic Matrix/neon)
    vibrant_green = "#39FF14", -- Verde radiactivo para gitsigns
    nord_blue = "#00BFFF",
    blue = "#0044FF", -- Intense electric blue
    yellow = "#FFFF00", -- Pure yellow (maximum alert)
    sun = "#FFEA00",
    purple = "#B026FF", -- Vibrant electric purple
    dark_purple = "#8A2BE2",
    teal = "#00FFCC", -- Cyan-verde brillante
    orange = "#FF5500", -- Naranja radiactivo
    cyan = "#00FFFF", -- 100% pure cyan (the brightest color)
    statusline_bg = "#030303",
    lightbg = "#141414",
    pmenu_bg = "#B026FF", -- Floating menus in electric purple
    folder_bg = "#0044FF",
}

-- ═══ COLORES DE TERMINAL INTEGRADA ═════════════════════════════════
M.base_16 = {
    base00 = "#050505", -- Background
    base01 = "#0A0A0A", -- Lighter Background
    base02 = "#181818", -- Selection Background
    base03 = "#444444", -- Comments, Invisibles
    base04 = "#888888", -- Dark Foreground
    base05 = "#FFFFFF", -- Default Foreground (Blanco puro)
    base06 = "#F5F5F5", -- Light Foreground
    base07 = "#FFFFFF", -- Light Background
    base08 = "#FF003C", -- Neon red
    base09 = "#FF5500", -- Neon orange
    base0A = "#FFFF00", -- Neon yellow
    base0B = "#00FF00", -- Neon green
    base0C = "#00FFFF", -- Neon cyan
    base0D = "#0044FF", -- Electric blue
    base0E = "#B026FF", -- Electric purple
    base0F = "#FF00FF", -- Magenta Puro
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "cyberneon")
return M
