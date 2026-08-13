-- Al abrir un archivo SQL, pregunta con qué motor vas a trabajar.
-- La elección queda en vim.b.sql_dialect (por buffer) y controla:
--  1) el dialecto que usa sqlfluff para lint
--  2) qué lista de palabras administrativas se resalta/autocompleta
local dialect_options = {
    { label = "MySQL", sqlfluff = "mysql" },
    { label = "MariaDB", sqlfluff = "mysql" }, -- sqlfluff no distingue MariaDB de MySQL
    { label = "PostgreSQL", sqlfluff = "postgres" },
    { label = "SQLite3", sqlfluff = "sqlite" },
    { label = "MSSQL (SQL Server)", sqlfluff = "tsql" },
    { label = "H2", sqlfluff = "ansi" }, -- sqlfluff no tiene dialecto H2 dedicado, usa ANSI genérico
    { label = "Vertica", sqlfluff = "vertica" },
}

local group = vim.api.nvim_create_augroup("SqlDialectPicker", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "sql", "mysql", "plsql" },
    callback = function(args)
        local bufnr = args.buf

        -- Evita prompts duplicados: FileType puede dispararse varias veces
        -- para el mismo buffer en un instante (detección + adjunto de LSP, etc.)
        -- Por eso marcamos la guardia YA, de forma síncrona, antes de programar
        -- el menú asíncrono — no esperamos a que el usuario termine de elegir.
        if vim.b[bufnr].sql_dialect or vim.b[bufnr].sql_dialect_prompted then
            return
        end
        vim.b[bufnr].sql_dialect_prompted = true

        vim.schedule(function()
            vim.ui.select(dialect_options, {
                prompt = "¿Con qué motor de base de datos vas a trabajar en este archivo?",
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
