---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "eldritch", -- Cambia automáticamente con tu selector de temas
    hl_override = {
        WinBar = { bg = "NONE" },
        WinBarNC = { bg = "NONE" },
        StatusLine = { bg = "NONE" },
        StatusLineNC = { bg = "NONE" },

        -- ── MEJORA DE CONTRASTE PARA TEXTO VIRTUAL DEL LSP ──
        -- Errores en rojo salmón suave y brillante (muy legible)
        DiagnosticVirtualTextError = { fg = "#ff7a93", bg = "NONE", italic = true },
        -- Warnings en amarillo/dorado cálido claro
        DiagnosticVirtualTextWarn = { fg = "#ffc27d", bg = "NONE", italic = true },
        -- Info y Hints en tonos celestes y grises claros visibles
        DiagnosticVirtualTextInfo = { fg = "#78dce8", bg = "NONE", italic = true },
        DiagnosticVirtualTextHint = { fg = "#a9b1d6", bg = "NONE", italic = true },
    },
}

M.ui = {
    statusline = {
        theme = "minimal",
        order = { "mode", "file_and_path", "align", "git", "diagnostics", "file_info" },
        modules = {
            -- 1. MODO (Automático con tu tema)
            mode = function()
                local m = vim.api.nvim_get_mode().mode
                local modes = {
                    n = "NORMAL",
                    i = "INSERT",
                    v = "VISUAL",
                    V = "V-LINE",
                    ["\22"] = "V-BLOCK",
                    c = "COMMAND",
                    R = "REPLACE",
                    t = "TERMINAL",
                }
                local hl = {
                    n = "St_NormalMode",
                    i = "St_InsertMode",
                    v = "St_VisualMode",
                    V = "St_VisualMode",
                    ["\22"] = "St_VisualMode",
                    c = "St_CommandMode",
                    R = "St_ReplaceMode",
                    t = "St_InsertMode",
                }
                return "%#" .. (hl[m] or "St_NormalMode") .. "# 󰕮 " .. (modes[m] or string.upper(m)) .. " "
            end,

            -- 2. ICONO + ARCHIVO (Limpio y protegido)
            file_and_path = function()
                local fn = vim.fn.expand "%:t"
                local bt = vim.bo.buftype

                -- Cortafuegos para paneles especiales (Lazy, Mason, Terminal)
                if bt == "nofile" or bt == "terminal" or bt == "prompt" or vim.bo.filetype == "lazy" then
                    local ft = vim.bo.filetype
                    return " %#St_file_txt# 󰈚 " .. (ft ~= "" and string.upper(ft) or "PANEL") .. " "
                end

                if fn == "" then
                    return ""
                end
                local ok, devicons = pcall(require, "nvim-web-devicons")
                local icon = ok and devicons.get_icon(fn, vim.fn.expand "%:e", { default = true }) or "󰈚"
                local mod = vim.bo.modified and " 󰏫" or ""
                return " %#St_file_txt# " .. icon .. " " .. fn .. mod .. " "
            end,

            -- 3. ALINEADOR
            align = function()
                return "%="
            end,

            -- 4. GIT (Tus configuraciones e íconos originales restaurados)
            git = function()
                if vim.bo.buftype ~= "" or vim.bo.filetype == "lazy" then
                    return ""
                end
                if not vim.b.gitsigns_head or vim.b.gitsigns_head == "" then
                    return ""
                end

                local branch = "%#St_gitIcons# " .. vim.b.gitsigns_head
                local status = vim.b.gitsigns_status_dict or {}
                local added = (status.added and status.added > 0) and (" %#St_lspInfo#+" .. status.added) or ""
                local changed = (status.changed and status.changed > 0) and (" %#St_lspWarning#~" .. status.changed)
                    or ""
                local removed = (status.removed and status.removed > 0) and (" %#St_lspError#-" .. status.removed) or ""

                return " " .. branch .. added .. changed .. removed .. " %#St_file_txt#│ "
            end,

            -- 5. DIAGNÓSTICOS (Se restauraron Error, Warn, Info y Hints con sus ondas/colores)
            diagnostics = function()
                if vim.bo.buftype ~= "" or vim.bo.filetype == "lazy" then
                    return ""
                end

                local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
                local hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
                local str = ""

                if err > 0 then
                    str = str .. "%#DiagnosticError# " .. err .. " "
                end
                if warn > 0 then
                    str = str .. "%#DiagnosticWarn# " .. warn .. " "
                end
                if info > 0 then
                    str = str .. "%#DiagnosticInfo# " .. info .. " "
                end
                if hint > 0 then
                    str = str .. "%#DiagnosticHint#󰛨 " .. hint .. " "
                end

                return str
            end,

            -- 6. INFO DE ARCHIVO Y PROYECTO (Estadísticas abajo a la derecha)
            file_info = function()
                if vim.bo.buftype ~= "" or vim.bo.filetype == "lazy" then
                    return ""
                end

                local line = vim.fn.line "."
                local total_lines = vim.fn.line "$"
                local percentage = math.floor((line / total_lines) * 100)
                local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                return "%#St_pos_txt# "
                    .. percentage
                    .. "%% 󰉋 "
                    .. root
                    .. "  "
                    .. line
                    .. "/"
                    .. total_lines
                    .. " "
            end,
        },
    },
}

-- 7. WINBAR SUPERIOR (Espacio máximo para la estructura de carpetas)
_G.WinBarDraw = function()
    if vim.bo.buftype ~= "" or vim.bo.filetype == "lazy" then
        return ""
    end

    local m = vim.api.nvim_get_mode().mode
    local modes = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        ["\22"] = "V-BLOCK",
        c = "COMMAND",
        R = "REPLACE",
        t = "TERMINAL",
    }
    local hl = {
        n = "St_NormalMode",
        i = "St_InsertMode",
        v = "St_VisualMode",
        V = "St_VisualMode",
        ["\22"] = "St_VisualMode",
        c = "St_CommandMode",
        R = "St_ReplaceMode",
        t = "St_InsertMode",
    }

    local left = "%#" .. (hl[m] or "St_NormalMode") .. "# 󰕮 " .. (modes[m] or string.upper(m)) .. " "

    -- Lógica para generar: Carpeta1  Carpeta2  Carpeta3
    local path = vim.fn.expand "%:~:h"
    local formatted_path = ""
    if path ~= "~" and path ~= "" and path ~= "." then
        path = path:gsub("^~/", "")
        formatted_path = "%#St_lspTxt# " .. path:gsub("/", "  ") .. "  "
    else
        formatted_path = " "
    end

    local fn = vim.fn.expand "%:t"
    local ok, devicons = pcall(require, "nvim-web-devicons")
    local icon = ok and devicons.get_icon(fn, vim.fn.expand "%:e", { default = true }) or "󰈚"
    local mod = vim.bo.modified and " 󰏫" or ""

    -- Al poner el alineador '%=' después de la ruta, esta toma todo el espacio central libre de la pantalla
    local center = "%#St_file_txt# " .. icon .. " " .. formatted_path .. fn .. mod .. " "
    local right = "%#St_file_txt#| " .. vim.bo.filetype .. " | " .. vim.bo.fileformat:upper() .. " | "

    return left .. center .. "%=" .. right
end

vim.opt.winbar = "%{%v:lua.WinBarDraw()%}"

return M
