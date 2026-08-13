local keywords_by_dialect = require "configs.sql_admin_keywords"
local ns = vim.api.nvim_create_namespace "sql_admin_keywords"

local function highlight_admin_keywords(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    local dialect = vim.b[bufnr].sql_dialect or "mysql"
    local keywords = keywords_by_dialect[dialect] or keywords_by_dialect.mysql

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        local upper_line = line:upper()
        for _, kw in ipairs(keywords) do
            local pattern = "%f[%a]" .. kw:gsub(" ", "%%s+") .. "%f[%A]"
            local start_idx = 1
            while true do
                local s, e = upper_line:find(pattern, start_idx)
                if not s then
                    break
                end
                vim.api.nvim_buf_add_highlight(bufnr, ns, "@keyword", i - 1, s - 1, e)
                start_idx = e + 1
            end
        end
    end
end

local group = vim.api.nvim_create_augroup("SqlAdminHighlight", { clear = true })
vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "TextChangedI", "BufEnter" }, {
    group = group,
    pattern = { "sql", "mysql", "plsql" },
    callback = function(args)
        highlight_admin_keywords(args.buf)
    end,
})

return { refresh = highlight_admin_keywords }
