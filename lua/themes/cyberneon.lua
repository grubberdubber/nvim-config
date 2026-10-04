-- ═══════════════════════════════════════════════════════════════
-- CYBERNEON ULTRA — tema cyberpunk de máximo contraste para NvChad
--
-- Fondos llevados casi al negro puro (#050505) para que los
-- colores neón resalten al máximo. Tonos 100% saturados.
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Blanco puro para que el texto resalte al máximo
    darker_black = "#000000", -- Negro puro absoluto para paneles secundarios
    black = "#050505", -- Fondo principal ultra oscuro, casi abismal
    black2 = "#0A0A0A", -- Línea de cursor sutil
    one_bg = "#111111", -- Statusline
    one_bg2 = "#181818", -- Tabs inactivas
    one_bg3 = "#222222", -- Bordes
    grey = "#333333", -- Comentarios oscurecidos para no competir con el neón
    grey_fg = "#666666",
    grey_fg2 = "#888888",
    light_grey = "#AAAAAA",
    red = "#FF003C", -- Rojo láser/Cyberpunk puro
    baby_pink = "#FF007F", -- Rosa radiactivo
    pink = "#FF00FF", -- Magenta puro al 100%
    line = "#1A1A1A",
    green = "#00FF00", -- Verde puro (Matrix/Neón clásico)
    vibrant_green = "#39FF14", -- Verde radiactivo para gitsigns
    nord_blue = "#00BFFF",
    blue = "#0044FF", -- Azul eléctrico intenso
    yellow = "#FFFF00", -- Amarillo puro (alerta máxima)
    sun = "#FFEA00",
    purple = "#B026FF", -- Púrpura eléctrico vibrante
    dark_purple = "#8A2BE2",
    teal = "#00FFCC", -- Cyan-verde brillante
    orange = "#FF5500", -- Naranja radiactivo
    cyan = "#00FFFF", -- Cyan puro al 100% (el color con más luz)
    statusline_bg = "#030303",
    lightbg = "#141414",
    pmenu_bg = "#B026FF", -- Menús flotantes en púrpura eléctrico
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
    base08 = "#FF003C", -- Rojo Neón
    base09 = "#FF5500", -- Naranja Neón
    base0A = "#FFFF00", -- Amarillo Neón
    base0B = "#00FF00", -- Verde Neón
    base0C = "#00FFFF", -- Cyan Neón
    base0D = "#0044FF", -- Azul Eléctrico
    base0E = "#B026FF", -- Púrpura Eléctrico
    base0F = "#FF00FF", -- Magenta Puro
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "cyberneon")
return M
