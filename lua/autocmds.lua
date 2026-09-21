require "nvchad.autocmds"
require "configs.sql_dialect_picker"

-- ── PARCHE DEFENSIVO: bug conocido de Treesitter (Neovim 0.12 + master) ──
-- github.com/nvim-treesitter/nvim-treesitter/issues/8618 y #8636
-- get_node_text() llama a node:range() sobre un nodo nil dentro de las
-- directivas de injection (#set! conceal_lines). Es un bug del núcleo
-- de Treesitter/nvim-treesitter, sin fix mergeado todavía. Envolvemos
-- la función exacta que falla en pcall, en su origen, para que el error
-- nunca se propague hasta el highlighter.
local orig_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
    local ok, result = pcall(orig_get_node_text, node, source, opts)
    if ok then
        return result
    end
    return ""
end

-- ── FIX PERMISOS MASON ───────────────────────────────────────────
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    desc = "Fix permisos Mason bin al arrancar",
    callback = function()
        if vim.fn.isdirectory(mason_bin) == 1 then
            vim.fn.system { "chmod", "-R", "+x", mason_bin }
        end
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolInstalled",
    desc = "Fix permisos tras instalar herramienta Mason",
    callback = function()
        if vim.fn.isdirectory(mason_bin) == 1 then
            vim.fn.system { "chmod", "-R", "+x", mason_bin }
        end
    end,
})

-- ── HIGHLIGHT ON YANK ────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Resalta brevemente el texto copiado con yank",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 }
    end,
})

-- ── RESTAURAR POSICIÓN AL ABRIR ARCHIVO ─────────────────────────
vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Restaura el cursor a la última posición conocida",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- ── QUITAR ESPACIOS AL FINAL AL GUARDAR ──────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Elimina trailing whitespace al guardar",
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd [[%s/\s\+$//e]]
        pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end,
})

-- ── NUMERACIÓN HÍBRIDA A PRUEBA DE FALLOS ────────────────────────
local numeracion_group = vim.api.nvim_create_augroup("NumeracionHibrida", { clear = true })

-- Al entrar en modo Insertar: Números Absolutos
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = numeracion_group,
    pattern = "*",
    callback = function()
        vim.opt_local.relativenumber = false
    end,
})

-- Al salir de modo Insertar o moverte por ventanas: Números Relativos
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "FocusGained" }, {
    group = numeracion_group,
    pattern = "*",
    callback = function()
        if vim.opt_local.number:get() then
            vim.opt_local.relativenumber = true
        end
    end,
})

-- ── INDENTACIÓN DE 2 ESPACIOS EXCLUSIVA PARA CSS / SCSS / LESS ───
vim.api.nvim_create_autocmd("FileType", {
    desc = "Forzar 2 espacios de indentación únicamente en hojas de estilo",
    pattern = { "css", "scss", "less" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.expandtab = true
    end,
})

-- ── COLORES DINÁMICOS PARA BLINK: toman blanco/morado real del tema activo ──
-- NvChad NO dispara el evento ColorScheme estándar (usa su propio sistema
-- interno de base46), por eso enganchamos a VimEnter en su lugar — mismo
-- patrón que ya usás para el fix de permisos de Mason más arriba. base46
-- ya terminó de compilar el tema mucho antes de que VimEnter dispare,
-- así que esto siempre corre a tiempo, antes de que blink.cmp cargue
-- (recién en el primer InsertEnter) y ponga sus propios colores por defecto.
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local ok, base46 = pcall(require, "base46")
        if not ok then
            return
        end
        local colors = base46.get_theme_tb "base_30"
        if not colors then
            return
        end

        -- Lo que ya tipeaste ("pri" de "print") -> azul/celeste fijo,
        -- estilo VS Code. Fijo a propósito: no depende del tema activo,
        -- porque los temas no definen este matiz de "coincidencia de
        -- autocompletado" por su cuenta.
        vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#2AAAFF", bold = true, force = true })

        -- Lo que falta completar de la palabra -> color normal del tema
        if colors.white then
            vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = colors.white, force = true })
        end
    end,
})

-- ── LÍNEA ACTUAL SUTIL (estilo VS Code) ───────────────────────────
-- Resalta la línea del cursor solo en modo Normal — en Insert desaparece
-- para no distraer mientras escribís. Mismo patrón que la numeración híbrida.
vim.opt.cursorline = true

local cursorline_group = vim.api.nvim_create_augroup("CursorlineNormalOnly", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "FocusGained" }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

-- ── AJUSTE DE CONTRASTE PARA CURSORLINE (el color del tema era invisible) ──
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local ok, base46 = pcall(require, "base46")
        if not ok then
            return
        end
        local colors = base46.get_theme_tb "base_30"
        if colors and colors.one_bg then
            -- one_bg es un tono apenas más claro que el fondo (black),
            -- perfecto para un cursorline sutil que sí se note.
            vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.black2 })
        end
    end,
})

-- ── FOLD COLUMN: siempre tenue (sin brillo al pasar el cursor) ────
-- Los puntos "..." de la línea plegada sí van en blanco, para
-- identificar rápido qué está compactado.
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local ok, base46 = pcall(require, "base46")
        if not ok then
            return
        end
        local colors = base46.get_theme_tb "base_30"
        if not colors then
            return
        end

        -- Triángulo del fold: siempre tenue, no cambia con el cursor
        if colors.grey then
            vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.grey })
            vim.api.nvim_set_hl(0, "CursorLineFold", { fg = colors.grey })
        end

        -- Los "..." de la línea plegada: blanco, bien visible
        if colors.white then
            vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { fg = colors.white, bold = true })
        end
    end,
})

-- ── AVANTE: bajada automática de modelo Gemini al agotar cuota ──────
-- Cascada: 3.1 Pro -> 3.7 Flash -> 3.6 Flash -> 3.5 Flash-Lite.
-- Al detectar un error de cuota/rate-limit, baja un escalón solo.
local avante_cascade = { "gemini", "gemini_flash38", "gemini_flash37", "gemini_flash36", "gemini_flash_lite" }
local avante_cascade_labels = {
    gemini = "Gemini 3.1 Pro",
    gemini_flash38 = "Gemini 3.8 Flash",
    gemini_flash37 = "Gemini 3.7 Flash",
    gemini_flash36 = "Gemini 3.6 Flash",
    gemini_flash_lite = "Gemini 3.5 Flash-Lite",
}
_G.AvanteCascadeIndex = 1

local orig_notify_avante = vim.notify
vim.notify = function(msg, level, opts)
    if
        type(msg) == "string"
        and (msg:find "rate.?limit" or msg:find "quota" or msg:find "429" or msg:find "RESOURCE_EXHAUSTED")
    then
        if _G.AvanteCascadeIndex < #avante_cascade then
            _G.AvanteCascadeIndex = _G.AvanteCascadeIndex + 1
            local next_provider = avante_cascade[_G.AvanteCascadeIndex]
            vim.schedule(function()
                pcall(vim.cmd, "AvanteSwitchProvider " .. next_provider)
                orig_notify_avante(
                    "Avante: cuota agotada, bajando a " .. avante_cascade_labels[next_provider],
                    vim.log.levels.WARN
                )
            end)
        else
            orig_notify_avante("Avante: todos los modelos de Gemini están sin cuota por ahora", vim.log.levels.ERROR)
        end
    end
    orig_notify_avante(msg, level, opts)
end

-- ── ENTER E INDENTACIÓN INTELIGENTE EN HTML/XML (estilo VS Code) ────────

local function smart_html_enter()
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1], cursor[2]
    local before = line:sub(1, col)
    local after = line:sub(col + 1)

    -- CASO 1: Split inicial entre <tag> y </tag>
    if before:match ">%s*$" and after:match "^%s*</" then
        local indent = line:match "^%s*"
        local sw = vim.fn.shiftwidth()
        local inner_indent = indent .. string.rep(" ", sw)

        local clean_before = before:gsub("%s+$", "")
        clean_after = after:gsub("^%s+", "")

        vim.api.nvim_set_current_line(clean_before)
        vim.api.nvim_buf_set_lines(0, row, row, false, { inner_indent, indent .. clean_after })
        vim.api.nvim_win_set_cursor(0, { row + 1, #inner_indent })
        return true
    end

    -- CASO 2: Múltiples Enter en líneas vacías
    if line:match "^%s*$" then
        vim.api.nvim_set_current_line(before)
        vim.api.nvim_buf_set_lines(0, row, row, false, { before })
        vim.api.nvim_win_set_cursor(0, { row + 1, #before })
        return true
    end

    -- CASO 3: Enter tras etiqueta de apertura suelta (ej. "<section>")
    if before:match "<[a-zA-Z0-9%-]+[^>]*>$" and not before:match "/>$" then
        local indent = line:match "^%s*"
        local sw = vim.fn.shiftwidth()
        local next_indent = indent .. string.rep(" ", sw)

        vim.api.nvim_set_current_line(before)
        vim.api.nvim_buf_set_lines(0, row, row, false, { next_indent .. after })
        vim.api.nvim_win_set_cursor(0, { row + 1, #next_indent })
        return true
    end

    return false
end

-- Backspace matemático por columna (estilo VS Code)
local function smart_html_bs()
    local col = vim.fn.col "." - 1 -- Columna actual (0-indexed)
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, col)

    -- Solo actúa si el cursor está posicionado sobre la sangría inicial
    if col > 0 and before:match "^%s+$" then
        local sw = vim.fn.shiftwidth()
        local target_col

        if col % sw == 0 then
            target_col = col - sw
        else
            target_col = math.floor(col / sw) * sw
        end
        if target_col < 0 then
            target_col = 0
        end

        local count = col - target_col
        return string.rep(vim.api.nvim_replace_termcodes("<BS>", true, true, true), count)
    end

    return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "xml" },
    callback = function(args)
        local buf = args.buf

        -- Anular el indenter nativo de Neovim para evitar retrocesos impares
        vim.bo[buf].indentexpr = ""
        vim.bo[buf].tabstop = 4
        vim.bo[buf].shiftwidth = 4
        vim.bo[buf].softtabstop = 4
        vim.bo[buf].expandtab = true

        -- Mapeo de Enter
        vim.keymap.set("i", "<CR>", function()
            if not smart_html_enter() then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", true)
            end
        end, { buffer = buf, desc = "Enter inteligente en HTML" })

        -- Mapeo de Backspace alineado a columnas (expr = true)
        vim.keymap.set("i", "<BS>", smart_html_bs, { expr = true, buffer = buf, desc = "Backspace en columna HTML" })
    end,
})
