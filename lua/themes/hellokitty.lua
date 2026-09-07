-- ═══════════════════════════════════════════════════════════════
-- MITEMA — tema personalizado para NvChad (base46) - EDICIÓN HIPER KAWAI 🎀✨
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL (30 colores — controla toda la UI) ══════════
M.base_30 = {
    white = "#FFF0F8", -- Blanco algodón de azúcar puro y brillante
    darker_black = "#1E0A15", -- Paneles secundarios: Fresa oscurísimo casi negro
    black = "#290D1C", -- Fondo principal: Frambuesa/Ciruela profundo (Ultra femenino)
    black2 = "#3D1429", -- Línea de cursor: Rosa tinto oscuro
    one_bg = "#4A1832", -- Fondo de statusline: Magenta apagado
    one_bg2 = "#5C1E3E", -- Pestañas inactivas
    one_bg3 = "#6E244A", -- Bordes sutiles
    grey = "#995C7A", -- Comentarios: Rosa viejo/Polvo de rosas
    grey_fg = "#B37092", -- Texto secundario: Rosa metálico
    grey_fg2 = "#CC85A9", -- Variante de texto secundario
    light_grey = "#E69EC0", -- Números de línea inactivos en rosa chicle suave
    red = "#FF004D", -- Rojo cereza intenso (¡El moño de Hello Kitty perfecto!) 🎀
    baby_pink = "#FFB3D9", -- Rosa bebé pastel súper dulce para íconos
    pink = "#FF4D94", -- Rosa Barbie vibrante para acentos principales
    line = "#5C1E3E", -- Líneas divisorias en tono ciruela
    green = "#80FFB2", -- Menta pastel neón para strings (contrasta hermoso con el rosa)
    vibrant_green = "#33FF85", -- Verde hada saturado
    nord_blue = "#B3D1FF", -- Azul nube pastel
    blue = "#80BFFF", -- Azul cenicienta para funciones
    yellow = "#FFF280", -- Amarillo pollito/estrellita para warnings
    sun = "#FFEB3B", -- Amarillo sol brillante
    purple = "#D280FF", -- Lila mágico vibrante para keywords
    dark_purple = "#B34DFF", -- Púrpura uva
    teal = "#80FFEA", -- Cyan sirena pastel para clases
    orange = "#FF9966", -- Durazno/Coral fuerte para números
    cyan = "#80E5FF", -- Celeste hielo
    statusline_bg = "#1F0A15", -- Fondo de barra de estado súper contrastante
    lightbg = "#4A1832", -- Línea activa en menús
    pmenu_bg = "#FF4D94", -- Item seleccionado en menús: ¡Rosa Barbie neón!
    folder_bg = "#FFB3D9", -- Carpetas en Rosa bebé
}

-- ═══ COLORES DE TERMINAL INTEGRADA (:terminal, toggleterm) ════════
M.base_16 = {
    base00 = "#290D1C", -- Fondo de terminal (= black)
    base01 = "#3D1429", -- Fondo secundario (= black2)
    base02 = "#5C1E3E", -- Selección de texto (= line)
    base03 = "#995C7A", -- Comentarios / gris apagado (= grey)
    base04 = "#E69EC0", -- Texto oscuro secundario (= light_grey)
    base05 = "#FFF0F8", -- Texto por defecto (= white)
    base06 = "#FFF0F8", -- Texto claro
    base07 = "#FFFFFF", -- Texto más brillante (blanco puro)
    base08 = "#FF004D", -- Rojo moño (errores, variables)
    base09 = "#FF9966", -- Coral (números, constantes)
    base0A = "#FFF280", -- Amarillo estrellita (warnings, clases)
    base0B = "#80FFB2", -- Menta pastel (strings, éxito)
    base0C = "#80E5FF", -- Celeste hielo (soporte, regex)
    base0D = "#80BFFF", -- Azul cenicienta (funciones)
    base0E = "#D280FF", -- Lila vibrante (keywords)
    base0F = "#FF4D94", -- Rosa Barbie (deprecated, tags)
}

-- ═══ TIPO DE TEMA (obligatorio, sin esto no compila) ══════════════
M.type = "dark"

vim.opt.bg = "dark"

-- ═══ TRANSPARENCIA ═════════════════════════════════════════════════
if TRANSPARENT then
    M.transparency = true
end

M = require("base46").override_theme(M, "mitema")
return M
