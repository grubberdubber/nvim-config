-- ═══════════════════════════════════════════════════════════════
-- CYBERKALI — tema hacker/futurista para NvChad (base46)
--
-- Inspirado en la estética oscura y minimalista de Kali Linux,
-- llevada a un tono más neón/cyberpunk. 4 acentos protagonistas:
-- rojo (peligro/errores), celeste (marca/info), azul (funciones),
-- verde (éxito/estilo Matrix, suavizado para no cansar la vista).
--
-- CÓMO MODIFICAR SIN ROMPERLO:
--   1. Solo cambiá los valores hexadecimales.
--   2. NUNCA cambies los NOMBRES de las claves.
--   3. Después de cualquier cambio: :so % o reiniciá Neovim.
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#E8F4F8", -- Texto principal (blanco con leve tinte celeste, cohesivo con el resto)
    darker_black = "#05070B", -- 6% más oscuro que "black" — paneles secundarios
    black = "#0A0E14", -- Fondo principal — casi negro puro, base de toda la estética hacker
    black2 = "#0F141B", -- 6% más claro — línea de cursor, popups menores
    one_bg = "#141A24", -- 10% más claro — statusline, paneles flotantes
    one_bg2 = "#1A212C", -- 6% más claro que one_bg — tabs inactivas
    one_bg3 = "#202834", -- 6% más claro que one_bg2 — bordes/detalles
    grey = "#3A4552", -- Gris azulado neutro — comentarios, texto apagado
    grey_fg = "#4A5666", -- Texto secundario
    grey_fg2 = "#566372", -- Variante de texto secundario
    light_grey = "#6B7A8C", -- Line numbers no activos
    red = "#FF3B5C", -- ROJO PROTAGONISTA: errores, peligro, alertas
    baby_pink = "#FF6B8A", -- Variante clara de rojo
    pink = "#FF4FA0", -- Acento magenta-neón secundario
    line = "#1E2731", -- Líneas divisorias entre splits
    green = "#39FF88", -- VERDE PROTAGONISTA: éxito, strings — estilo Matrix suavizado
    vibrant_green = "#00FF9C", -- Verde más saturado — gitsigns (líneas añadidas)
    nord_blue = "#4C7FE0", -- Azul suave — separadores, íconos
    blue = "#2E9EFF", -- AZUL PROTAGONISTA: funciones, links
    yellow = "#FFD93B", -- Warnings, keywords en sintaxis
    sun = "#FFE873", -- Variante clara de amarillo
    purple = "#B14EFF", -- Keywords de control (if/for/return)
    dark_purple = "#7C3AED", -- Variante apagada de purple
    teal = "#00D9A3", -- Verde-celeste — íconos de tipo/clase
    orange = "#FF9E3D", -- Números, constantes
    cyan = "#00F0FF", -- CELESTE PROTAGONISTA: tipos, marca, énfasis (el "signature" del tema)
    statusline_bg = "#0D1219", -- Fondo de la barra de estado
    lightbg = "#141A24", -- Elementos levemente destacados
    pmenu_bg = "#00F0FF", -- Ítem seleccionado en menús — celeste neón, bien visible
    folder_bg = "#2E9EFF", -- Íconos de carpeta — azul
}

-- ═══ COLORES DE TERMINAL INTEGRADA ═════════════════════════════════
M.base_16 = {
    base00 = "#0A0E14",
    base01 = "#0F141B",
    base02 = "#1E2731",
    base03 = "#3A4552",
    base04 = "#6B7A8C",
    base05 = "#E8F4F8",
    base06 = "#E8F4F8",
    base07 = "#FFFFFF",
    base08 = "#FF3B5C", -- Rojo
    base09 = "#FF9E3D", -- Naranja
    base0A = "#FFD93B", -- Amarillo
    base0B = "#39FF88", -- Verde
    base0C = "#00F0FF", -- Celeste
    base0D = "#2E9EFF", -- Azul
    base0E = "#B14EFF", -- Púrpura
    base0F = "#FF4FA0", -- Rosa
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "cyberkali")
return M
