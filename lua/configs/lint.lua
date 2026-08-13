local lint = require "lint"

lint.linters_by_ft = {
    sql = { "sqlfluff" },
    mysql = { "sqlfluff" },
    css = { "stylelint" },
    scss = { "stylelint" },
    less = { "stylelint" },
    vue = { "stylelint" },
}

-- ── SINCRONIZACIÓN DE ARGUMENTOS (SQLFLUFF) ───────────────────────
local function sync_sqlfluff_dialect()
    local dialect = vim.b.sql_dialect or "mysql"
    lint.linters.sqlfluff.args = { "lint", "--dialect", dialect, "--format", "json", "-" }
end

-- ── SINCRONIZACIÓN DE ARGUMENTOS GLOBAL PROFESIONAL (STYLELINT) ───
local function sync_stylelint()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        return
    end

    local nvim_dir = vim.fn.stdpath "config"

    lint.linters.stylelint.args = {
        "-f",
        "json",
        "--config",
        nvim_dir .. "/.stylelintrc.json",
        "--config-basedir",
        nvim_dir,
        "--stdin",
        "--stdin-filename",
        filepath,
    }
end

-- ── FALSOS POSITIVOS CONOCIDOS DE SQLFLUFF (comandos administrativos) ──
local keywords_by_dialect = require "configs.sql_admin_keywords"

local original_parser = lint.linters.sqlfluff.parser
lint.linters.sqlfluff.parser = function(output, bufnr, cmd)
    local diagnostics = original_parser(output, bufnr, cmd)
    local dialect = vim.b[bufnr].sql_dialect or "mysql"
    local admin_keywords = keywords_by_dialect[dialect] or keywords_by_dialect.mysql

    local filtered = {}
    for _, diag in ipairs(diagnostics) do
        local msg = (diag.message or ""):upper()
        local is_admin_false_positive = false
        if msg:find("FOUND UNPARSABLE SECTION", 1, true) then
            for _, kw in ipairs(admin_keywords) do
                if msg:find("'" .. kw, 1, true) then
                    is_admin_false_positive = true
                    break
                end
            end
        end
        if not is_admin_false_positive then
            table.insert(filtered, diag)
        end
    end
    return filtered
end

-- ── EJECUCIÓN CENTRALIZADA ────────────────────────────────────────
local function lint_sql_aware()
    sync_sqlfluff_dialect()
    sync_stylelint()
    lint.try_lint()
end

local lint_group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = lint_group,
    callback = lint_sql_aware,
})

return { lint_sql = lint_sql_aware }
