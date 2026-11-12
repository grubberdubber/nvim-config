-- ═══════════════════════════════════════════════════════════════
-- CYBERKALI — hacker/futuristic theme for NvChad (base46)
--
-- Inspired by Kali Linux's dark, minimalist aesthetic,
-- pushed toward a neon/cyberpunk tone. Four leading accents:
-- red (danger/errors), cyan (brand/info), blue (functions),
-- green (success/Matrix, softened to avoid eye strain).
--
-- HOW TO EDIT WITHOUT BREAKING IT:
--   1. Only change the hexadecimal values.
--   2. NEVER change the key NAMES.
--   3. After any change: :so % or restart Neovim.
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#E8F4F8", -- Texto principal (blanco con leve tinte celeste, cohesivo con el resto)
    darker_black = "#05070B", -- 6% darker than "black": secondary panels
    black = "#0A0E14", -- Main background: near-black, base of the whole hacker aesthetic
    black2 = "#0F141B", -- 6% lighter: cursor line, minor popups
    one_bg = "#141A24", -- 10% lighter: statusline, floating panels
    one_bg2 = "#1A212C", -- 6% lighter than one_bg: inactive tabs
    one_bg3 = "#202834", -- 6% lighter than one_bg2: borders/details
    grey = "#3A4552", -- Gris azulado neutro — comentarios, texto apagado
    grey_fg = "#4A5666", -- Texto secundario
    grey_fg2 = "#566372", -- Variante de texto secundario
    light_grey = "#6B7A8C", -- Line numbers no activos
    red = "#FF3B5C", -- ROJO PROTAGONISTA: errores, peligro, alertas
    baby_pink = "#FF6B8A", -- Variante clara de rojo
    pink = "#FF4FA0", -- Secondary neon magenta accent
    line = "#1E2731", -- Separator lines between splits
    green = "#39FF88", -- LEADING GREEN: success, strings, softened Matrix style
    vibrant_green = "#00FF9C", -- More saturated green: gitsigns (added lines)
    nord_blue = "#4C7FE0", -- Soft blue: separators, icons
    blue = "#2E9EFF", -- AZUL PROTAGONISTA: funciones, links
    yellow = "#FFD93B", -- Warnings, keywords en sintaxis
    sun = "#FFE873", -- Variante clara de amarillo
    purple = "#B14EFF", -- Keywords de control (if/for/return)
    dark_purple = "#7C3AED", -- Variante apagada de purple
    teal = "#00D9A3", -- Teal: type/class icons
    orange = "#FF9E3D", -- Numbers, constants
    cyan = "#00F0FF", -- LEADING CYAN: types, brand, emphasis (the theme's signature)
    statusline_bg = "#0D1219", -- Fondo de la barra de estado
    lightbg = "#141A24", -- Elementos levemente destacados
    pmenu_bg = "#00F0FF", -- Selected menu item: neon cyan, clearly visible
    folder_bg = "#2E9EFF", -- Folder icons: blue
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
    base0E = "#B14EFF", -- Purple
    base0F = "#FF4FA0", -- Rosa
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "cyberkali")
return M
