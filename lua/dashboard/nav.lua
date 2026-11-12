-- Dashboard navigation: row registry, movement, activation and the active-row
-- highlight. Search (/), n and N are intentionally left to Vim.
local M = {}

local ns = vim.api.nvim_create_namespace "dashboard_nav"
local rows = {}

function M.set_rows(list)
    rows = list or {}
end

function M.rows()
    return rows
end

function M.first_line()
    return rows[1] and rows[1].line or nil
end

--- Run the action attached to the current line, if any.
function M.activate()
    local line = vim.fn.line "."
    for _, row in ipairs(rows) do
        if row.line == line then
            local ok, err = pcall(row.action)
            if not ok then
                vim.notify("Dashboard action failed: " .. tostring(err), vim.log.levels.ERROR)
            end
            return true
        end
    end
    return false
end

--- Move the cursor to the next/previous interactive row (wrapping).
function M.move(direction)
    if #rows == 0 then
        return
    end

    local current = vim.fn.line "."
    local target

    if direction > 0 then
        for _, row in ipairs(rows) do
            if row.line > current then
                target = row.line
                break
            end
        end
        target = target or rows[1].line
    else
        for index = #rows, 1, -1 do
            if rows[index].line < current then
                target = rows[index].line
                break
            end
        end
        target = target or rows[#rows].line
    end

    pcall(vim.api.nvim_win_set_cursor, 0, { target, 0 })
end

--- Highlight the row under the cursor so the selection is unambiguous.
function M.highlight()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    local line = vim.fn.line "." - 1
    if vim.bo[buf].filetype ~= "dashboard" then
        return
    end

    pcall(vim.api.nvim_buf_set_extmark, buf, ns, line, 0, {
        end_row = line + 1,
        hl_eol = true,
        hl_group = "DashRow",
        priority = 10,
    })
end

function M.clear()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
end

--- Row metadata for the current line (used by pin toggle/remove).
function M.current_info()
    local line = vim.fn.line "."
    for _, row in ipairs(rows) do
        if row.line == line then
            return row.info or {}
        end
    end
    return {}
end

--- Nearest pin row, so x/D work even when the cursor is not exactly on one.
function M.find_pin_info()
    local info = M.current_info()
    if info.type == "pin" then
        return info
    end
    for _, row in ipairs(rows) do
        if row.info and row.info.type == "pin" then
            return row.info
        end
    end
    return nil
end

return M
