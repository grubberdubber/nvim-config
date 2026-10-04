local keywords_by_dialect = require "configs.sql_admin_keywords"

local source = {}
source.__index = source

function source.new()
    return setmetatable({}, source)
end

function source:get_completions(_, callback)
    local dialect = vim.b.sql_dialect or "mysql"
    local keywords = keywords_by_dialect[dialect] or keywords_by_dialect.mysql

    local items = {}
    for i, kw in ipairs(keywords) do
        table.insert(items, {
            label = kw,
            kind = require("blink.cmp.types").CompletionItemKind.Keyword,
            insertText = kw,
            sortText = string.format("%04d", i),
        })
    end
    callback { items = items, is_incomplete_forward = false, is_incomplete_backward = false }
end

return source
