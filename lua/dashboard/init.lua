-- Dashboard orchestrator: setup, lifecycle, keymaps, actions and snapshot
-- assembly. Layout lives in render.lua, data in data.lua, sessions in
-- sessions.lua and selection behavior in nav.lua.
local M = {}

local uv = vim.uv or vim.loop
local data = require "dashboard.data"
local sessions = require "dashboard.sessions"
local render = require "dashboard.render"
local nav = require "dashboard.nav"

local defaults = require "dashboard.config"
local cfg = vim.deepcopy(defaults)

local dashboard_buf = nil
local dashboard_win = nil
local saved_win_opts = nil
local saved_guicursor = nil
local augroup = nil
local render_timer = nil

-- ── OPTIONAL DEPENDENCIES ────────────────────────────────────────

local function load(module)
    local ok, value = pcall(require, module)
    return ok and value or nil
end

local function telescope()
    return load "telescope.builtin"
end

local function fzf()
    return load "fzf-lua"
end

local function has_command(command)
    return vim.fn.executable(command) == 1
end

local function has_excommand(name)
    return vim.fn.exists(":" .. name) == 2
end

-- ── ICONS ────────────────────────────────────────────────────────

-- devicons is loaded lazily: the dashboard renders before plugins are loaded.
local devicons = nil

local function get_devicons()
    if devicons == nil then
        devicons = load "nvim-web-devicons" or false
    end
    return devicons or nil
end

local icons = {
    dir = cfg.icons and "" or "",
    file_for = function(name)
        local module = cfg.icons and get_devicons()
        if not module then
            return ""
        end
        local icon = module.get_icon(name, vim.fn.fnamemodify(name, ":e"), { default = true })
        return icon or ""
    end,
}

-- ── ACTIONS ──────────────────────────────────────────────────────

local function open_file(path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
end

local function open_buffer(bufnr)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_win_set_buf(0, bufnr)
    end
end

local function open_diagnostic(bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" and vim.api.nvim_win_get_buf(0) ~= bufnr then
        vim.cmd("edit " .. vim.fn.fnameescape(name))
    end
    pcall(vim.diagnostic.jump, { count = 1, bufnr = bufnr })
end

local function jump(path, line)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
    vim.cmd "normal! zz"
end

local function select_project(path)
    if not path or path == "" or uv.fs_stat(path) == nil then
        vim.notify("Directory not found: " .. tostring(path), vim.log.levels.WARN)
        M.render()
        return
    end
    vim.fn.chdir(path)
    data.touch_project(path)
    data.reset()
    vim.notify("Working directory: " .. vim.fn.fnamemodify(path, ":~"), vim.log.levels.INFO)
    M.render()
    M.refresh()
end

local function find_files()
    local picker = telescope()
    if picker then
        picker.find_files()
        return
    end
    local fz = fzf()
    if fz then
        fz.files()
        return
    end
    vim.ui.input({ prompt = "File: ", completion = "file" }, function(input)
        if input and input ~= "" then
            open_file(input)
        end
    end)
end

local function live_grep()
    local picker = telescope()
    if picker then
        picker.live_grep()
        return
    end
    local fz = fzf()
    if fz then
        fz.live_grep()
        return
    end
    vim.ui.input({ prompt = "Grep: " }, function(input)
        if input and input ~= "" then
            vim.cmd("lgrep! " .. vim.fn.fnameescape(input))
            vim.cmd "lopen"
        end
    end)
end

local function list_buffers()
    local picker = telescope()
    if picker then
        picker.buffers()
        return
    end
    local fz = fzf()
    if fz then
        fz.buffers()
        return
    end
    vim.cmd "buffers"
end

local function recent_files()
    local picker = telescope()
    if picker then
        picker.oldfiles()
        return
    end
    local fz = fzf()
    if fz then
        fz.oldfiles()
        return
    end
    M.render()
end

local function git_action()
    if has_command "lazygit" then
        vim.cmd "LazyGit"
        return
    end
    local picker = telescope()
    if picker then
        picker.git_status()
    end
end

local function diagnostics_action()
    -- Trouble is the primary project-wide panel; Telescope is only a fallback
    -- for installations where the plugin was disabled.
    if has_excommand "Trouble" then
        vim.cmd "Trouble diagnostics toggle focus=true win.position=bottom"
        return
    end
    local picker = telescope()
    if picker then
        picker.diagnostics()
        return
    end
    vim.diagnostic.setqflist()
    vim.cmd "copen"
end

local function todo_picker()
    local picker = telescope()
    if picker then
        picker.live_grep { default_text = "TODO|FIXME|HACK|XXX|BUG" }
        return
    end
    vim.cmd [[lgrep! "TODO\|FIXME\|HACK\|XXX\|BUG"]]
    vim.cmd "lopen"
end

local function open_terminal()
    local ok, term = pcall(require, "nvchad.term")
    if ok and term and term.toggle then
        term.toggle { pos = "float", id = "dashboardTerm" }
        return
    end
    vim.cmd "terminal"
end

local function edit_config()
    local config = vim.fn.stdpath "config"
    open_file(config .. "/init.lua")
end

local function new_file()
    vim.ui.input({ prompt = "New file: ", completion = "file" }, function(input)
        if input and input ~= "" then
            vim.cmd("edit " .. vim.fn.fnameescape(input))
        end
    end)
end

local function explorer()
    local oil = load "oil"
    if oil then
        oil.open(vim.fn.getcwd())
        return
    end
    open_file(vim.fn.getcwd())
end

local function prompt_projects()
    local projects = M.get_projects()
    if #projects == 0 then
        vim.notify("No projects recorded yet.", vim.log.levels.INFO)
        return
    end

    local items = {}
    for _, project in ipairs(projects) do
        table.insert(items, project.name .. "  " .. vim.fn.fnamemodify(project.path, ":~"))
    end

    vim.ui.select(items, { prompt = "Recent projects:" }, function(_, index)
        if index and projects[index] then
            select_project(projects[index].path)
        end
    end)
end

local function prompt_add_pin()
    local picker = telescope()
    if not picker then
        vim.ui.input({ prompt = "File to pin: ", completion = "file" }, function(input)
            if input and input ~= "" then
                local ok, message = M.add_pin(input)
                vim.notify(message, ok and vim.log.levels.INFO or vim.log.levels.WARN)
                M.render()
            end
        end)
        return
    end

    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    picker.find_files {
        prompt_title = "Pin file to dashboard",
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    local ok, message = M.add_pin(selection.path or selection.value or selection[1])
                    vim.notify(message, ok and vim.log.levels.INFO or vim.log.levels.WARN)
                    M.render()
                end
            end)
            return true
        end,
    }
end

local function open_pin(pin)
    if uv.fs_stat(pin.path) == nil then
        vim.notify("File no longer exists: " .. pin.path, vim.log.levels.WARN)
        return
    end
    open_file(pin.path)
end

local function toggle_pin_at_cursor()
    local info = nav.find_pin_info()
    if not info then
        vim.notify("Place the cursor on a pinned file first.", vim.log.levels.INFO)
        return
    end
    M.toggle_pin(info.index)
    M.render()
end

local function remove_pin_at_cursor()
    local info = nav.find_pin_info()
    if not info then
        vim.notify("Place the cursor on a pinned file first.", vim.log.levels.INFO)
        return
    end
    local ok, name = M.remove_pin(info.index)
    if ok then
        vim.notify("Unpinned: " .. name, vim.log.levels.INFO)
    end
    M.render()
end

--- Launchers shown in the ACTIONS grid. Actions whose dependencies are
-- missing are simply not added, never rendered broken.
local function get_launchers()
    local list = {}

    local function add(key, label, action)
        table.insert(list, { key = key, label = label, action = action })
    end

    add("f", "Find files", find_files)
    add("w", "Live grep", live_grep)
    add("b", "Buffers", list_buffers)
    add("r", "Recent files", recent_files)
    if has_command "lazygit" or telescope() then
        add("g", "Git status", git_action)
    end
    add("c", "Neovim config", edit_config)
    if load "oil" then
        add("e", "Explorer", explorer)
    end
    add("i", "New file", new_file)
    if has_excommand "Lazy" then
        add("z", "Plugins", function()
            vim.cmd "Lazy"
        end)
    end
    if has_excommand "Mason" then
        add("m", "Mason", function()
            vim.cmd "Mason"
        end)
    end
    if has_excommand "checkhealth" then
        add("H", "Health", function()
            vim.cmd "checkhealth"
        end)
    end
    add("p", "Projects", prompt_projects)
    add("d", "Diagnostics", diagnostics_action)
    add("t", "Terminal", open_terminal)
    add("u", "TODOs", todo_picker)

    return list
end

-- ── SNAPSHOT ─────────────────────────────────────────────────────

local function loaded_buffers(limit)
    local buffers = {}
    for _, info in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
        if info.name ~= "" then
            local modified = info.changed == 1
            table.insert(buffers, {
                bufnr = info.bufnr,
                name = vim.fn.fnamemodify(info.name, ":t"),
                rel = vim.fn.fnamemodify(info.name, ":~"),
                modified = modified,
                lastused = info.lastused or 0,
            })
        end
    end
    table.sort(buffers, function(a, b)
        return a.lastused > b.lastused
    end)

    local out = {}
    for index = 1, math.min(#buffers, limit) do
        out[index] = buffers[index]
    end
    return out
end

local function take(list, limit)
    local out = {}
    for index = 1, math.min(#list, limit) do
        out[index] = list[index]
    end
    return out
end

local function make_snapshot()
    local cwd = vim.fn.getcwd()
    local saved = sessions.list(cwd, cfg.limits.sessions)
    local latest = saved[1]

    return {
        cwd = cwd,
        cwd_short = vim.fn.fnamemodify(cwd, ":~"),
        git = data.get_git_info(),
        diag = data.get_diagnostics(),
        env = data.get_environment(),
        actions = get_launchers(),
        projects = take(data.get_projects(), cfg.limits.projects),
        directories = data.get_directories(cfg.limits.directories),
        recents = data.get_recent_files(cfg.limits.recents),
        todos = data.get_todos(),
        pins = take(data.sorted_pins(), cfg.limits.pins),
        buffers = loaded_buffers(cfg.limits.buffers),
        sessions = saved,
        session_latest = latest,
        build = data.get_last_build(),
        icons = icons,
        callbacks = {
            open_file = open_file,
            open_buffer = open_buffer,
            open_diagnostic = open_diagnostic,
            jump = jump,
            select_project = select_project,
            add_pin = prompt_add_pin,
            toggle_pin = toggle_pin_at_cursor,
            remove_pin = remove_pin_at_cursor,
            open_pin = open_pin,
            restore_session = function()
                if latest and sessions.restore(latest) then
                    return
                end
                sessions.restore_persistence()
            end,
            save_session = function()
                local ok = sessions.save(cwd, data.get_branch())
                vim.notify(
                    ok and "Layout saved for this project/branch" or "Could not save the layout in this buffer",
                    ok and vim.log.levels.INFO or vim.log.levels.WARN
                )
                M.render()
            end,
            restore_last = sessions.restore_last,
            ignore_last = sessions.ignore_last,
            restore_entry = function(entry)
                if not sessions.restore(entry) then
                    vim.notify("Session file is missing.", vim.log.levels.WARN)
                end
            end,
        },
    }
end

-- ── RENDER ───────────────────────────────────────────────────────

function M.is_open()
    return dashboard_buf ~= nil
        and vim.api.nvim_buf_is_valid(dashboard_buf)
        and dashboard_win ~= nil
        and vim.api.nvim_win_is_valid(dashboard_win)
        and vim.api.nvim_win_get_buf(dashboard_win) == dashboard_buf
end

function M.render()
    if not M.is_open() then
        return
    end

    local previous = vim.api.nvim_win_get_cursor(dashboard_win)[1]
    local width = vim.api.nvim_win_get_width(dashboard_win)
    local height = vim.api.nvim_win_get_height(dashboard_win)
    local lines, spans, rows = render.build(make_snapshot(), cfg, width, height)

    vim.bo[dashboard_buf].modifiable = true
    vim.api.nvim_buf_clear_namespace(dashboard_buf, -1, 0, -1)
    vim.api.nvim_buf_set_lines(dashboard_buf, 0, -1, false, lines)

    local ns = vim.api.nvim_create_namespace "dashboard_hl"
    for _, span in ipairs(spans) do
        pcall(vim.api.nvim_buf_add_highlight, dashboard_buf, ns, span.group, span.line, span.start_col, span.end_col)
    end

    vim.bo[dashboard_buf].modifiable = false
    nav.set_rows(rows)

    local target = math.min(math.max(previous, 1), #lines)
    pcall(vim.api.nvim_win_set_cursor, dashboard_win, { target, 0 })
    nav.highlight()
end

-- ── LIFECYCLE ────────────────────────────────────────────────────

local function save_window_options(win)
    local wo = vim.wo[win]
    saved_win_opts = {
        list = wo.list,
        number = wo.number,
        relativenumber = wo.relativenumber,
        cursorline = wo.cursorline,
        signcolumn = wo.signcolumn,
        foldcolumn = wo.foldcolumn,
        statuscolumn = wo.statuscolumn,
        wrap = wo.wrap,
        spell = wo.spell,
    }

    if cfg.hide_cursor then
        saved_guicursor = vim.o.guicursor
        vim.o.guicursor = "a:"
    end
end

local function restore_window_options()
    nav.clear()

    if saved_win_opts and dashboard_win and vim.api.nvim_win_is_valid(dashboard_win) then
        local wo = vim.wo[dashboard_win]
        for key, value in pairs(saved_win_opts) do
            pcall(function()
                wo[key] = value
            end)
        end
    end
    saved_win_opts = nil

    if saved_guicursor then
        vim.o.guicursor = saved_guicursor
        saved_guicursor = nil
    end

    if render_timer then
        pcall(render_timer.stop, render_timer)
        pcall(render_timer.close, render_timer)
        render_timer = nil
    end

    if augroup then
        pcall(vim.api.nvim_del_augroup_by_id, augroup)
        augroup = nil
    end
end

-- ── KEYMAPS ──────────────────────────────────────────────────────

local function bmap(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, {
        buffer = dashboard_buf,
        silent = true,
        nowait = true,
        desc = "Dashboard: " .. desc,
    })
end

function M.help()
    local lines = {
        "Dashboard — keyboard reference",
        "",
        "  j / ↓, k / ↑        next / previous entry",
        "  h / ←, l / →        previous / next entry",
        "  Tab, S-Tab          cycle entries",
        "  Enter               activate entry",
        "  /                   search inside the dashboard (n / N to repeat)",
        "",
        "  f  find files        w  live grep        b  buffers",
        "  r  recent files      g  git status       c  Neovim config",
        "  e  explorer          i  new file         z  plugins",
        "  m  Mason             H  checkhealth      p  projects",
        "  d  diagnostics       t  terminal         u  TODOs",
        "",
        "  s  restore session   S  save layout      L  last session",
        "  X  ignore last       a  pin file         x  toggle pin",
        "  D  remove pin        1-9 open project",
        "",
        "  R  refresh           ?  this help        q / Esc  quit",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = "help"
    vim.bo[buf].bufhidden = "wipe"

    local width = 64
    local height = #lines
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.max(math.floor((vim.o.lines - height) / 2), 1),
        col = math.max(math.floor((vim.o.columns - width) / 2), 1),
        style = "minimal",
        border = "rounded",
        title = " Help ",
        title_pos = "center",
    })

    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(win, true)
    end, { buffer = buf, desc = "Help: close" })
    vim.keymap.set("n", "<Esc>", function()
        vim.api.nvim_win_close(win, true)
    end, { buffer = buf, desc = "Help: close" })
end

local function setup_keymaps()
    bmap("<CR>", function()
        nav.activate()
    end, "open entry")
    bmap("<2-LeftMouse>", function()
        vim.cmd "normal! <LeftMouse>"
        nav.activate()
    end, "open entry")

    for _, key in ipairs { "j", "<Down>", "l", "<Right>", "<Tab>" } do
        bmap(key, function()
            nav.move(1)
        end, "next entry")
    end
    for _, key in ipairs { "k", "<Up>", "h", "<Left>", "<S-Tab>" } do
        bmap(key, function()
            nav.move(-1)
        end, "previous entry")
    end

    bmap("f", find_files, "find files")
    bmap("w", live_grep, "live grep")
    bmap("b", list_buffers, "buffers")
    bmap("r", recent_files, "recent files")
    bmap("g", git_action, "git status")
    bmap("c", edit_config, "open config")
    bmap("e", explorer, "explorer")
    bmap("i", new_file, "new file")
    bmap("z", function()
        vim.cmd "Lazy"
    end, "plugins")
    bmap("m", function()
        vim.cmd "Mason"
    end, "Mason")
    bmap("H", function()
        vim.cmd "checkhealth"
    end, "health")
    bmap("p", prompt_projects, "projects")
    bmap("d", diagnostics_action, "diagnostics")
    bmap("t", open_terminal, "terminal")
    bmap("u", todo_picker, "TODOs")

    bmap("s", function()
        local cwd = vim.fn.getcwd()
        if not sessions.restore_latest(cwd) then
            sessions.restore_persistence()
        end
    end, "restore session")
    bmap("S", function()
        local ok = sessions.save(vim.fn.getcwd(), data.get_branch())
        vim.notify(
            ok and "Layout saved" or "Could not save the layout",
            ok and vim.log.levels.INFO or vim.log.levels.WARN
        )
        M.render()
    end, "save layout")
    bmap("L", sessions.restore_last, "last session")
    bmap("X", sessions.ignore_last, "ignore last session")
    bmap("a", prompt_add_pin, "pin file")
    bmap("x", toggle_pin_at_cursor, "toggle pin")
    bmap("D", remove_pin_at_cursor, "remove pin")

    for number = 1, cfg.limits.projects do
        bmap(tostring(number), function()
            local projects = M.get_projects()
            if projects[number] then
                select_project(projects[number].path)
            end
        end, "open project " .. number)
    end

    bmap("R", function()
        data.reset()
        M.render()
        M.refresh()
    end, "refresh")
    bmap("?", M.help, "help")
    bmap("q", function()
        vim.cmd "qa"
    end, "quit Neovim")
    bmap("<Esc>", function()
        vim.cmd "qa"
    end, "quit Neovim")
end

-- ── OPEN ─────────────────────────────────────────────────────────

function M.open()
    if M.is_open() then
        M.render()
        return
    end

    augroup = vim.api.nvim_create_augroup("DashboardSession", { clear = true })

    local win = vim.api.nvim_get_current_win()
    save_window_options(win)

    dashboard_buf = vim.api.nvim_create_buf(false, true)
    dashboard_win = win

    vim.bo[dashboard_buf].buftype = "nofile"
    vim.bo[dashboard_buf].filetype = "dashboard"
    vim.bo[dashboard_buf].bufhidden = "wipe"
    vim.bo[dashboard_buf].swapfile = false
    vim.bo[dashboard_buf].buflisted = false
    pcall(vim.api.nvim_buf_set_name, dashboard_buf, "Dashboard")
    vim.api.nvim_win_set_buf(win, dashboard_buf)

    local wo = vim.wo[win]
    wo.wrap = false
    wo.cursorline = false
    wo.number = false
    wo.relativenumber = false
    wo.list = false -- no listchars dots on the dashboard, only here
    wo.foldcolumn = "0"
    wo.foldenable = false
    wo.signcolumn = "no"
    wo.statuscolumn = ""
    wo.spell = false

    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        buffer = dashboard_buf,
        once = true,
        callback = restore_window_options,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        buffer = dashboard_buf,
        callback = function()
            if cfg.highlight_selection then
                nav.highlight()
            end
        end,
    })

    -- Keep the counters trustworthy while the dashboard is open: diagnostics
    -- and language servers can change at any moment.
    vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach" }, {
        group = augroup,
        callback = function()
            if render_timer then
                return
            end
            render_timer = vim.defer_fn(function()
                render_timer = nil
                if M.is_open() then
                    M.render()
                end
            end, 200)
        end,
    })

    setup_keymaps()
    M.render()
    M.refresh()

    local first = nav.first_line()
    if first then
        pcall(vim.api.nvim_win_set_cursor, win, { first, 0 })
    end
end

--- Kick every asynchronous data source. Each one re-renders on completion.
function M.refresh()
    data.refresh_git(function()
        if M.is_open() then
            M.render()
        end
    end)
    data.refresh_todos(function()
        if M.is_open() then
            M.render()
        end
    end)
    data.refresh_projects(function()
        if M.is_open() then
            M.render()
        end
    end)
end

-- ── SETUP ────────────────────────────────────────────────────────

function M.setup(opts)
    cfg = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
    icons.dir = cfg.icons and "" or ""

    vim.api.nvim_create_user_command("Dashboard", function()
        M.open()
    end, { desc = "Open the IDE dashboard" })

    vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
            if vim.fn.argc() > 0 then
                return
            end
            local buf = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local empty = vim.api.nvim_buf_get_name(buf) == "" and #lines <= 1 and (lines[1] == nil or lines[1] == "")
            if empty then
                M.open()
            end
        end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            if M.is_open() then
                M.render()
            end
        end,
    })

    vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
            data.reset()
            if M.is_open() then
                M.render()
                M.refresh()
            end
        end,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            if M.is_open() then
                M.render()
            end
        end,
    })
end

-- ── PUBLIC DATA WRAPPERS (used by tests and external config) ─────

function M.get_pins()
    return data.get_pins()
end

function M.add_pin(path)
    local ok = data.add_pin(path)
    return ok, ok and "Pinned to dashboard" or "File is already pinned"
end

function M.remove_pin(index)
    return data.remove_pin(index)
end

function M.toggle_pin(index)
    return data.toggle_pin(index)
end

function M.prompt_add_pin()
    prompt_add_pin()
end

function M.get_projects()
    return data.get_projects()
end

function M.select_project(path)
    select_project(path)
end

function M.prompt_projects()
    prompt_projects()
end

function M.get_git_info()
    return data.get_git_info()
end

function M.get_diagnostics()
    return data.get_diagnostics()
end

function M.get_recent_files(limit)
    return data.get_recent_files(limit)
end

return M
