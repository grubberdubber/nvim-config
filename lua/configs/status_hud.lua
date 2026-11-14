-- ── BOTTOM STATUS HUD ────────────────────────────────────────────
-- Neither bar should carry search or selection counters. Neovim has no
-- formatted "3 lines, 51 chars" output, so draw both counters in a one-line
-- floating window over the command row. It is not focusable and never writes
-- a message, so it cannot leave Neovim in the "Press ENTER" state.
local M = {}

local scheduled = false
local deferred
local hud_buf
local hud_win
local showcmd_suppressed = false
local showcmd_was_enabled = true
local last_search

local function get_hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function search_count()
    if vim.v.hlsearch ~= 1 or vim.fn.getreg "/" == "" then
        last_search = nil
        return nil
    end

    -- searchcount() counts matches in the current buffer. Terminals and
    -- panels have none, so keep the last file count while one is focused.
    if vim.bo.buftype ~= "" then
        return last_search
    end

    local ok, count = pcall(vim.fn.searchcount, { maxcount = 999 })
    if not ok or not count or (count.total or 0) == 0 then
        last_search = nil
        return nil
    end

    last_search = string.format("[%d/%d]", count.current or 0, count.total)
    return last_search
end

local function visual_size()
    local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
    if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
        return nil
    end

    local lines = math.abs(vim.fn.line "v" - vim.fn.line ".") + 1
    if mode == "\22" then
        local columns = math.abs(vim.fn.virtcol "v" - vim.fn.virtcol ".") + 1
        return string.format("%dx%d", lines, columns)
    end

    local chars = vim.fn.wordcount().visual_chars or 0
    if lines == 1 then
        return string.format("%d %s", chars, chars == 1 and "char" or "chars")
    end
    return string.format("%d lines, %d chars", lines, chars)
end

local function hud_text()
    local ft = vim.bo.filetype
    if ft == "dashboard" or ft == "lazy" then
        return ""
    end

    local parts = {}
    local search = search_count()
    if search then
        table.insert(parts, search)
    end

    -- Selection sizes only make sense in a real file window; search is
    -- global and stays visible when a terminal or DAP panel is focused.
    if vim.bo.buftype == "" then
        local visual = visual_size()
        if visual then
            table.insert(parts, visual)
        end
    end

    if #parts == 0 then
        return ""
    end
    return table.concat(parts, "   ")
end

local function set_hud_hl()
    local normal = get_hl "Normal"
    vim.api.nvim_set_hl(0, "StatusHud", {
        fg = normal.fg or 0xFFFFFF,
        bg = normal.bg or 0x000000,
        bold = true,
    })
end

local function close_hud()
    if hud_win and vim.api.nvim_win_is_valid(hud_win) then
        pcall(vim.api.nvim_win_close, hud_win, true)
        -- A full-row float can leave the previous command text painted
        -- underneath it. Force a redraw after removing it.
        pcall(vim.cmd, "redraw!")
    end
    hud_win = nil
    hud_buf = nil
end

local function sync_showcmd(visible)
    if visible and not showcmd_suppressed then
        showcmd_suppressed = true
        vim.o.showcmd = false
    elseif not visible and showcmd_suppressed then
        showcmd_suppressed = false
        vim.o.showcmd = showcmd_was_enabled
    end
end

local function ensure_hud()
    if hud_win and vim.api.nvim_win_is_valid(hud_win) then
        return hud_win
    end

    -- The command row keeps the previous search text until a redraw; the
    -- float is painted over that row, so clear it before opening the window.
    pcall(vim.cmd, "redraw")

    hud_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[hud_buf].bufhidden = "wipe"
    vim.bo[hud_buf].buftype = "nofile"
    hud_win = vim.api.nvim_open_win(hud_buf, false, {
        relative = "editor",
        row = 0,
        col = 0,
        width = 1,
        height = 1,
        style = "minimal",
        focusable = false,
        noautocmd = true,
        -- The search pattern/message row is drawn above ordinary floats.
        -- A high zindex keeps the HUD visible after n/N repaints `/for`.
        zindex = 1000,
    })
    vim.wo[hud_win].winhl = "Normal:StatusHud"
    return hud_win
end

local function place_hud(text)
    local win = ensure_hud()
    local width = vim.o.columns
    -- row = lines - cmdheight is the command line itself: the HUD stays
    -- below the statusline and above the buffer, exactly where it was before.
    local row = math.max(0, vim.o.lines - vim.o.cmdheight)
    local padding = math.max(1, width - vim.fn.strdisplaywidth(text) - 1)

    vim.api.nvim_win_set_config(win, {
        relative = "editor",
        row = row,
        col = 0,
        width = width,
        height = 1,
        style = "minimal",
        focusable = false,
        noautocmd = true,
        zindex = 1000,
    })
    -- Paint the full row so the previous command line ("/fo", ":w", ...)
    -- cannot remain visible under the transparent part of the float.
    vim.api.nvim_buf_set_lines(hud_buf, 0, -1, false, { string.rep(" ", padding) .. text .. " " })
    sync_showcmd(true)
    pcall(vim.cmd, "redraw")
end

local function render()
    if vim.fn.getcmdtype() ~= "" then
        close_hud()
        sync_showcmd(false)
        return
    end

    local text = hud_text()
    if text == "" then
        close_hud()
        sync_showcmd(false)
        return
    end

    place_hud(text)
end

local function schedule_render()
    if scheduled then
        return
    end
    scheduled = true
    vim.schedule(function()
        scheduled = false
        render()
    end)
end

-- Commands such as :w and :Lazy replace the message row. Give their output a
-- brief moment, then restore the HUD if the counters still apply.
local function stop_deferred()
    if deferred then
        pcall(deferred.stop, deferred)
        pcall(deferred.close, deferred)
        deferred = nil
    end
end

local function defer_render()
    stop_deferred()
    deferred = vim.defer_fn(function()
        deferred = nil
        schedule_render()
    end, 400)
end

function M.setup()
    showcmd_was_enabled = vim.o.showcmd
    set_hud_hl()

    local group = vim.api.nvim_create_augroup("StatusHud", { clear = true })
    vim.api.nvim_create_autocmd({
        "ModeChanged",
        "CursorMoved",
        "CursorMovedI",
        "BufEnter",
        "BufLeave",
        "WinEnter",
        "WinLeave",
        "VimResized",
        "SearchWrapped",
    }, {
        group = group,
        callback = schedule_render,
    })

    -- Cache the count before leaving a file for a terminal/panel. BufEnter
    -- fires after the current buffer has already changed, which would make
    -- searchcount() return zero inside the terminal.
    vim.api.nvim_create_autocmd("BufLeave", {
        group = group,
        callback = function()
            search_count()
        end,
    })

    vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = group,
        callback = function()
            -- close_hud() already repaints when a HUD was open. A second,
            -- unconditional redraw here also runs for hit-enter prompts
            -- (swap dialog, long messages) and clears their message area,
            -- leaving only the prompt line behind.
            close_hud()
            sync_showcmd(false)
        end,
    })

    vim.api.nvim_create_autocmd("OptionSet", {
        group = group,
        pattern = "hlsearch",
        -- A search sets hlsearch while the ":" command is still being
        -- processed. Wait until the command-line teardown has finished.
        callback = defer_render,
    })

    vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = group,
        callback = defer_render,
    })

    local function on_theme_change()
        set_hud_hl()
        schedule_render()
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = on_theme_change,
    })

    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "NvThemeReload",
        callback = on_theme_change,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            stop_deferred()
            close_hud()
        end,
    })

    schedule_render()
end

return M
