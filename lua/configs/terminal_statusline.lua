-- ── ONE GLOBAL STATUSBAR AND WINBARS ONLY WHERE THEY MATTER ───────
-- `laststatus=0` hides the bottom bar, but with a split it turns the split
-- separator into a statusline that shows terminal/buffer text. Several UI
-- plugins (terminals, DAP, Aerial) can temporarily set `laststatus=2` while
-- they build their layout, which leaves a statusline inside every new split.
-- Keep one global statusline and re-assert it after any window/buffer change.
--
-- `winbar` is global-local. An empty local value falls back to the global
-- expression, so setting only the local option to "" still reserves a blank
-- row (WinBarNC) in terminal/Aerial windows. To remove the row completely, the
-- global value stays empty and the expression is assigned window by window:
--   normal file windows -> breadcrumb expression
--   DAP panel windows   -> expression (WinBarDraw keeps the DAP titles)
--   terminal/Aerial/... -> genuinely empty, so no row is drawn
-- Window-local winbars installed by plugins (for example DAP controls) are
-- left untouched.
local M = {}
local WINBAR = "%{%v:lua.WinBarDraw()%}"

local function wants_winbar(buf)
    local bt = vim.bo[buf].buftype
    local ft = vim.bo[buf].filetype
    if ft:match "^dapui_" then
        return true
    end
    return bt == "" and ft ~= "lazy" and ft ~= "dashboard" and ft ~= "aerial"
end

local function sync_window_winbars()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local current = vim.api.nvim_get_option_value("winbar", { win = win, scope = "local" })
        if wants_winbar(buf) then
            if current == "" or current == WINBAR then
                vim.api.nvim_set_option_value("winbar", WINBAR, { win = win })
            end
        elseif current == WINBAR or current == "" then
            vim.api.nvim_set_option_value("winbar", "", { win = win })
        end
    end
end

-- Keep the background of any empty bar row identical to Normal as a fallback
-- for plugin windows that intentionally keep their own winbar.
local function clear_empty_winbar_strip()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local bt = vim.bo[buf].buftype
        local ft = vim.bo[buf].filetype
        if bt == "terminal" or ft == "aerial" then
            local parts = {}
            for part in (vim.wo[win].winhighlight or ""):gmatch "[^,]+" do
                if not part:match "^WinBar:" and not part:match "^WinBarNC:" then
                    table.insert(parts, part)
                end
            end
            table.insert(parts, "WinBar:Normal")
            table.insert(parts, "WinBarNC:Normal")
            vim.wo[win].winhighlight = table.concat(parts, ",")
        end
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup("GlobalStatusline", { clear = true })

    -- The expression lives in chadrc for normal file windows. Clearing the
    -- global value is what allows aux windows to have no winbar row at all.
    vim.opt.winbar = ""

    local function refresh_bars()
        vim.schedule(function()
            if vim.o.laststatus ~= 3 then
                vim.o.laststatus = 3
                pcall(vim.cmd, "redrawstatus")
            end
            vim.opt.winbar = ""
            sync_window_winbars()
            clear_empty_winbar_strip()
        end)
    end

    vim.api.nvim_create_autocmd({ "VimEnter", "TermOpen", "FileType", "BufEnter", "WinEnter", "TabEnter" }, {
        group = group,
        pattern = "*",
        callback = refresh_bars,
    })

    refresh_bars()
end

return M
