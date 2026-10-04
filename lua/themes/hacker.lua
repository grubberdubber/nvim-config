-- ═══════════════════════════════════════════════════════════════
-- MITEMA — tema personalizado para NvChad (base46) - EDICIÓN HACKER NEÓN 👾📟
-- ═══════════════════════════════════════════════════════════════

local M = {}

-- ── INTERRUPTOR DE TRANSPARENCIA ──────────────────────────────────
-- Si usas transparencia en tu emulador de terminal, este tema se
-- fusionará increíblemente bien con fondos oscuros.
local TRANSPARENT = true

-- ═══ PALETA PRINCIPAL (30 colores — controla toda la UI) ══════════
M.base_30 = {
    white = "#E0FFDE", -- Blanco con un ligero tinte verde fósforo para no cansar la vista
    darker_black = "#000000", -- Negro puro (Vantablack) para paneles como NvimTree
    black = "#030604", -- Fondo principal: Negro abisal con un micro-toque de verde Matrix
    black2 = "#08120B", -- Línea de cursor sutil
    one_bg = "#0D1D12", -- Fondo de statusline (Gris/Verde muy oscuro)
    one_bg2 = "#122A1A", -- Pestañas inactivas
    one_bg3 = "#1A3823", -- Bordes
    grey = "#006622", -- Comentarios: Verde oscuro terminal antiguo (estilo fósforo apagado)
    grey_fg = "#00882D", -- Texto secundario
    grey_fg2 = "#00AA38", -- Variante texto secundario
    light_grey = "#00CC44", -- Números de línea inactivos
    red = "#FF003C", -- Rojo láser de alerta (Errores críticos/Exploits)
    baby_pink = "#FF00FF", -- Magenta neón puro
    pink = "#D900FF", -- Fucsia cibernético
    line = "#122A1A", -- Líneas divisorias
    green = "#00FF41", -- Verde Matrix clásico para strings y texto inyectado
    vibrant_green = "#00FF00", -- Verde puro RGB
    nord_blue = "#00B8FF", -- Azul Tron
    blue = "#00F0FF", -- Cian neón brillante para funciones y llamadas
    yellow = "#F3E600", -- Amarillo radiactivo para warnings
    sun = "#FFFF00", -- Amarillo puro
    purple = "#9D00FF", -- Púrpura oscuro neón para keywords de control
    dark_purple = "#6B00FF", -- Variante índigo
    teal = "#00FFEA", -- Aqua láser para clases y tipos
    orange = "#FF7300", -- Naranja plasma para números y booleanos
    cyan = "#00FFFF", -- Cian puro
    statusline_bg = "#000000", -- Barra de estado en negro absoluto para máximo contraste
    lightbg = "#0D1D12", -- Fondo de elementos destacados
    pmenu_bg = "#00FF41", -- Item seleccionado en menús popup (¡Verde Matrix brillante!)
    folder_bg = "#00F0FF", -- Carpetas en NvimTree color Cian Neón
}

-- ═══ COLORES DE TERMINAL INTEGRADA (:terminal, toggleterm) ════════
M.base_16 = {
    base00 = "#030604", -- Fondo de terminal (= black)
    base01 = "#08120B", -- Fondo secundario (= black2)
    base02 = "#122A1A", -- Selección de texto (= line)
    base03 = "#006622", -- Comentarios / gris apagado (= grey)
    base04 = "#00CC44", -- Texto oscuro secundario (= light_grey)
    base05 = "#E0FFDE", -- Texto por defecto (= white)
    base06 = "#E0FFDE", -- Texto claro
    base07 = "#FFFFFF", -- Texto más brillante (blanco puro)
    base08 = "#FF003C", -- Rojo láser (errores, variables)
    base09 = "#FF7300", -- Naranja plasma (números, constantes)
    base0A = "#F3E600", -- Amarillo radiactivo (warnings, clases)
    base0B = "#00FF41", -- Verde Matrix (strings, éxito)
    base0C = "#00FFFF", -- Cian puro (soporte, regex)
    base0D = "#00F0FF", -- Cian neón (funciones)
    base0E = "#9D00FF", -- Púrpura neón (keywords)
    base0F = "#FF00FF", -- Magenta neón (deprecated, tags)
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
