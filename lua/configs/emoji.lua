-- ── MARKDOWN EMOJI AUTOCONVERT ────────────────────────────────────
-- blink-emoji inserts an emoji only when the completion menu is accepted.
-- This module converts a completed :shortcode: as soon as it is typed, using
-- the same emoji table so both paths stay consistent.
local M = {}

local shortcode_map
local converting = false

local function load_map()
    if shortcode_map then
        return shortcode_map
    end

    shortcode_map = {}
    local ok, emojis = pcall(require, "blink-emoji.emojis")
    if not ok then
        return shortcode_map
    end

    for _, item in ipairs(emojis.get()) do
        local shortcode = item.textEdit and item.textEdit.newText
        if shortcode and item.insertText then
            shortcode_map[shortcode] = item.insertText
        end
    end
    return shortcode_map
end

local function convert_current_line()
    if converting or vim.bo.filetype ~= "markdown" then
        return
    end

    local map = load_map()
    if next(map) == nil then
        return
    end

    local line = vim.api.nvim_get_current_line()
    local matches = {}
    local init = 1
    while true do
        local start_col, end_col = line:find(":[%w_+%-]+:", init)
        if not start_col then
            break
        end

        local shortcode = line:sub(start_col, end_col)
        local emoji = map[shortcode]
        if emoji then
            table.insert(matches, { start_col = start_col, end_col = end_col, emoji = emoji })
        end
        init = end_col + 1
    end

    if #matches == 0 then
        return
    end

    converting = true
    local row = vim.fn.line "."
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_col = cursor[2]
    local buf = vim.api.nvim_get_current_buf()

    -- Replace right-to-left so earlier byte offsets stay valid.
    for i = #matches, 1, -1 do
        local match = matches[i]
        local delta = #match.emoji - (match.end_col - match.start_col + 1)
        if match.end_col <= cursor_col then
            cursor_col = cursor_col + delta
        end
        vim.api.nvim_buf_set_text(buf, row - 1, match.start_col - 1, row - 1, match.end_col, { match.emoji })
    end

    cursor_col = math.max(0, cursor_col)
    pcall(vim.api.nvim_win_set_cursor, 0, { row, cursor_col })
    converting = false
end

function M.setup()
    vim.api.nvim_create_autocmd({ "TextChangedI", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("MarkdownEmojiAutoconvert", { clear = true }),
        callback = function()
            vim.schedule(function()
                local ok = pcall(convert_current_line)
                if not ok then
                    converting = false
                end
            end)
        end,
    })
end

return M
