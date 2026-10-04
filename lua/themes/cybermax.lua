-- ═══════════════════════════════════════════════════════════════
-- CYBERMAX — El límite absoluto de saturación y brillo.
--
-- Fondo 100% negro. Todos los colores de sintaxis son láseres
-- puros. Se eliminó el morado de los comentarios y números de
-- línea para evitar opacidad.
-- ═══════════════════════════════════════════════════════════════

local M = {}

local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Texto general en blanco puro
    darker_black = "#000000", -- Negro puro
    black = "#000000", -- Fondo absoluto, cero gris
    black2 = "#000000", -- Cero paneles oscuros
    one_bg = "#050505", -- Statusline levísimamente visible
    one_bg2 = "#0A0A0A",
    one_bg3 = "#0F0F0F",

    -- ── REEMPLAZO DE COMENTARIOS Y NÚMEROS DE LÍNEA ──
    grey = "#FF007F", -- Comentarios en Rosa Neón ultrapotente (adiós al morado)
    grey_fg = "#FF00FF", -- Texto secundario en Magenta puro
    grey_fg2 = "#FF00AA",
    light_grey = "#FFFF00", -- Números de línea en Amarillo Eléctrico 100%

    -- ── SINTAXIS ULTRA CHILLONA ──
    red = "#FF0000", -- Rojo puro (Peligro/Errores)
    baby_pink = "#FF0077",
    pink = "#FF00FF", -- Magenta puro
    line = "#111111", -- Separadores casi invisibles
    green = "#00FF00", -- Verde puro 100% (Strings)
    vibrant_green = "#39FF14", -- Verde radiactivo
    nord_blue = "#00FFFF", -- Azul claro cambiado a Cyan puro
    blue = "#0066FF", -- Azul eléctrico intenso (Funciones)
    yellow = "#FFFF00", -- Amarillo puro
    sun = "#FFFF00",
    purple = "#D500FF", -- Morado neón cegador SOLO para keywords
    dark_purple = "#AA00FF",
    teal = "#00FFCC", -- Menta/Cyan radiactivo para tipos
    orange = "#FF5500", -- Naranja fuego puro al 100%
    cyan = "#00FFFF", -- Cyan puro al 100%

    -- ── INTERFAZ ──
    statusline_bg = "#000000", -- Fondo de barra invisible
    lightbg = "#0A0A0A",
    pmenu_bg = "#00FFFF", -- Menús flotantes en Cyan brillante
    folder_bg = "#00FF00", -- Carpetas en Verde puro
}

-- ═══ COLORES DE TERMINAL INTEGRADA ═════════════════════════════════
M.base_16 = {
    base00 = "#000000", -- Background
    base01 = "#050505", -- Lighter Background
    base02 = "#0F0F0F", -- Selection Background
    base03 = "#FF007F", -- Comments (Rosa Neón)
    base04 = "#FFFF00", -- Dark Foreground (Amarillo)
    base05 = "#FFFFFF", -- Default Foreground (Blanco)
    base06 = "#FFFFFF", -- Light Foreground
    base07 = "#FFFFFF", -- Light Background
    base08 = "#FF0000", -- Rojo Puro
    base09 = "#FF5500", -- Naranja Fuego
    base0A = "#FFFF00", -- Amarillo Puro
    base0B = "#00FF00", -- Verde Puro
    base0C = "#00FFFF", -- Cyan Puro
    base0D = "#0066FF", -- Azul Eléctrico
    base0E = "#D500FF", -- Morado Neón Cegador
    base0F = "#FF00FF", -- Magenta Puro
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "cybermax")
return M
