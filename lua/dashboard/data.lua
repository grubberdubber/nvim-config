-- Dashboard data layer: JSON storage, project/directory discovery, git status,
-- diagnostics, environment info and project TODO scanning. Everything here is
-- either cached or asynchronous; nothing blocks a redraw.
local M = {}

local uv = vim.uv or vim.loop
local data_dir = vim.fn.stdpath "data"

M.paths = {
    pins = data_dir .. "/dashboard_pins.json",
    projects = data_dir .. "/dashboard_projects.json",
    sessions = data_dir .. "/dashboard_sessions.json",
    session_dir = data_dir .. "/dashboard_sessions",
    last_build = data_dir .. "/dashboard_last_build.json",
}

local cache = {
    projects = nil,
    projects_pending = false,
    git = nil,
    git_pending = false,
    todos = nil,
    todos_pending = false,
}

--- Override storage paths (used by the headless test suite).
---@param paths table
function M.set_paths(paths)
    for key, value in pairs(paths) do
        M.paths[key] = value
    end
    cache =
        { projects = nil, projects_pending = false, git = nil, git_pending = false, todos = nil, todos_pending = false }
end

-- ── JSON STORAGE (ATOMIC WRITES) ─────────────────────────────────

local function read_json(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local content = f:read "*a"
    f:close()
    if not content or content == "" then
        return nil
    end
    local ok, decoded = pcall(vim.json.decode, content)
    return ok and type(decoded) == "table" and decoded or nil
end

--- Write through a temp file + rename so a crash never truncates the cache.
local function write_json(path, data)
    local ok, encoded = pcall(vim.json.encode, data)
    if not ok then
        return false
    end

    local dir = vim.fn.fnamemodify(path, ":h")
    vim.fn.mkdir(dir, "p")

    local tmp = path .. ".tmp"
    local f = io.open(tmp, "w")
    if not f then
        return false
    end
    f:write(encoded)
    f:close()

    local renamed = os.rename(tmp, path)
    if not renamed then
        os.remove(tmp)
        return false
    end
    return true
end

-- ── PINS ─────────────────────────────────────────────────────────

function M.get_pins()
    return read_json(M.paths.pins) or {}
end

function M.save_pins(pins)
    return write_json(M.paths.pins, pins)
end

function M.add_pin(filepath)
    if not filepath or filepath == "" then
        return false, "no file selected"
    end

    local full_path = vim.fn.fnamemodify(filepath, ":p")
    local pins = M.get_pins()
    for _, pin in ipairs(pins) do
        if pin.path == full_path then
            return false, "already pinned"
        end
    end

    table.insert(pins, {
        path = full_path,
        name = vim.fn.fnamemodify(full_path, ":t"),
        done = false,
        added_at = os.time(),
    })
    M.save_pins(pins)
    return true
end

function M.remove_pin(index)
    local pins = M.get_pins()
    if not pins[index] then
        return false
    end
    local removed = table.remove(pins, index)
    M.save_pins(pins)
    return true, removed and removed.name or ""
end

function M.toggle_pin(index)
    local pins = M.get_pins()
    if not pins[index] then
        return false
    end
    pins[index].done = not pins[index].done
    M.save_pins(pins)
    return true
end

--- Sort unfinished pins first, keeping insertion order inside each group.
function M.sorted_pins()
    local pins = M.get_pins()
    table.sort(pins, function(a, b)
        if a.done ~= b.done then
            return not a.done
        end
        return (a.added_at or 0) < (b.added_at or 0)
    end)
    return pins
end

-- ── PROJECT DISCOVERY ────────────────────────────────────────────
local ROOT_MARKERS = { ".git", ".hg", "Cargo.toml", "go.mod", "package.json", "pyproject.toml", "pom.xml" }

-- Project history kept on disk. The dashboard renders only the first few,
-- but older entries stay reachable through the projects picker.
local MAX_PROJECTS = 30

local function is_usable_root(path)
    return path and path ~= "" and path ~= "/" and path ~= vim.env.HOME and uv.fs_stat(path) ~= nil
end

--- Ignore paths that belong to the system or to package managers: history
-- entries from library files must never become "projects".
local system_prefixes = { "/usr/", "/opt/", "/var/", "/etc/", "/lib/", "/nix/" }
local function is_system_path(path)
    for _, prefix in ipairs(system_prefixes) do
        if path:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

--- Walk up from a file to its repository/project root without spawning git.
-- Files that live outside any project only return nil: random directories from
-- the file history must not pollute the project list.
local function root_for(path)
    local dir = vim.fn.fnamemodify(path, ":p:h")
    return vim.fs.root(dir, ROOT_MARKERS)
end

local function discover_projects(existing)
    local cwd = vim.fn.getcwd()
    local seen = {}
    for _, project in ipairs(existing) do
        seen[project.path] = true
    end

    for _, file in ipairs(vim.v.oldfiles or {}) do
        if #existing >= MAX_PROJECTS then
            break
        end
        if file and file ~= "" then
            local root = root_for(file)
            if root and is_usable_root(root) and not seen[root] then
                seen[root] = true
                table.insert(existing, {
                    path = root,
                    name = vim.fn.fnamemodify(root, ":t"),
                    last_opened = os.time() - 3600,
                })
            end
        end
    end

    -- Always keep the current working directory at the top.
    for index, project in ipairs(existing) do
        if project.path == cwd then
            project.last_opened = os.time()
            table.remove(existing, index)
            table.insert(existing, 1, project)
            break
        end
    end

    local current = false
    for _, project in ipairs(existing) do
        if project.path == cwd then
            current = true
            break
        end
    end
    if not current and is_usable_root(cwd) then
        table.insert(existing, 1, { path = cwd, name = vim.fn.fnamemodify(cwd, ":t"), last_opened = os.time() })
    end

    return existing
end

--- Ensure the current working directory is always offered, even right after
-- a :cd and before the background discovery finishes.
local function ensure_current(projects)
    local cwd = vim.fn.getcwd()
    for _, project in ipairs(projects) do
        if project.path == cwd then
            return projects
        end
    end
    if is_usable_root(cwd) then
        table.insert(projects, 1, {
            path = cwd,
            name = vim.fn.fnamemodify(cwd, ":t"),
            last_opened = os.time(),
            manual = true,
        })
    end
    return projects
end

--- Projects from the cache, sanitized. Discovery runs in a scheduled tick.
function M.get_projects()
    if cache.projects then
        return ensure_current(cache.projects)
    end

    local stored = read_json(M.paths.projects) or {}

    if #stored == 0 and cache.projects == nil then
        -- First call: return the current directory immediately while the
        -- background scan looks for more projects.
        cache.projects = ensure_current {}
        return cache.projects
    end
    local valid = {}
    for _, project in ipairs(stored) do
        if #valid >= MAX_PROJECTS then
            break
        end
        if type(project) == "table" and is_usable_root(project.path) and not is_system_path(project.path) then
            -- Older caches could contain plain directories discovered from the
            -- file history. Keep only real project roots or explicit choices.
            local has_marker = vim.fs.root(project.path, ROOT_MARKERS) ~= nil
            if has_marker or project.manual or project.path == vim.fn.getcwd() then
                table.insert(valid, project)
            end
        end
    end

    cache.projects = ensure_current(valid)
    return cache.projects
end

--- Discover extra projects from the file history without blocking the first paint.
function M.refresh_projects(callback)
    if cache.projects_pending then
        return
    end
    cache.projects_pending = true

    vim.schedule(function()
        local projects = discover_projects(M.get_projects())
        table.sort(projects, function(a, b)
            return (a.last_opened or 0) > (b.last_opened or 0)
        end)
        for index = #projects, MAX_PROJECTS + 1, -1 do
            table.remove(projects, index)
        end
        cache.projects = projects
        write_json(M.paths.projects, projects)
        cache.projects_pending = false
        if callback then
            callback()
        end
    end)
end

--- Remember the project the user just switched to.
function M.touch_project(path)
    local projects = M.get_projects()
    for index, project in ipairs(projects) do
        if project.path == path then
            project.last_opened = os.time()
            project.manual = true
            table.remove(projects, index)
            table.insert(projects, 1, project)
            break
        end
    end
    cache.projects = projects
    write_json(M.paths.projects, projects)
end

-- ── RECENT DIRECTORIES ───────────────────────────────────────────

function M.get_directories(limit)
    limit = limit or 4
    local cwd = vim.fn.getcwd()
    local dirs, seen = {}, {}

    local function add(path)
        if #dirs >= limit or not is_usable_root(path) or path == cwd or seen[path] or is_system_path(path) then
            return
        end
        seen[path] = true
        table.insert(dirs, { path = path, name = vim.fn.fnamemodify(path, ":t") })
    end

    for _, project in ipairs(M.get_projects()) do
        add(project.path)
    end
    for _, file in ipairs(vim.v.oldfiles or {}) do
        add(vim.fn.fnamemodify(file, ":p:h"))
    end

    return dirs
end

-- ── RECENT FILES ─────────────────────────────────────────────────

local IGNORED_FILES = { "COMMIT_EDITMSG$", "git%-rebase%-todo$", "^/tmp/", "/%.git/", " fugitive://" }

function M.get_recent_files(limit)
    limit = limit or 6
    local files, seen = {}, {}
    local cwd = vim.fn.getcwd()

    for _, file in ipairs(vim.v.oldfiles or {}) do
        if #files >= limit then
            break
        end

        local ignored = not file or file == "" or seen[file]
        if not ignored then
            for _, pattern in ipairs(IGNORED_FILES) do
                if file:match(pattern) then
                    ignored = true
                    break
                end
            end
        end

        if not ignored then
            seen[file] = true
            local relative = file
            if file:sub(1, #cwd) == cwd then
                relative = "." .. file:sub(#cwd + 1)
            else
                relative = vim.fn.fnamemodify(file, ":~")
            end
            table.insert(files, {
                path = file,
                name = vim.fn.fnamemodify(file, ":t"),
                rel_path = relative,
                missing = uv.fs_stat(file) == nil,
            })
        end
    end

    return files
end

-- ── GIT ──────────────────────────────────────────────────────────

local function empty_git()
    return {
        is_git = false,
        branch = "",
        staged = 0,
        modified = 0,
        untracked = 0,
        ahead = 0,
        behind = 0,
        stash = 0,
        files = 0,
        clean = true,
        last_commit = nil,
    }
end

function M.get_git_info()
    return cache.git or empty_git()
end

function M.get_branch()
    return cache.git and cache.git.is_git and cache.git.branch or ""
end

--- Refresh git state asynchronously and call back once with the result.
function M.refresh_git(callback)
    local cwd = vim.fn.getcwd()
    if cache.git_pending then
        return
    end
    cache.git_pending = true

    local results = {}
    local expected = 6
    local finished = 0
    local failed = false

    local function complete()
        finished = finished + 1
        if finished < expected then
            return
        end

        cache.git_pending = false
        if failed or not results.branch or results.branch.code ~= 0 then
            cache.git = empty_git()
            if callback then
                callback(cache.git)
            end
            return
        end

        local branch = (vim.trim(results.branch.stdout or "") ~= "" and vim.trim(results.branch.stdout)) or "HEAD"
        local staged, modified, untracked = 0, 0, 0
        for _, line in ipairs(vim.split(results.status.stdout or "", "\n", { trimempty = true })) do
            if #line >= 2 then
                local x, y = line:sub(1, 1), line:sub(2, 2)
                if x == "?" then
                    untracked = untracked + 1
                else
                    if x ~= " " then
                        staged = staged + 1
                    end
                    if y ~= " " then
                        modified = modified + 1
                    end
                end
            end
        end

        local ahead, behind = 0, 0
        local ab = vim.trim(results.ab.stdout or "")
        local behind_s, ahead_s = ab:match "^(%d+)%s+(%d+)$"
        if behind_s then
            behind, ahead = tonumber(behind_s), tonumber(ahead_s)
        end

        local stash = #vim.split(results.stash.stdout or "", "\n", { trimempty = true })
        local files = #vim.split(results.files.stdout or "", "\n", { trimempty = true })
        local commit = nil
        local raw_commit = vim.trim(results.log.stdout or "")
        if raw_commit ~= "" then
            local hash, author, subject, when = raw_commit:match "^([^|]+)|([^|]+)|([^|]+)|(.+)$"
            if hash then
                commit = { hash = hash, author = author, subject = subject, when = when }
            else
                commit = { hash = raw_commit }
            end
        end

        cache.git = {
            is_git = true,
            branch = branch,
            staged = staged,
            modified = modified,
            untracked = untracked,
            ahead = ahead,
            behind = behind,
            stash = stash,
            files = files,
            clean = (staged + modified + untracked == 0),
            last_commit = commit,
        }
        if callback then
            callback(cache.git)
        end
    end

    local opts = { text = true, cwd = cwd, timeout = 4000 }
    local commands = {
        branch = { "git", "branch", "--show-current" },
        status = { "git", "status", "--porcelain" },
        ab = { "git", "rev-list", "--left-right", "--count", "@{upstream}...HEAD" },
        stash = { "git", "stash", "list", "--format=%gd" },
        files = { "git", "ls-files" },
        log = { "git", "log", "-1", "--pretty=format:%h|%an|%s|%cr" },
    }

    for key, args in pairs(commands) do
        vim.system(args, opts, function(obj)
            -- Only a failed branch lookup means "not a repository". A missing
            -- upstream (rev-list) or empty stash must not hide the repo.
            if key == "branch" and obj.code ~= 0 then
                failed = true
            end
            results[key] = { code = obj.code, stdout = obj.stdout or "" }
            vim.schedule(complete)
        end)
    end
end

-- ── DIAGNOSTICS ──────────────────────────────────────────────────

--- Aggregate every diagnostic known to the running session. LSP diagnostics
-- only exist for buffers that were loaded/analyzed, so the renderer labels the
-- scope explicitly instead of pretending it scanned the whole tree.
function M.get_diagnostics()
    local severity = vim.diagnostic.severity
    local result = {
        error = 0,
        warn = 0,
        info = 0,
        hint = 0,
        total = 0,
        files = {},
    }

    local by_buf = {}
    for _, diagnostic in ipairs(vim.diagnostic.get()) do
        local sev = diagnostic.severity
        if sev == severity.ERROR then
            result.error = result.error + 1
        elseif sev == severity.WARN then
            result.warn = result.warn + 1
        elseif sev == severity.INFO then
            result.info = result.info + 1
        elseif sev == severity.HINT then
            result.hint = result.hint + 1
        end
        result.total = result.total + 1

        local bufnr = diagnostic.bufnr
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
            local entry = by_buf[bufnr]
            if not entry then
                entry = { bufnr = bufnr, error = 0, warn = 0, info = 0, hint = 0, total = 0 }
                by_buf[bufnr] = entry
            end
            entry.total = entry.total + 1
            if sev == severity.ERROR then
                entry.error = entry.error + 1
            elseif sev == severity.WARN then
                entry.warn = entry.warn + 1
            elseif sev == severity.INFO then
                entry.info = entry.info + 1
            elseif sev == severity.HINT then
                entry.hint = entry.hint + 1
            end
        end
    end

    local cwd = vim.fn.getcwd()
    for _, entry in pairs(by_buf) do
        local name = vim.api.nvim_buf_get_name(entry.bufnr)
        if name ~= "" then
            entry.path = name
            entry.name = vim.fn.fnamemodify(name, ":t")
            entry.rel = name:sub(1, #cwd) == cwd and ("." .. name:sub(#cwd + 1)) or vim.fn.fnamemodify(name, ":~")
            table.insert(result.files, entry)
        end
    end

    table.sort(result.files, function(a, b)
        if a.error ~= b.error then
            return a.error > b.error
        end
        if a.warn ~= b.warn then
            return a.warn > b.warn
        end
        return a.rel < b.rel
    end)

    return result
end

-- ── ENVIRONMENT ──────────────────────────────────────────────────

local cached_startup_ms = nil

function M.get_environment()
    local version = vim.version()

    -- Startup time is measured once, on the first render, never re-measured.
    if not cached_startup_ms and vim.g.nvim_start_hrtime then
        cached_startup_ms = math.floor((uv.hrtime() - vim.g.nvim_start_hrtime) / 1e6 + 0.5)
    end
    local startup_ms = cached_startup_ms

    local plugins = 0
    pcall(function()
        plugins = require("lazy").stats().count
    end)

    local clients = vim.lsp.get_clients()
    local lsp_names = {}
    for _, client in ipairs(clients) do
        table.insert(lsp_names, client.name)
    end
    table.sort(lsp_names)

    -- Count unique formatters configured across every filetype, not just the
    -- ones available for the (possibly empty) current buffer.
    local formatters, missing = 0, 0
    pcall(function()
        local configured = require("configs.conform").formatters_by_ft or {}
        local seen, names = {}, {}
        for _, list in pairs(configured) do
            for _, name in ipairs(list) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(names, name)
                end
            end
        end
        formatters = #names

        local conform = require "conform"
        for _, name in ipairs(names) do
            local ok, info = pcall(conform.get_formatter_info, name, 0)
            local command = ok and type(info) == "table" and info.command or nil
            if type(command) == "string" and vim.fn.executable(command) == 0 then
                missing = missing + 1
            end
        end
    end)

    -- Locale-independent English date (the UI language is English).
    local now = os.date "*t"
    local weekdays = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
    local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

    return {
        version = string.format("%d.%d.%d", version.major, version.minor, version.patch),
        startup_ms = startup_ms,
        plugins = plugins,
        lsp = lsp_names,
        lsp_count = #lsp_names,
        formatters = formatters,
        missing_formatters = missing,
        date = string.format("%s %d %s", weekdays[now.wday], now.day, months[now.month]),
        week = tonumber(os.date "%V"),
    }
end

--- Optional summary of the last test/build, written by external tooling.
function M.get_last_build()
    local info = read_json(M.paths.last_build)
    if type(info) ~= "table" or not info.status then
        return nil
    end
    return info
end

-- ── PROJECT TODOS ────────────────────────────────────────────────

function M.get_todos()
    return cache.todos
end

--- Scan TODO/FIXME markers with ripgrep, off the main thread.
function M.refresh_todos(callback)
    if cache.todos_pending then
        return
    end
    if vim.fn.executable "rg" == 0 then
        cache.todos = { count = 0, items = {}, available = false }
        return
    end

    cache.todos_pending = true
    local cwd = vim.fn.getcwd()

    vim.system({
        "rg",
        "--line-number",
        "--no-heading",
        "--color=never",
        "--max-filesize",
        "1M",
        "-e",
        "\\b(TODO|FIXME|HACK|XXX|BUG)\\b",
        "--",
        cwd,
    }, { text = true, cwd = cwd, timeout = 5000 }, function(obj)
        vim.schedule(function()
            local items = {}
            local count = 0
            if obj.code == 0 then
                for _, line in ipairs(vim.split(obj.stdout or "", "\n", { trimempty = true })) do
                    count = count + 1
                    local file, line_nr, text = line:match "^(.-):(%d+):(.*)$"
                    if file and #items < 200 then
                        table.insert(items, {
                            path = file,
                            line = tonumber(line_nr),
                            text = vim.trim(text),
                        })
                    end
                end
            end
            cache.todos = { count = count, items = items, available = true, cwd = cwd }
            cache.todos_pending = false
            if callback then
                callback(cache.todos)
            end
        end)
    end)
end

--- Reset per-directory caches (used on DirChanged and manual refresh).
function M.reset()
    cache.git = nil
    cache.todos = nil
    cache.git_pending = false
    cache.todos_pending = false
    cache.projects = nil
end

return M
