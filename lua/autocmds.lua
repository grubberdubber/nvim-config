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

        -- Lo que ya tipeaste -> blanco del tema
        if colors.white then
            vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = colors.white })
        end

        -- Lo que falta completar de la palabra -> morado del tema
        if colors.purple then
            vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = colors.purple })
        end
    end,
})
