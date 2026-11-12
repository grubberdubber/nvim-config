-- ═══════════════════════════════════════════════════════════════
-- MY THEME — custom NvChad (base46) theme: NEON HACKER edition 👾📟
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── TRANSPARENCY SWITCH ──────────────────────────────────────────
-- With a transparent terminal background this theme
-- blends beautifully with dark backgrounds.
local TRANSPARENT = true

-- ═══ MAIN PALETTE (30 colors, controls the whole UI) ═════════════
M.base_30 = {
    white = "#E0FFDE", -- White with a faint phosphor-green tint to avoid eye strain
    darker_black = "#000000", -- Negro puro (Vantablack) para paneles como NvimTree
    black = "#030604", -- Fondo principal: Negro abisal con un micro-toque de verde Matrix
    black2 = "#08120B", -- Subtle cursor line
    one_bg = "#0D1D12", -- Fondo de statusline (Gris/Verde muy oscuro)
    one_bg2 = "#122A1A", -- Inactive tabs
    one_bg3 = "#1A3823", -- Bordes
    grey = "#006622", -- Comments: old-terminal dark green (dim phosphor)
    grey_fg = "#00882D", -- Texto secundario
    grey_fg2 = "#00AA38", -- Variante texto secundario
    light_grey = "#00CC44", -- Inactive line numbers
    red = "#FF003C", -- Alert laser red (critical errors/exploits)
    baby_pink = "#FF00FF", -- Pure neon magenta
    pink = "#D900FF", -- Cyber fuchsia
    line = "#122A1A", -- Separator lines
    green = "#00FF41", -- Classic Matrix green for strings and injected text
    vibrant_green = "#00FF00", -- Verde puro RGB
    nord_blue = "#00B8FF", -- Azul Tron
    blue = "#00F0FF", -- Bright neon cyan for functions and calls
    yellow = "#F3E600", -- Amarillo radiactivo para warnings
    sun = "#FFFF00", -- Amarillo puro
    purple = "#9D00FF", -- Dark neon purple for control keywords
    dark_purple = "#6B00FF", -- Indigo variant
    teal = "#00FFEA", -- Laser aqua for classes and types
    orange = "#FF7300", -- Plasma orange for numbers and booleans
    cyan = "#00FFFF", -- Cian puro
    statusline_bg = "#000000", -- Statusline in absolute black for maximum contrast
    lightbg = "#0D1D12", -- Fondo de elementos destacados
    pmenu_bg = "#00FF41", -- Selected popup item (bright Matrix green)
    folder_bg = "#00F0FF", -- Folders in NvimTree, neon cyan
}

-- ═══ COLORES DE TERMINAL INTEGRADA (:terminal, toggleterm) ════════
M.base_16 = {
    base00 = "#030604", -- Fondo de terminal (= black)
    base01 = "#08120B", -- Fondo secundario (= black2)
    base02 = "#122A1A", -- Visual selection (= line)
    base03 = "#006622", -- Comentarios / gris apagado (= grey)
    base04 = "#00CC44", -- Texto oscuro secundario (= light_grey)
    base05 = "#E0FFDE", -- Texto por defecto (= white)
    base06 = "#E0FFDE", -- Texto claro
    base07 = "#FFFFFF", -- Brightest text (pure white)
    base08 = "#FF003C", -- Laser red (errors, variables)
    base09 = "#FF7300", -- Plasma orange (numbers, constants)
    base0A = "#F3E600", -- Amarillo radiactivo (warnings, clases)
    base0B = "#00FF41", -- Matrix green (strings, success)
    base0C = "#00FFFF", -- Cian puro (soporte, regex)
    base0D = "#00F0FF", -- Neon cyan (functions)
    base0E = "#9D00FF", -- Neon purple (keywords)
    base0F = "#FF00FF", -- Neon magenta (deprecated, tags)
}

-- ═══ THEME TYPE (required; the theme will not compile without it) ═
M.type = "dark"

vim.opt.bg = "dark"

-- ═══ TRANSPARENCIA ═════════════════════════════════════════════════
if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "mitema")
return M
