-- Dashboard renderer: builds a responsive, display-width-aware layout and the
-- list of interactive rows. It owns no state; callers pass a data snapshot and
-- the callbacks to run for each entry.
local M = {}

-- ── THEME HELPERS ────────────────────────────────────────────────

local function fg(name, fallback)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl and hl.fg then
        return string.format("#%06x", hl.fg)
    end
    return fallback
end

local function bg(name, fallback)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl and hl.bg then
        return string.format("#%06x", hl.bg)
    end
    return fallback
end

local function hex_to_rgb(color)
    local value = tonumber((color or "#000000"):gsub("#", ""), 16) or 0
    return math.floor(value / 65536) % 256, math.floor(value / 256) % 256, value % 256
end

local mix

--- Background used by the active theme for the current line. The dashboard
-- reuses it instead of inventing an accent color, so both stay in sync.
local function cursorline_bg(normal_bg)
    local ok, base46 = pcall(require, "base46")
    if ok then
        local colors = base46.get_theme_tb "base_30"
        if colors and colors.black2 then
            return colors.black2
        end
    end

    local ok_hl, hl = pcall(vim.api.nvim_get_hl, 0, { name = "CursorLine", link = false })
    if ok_hl and hl and hl.bg then
        return string.format("#%06x", hl.bg)
    end

    return mix(normal_bg, fg("Normal", "#c0caf5"), 0.08)
end

mix = function(a, b, t)
    local ar, ag, ab = hex_to_rgb(a)
    local br, bgc, bb = hex_to_rgb(b)
    local function lerp(x, y)
        return math.floor(x + (y - x) * t + 0.5)
    end
    return string.format("#%02x%02x%02x", lerp(ar, br), lerp(ag, bgc), lerp(ab, bb))
end

--- Recompute every dashboard highlight from the active colorscheme.
function M.setup_highlights()
    local normal_fg = fg("Normal", "#c0caf5")
    local normal_bg = bg("Normal", "#1a1b26")
    local accent = fg("Function", "#7aa2f7")
    local accent2 = fg("Type", "#bb9af7")
    local key = fg("DiagnosticWarn", "#ffc27d")
    local err = fg("DiagnosticError", "#ff7a93")
    local ok = fg("DiagnosticOk", fg("String", "#9ece6a"))
    local comment = fg("Comment", "#6272a4")

    local function set(name, opts)
        vim.api.nvim_set_hl(0, name, opts)
    end

    set("DashHeader", { fg = accent, bold = true })
    set("DashSub", { fg = comment, italic = true })
    set("DashTitle", { fg = accent2, bold = true })
    set("DashKey", { fg = key, bold = true })
    set("DashText", { fg = normal_fg })
    set("DashPath", { fg = comment, italic = true })
    set("DashBorder", { fg = mix(comment, normal_bg, 0.45) })
    set("DashOk", { fg = ok })
    set("DashErr", { fg = err })
    set("DashWarn", { fg = key })
    set("DashDim", { fg = mix(comment, normal_bg, 0.2) })
    set("DashRow", { bg = cursorline_bg(normal_bg) })
    set("DashRule", { fg = mix(comment, normal_bg, 0.55) })

    -- Header gradient: accent -> accent2 across the ASCII lines.
    for index = 1, 6 do
        set("DashArt" .. index, { fg = mix(accent, accent2, (index - 1) / 5), bold = true })
    end
end

-- ── WIDTH HELPERS ────────────────────────────────────────────────

local function display_width(text)
    return vim.fn.strdisplaywidth(text)
end

local function truncate(text, max_width)
    if max_width <= 0 then
        return ""
    end
    if display_width(text) <= max_width then
        return text
    end

    local out, index = "", 0
    while true do
        local char = vim.fn.strcharpart(text, index, 1)
        if char == "" or display_width(out .. char) > max_width - 1 then
            break
        end
        out = out .. char
        index = index + 1
    end
    return out .. "…"
end

local function relative_time(timestamp)
    if not timestamp then
        return ""
    end
    local delta = os.time() - timestamp
    if delta < 60 then
        return "just now"
    elseif delta < 3600 then
        return math.floor(delta / 60) .. "m ago"
    elseif delta < 86400 then
        return math.floor(delta / 3600) .. "h ago"
    end
    return math.floor(delta / 86400) .. "d ago"
end

-- ── BUILDER ──────────────────────────────────────────────────────

local Builder = {}
Builder.__index = Builder

local function new_builder(win_width, cfg)
    return setmetatable({
        cfg = cfg,
        win_width = win_width,
        width = math.min(math.max(win_width - 4, 40), 96),
        lines = {},
        spans = {},
        rows = {},
    }, Builder)
end

function Builder:left()
    return math.max(math.floor((self.win_width - self.width) / 2), 0)
end

function Builder:blank()
    table.insert(self.lines, "")
    return #self.lines
end

--- Push a row made of { text, highlight } segments. Returns the line number.
function Builder:push(segments)
    -- The padding must be part of the text: highlight columns are byte columns
    -- of this same buffer line, so both have to start at the same offset.
    local pad = string.rep(" ", self:left())
    local text, col = pad, #pad
    for _, segment in ipairs(segments or { { "", nil } }) do
        local chunk = segment[1] or ""
        if segment[2] then
            table.insert(self.spans, {
                line = #self.lines,
                start_col = col,
                end_col = col + #chunk,
                group = segment[2],
            })
        end
        text = text .. chunk
        col = col + #chunk
    end
    table.insert(self.lines, text)
    return #self.lines
end

function Builder:centered(segments)
    local total = 0
    for _, segment in ipairs(segments) do
        total = total + display_width(segment[1] or "")
    end
    -- push() already prepends the left gutter, so only the remaining centering
    -- offset is added here.
    local pad_width = math.max(math.floor((self.win_width - total) / 2) - self:left(), 0)
    local pad = string.rep(" ", pad_width)
    local shifted = { { pad, nil } }
    vim.list_extend(shifted, segments)
    return self:push(shifted)
end

function Builder:section(title)
    self:push { { title, "DashTitle" } }
end

function Builder:rule()
    self:push { { string.rep("─", self.width), "DashRule" } }
end

--- One actionable line: [key] icon label ... suffix
function Builder:item(opts)
    local key = opts.key and ("[" .. opts.key .. "]") or "[↵]"
    local segments = {
        { "  " .. key .. "  ", "DashKey" },
    }

    if self.cfg.icons and opts.icon and opts.icon ~= "" then
        table.insert(segments, { opts.icon .. " ", "DashText" })
    end

    table.insert(segments, { opts.label, opts.group or "DashText" })

    if opts.suffix and opts.suffix ~= "" then
        local used = 0
        for _, segment in ipairs(segments) do
            used = used + display_width(segment[1])
        end
        local room = self.width - used - display_width(opts.suffix) - 2
        if room > 2 then
            table.insert(segments, { string.rep(" ", room), nil })
            table.insert(segments, { opts.suffix, opts.suffix_group or "DashPath" })
        end
    end

    local line = self:push(segments)
    if opts.action then
        table.insert(self.rows, { line = line, action = opts.action, info = opts.info })
    end
    return line
end

--- Two action columns with a deterministic split column.
function Builder:columns(items, col_width)
    for index = 1, #items, 2 do
        local first, second = items[index], items[index + 1]
        local first_cell = "  [" .. first.key .. "]  " .. first.label
        local pad = math.max(col_width - display_width(first_cell), 2)
        local line = self:push {
            { first_cell, "DashKey" },
            { second and string.rep(" ", pad) or "", nil },
            second and { "[" .. second.key .. "]  ", "DashKey" } or nil,
            second and { second.label, "DashText" } or nil,
        }
        local split_at = self:left() + col_width
        table.insert(self.rows, {
            line = line,
            action = function()
                if second and vim.fn.col "." - 1 >= split_at then
                    second.action()
                else
                    first.action()
                end
            end,
            info = { type = "columns", first = first, second = second },
        })
    end
end

--- A card row with left and right aligned groups.
function Builder:card_line(left_segments, right_segments)
    local inner = self.width - 2
    local right_width = 0
    for _, segment in ipairs(right_segments) do
        right_width = right_width + display_width(segment[1] or "")
    end

    local left_width = 0
    for _, segment in ipairs(left_segments) do
        left_width = left_width + display_width(segment[1] or "")
    end

    local available = inner - right_width - 3
    local segments = { { "│ ", "DashBorder" } }

    local used = 0
    for _, segment in ipairs(left_segments) do
        local chunk = segment[1] or ""
        local room = available - used
        if room <= 0 then
            break
        end
        chunk = truncate(chunk, room)
        table.insert(segments, { chunk, segment[2] })
        used = used + display_width(chunk)
        if chunk ~= (segment[1] or "") then
            break
        end
    end

    table.insert(segments, { string.rep(" ", math.max(inner - used - right_width - 2, 1)), nil })
    vim.list_extend(segments, right_segments)
    table.insert(segments, { " │", "DashBorder" })

    return self:push(segments)
end

-- ── SECTIONS ─────────────────────────────────────────────────────

local ART = {
    "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
    "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
    "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
    "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}

local function render_header(builder, snapshot)
    local env = snapshot.env
    builder:blank()

    if builder.win_width >= 70 then
        for index, line in ipairs(ART) do
            builder:centered { { line, "DashArt" .. index } }
        end
    else
        builder:centered { { "NEOVIM", "DashHeader" } }
    end

    local parts = { "Neovim " .. env.version }
    if builder.cfg.show.plugins then
        table.insert(parts, env.plugins .. " plugins")
    end
    if builder.cfg.show.startup and env.startup_ms then
        table.insert(parts, env.startup_ms .. " ms startup")
    end
    table.insert(parts, "week " .. env.week)
    table.insert(parts, env.date)
    local subtitle = truncate(table.concat(parts, "  ·  "), builder.win_width - 4)
    builder:centered { { subtitle, "DashSub" } }
    builder:blank()
end

local function render_status(builder, snapshot)
    local git = snapshot.git
    local diag = snapshot.diag
    local env = snapshot.env

    builder:push { { "╭" .. string.rep("─", builder.width - 2) .. "╮", "DashBorder" } }

    local branch = git.is_git and git.branch or "not a repository"
    if git.is_git and git.files > 0 then
        branch = branch .. "  ·  " .. git.files .. " files"
    end
    builder:card_line({
        { snapshot.cwd_short, "DashTitle" },
    }, {
        { branch, git.is_git and "DashOk" or "DashPath" },
    })

    local git_text
    if not git.is_git then
        git_text = "git: unavailable"
    elseif git.clean then
        git_text = "clean tree"
    else
        git_text = string.format("+%d staged  ~%d changed  ?%d untracked", git.staged, git.modified, git.untracked)
    end
    if git.is_git then
        git_text = git_text .. string.format("  ↑%d ↓%d  stash %d", git.ahead, git.behind, git.stash)
    end

    local diag_text = string.format("E %d  W %d  I %d  H %d", diag.error, diag.warn, diag.info, diag.hint)
    builder:card_line({
        { git_text, git.clean and "DashOk" or "DashWarn" },
    }, {
        { diag_text, (diag.error > 0 and "DashErr") or (diag.warn > 0 and "DashWarn") or "DashOk" },
    })

    local env_segments = {}
    if builder.cfg.show.lsp then
        local lsp = env.lsp_count > 0 and table.concat(env.lsp, ", ") or "none"
        table.insert(env_segments, { "LSP " .. env.lsp_count .. ": " .. lsp, "DashText" })
    end
    if builder.cfg.show.formatters then
        if #env_segments > 0 then
            table.insert(env_segments, { "  ·  ", "DashDim" })
        end
        local formatters = env.formatters .. " formatters"
        if env.missing_formatters > 0 then
            formatters = formatters .. " (" .. env.missing_formatters .. " missing)"
        end
        table.insert(env_segments, { formatters, env.missing_formatters > 0 and "DashWarn" or "DashText" })
    end
    if #env_segments > 0 then
        builder:card_line(env_segments, {})
    end

    if git.is_git and git.last_commit then
        local commit = git.last_commit
        local left = "  " .. (commit.subject or "no commits yet")
        if commit.author and commit.author ~= "" then
            left = left .. "  ·  " .. commit.author
        end
        local right = commit.hash or ""
        if commit.when and commit.when ~= "" then
            right = right .. " · " .. commit.when
        end
        builder:card_line({
            { truncate(left, builder.width - 16), "DashText" },
        }, {
            { truncate(right, 24), "DashPath" },
        })
    end

    if builder.cfg.show.last_build and snapshot.build then
        local status = snapshot.build.status or "unknown"
        local group = status == "passed" and "DashOk" or "DashErr"
        local label = snapshot.build.label or "build"
        local when = snapshot.build.when and ("  ·  " .. snapshot.build.when) or ""
        builder:card_line({ { "last build: " .. label .. " · " .. status .. when, group } }, {})
    end

    builder:push { { "╰" .. string.rep("─", builder.width - 2) .. "╯", "DashBorder" } }
    builder:blank()
end

local function render_diagnostics(builder, snapshot)
    local diag = snapshot.diag
    builder:section "PROJECT DIAGNOSTICS"

    if diag.total == 0 then
        builder:push { { "  No diagnostics in loaded buffers.", "DashOk" } }
        builder:push { { "  Open a file or restore a session to analyze the project.", "DashPath" } }
        builder:blank()
        return
    end

    local counts = {
        { string.format("%d errors", diag.error), diag.error > 0 and "DashErr" or "DashDim" },
        { "  ·  ", "DashDim" },
        { string.format("%d warnings", diag.warn), diag.warn > 0 and "DashWarn" or "DashDim" },
        { "  ·  ", "DashDim" },
        { string.format("%d info", diag.info), diag.info > 0 and "DashText" or "DashDim" },
        { "  ·  ", "DashDim" },
        { string.format("%d hints", diag.hint), diag.hint > 0 and "DashText" or "DashDim" },
    }
    builder:push(counts)

    local limit = builder.cfg.limits.diagnostics
    for index, file in ipairs(diag.files) do
        if index > limit then
            break
        end
        local suffix = string.format("%dE %dW %dI %dH", file.error, file.warn, file.info, file.hint)
        builder:item {
            icon = snapshot.icons.file_for(file.name),
            label = file.rel,
            suffix = suffix,
            suffix_group = file.error > 0 and "DashErr" or (file.warn > 0 and "DashWarn" or "DashPath"),
            action = function()
                snapshot.callbacks.open_diagnostic(file.bufnr)
            end,
        }
    end

    if #diag.files > limit then
        builder:push { { "  … " .. (#diag.files - limit) .. " more (d: full list)", "DashPath" } }
    end
    builder:blank()
end

local function render_actions(builder, snapshot)
    builder:section "ACTIONS"
    builder:columns(snapshot.actions, math.floor(builder.width / 2))
    builder:blank()
end

local function render_sessions(builder, snapshot)
    builder:section "SESSIONS"

    builder:item {
        key = "s",
        label = snapshot.session_latest and "Restore project/branch layout" or "Restore directory session",
        suffix = snapshot.session_latest and relative_time(snapshot.session_latest.saved_at) or nil,
        action = snapshot.callbacks.restore_session,
    }
    builder:item {
        key = "S",
        label = "Save current layout for this project/branch",
        action = snapshot.callbacks.save_session,
    }
    builder:item { key = "L", label = "Restore last session", action = snapshot.callbacks.restore_last }
    builder:item { key = "X", label = "Ignore last session on exit", action = snapshot.callbacks.ignore_last }

    for _, entry in ipairs(snapshot.sessions) do
        builder:item {
            label = "layout: " .. (entry.branch or "no branch"),
            suffix = relative_time(entry.saved_at),
            group = "DashPath",
            action = function()
                snapshot.callbacks.restore_entry(entry)
            end,
        }
    end
    builder:blank()
end

local function render_buffers(builder, snapshot)
    if #snapshot.buffers == 0 then
        return
    end

    builder:section "OPEN BUFFERS"
    for _, buffer in ipairs(snapshot.buffers) do
        builder:item {
            icon = snapshot.icons.file_for(buffer.name),
            label = buffer.name,
            suffix = buffer.modified and "modified" or buffer.rel,
            suffix_group = buffer.modified and "DashWarn" or "DashPath",
            action = function()
                snapshot.callbacks.open_buffer(buffer.bufnr)
            end,
        }
    end
    builder:blank()
end

local function render_projects(builder, snapshot)
    builder:section "PROJECTS"
    if #snapshot.projects == 0 then
        builder:push { { "  No projects recorded yet. Open a repository to populate this list.", "DashPath" } }
    end

    for index, project in ipairs(snapshot.projects) do
        local is_current = project.path == vim.fn.getcwd()
        builder:item {
            key = tostring(index),
            icon = snapshot.icons.dir,
            label = project.name,
            suffix = is_current and "current" or vim.fn.fnamemodify(project.path, ":~"),
            suffix_group = is_current and "DashOk" or "DashPath",
            group = is_current and "DashOk" or "DashText",
            action = function()
                snapshot.callbacks.select_project(project.path)
            end,
        }
    end
    builder:blank()
end

local function render_directories(builder, snapshot)
    builder:section "DIRECTORIES"
    if #snapshot.directories == 0 then
        builder:push { { "  No recent directories.", "DashPath" } }
    end

    for _, dir in ipairs(snapshot.directories) do
        builder:item {
            icon = snapshot.icons.dir,
            label = dir.name,
            suffix = vim.fn.fnamemodify(dir.path, ":~"),
            action = function()
                snapshot.callbacks.select_project(dir.path)
            end,
        }
    end
    builder:blank()
end

local function render_recents(builder, snapshot)
    builder:section "RECENT FILES"

    for _, file in ipairs(snapshot.recents) do
        local suffix = file.missing and "missing · " .. file.rel_path or file.rel_path
        builder:item {
            icon = snapshot.icons.file_for(file.name),
            label = file.name,
            suffix = suffix,
            suffix_group = file.missing and "DashErr" or "DashPath",
            action = function()
                if file.missing then
                    vim.notify("File no longer exists: " .. file.path, vim.log.levels.WARN)
                    return
                end
                snapshot.callbacks.open_file(file.path)
            end,
        }
    end
    builder:blank()
end

local function render_todos(builder, snapshot)
    local todos = snapshot.todos
    builder:section("PROJECT TODOS" .. (todos and ("  (" .. todos.count .. ")") or ""))

    if not todos then
        builder:push { { "  scanning…", "DashPath" } }
    elseif todos.count == 0 then
        builder:push { { "  No TODO/FIXME markers found.", "DashOk" } }
    else
        local limit = builder.cfg.limits.todos
        local shown = 0
        for _, item in ipairs(todos.items) do
            if shown >= limit then
                break
            end
            shown = shown + 1
            local name = vim.fn.fnamemodify(item.path, ":~:.")
            builder:item {
                label = name .. ":" .. item.line,
                suffix = item.text,
                action = function()
                    snapshot.callbacks.jump(item.path, item.line)
                end,
            }
        end
        if todos.count > shown then
            builder:push { { "  … " .. (todos.count - shown) .. " more (u: browse all)", "DashPath" } }
        end
    end
    builder:blank()
end

local function render_pins(builder, snapshot)
    builder:section "PINNED"
    if #snapshot.pins == 0 then
        builder:item { key = "a", label = "Pin a file to this list", action = snapshot.callbacks.add_pin }
    else
        for index, pin in ipairs(snapshot.pins) do
            builder:item {
                key = pin.done and "✔" or "○",
                icon = snapshot.icons.file_for(pin.name),
                label = pin.name,
                suffix = pin.done and "done" or vim.fn.fnamemodify(pin.path, ":~"),
                suffix_group = pin.done and "DashOk" or "DashPath",
                group = pin.done and "DashPath" or "DashText",
                action = function()
                    snapshot.callbacks.open_pin(pin)
                end,
                info = { type = "pin", index = index, pin = pin },
            }
        end
        builder:item { key = "a", label = "Pin another file", action = snapshot.callbacks.add_pin }
        builder:item { key = "x", label = "Toggle pin under the cursor as done", action = snapshot.callbacks.toggle_pin }
        builder:item { key = "D", label = "Remove pin under the cursor", action = snapshot.callbacks.remove_pin }
    end
end

local function render_footer(builder)
    builder:blank()
    builder:centered { { "hjkl/arrows move · Enter opens · / searches · ? help", "DashPath" } }
    builder:centered { { "f files · w grep · b buffers · r recents · g git", "DashPath" } }
    builder:centered { { "R refresh · q quit", "DashPath" } }
    builder:blank()
end

-- ── PUBLIC API ───────────────────────────────────────────────────

--- Build the dashboard. Returns lines, highlight spans and interactive rows.
---@return string[] lines
---@return table[] spans
---@return table[] rows
function M.build(snapshot, cfg, win_width, win_height)
    M.setup_highlights()

    local builder = new_builder(win_width, cfg)
    local renderers = {
        header = render_header,
        status = render_status,
        diagnostics = render_diagnostics,
        actions = render_actions,
        sessions = render_sessions,
        buffers = render_buffers,
        projects = render_projects,
        directories = render_directories,
        recents = render_recents,
        todos = render_todos,
        pins = render_pins,
    }

    for _, name in ipairs(cfg.sections) do
        local renderer = renderers[name]
        if renderer then
            renderer(builder, snapshot)
        end
    end

    render_footer(builder)

    table.sort(builder.rows, function(a, b)
        return a.line < b.line
    end)

    -- Center the whole layout vertically when it fits, leaving breathing room
    -- above and below instead of pinning it to the top of the window.
    if win_height and win_height > #builder.lines then
        local top = math.floor((win_height - #builder.lines) / 2)
        if top > 0 then
            for _ = 1, top do
                table.insert(builder.lines, 1, "")
            end
            for _, span in ipairs(builder.spans) do
                span.line = span.line + top
            end
            for _, row in ipairs(builder.rows) do
                row.line = row.line + top
            end
        end
    end

    return builder.lines, builder.spans, builder.rows
end

return M
