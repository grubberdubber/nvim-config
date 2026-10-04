-- ═══════════════════════════════════════════════════════════════
-- FLUORODARK — Fork de Fluoromachine (Ultra Contraste)
--
-- Fondo ultra oscuro (#050308) para que los colores synthwave
-- resalten al máximo. Incluye reglas estrictas de Tree-sitter
-- para separar visualmente variables, puntuación y métodos,
-- evitando que el código se fusione en un solo color.
-- ═══════════════════════════════════════════════════════════════

local M = {}

local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL ═════════════════════════════════════════════
M.base_30 = {
    white = "#FFFFFF", -- Texto base y puntuación
    darker_black = "#020104", -- Paneles más oscuros (casi negro puro)
    black = "#050308", -- Fondo principal (Negro abismal con leve tinte fluor)
    black2 = "#0A0612", -- Línea de cursor
    one_bg = "#0D0817", -- Statusline
    one_bg2 = "#140C24", -- Tabs inactivas
    one_bg3 = "#1C1133", -- Bordes

    -- ── COMENTARIOS Y LÍNEAS ──
    grey = "#0088FF", -- Comentarios en Azul Eléctrico brillante (Cero morado)
    grey_fg = "#00AAFF",
    grey_fg2 = "#00CCFF",
    light_grey = "#FF007F", -- Números de línea en Rosa Neón

    -- ── SINTAXIS FLUOROMACHINE ──
    red = "#FF0044", -- Rojo Láser (Errores)
    baby_pink = "#FF0099", -- Rosa intenso (Propiedades de objetos)
    pink = "#FF00FF", -- Magenta Puro (Keywords: if, return, for)
    line = "#0A0612",
    green = "#39FF14", -- Verde Ácido (Strings)
    vibrant_green = "#00FF00",
    nord_blue = "#00FFFF",
    blue = "#00FFFF", -- Cyan Neón (Funciones y Métodos)
    yellow = "#FFE600", -- Amarillo Eléctrico (Variables y Clases)
    sun = "#FFFF00",
    purple = "#9D00FF", -- Morado Fluor (Solo para operadores lógicos)
    dark_purple = "#7A00CC",
    teal = "#00FFAA", -- Menta/Aqua (Tipos de datos)
    orange = "#FF5500", -- Naranja Fuego (Números)
    cyan = "#00FFFF",

    -- ── INTERFAZ ──
    statusline_bg = "#020104",
    lightbg = "#0D0817",
    pmenu_bg = "#FF00FF", -- Menús flotantes en Magenta
    folder_bg = "#FFE600", -- Carpetas en Amarillo
}

-- ═══ COLORES DE TERMINAL INTEGRADA ═════════════════════════════════
M.base_16 = {
    base00 = "#050308", -- Background
    base01 = "#0A0612", -- Lighter Background
    base02 = "#140C24", -- Selection Background
    base03 = "#0088FF", -- Comments (Azul Eléctrico)
    base04 = "#00AAFF", -- Dark Foreground
    base05 = "#FFFFFF", -- Default Foreground (Blanco)
    base06 = "#FFFFFF", -- Light Foreground
    base07 = "#FFFFFF", -- Light Background
    base08 = "#FFE600", -- Variables (Amarillo) -> 'nombre'
    base09 = "#FF5500", -- Naranja
    base0A = "#00FFAA", -- Menta
    base0B = "#39FF14", -- Verde Ácido (Strings)
    base0C = "#00FFFF", -- Cyan
    base0D = "#00FFFF", -- Funciones (Cyan) -> 'llamar'
    base0E = "#FF00FF", -- Keywords (Magenta)
    base0F = "#FF0044", -- Rosa/Rojo
}

M.type = "dark"

vim.opt.bg = "dark"

if TRANSPARENT then
    M.transparency = true
end

-- ── REGLAS ESTRICTAS PARA TREE-SITTER (SEPARACIÓN DE COLORES) ──
M.hl_add = {
    -- Fuerza que 'nombre' (la variable) sea Amarillo Eléctrico
    ["@variable"] = { fg = M.base_16.base08 },
    ["@variable.parameter"] = { fg = M.base_16.base08 },

    -- Fuerza que 'self' o 'this' sean Naranja Fuego para destacarlos
    ["@variable.builtin"] = { fg = M.base_16.base09, italic = true },

    -- Fuerza que el punto '.' sea Blanco puro
    ["@punctuation.delimiter"] = { fg = M.base_30.white },
    ["@punctuation.bracket"] = { fg = M.base_30.white },

    -- Fuerza que 'llamar' (la función/método) sea Cyan Neón
    ["@function.call"] = { fg = M.base_16.base0D, bold = true },
    ["@method.call"] = { fg = M.base_16.base0D, bold = true },

    -- Fuerza que las propiedades (ej: nombre.propiedad) sean Rosa intenso
    ["@property"] = { fg = M.base_30.baby_pink },
}

M = require("base46").override_theme(M, "fluorodark")
return M
