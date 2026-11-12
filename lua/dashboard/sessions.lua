-- Dashboard session manager: one layout per project + git branch, saved with
-- :mksession (tabs, splits, window sizes) and indexed in JSON. Falls back to
-- persistence.nvim when no dashboard session exists yet.
local M = {}

local data = require "dashboard.data"

local function read_index()
    local f = io.open(data.paths.sessions, "r")
    if not f then
        return {}
    end
    local content = f:read "*a"
    f:close()
    if not content or content == "" then
        return {}
    end
    local ok, decoded = pcall(vim.json.decode, content)
    return ok and type(decoded) == "table" and decoded or {}
end

local function write_index(index)
    local ok, encoded = pcall(vim.json.encode, index)
    if not ok then
        return false
    end
    vim.fn.mkdir(data.paths.session_dir, "p")
    local f = io.open(data.paths.sessions, "w")
    if not f then
        return false
    end
    f:write(encoded)
    f:close()
    return true
end

local function key_for(cwd, branch)
    return cwd .. "|" .. (branch ~= "" and branch or "no-branch")
end

local function file_for(cwd, branch)
    local hash = vim.fn.sha256(key_for(cwd, branch)):sub(1, 16)
    local name = vim.fn.fnamemodify(cwd, ":t"):gsub("[^%w_%-]", "_")
    return data.paths.session_dir .. "/" .. name .. "-" .. hash .. ".vim"
end

--- Save the current layout for this project/branch.
---@param cwd string
---@param branch string
---@return boolean ok
function M.save(cwd, branch)
    if vim.bo.buftype ~= "" then
        return false
    end

    vim.fn.mkdir(data.paths.session_dir, "p")
    local file = file_for(cwd, branch)

    -- :mksession only stores tabs when 'sessionoptions' includes tabpages.
    -- Change it for the duration of the write and restore immediately.
    local sessionoptions = vim.o.sessionoptions
    if not sessionoptions:find "tabpages" then
        vim.o.sessionoptions = sessionoptions .. ",tabpages"
    end
    local ok = pcall(vim.cmd, "silent! mksession! " .. vim.fn.fnameescape(file))
    vim.o.sessionoptions = sessionoptions

    if not ok or vim.fn.filereadable(file) == 0 then
        return false
    end

    local index = read_index()
    index[key_for(cwd, branch)] = {
        cwd = cwd,
        branch = branch ~= "" and branch or nil,
        file = file,
        saved_at = os.time(),
    }
    write_index(index)
    return true
end

--- Sessions saved for a directory, newest first.
function M.list(cwd, limit)
    local entries = {}
    for _, entry in pairs(read_index()) do
        if entry.cwd == cwd and entry.file and vim.fn.filereadable(entry.file) == 1 then
            table.insert(entries, entry)
        end
    end
    table.sort(entries, function(a, b)
        return (a.saved_at or 0) > (b.saved_at or 0)
    end)

    local out = {}
    for _, entry in ipairs(entries) do
        if not limit or #out < limit then
            table.insert(out, entry)
        end
    end
    return out
end

--- Load a saved layout. Returns false when the file is gone.
function M.restore(entry)
    if not entry or not entry.file or vim.fn.filereadable(entry.file) == 0 then
        return false
    end
    return pcall(vim.cmd, "silent! source " .. vim.fn.fnameescape(entry.file))
end

--- Load the newest session for this directory, if any.
function M.restore_latest(cwd)
    local entries = M.list(cwd, 1)
    if #entries == 0 then
        return false
    end
    return M.restore(entries[1])
end

--- Fall back to persistence.nvim's directory session.
function M.restore_persistence()
    local ok, persistence = pcall(require, "persistence")
    if ok then
        pcall(persistence.load)
    end
end

--- Restore the last session saved anywhere (persistence.nvim).
function M.restore_last()
    local ok, persistence = pcall(require, "persistence")
    if ok then
        pcall(persistence.load, { last = true })
    end
end

--- Stop persistence.nvim from overwriting the last session on exit.
function M.ignore_last()
    local ok, persistence = pcall(require, "persistence")
    if ok then
        pcall(persistence.stop)
    end
end

return M
