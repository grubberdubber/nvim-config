---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "gruvbox",
}

M.ui = {
    statusline = {
        theme = "minimal",
        order = {
            "mode",
            "file_and_path",
            "align",
            "cursor_pos",
            "file_info",
            "git",
            "diagnostics",
        },
        modules = {
            -- 1. MODO
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
                local mode_hl = {
                    n = "St_NormalMode",
                    i = "St_InsertMode",
                    v = "St_VisualMode",
                    V = "St_VisualMode",
                    ["\22"] = "St_VisualMode",
                    c = "St_CommandMode",
                    R = "St_ReplaceMode",
                    t = "St_TerminalMode",
                }
                return "%#" .. (mode_hl[m] or "St_NormalMode") .. "#  " .. (modes[m] or m) .. "  "
            end,

            -- 2. ICONO + ARCHIVO + RUTA COMPLETA
            file_and_path = function()
                local fn = vim.fn.expand "%:t"
                local bt = vim.bo.buftype

                -- Evita que paneles como Lazy o Mason rompan la barra
                if bt == "nofile" or bt == "terminal" or bt == "prompt" then
                    local ft = vim.bo.filetype
                    return " %#St_file_txt# 󰈚 " .. (ft ~= "" and string.upper(ft) or "PANEL") .. " "
                end

                if fn == "" then
                    return ""
                end

                -- Obtener el logo específico del lenguaje
                local ok, devicons = pcall(require, "nvim-web-devicons")
                local icon = "󰈚"
                if ok then
                    icon = devicons.get_icon(fn, vim.fn.expand "%:e", { default = true }) or icon
                end

                -- Ruta relativa siempre desde el HOME (~), obligando a mostrar carpetas anteriores
                local path = vim.fn.expand "%:~:h"
                local formatted_path = ""

                if path ~= "~" and path ~= "" and path ~= "." then
                    -- Quita el "~/" inicial y reemplaza las barras por los separadores angulares
                    path = path:gsub("^~/", "")
                    formatted_path = "  %#St_lspTxt#" .. path:gsub("/", "  ") .. "  "
                else
                    formatted_path = "  "
                end

                local mod = vim.bo.modified and " 󰏫" or ""
                return " %#St_file_txt#" .. icon .. " " .. fn .. mod .. formatted_path
            end,

            -- 3. CENTRADOR
            align = function()
                return "%="
            end,

            -- 4. POSICIÓN (Oculto en paneles de plugins)
            cursor_pos = function()
                if vim.bo.buftype ~= "" then
                    return ""
                end

                local line = vim.fn.line "."
                local col = vim.fn.col "."
                local total_lines = vim.fn.line "$"
                local percentage = math.floor((line / total_lines) * 100)
                return "%#St_pos_txt#  " .. line .. ":" .. col .. "   " .. percentage .. "%% │ "
            end,

            -- 5. INFO ARCHIVO (Oculto en paneles de plugins)
            file_info = function()
                if vim.bo.buftype ~= "" then
                    return ""
                end

                local ft = vim.bo.filetype
                if ft == "" then
                    ft = "none"
                end
                local enc = (vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc):lower()
                local fmt = vim.bo.fileformat == "unix" and "LF" or "CRLF"
                return "%#St_ft# ≡ " .. ft .. "   " .. enc .. "   " .. fmt .. "   %#St_file_txt#● unix │ "
            end,

            -- 6. GIT (Unificación de colores)
            git = function()
                if vim.bo.buftype ~= "" then
                    return ""
                end
                if not vim.b.gitsigns_head or vim.b.gitsigns_head == "" then
                    return ""
                end

                -- Aquí se unifica el color del ícono y el texto de la rama (St_gitIcons)
                local branch = "%#St_gitIcons# " .. vim.b.gitsigns_head

                local status = vim.b.gitsigns_status_dict or {}
                local added = (status.added and status.added > 0) and (" %#St_lspInfo#+" .. status.added) or ""
                local changed = (status.changed and status.changed > 0) and (" %#St_lspWarning#~" .. status.changed)
                    or ""
                local removed = (status.removed and status.removed > 0) and (" %#St_lspError#-" .. status.removed) or ""

                return branch .. added .. changed .. removed .. " %#St_file_txt#│ "
            end,

            -- 7. DIAGNÓSTICOS
            diagnostics = function()
                if vim.bo.buftype ~= "" then
                    return ""
                end

                local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
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

                return str
            end,
        },
    },
}

return M
