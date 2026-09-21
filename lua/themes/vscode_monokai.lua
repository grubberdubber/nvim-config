local M = {}
local TRANSPARENT = false

M.base_30 = {
    white = "#F8F8F2", -- Texto general
    darker_black = "#1E1F1C",
    black = "#272822", -- Fondo clásico Monokai
    black2 = "#3E3D32",
    one_bg = "#49483E",
    one_bg2 = "#49483E",
    one_bg3 = "#75715E",
    grey = "#49483E",
    grey_fg = "#75715E", -- Comentarios
    grey_fg2 = "#75715E",
    light_grey = "#90908A",
    red = "#F92672", -- Keywords, borrar
    baby_pink = "#F92672",
    pink = "#F92672",
    line = "#3E3D32",
    green = "#A6E22E", -- Strings y clases
    vibrant_green = "#A6E22E",
    nord_blue = "#66D9EF",
    blue = "#66D9EF", -- Tipos, funciones nativas
    yellow = "#E6DB74", -- Strings
    sun = "#E6DB74",
    purple = "#AE81FF", -- Números y constantes
    dark_purple = "#AE81FF",
    teal = "#66D9EF",
    orange = "#FD971F", -- Parámetros
    cyan = "#66D9EF",
    statusline_bg = "#1E1F1C",
    lightbg = "#3E3D32",
    pmenu_bg = "#3E3D32",
    folder_bg = "#E6DB74",
}

M.base_16 = {
    base00 = "#272822",
    base01 = "#3E3D32",
    base02 = "#49483E",
    base03 = "#75715E",
    base04 = "#90908A",
    base05 = "#F8F8F2",
    base06 = "#F8F8F0",
    base07 = "#F9F8F5",
    base08 = "#F92672",
    base09 = "#FD971F",
    base0A = "#E6DB74",
    base0B = "#A6E22E",
    base0C = "#66D9EF",
    base0D = "#66D9EF",
    base0E = "#AE81FF",
    base0F = "#F92672",
}

M.type = "dark"
vim.opt.bg = "dark"
if TRANSPARENT then
    M.transparency = true
end
M = require("base46").override_theme(M, "vscode_monokai")
return M
