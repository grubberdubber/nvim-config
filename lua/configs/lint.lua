local lint = require "lint"

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  LINTING SQL — sqlfluff (dialecto MySQL)                     ║
-- ╚══════════════════════════════════════════════════════════════╝
lint.linters_by_ft = {
    sql = { "sqlfluff" },
    mysql = { "sqlfluff" },
}

lint.linters.sqlfluff.args = {
    "lint",
    "--dialect",
    "mysql",
    "--format",
    "json",
    "-",
}

-- ── FALSOS POSITIVOS CONOCIDOS DE SQLFLUFF ────────────────────────
-- sqlfluff no cubre la gramática completa de los comandos administrativos
-- de MySQL y los reporta como error de parseo (PRS / "Found unparsable
-- section") aunque la sintaxis sea 100% válida. Es una limitación
-- documentada del proyecto (ver issues #1628, #3944, #4885, #5603 en
-- github.com/sqlfluff/sqlfluff), no un bug de esta config.
--
-- Filtramos SOLO estos statements administrativos puntuales.
-- Cualquier otro error real (SELECT/INSERT/UPDATE/DELETE/DDL mal escrito)
-- sigue detectándose sin cambios.
local admin_keywords = {
    -- Utility statements
    "SHOW",
    "DESCRIBE",
    "DESC",
    "USE",
    "EXPLAIN",
    "HELP",

    -- Table maintenance statements
    "ANALYZE TABLE",
    "CHECK TABLE",
    "CHECKSUM TABLE",
    "OPTIMIZE TABLE",
    "REPAIR TABLE",

    -- Account management statements
    "CREATE USER",
    "DROP USER",
    "ALTER USER",
    "RENAME USER",
    "CREATE ROLE",
    "DROP ROLE",
    "GRANT",
    "REVOKE",
    "SET PASSWORD",
    "SET ROLE",
    "SET DEFAULT ROLE",

    -- Otros statements administrativos
    "FLUSH",
    "RESET",
    "KILL",
    "SHUTDOWN",
    "RESTART",
    "BINLOG",
    "CACHE INDEX",
    "LOAD INDEX INTO CACHE",
    "PURGE BINARY LOGS",
    "LOCK TABLES",
    "UNLOCK TABLES",

    -- Plugins y componentes
    "INSTALL PLUGIN",
    "UNINSTALL PLUGIN",
    "INSTALL COMPONENT",
    "UNINSTALL COMPONENT",
}

-- Envuelve el parser JSON que ya trae nvim-lint para sqlfluff.
-- No lo reemplaza: solo descarta las violaciones PRS que matchean
-- con un statement administrativo conocido.
local original_parser = lint.linters.sqlfluff.parser

lint.linters.sqlfluff.parser = function(output, bufnr, cmd)
    local diagnostics = original_parser(output, bufnr, cmd)
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

-- ── AUTOCMD: cuándo se dispara el lint ────────────────────────────
local lint_group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = lint_group,
    callback = function()
        lint.try_lint()
    end,
})
