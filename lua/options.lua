-- ── DESACTIVAR ENRUTAMIENTO DE TECLAS DE CODEIUM ANTES DE QUE CARGUE ──
vim.g.codeium_disable_bindings = 1

require "nvchad.options"

local o = vim.o
local opt = vim.opt
vim.g.editorconfig = false

-- ── NÚMEROS DE LÍNEA Y CONFIGURACIÓN VISUAL ─────────────────────
o.number = true
o.relativenumber = false
o.cursorline = true
o.cursorlineopt = "both"

-- Centralización de estilos (Corrección de colores y máxima legibilidad)
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        -- UI Base
        vim.api.nvim_set_hl(0, "Comment", { fg = "#6272a4", italic = true, bold = false })
        vim.api.nvim_set_hl(0, "Whitespace", { fg = "#4b5263" })
        vim.api.nvim_set_hl(0, "NonText", { fg = "#4b5263" })

        -- Paleta clara, vibrante y súper legible para Diagnósticos (Sin grises opacos)
        local err_color = "#ff7a93" -- Rojo salmón claro y brillante
        local warn_color = "#ffc27d" -- Amarillo/dorado cálido nítido
        local info_color = "#78dce8" -- Cyan luminoso
        local hint_color = "#a9b1d6" -- Gris azulado claro visible

        -- Corrección de texto flotante y virtual (Sin fondos sólidos que tapen código)
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = err_color, bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = warn_color, bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = info_color, bg = "NONE" })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = hint_color, bg = "NONE" })

        -- Subrayado ondulado fino con los nuevos colores vivos
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = err_color })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = warn_color })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = info_color })
        vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = hint_color })

        -- Errores puros de sintaxis de Treesitter
        vim.api.nvim_set_hl(0, "Error", { fg = err_color, bg = "NONE", bold = true })
    end,
})
-- Forzar la ejecución de los colores corregidos inmediatamente
vim.cmd "doautocmd ColorScheme"

-- ── INDENTACIÓN ──────────────────────────────────────────────────
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

opt.list = true
opt.listchars = {
    lead = "·",
    tab = "  ",
    trail = "·",
    nbsp = "␣",
}

-- ── DIAGNÓSTICOS (Íconos limpios) ────────────────────────────────
vim.diagnostic.config {
    virtual_text = { prefix = "● ", spacing = 4 },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded" },
}

-- ── AUTO-LIMPIEZA Y ASESINO DE CRLF / ESPACIOS FANTASMAS ─────────
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = "*",
    desc = "Purga de espacios invisibles y fijación de formato Unix",
    callback = function()
        vim.bo.fileformat = "unix"
        vim.cmd [[%s/\%u00a0/ /ge]]
    end,
})

-- ── UI Y MISCELÁNEOS ─────────────────────────────────────────────
o.ignorecase = true
o.smartcase = true
o.scrolloff = 8
o.signcolumn = "yes:1"
o.updatetime = 250
o.timeoutlen = 400
o.splitbelow = true
o.splitright = true
opt.clipboard = ""
o.undofile = true
opt.fileformats = { "unix", "dos" }
opt.cmdheight = 1 -- Evita que la barra tape el código generando un pequeño margen
