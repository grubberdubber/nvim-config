-- ═══════════════════════════════════════════════════════════════
-- MR. ROBOT / FSOCIETY — Tema para NvChad
-- Estética realista, cruda y de bajo contraste para auditorías.
-- ═══════════════════════════════════════════════════════════════

local M = {}
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ══════════════════════════════════════════
M.base_30 = {
    white = "#C8D3CC", -- Blanco ceniza con un leve tinte verdoso sucio
    darker_black = "#0A0B0E", -- Paneles secundarios casi apagados
    black = "#111216", -- Fondo mate oscuro (no negro puro, fatiga menos)
    black2 = "#1A1C23", -- Línea de cursor
    one_bg = "#22252D", -- Statusline
    one_bg2 = "#2A2D37", -- Pestañas inactivas
    one_bg3 = "#323641",
    grey = "#545C68", -- Comentarios crudos y sigilosos
    grey_fg = "#6B7482",
    grey_fg2 = "#828C9B",
    light_grey = "#96A0B0",
    red = "#CC0000", -- ROJO FSOCIETY: Intenso, oscuro, sangre (Errores críticos)
    baby_pink = "#B24C5E", -- Acentos desaturados
    pink = "#A33B53",
    line = "#2A2D37", -- Divisores
    green = "#2E8B57", -- Verde terminal realista (no es neón, es más crudo)
    vibrant_green = "#3CB371",
    nord_blue = "#4B6B8A", -- Azul pizarra apagado
    blue = "#3276B1",
    yellow = "#B8860B", -- Amarillo mostaza/sucio
    sun = "#DAA520",
    purple = "#7B5D8F", -- Púrpura industrial
    dark_purple = "#5E466E",
    teal = "#3A8B88",
    orange = "#BD5E24", -- Naranja óxido
    cyan = "#469B9E", -- Cian apagado
    statusline_bg = "#0D0F12",
    lightbg = "#2A2D37",
    pmenu_bg = "#CC0000", -- Elemento seleccionado en menú popup en rojo sangre
    folder_bg = "#4B6B8A",
}

-- ═══ COLORES DE TERMINAL ═══════════════════════════════════════
M.base_16 = {
    base00 = "#111216",
    base01 = "#1A1C23",
    base02 = "#2A2D37",
    base03 = "#545C68",
    base04 = "#96A0B0",
    base05 = "#C8D3CC",
    base06 = "#D5DFD9",
    base07 = "#E2ECE6",
    base08 = "#CC0000", -- Rojo
    base09 = "#BD5E24", -- Naranja
    base0A = "#B8860B", -- Amarillo
    base0B = "#2E8B57", -- Verde
    base0C = "#469B9E", -- Cian
    base0D = "#3276B1", -- Azul
    base0E = "#7B5D8F", -- Púrpura
    base0F = "#A33B53", -- Rosa oscuro
}

M.type = "dark"
vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "mrrobot")
return M
