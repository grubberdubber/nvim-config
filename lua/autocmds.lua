require "nvchad.autocmds"

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
