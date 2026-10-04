local M = {}
local TRANSPARENT = false

M.base_30 = {
    white = "#D4D4D4", -- Texto general
    darker_black = "#111111", -- Más oscuro
    black = "#1E1E1E", -- Fondo clásico de VSCode
    black2 = "#252526", -- Paneles y menús
    one_bg = "#2D2D30", -- Statusline/Pestañas
    one_bg2 = "#37373D",
    one_bg3 = "#3E3E42", -- Bordes
    grey = "#404040",
    grey_fg = "#858585",
    grey_fg2 = "#6A9955", -- Comentarios
    light_grey = "#858585", -- Números de línea
    red = "#F44747", -- Errores
    baby_pink = "#D16969",
    pink = "#C586C0", -- Control de flujo (if/return)
    line = "#404040",
    green = "#6A9955", -- Comentarios en terminal
    vibrant_green = "#B5CEA8", -- Números
    nord_blue = "#569CD6",
    blue = "#569CD6", -- Keywords (const, let, var, function)
    yellow = "#DCDCAA", -- Funciones
    sun = "#DCDCAA",
    purple = "#C586C0", -- Imports y sentencias
    dark_purple = "#646695",
    teal = "#4EC9B0", -- Clases y tipos
    orange = "#CE9178", -- Strings
    cyan = "#9CDCFE", -- Variables
    statusline_bg = "#007ACC", -- Barra inferior azul típica de VSCode
    lightbg = "#2D2D30",
    pmenu_bg = "#252526",
    folder_bg = "#DCDCAA",
}

M.base_16 = {
    base00 = "#1E1E1E",
    base01 = "#252526",
    base02 = "#2D2D30",
    base03 = "#404040",
    base04 = "#858585",
    base05 = "#D4D4D4",
    base06 = "#D4D4D4",
    base07 = "#FFFFFF",
    base08 = "#F44747",
    base09 = "#CE9178",
    base0A = "#DCDCAA",
    base0B = "#6A9955",
    base0C = "#4EC9B0",
    base0D = "#569CD6",
    base0E = "#C586C0",
    base0F = "#D16969",
}

M.type = "dark"
vim.opt.bg = "dark"
if TRANSPARENT then
    M.transparency = true
end
M = require("base46").override_theme(M, "vscode_dark")
return M
