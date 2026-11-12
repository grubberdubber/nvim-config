-- When a SQL file opens, ask which engine the buffer targets.
-- The choice is stored in vim.b.sql_dialect (per buffer) and controls:
--  1) the dialect sqlfluff uses for linting
--  2) which administrative keyword list is highlighted/completed
local dialect_options = {
    { label = "MySQL", sqlfluff = "mysql" },
    { label = "MariaDB", sqlfluff = "mysql" }, -- sqlfluff no distingue MariaDB de MySQL
    { label = "PostgreSQL", sqlfluff = "postgres" },
    { label = "SQLite3", sqlfluff = "sqlite" },
    { label = "MSSQL (SQL Server)", sqlfluff = "tsql" },
    { label = "H2", sqlfluff = "ansi" }, -- sqlfluff has no dedicated H2 dialect, use generic ANSI
    { label = "Vertica", sqlfluff = "vertica" },
}

local group = vim.api.nvim_create_augroup("SqlDialectPicker", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "sql", "mysql", "plsql" },
    callback = function(args)
        local bufnr = args.buf

        -- Prevent duplicate prompts: FileType can fire more than once
        -- for the same buffer at once (detection + LSP attach, etc.)
        -- That is why the guard is set NOW, synchronously, before scheduling
        -- the async menu; we do not wait for the user to finish choosing.
        if vim.b[bufnr].sql_dialect or vim.b[bufnr].sql_dialect_prompted then
            return
        end
        vim.b[bufnr].sql_dialect_prompted = true

        vim.schedule(function()
            vim.ui.select(dialect_options, {
                prompt = "Which database engine does this file target?",
                format_item = function(item)
                    return item.label
                end,
            }, function(choice)
                if not choice then
                    choice = dialect_options[1]
                end
                vim.b[bufnr].sql_dialect = choice.sqlfluff
                vim.b[bufnr].sql_dialect_label = choice.label
                vim.notify("SQL: trabajando en " .. choice.label, vim.log.levels.INFO)
                pcall(function()
                    require("configs.sql_admin_highlight").refresh(bufnr)
                end)

                pcall(function()
                    require("lint").try_lint()
                end)
            end)
        end)
    end,
})

return {}
