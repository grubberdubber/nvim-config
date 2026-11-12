-- ── PANEL CONTROL ────────────────────────────────────────────────
-- Close the current window with `q` without ever quitting Neovim while
-- preserving the internal state of plugin-managed panels.
local M = {}

-- Filetypes that behave as panels rather than code buffers.
local panel_filetypes = {
    aerial = true,
    trouble = true,
    NvimTree = true,
    dbui = true,
    oil = true,
    harpoon = true,
    dashboard = true,
    lazy = true,
    mason = true,
    TelescopePrompt = true,
    ["dap-repl"] = true,
}

local function is_panel()
    local ft = vim.bo.filetype
    return vim.bo.buftype ~= "" or panel_filetypes[ft] == true or ft:match "^dapui_" ~= nil
end

-- Count windows across ALL tabpages: `:close` on the last global window
-- exits Neovim, which must never happen from `q`.
local function window_count()
    local count = 0
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        count = count + #vim.api.nvim_tabpage_list_wins(tab)
    end
    return count
end

local function safe(cmd)
    local ok, err = pcall(vim.cmd, cmd)
    if not ok then
        vim.notify(err, vim.log.levels.WARN)
    end
end

--- Find a window (in the current tab) whose buffer has the given filetype.
---@param pattern string
---@return integer|nil
local function find_window(pattern)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype:match(pattern) then
            return win
        end
    end
end

-- Close panels through their own API so no orphan buffers are left and the
-- plugin layout stays consistent.
local function close_with_api()
    local ft = vim.bo.filetype
    local win = vim.api.nvim_get_current_win()

    if ft:match "^dapui_" then
        pcall(function()
            require("dapui").close()
        end)
    elseif ft == "dap-repl" then
        pcall(function()
            require("dap").repl.close()
        end)
    elseif ft == "aerial" then
        pcall(function()
            require("aerial").close()
        end)
    elseif ft == "NvimTree" then
        pcall(function()
            require("nvim-tree.api").tree.close()
        end)
    elseif ft == "dbui" then
        pcall(vim.cmd, "DBUIClose")
    elseif ft == "trouble" then
        pcall(function()
            require("trouble").close()
        end)
    end

    -- If the plugin API did not close this window, close it manually.
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_get_current_win() == win then
        safe "close"
    end
end

--- Whether `q` can close something without quitting Neovim.
---@return boolean
function M.can_close()
    return window_count() > 1 or is_panel()
end

--- Close the current window/panel. Never quits Neovim and leaves a normal
--- file alone when it is the only window (there `q` still records a macro).
---@return boolean closed
function M.close()
    -- Last window: a panel is replaced by an empty buffer; a normal file is
    -- left untouched so `q` keeps recording macros.
    if window_count() == 1 then
        if is_panel() then
            safe "enew"
            return true
        end
        return false
    end

    close_with_api()
    return true
end

--- Focus the aerial outline if it is open; otherwise open it.
function M.aerial_focus()
    local win = find_window "^aerial$"
    if win then
        vim.api.nvim_set_current_win(win)
        return
    end

    local ok, aerial = pcall(require, "aerial")
    if ok then
        aerial.open()
    end
end

return M
