-- ═══════════════════════════════════════════════════════════════
-- CYBERCHILLÓN — tema de saturación extrema y colores "arcade"
--
-- Evita el negro puro. Usa fondos índigo/violeta fuertes para
-- darle un aspecto de plástico brillante, marcadores fluorescentes
-- y estética pop-art/arcade muy escandalosa.
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Texto blanco puro para no perderse entre los colores
    darker_black = "#140524", -- Fondo de terminal muy violeta
    black = "#1D0B33", -- Fondo principal (índigo fuerte, no negro)
    black2 = "#261042", -- Línea de cursor
    one_bg = "#35155D", -- Paneles y statusline (violeta chillón)
    one_bg2 = "#421C75", -- Tabs inactivas
    one_bg3 = "#51268A", -- Bordes
    grey = "#7B46C9", -- Los comentarios ahora son de un morado visible, no gris
    grey_fg = "#9F70E6", -- Texto secundario
    grey_fg2 = "#B78FFA",
    light_grey = "#6530AD", -- Números de línea inactivos
    red = "#FF0055", -- Rojo cereza muy chillón
    baby_pink = "#FF66B2",
    pink = "#f10076", -- Tu color: Rosa chicle escandaloso
    line = "#35155D",
    green = "#a6e22e", -- Tu color: Verde ácido/limón
    vibrant_green = "#CCFF00", -- Verde fosforescente puro (adiciones git)
    nord_blue = "#19bffe", -- Tu color: Celeste/Azul brillante
    blue = "#19bffe", -- Funciones y directorios
    yellow = "#f3e430", -- Tu color: Amarillo patito/marcador
    sun = "#FFFF00",
    purple = "#9D00FF", -- Morado eléctrico (más claro y chillón que el #6800d2)
    dark_purple = "#6800d2", -- Tu color: Lo usamos para fondos y selecciones
    teal = "#27fbfe", -- Tu color: Aqua/Cyan escandaloso
    orange = "#FF5500", -- Naranja puro
    cyan = "#27fbfe", -- Strings especiales y variables
    statusline_bg = "#140524",
    lightbg = "#35155D",
    pmenu_bg = "#f10076", -- Menús flotantes en tu rosa chillón
    folder_bg = "#f3e430", -- Íconos de carpeta en amarillo brillante
}

-- ═══ COLORES DE TERMINAL INTEGRADA ═════════════════════════════════
M.base_16 = {
    base00 = "#1D0B33", -- Background
    base01 = "#261042", -- Lighter Background
    base02 = "#421C75", -- Selection Background
    base03 = "#7B46C9", -- Comments
    base04 = "#9F70E6", -- Dark Foreground
    base05 = "#FFFFFF", -- Default Foreground
    base06 = "#FFFFFF", -- Light Foreground
    base07 = "#FFFFFF", -- Light Background
    base08 = "#f10076", -- Rosa chicle
    base09 = "#FF5500", -- Naranja
    base0A = "#f3e430", -- Amarillo marcador
    base0B = "#a6e22e", -- Verde ácido
    base0C = "#27fbfe", -- Aqua/Cyan
    base0D = "#19bffe", -- Azul brillante
    base0E = "#9D00FF", -- Morado eléctrico
    base0F = "#FF0055", -- Rojo cereza
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "cyberchillon")
return M
