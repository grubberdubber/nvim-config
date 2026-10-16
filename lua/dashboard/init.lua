---@class DashboardModule
local M = {}

local uv = vim.uv or vim.loop
local PINS_FILE = vim.fn.stdpath("data") .. "/dashboard_pins.json"
local PROJECTS_FILE = vim.fn.stdpath("data") .. "/dashboard_projects.json"

local dashboard_buf = nil
local dashboard_win = nil
local line_actions = {}
local interactive_lines = {}
local line_item_info = {}

-- ── PERSISTENCIA Y ESTADO ───────────────────────────────────────────

local function read_json_file(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    if not content or content == "" then
        return nil
    end
    local ok, res = pcall(vim.json.decode, content)
    if ok and type(res) == "table" then
        return res
    end
    return nil
end

local function write_json_file(path, data)
    local ok, encoded = pcall(vim.json.encode, data)
    if not ok then
        return false
    end
    local f = io.open(path, "w")
    if not f then
        return false
    end
    f:write(encoded)
    f:close()
    return true
end

function M.get_pins()
    local pins = read_json_file(PINS_FILE) or {}
    return pins
end

function M.save_pins(pins)
    write_json_file(PINS_FILE, pins)
end

function M.toggle_pin(idx)
    local pins = M.get_pins()
    if pins[idx] then
        pins[idx].done = not pins[idx].done
        M.save_pins(pins)
        local cur_pos = vim.api.nvim_win_get_cursor(0)
        M.render()
        pcall(vim.api.nvim_win_set_cursor, 0, cur_pos)
    end
end

function M.remove_pin(idx)
    local pins = M.get_pins()
    if pins[idx] then
        local removed = table.remove(pins, idx)
        M.save_pins(pins)
        vim.notify("Desanclado: " .. (removed.name or removed.path), vim.log.levels.INFO)
        M.render()
    end
end

function M.add_pin(filepath)
    if not filepath or filepath == "" then
        return
    end
    local full_path = vim.fn.fnamemodify(filepath, ":p")
    local name = vim.fn.fnamemodify(full_path, ":t")
    local pins = M.get_pins()

    for _, p in ipairs(pins) do
        if p.path == full_path then
            vim.notify("El archivo ya está fijado: " .. name, vim.log.levels.WARN)
            return
        end
    end

    table.insert(pins, {
        path = full_path,
        name = name,
        done = false,
        added_at = os.time(),
    })
    M.save_pins(pins)
    vim.notify("Archivo fijado al Dashboard: " .. name, vim.log.levels.INFO)
    M.render()
end

function M.prompt_add_pin()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        telescope.find_files({
            prompt_title = "📌 Selecciona archivo para fijar al Dashboard",
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if selection then
                        local path = selection.path or selection.value or selection[1]
                        M.add_pin(path)
                    end
                end)
                return true
            end,
        })
    else
        vim.ui.input({
            prompt = "Ruta del archivo a fijar: ",
            completion = "file",
        }, function(input)
            if input and input ~= "" then
                M.add_pin(input)
            end
        end)
    end
end

-- ── GESTIÓN DE PROYECTOS Y DIRECTORIOS ──────────────────────────────

function M.get_projects()
    local projects = read_json_file(PROJECTS_FILE) or {}
    local current_cwd = vim.fn.getcwd()
    local exists = false

    for i, p in ipairs(projects) do
        if p.path == current_cwd then
            exists = true
            p.last_opened = os.time()
            table.remove(projects, i)
            table.insert(projects, 1, p)
            break
        end
    end

    if not exists and current_cwd ~= "" and current_cwd ~= "/" then
        local name = vim.fn.fnamemodify(current_cwd, ":t")
        table.insert(projects, 1, {
            path = current_cwd,
            name = (name ~= "" and name) or current_cwd,
            last_opened = os.time(),
        })
    end

    -- Si tenemos pocos proyectos, descubrir de oldfiles
    if #projects < 4 then
        local seen = {}
        for _, p in ipairs(projects) do
            seen[p.path] = true
        end

        for _, file in ipairs(vim.v.oldfiles or {}) do
            if #projects >= 6 then
                break
            end
            if file and uv.fs_stat(file) then
                local dir = vim.fn.fnamemodify(file, ":p:h")
                local git_out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel")
                local root = (vim.v.shell_error == 0 and git_out[1] and git_out[1] ~= "") and git_out[1] or dir

                if root and root ~= "" and uv.fs_stat(root) and not seen[root] and root ~= vim.env.HOME and root ~= "/" then
                    seen[root] = true
                    table.insert(projects, {
                        path = root,
                        name = vim.fn.fnamemodify(root, ":t"),
                        last_opened = os.time() - 3600,
                    })
                end
            end
        end
    end

    write_json_file(PROJECTS_FILE, projects)
    return projects
end

function M.select_project(path)
    if not path or path == "" or not uv.fs_stat(path) then
        vim.notify("Directorio inválido: " .. tostring(path), vim.log.levels.WARN)
        return
    end
    vim.fn.chdir(path)
    vim.notify("Proyecto cambiado a: " .. path, vim.log.levels.INFO)
    M.render()
end

function M.prompt_projects()
    local projects = M.get_projects()
    local items = {}
    for _, p in ipairs(projects) do
        table.insert(items, p.name .. " (" .. p.path .. ")")
    end
    vim.ui.select(items, {
        prompt = "📂 Selecciona un Proyecto Reciente:",
    }, function(choice, idx)
        if choice and idx and projects[idx] then
            M.select_project(projects[idx].path)
        end
    end)
end

-- ── INFORMACIÓN DE GIT ──────────────────────────────────────────────

function M.get_git_info()
    local cwd = vim.fn.getcwd()
    local git_check = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --is-inside-work-tree")
    if vim.v.shell_error ~= 0 or not git_check[1] or git_check[1] ~= "true" then
        return { is_git = false }
    end

    local branch_out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " branch --show-current")
    local branch = (branch_out and branch_out[1] and branch_out[1] ~= "") and branch_out[1] or "HEAD (detached)"

    local status_lines = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " status --porcelain")
    local staged = 0
    local modified = 0
    local untracked = 0

    if vim.v.shell_error == 0 and status_lines then
        for _, line in ipairs(status_lines) do
            if #line >= 2 then
                local x = line:sub(1, 1)
                local y = line:sub(2, 2)
                if x == "?" then
                    untracked = untracked + 1
                else
                    if x ~= " " and x ~= "?" then
                        staged = staged + 1
                    end
                    if y ~= " " and y ~= "?" then
                        modified = modified + 1
                    end
                end
            end
        end
    end

    local commit_out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " log -1 --pretty=format:'%h %s (%cr)'")
    local last_commit = (commit_out and commit_out[1] and commit_out[1] ~= "") and commit_out[1] or nil

    return {
        is_git = true,
        branch = branch,
        staged = staged,
        modified = modified,
        untracked = untracked,
        last_commit = last_commit,
        clean = (staged == 0 and modified == 0 and untracked == 0),
    }
end

-- ── DIAGNÓSTICOS DEL PROYECTO ───────────────────────────────────────

function M.get_diagnostics()
    local diags = vim.diagnostic.get()
    local err = 0
    local warn = 0
    local info = 0
    local hint = 0

    for _, d in ipairs(diags) do
        if d.severity == vim.diagnostic.severity.ERROR then
            err = err + 1
        elseif d.severity == vim.diagnostic.severity.WARN then
            warn = warn + 1
        elseif d.severity == vim.diagnostic.severity.INFO then
            info = info + 1
        elseif d.severity == vim.diagnostic.severity.HINT then
            hint = hint + 1
        end
    end

    return {
        error = err,
        warn = warn,
        info = info,
        hint = hint,
        total = #diags,
    }
end

-- ── ARCHIVOS RECIENTES ──────────────────────────────────────────────

function M.get_recent_files(limit)
    limit = limit or 6
    local files = {}
    local seen = {}
    local current_cwd = vim.fn.getcwd()

    for _, f in ipairs(vim.v.oldfiles or {}) do
        if #files >= limit then
            break
        end
        if f and f ~= "" and not seen[f] then
            if not f:match("COMMIT_EDITMSG$")
                and not f:match("git%-rebase%-todo$")
                and not f:match("/tmp/")
                and not f:match("%.git/")
                and not f:match(" fugitive://")
                and uv.fs_stat(f)
            then
                seen[f] = true
                local rel = f
                if f:sub(1, #current_cwd) == current_cwd then
                    rel = "." .. f:sub(#current_cwd + 1)
                else
                    rel = vim.fn.fnamemodify(f, ":~")
                end
                table.insert(files, {
                    path = f,
                    name = vim.fn.fnamemodify(f, ":t"),
                    rel_path = rel,
                })
            end
        end
    end

    return files
end

-- ── HIGHLIGHTS DEL DASHBOARD ────────────────────────────────────────

local function setup_highlights()
    local function set_hl_default(name, opts)
        opts.default = true
        vim.api.nvim_set_hl(0, name, opts)
    end

    set_hl_default("DashHeader", { fg = "#7aa2f7", bold = true })
    set_hl_default("DashSub", { fg = "#bb9af7", italic = true })
    set_hl_default("DashKey", { fg = "#ffc27d", bold = true })
    set_hl_default("DashIcon", { fg = "#78dce8" })
    set_hl_default("DashTitle", { fg = "#78dce8", bold = true })
    set_hl_default("DashBorder", { fg = "#444b6a" })
    set_hl_default("DashDesc", { fg = "#c0caf5" })
    set_hl_default("DashPath", { fg = "#6272a4", italic = true })
    set_hl_default("DashBranch", { fg = "#9ece6a", bold = true })
    set_hl_default("DashGitClean", { fg = "#9ece6a" })
    set_hl_default("DashGitMod", { fg = "#ffc27d" })
    set_hl_default("DashGitAdd", { fg = "#73daca" })
    set_hl_default("DashGitDel", { fg = "#ff7a93" })
    set_hl_default("DashPinDone", { fg = "#6272a4", strikethrough = true })
    set_hl_default("DashPinPending", { fg = "#ffc27d", bold = true })
end

-- ── RENDERIZADO DEL DASHBOARD ───────────────────────────────────────

function M.render()
    if not dashboard_buf or not vim.api.nvim_buf_is_valid(dashboard_buf) then
        return
    end

    setup_highlights()

    vim.bo[dashboard_buf].modifiable = true
    vim.api.nvim_buf_clear_namespace(dashboard_buf, -1, 0, -1)

    local lines = {}
    local highlights = {}
    line_actions = {}
    interactive_lines = {}
    line_item_info = {}

    local width = 80
    if dashboard_win and vim.api.nvim_win_is_valid(dashboard_win) then
        width = math.max(vim.api.nvim_win_get_width(dashboard_win), 80)
    end

    local function add_line(text, hl_groups)
        table.insert(lines, text or "")
        local line_nr = #lines
        if hl_groups then
            for _, hl in ipairs(hl_groups) do
                if hl then
                    table.insert(highlights, {
                        line = line_nr - 1,
                        col_start = hl.start_col or 0,
                        col_end = hl.end_col or -1,
                        hl_group = hl.group,
                    })
                end
            end
        end
        return line_nr
    end

    local function add_centered(text, hl_group)
        local pad = math.max(math.floor((width - vim.fn.strdisplaywidth(text)) / 2), 0)
        local line_str = string.rep(" ", pad) .. text
        return add_line(line_str, { { start_col = pad, end_col = pad + #text, group = hl_group } })
    end

    local function add_interactive(display_text, action_fn, info, hl_groups)
        local line_nr = add_line(display_text, hl_groups)
        line_actions[line_nr] = action_fn
        line_item_info[line_nr] = info or {}
        table.insert(interactive_lines, line_nr)
        return line_nr
    end

    local pad_l = math.max(math.floor((width - 76) / 2), 2)
    local indent = string.rep(" ", pad_l)

    -- 1. Espacio inicial
    add_line("")

    -- 2. ARTE ASCII SOLICITADO EXACTAMENTE POR EL USUARIO:
    local ascii_art = {
        "▄▄▄ ▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄ ▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄▄▄",
        "█ ▀██ █ █ ▄▄▄▄█ █ ▄▄▄ █ █ █ █ █ █▄ ▄█ █ ▄ ▄ █",
        "█ █▄▀ █ █ ▄▄▄█▄ █ █▄█ █ █▄▀█▀▄█ ▄█ █▄ █ █ █ █",
        "█▄█▀█▄█ █▄▄▄▄▄█ █▄▄▄▄▄█  ▀█▄█▀  █▄▄▄█ █▄█▀█▄█",
    }
    for _, art_line in ipairs(ascii_art) do
        add_centered(art_line, "DashHeader")
    end

    -- Subtítulo
    local plugin_count = 0
    pcall(function()
        plugin_count = require("lazy").stats().count
    end)
    local sub_txt = " NEOVIM STAFF ENGINEER  •  󰏖 " .. tostring(plugin_count) .. " plugins cargados  •   LuaJIT"
    add_centered(sub_txt, "DashSub")
    add_line("")

    -- 3. TARJETA DE ESTADO (CWD, GIT, DIAGNÓSTICOS)
    local git = M.get_git_info()
    local diag = M.get_diagnostics()
    local cwd = vim.fn.getcwd()
    local cwd_disp = vim.fn.fnamemodify(cwd, ":~")

    local box_width = 72
    local bar = "─"
    local top_box = indent .. "╭" .. string.rep(bar, box_width) .. "╮"
    local bot_box = indent .. "╰" .. string.rep(bar, box_width) .. "╯"

    add_line(top_box, { { start_col = pad_l, end_col = -1, group = "DashBorder" } })

    -- Línea CWD + Git Branch
    local branch_disp = git.is_git and (" " .. git.branch) or " Sin Git"
    local left_part = " 󰉋 " .. cwd_disp
    local right_part = branch_disp .. " "
    local gap = box_width - vim.fn.strdisplaywidth(left_part) - vim.fn.strdisplaywidth(right_part)
    if gap < 2 then gap = 2 end
    local info_line = indent .. "│" .. left_part .. string.rep(" ", gap) .. right_part .. "│"
    add_line(info_line, {
        { start_col = pad_l, end_col = pad_l + 1, group = "DashBorder" },
        { start_col = pad_l + 2, end_col = pad_l + 5, group = "DashIcon" },
        { start_col = pad_l + 5, end_col = pad_l + 5 + #cwd_disp, group = "DashTitle" },
        { start_col = #info_line - #right_part - 1, end_col = #info_line - 1, group = git.is_git and "DashBranch" or "DashPath" },
        { start_col = #info_line - 1, end_col = #info_line, group = "DashBorder" },
    })

    -- Estado Git y Diagnósticos
    local git_status_str = ""
    local git_hl_group = "DashGitClean"
    if git.is_git then
        if git.clean then
            git_status_str = " Repositorio limpio"
            git_hl_group = "DashGitClean"
        else
            local parts = {}
            if git.staged > 0 then table.insert(parts, "+" .. git.staged .. " staged") end
            if git.modified > 0 then table.insert(parts, "~" .. git.modified .. " mod") end
            if git.untracked > 0 then table.insert(parts, "?" .. git.untracked .. " untracked") end
            git_status_str = "● " .. table.concat(parts, "  ")
            git_hl_group = "DashGitMod"
        end
    else
        git_status_str = "No en un repo git"
        git_hl_group = "DashPath"
    end

    local diag_str = string.format("󰅚 %d  󰀪 %d  󰌵 %d", diag.error, diag.warn, diag.hint)
    local l2_gap = box_width - vim.fn.strdisplaywidth(" " .. git_status_str) - vim.fn.strdisplaywidth(diag_str .. " ")
    if l2_gap < 2 then l2_gap = 2 end
    local info_line2 = indent .. "│ " .. git_status_str .. string.rep(" ", l2_gap) .. diag_str .. " │"
    add_line(info_line2, {
        { start_col = pad_l, end_col = pad_l + 1, group = "DashBorder" },
        { start_col = pad_l + 2, end_col = pad_l + 2 + #git_status_str, group = git_hl_group },
        { start_col = #info_line2 - #diag_str - 2, end_col = #info_line2 - 2, group = (diag.error > 0 and "DiagnosticError") or (diag.warn > 0 and "DiagnosticWarn") or "DashDesc" },
        { start_col = #info_line2 - 1, end_col = #info_line2, group = "DashBorder" },
    })

    add_line(bot_box, { { start_col = pad_l, end_col = -1, group = "DashBorder" } })
    add_line("")

    -- 4. LANZADORES RÁPIDOS (LAUNCHERS)
    local function render_section_title(title, icon)
        local t_line = indent .. "  " .. icon .. "  " .. title
        add_line(t_line, {
            { start_col = pad_l + 2, end_col = pad_l + 5, group = "DashIcon" },
            { start_col = pad_l + 5, end_col = -1, group = "DashTitle" },
        })
    end

    render_section_title("BUSCADORES & LANZADORES RÁPIDOS", "🚀")

    local launchers = {
        { key = "f", icon = " ", title = "Buscar Archivo", desc = "Telescope find_files", fn = function() require("telescope.builtin").find_files() end },
        { key = "w", icon = "󰈭 ", title = "Buscar Código", desc = "Telescope live_grep", fn = function() require("telescope.builtin").live_grep() end },
        { key = "b", icon = "󰈔 ", title = "Buffers Abiertos", desc = "Telescope buffers", fn = function() require("telescope.builtin").buffers() end },
        { key = "r", icon = " ", title = "Historial Reciente", desc = "Telescope oldfiles", fn = function() require("telescope.builtin").oldfiles() end },
        { key = "s", icon = "󰁯 ", title = "Restaurar Sesión", desc = "Sesión de este proyecto", fn = function() require("persistence").load() end },
        { key = "l", icon = "󰦛 ", title = "Última Sesión", desc = "Restaurar sesión previa", fn = function() require("persistence").load({ last = true }) end },
        { key = "g", icon = "󰊢 ", title = "Lazygit", desc = "Gestor Git interactivo", fn = function() vim.cmd("LazyGit") end },
        { key = "n", icon = "󰝒 ", title = "Nuevo Archivo", desc = "Crear buffer vacío", fn = function() vim.cmd("enew") end },
    }

    for i = 1, #launchers, 2 do
        local l1 = launchers[i]
        local l2 = launchers[i + 1]

        local col1_txt = string.format("   [%s] %s %-16s", l1.key, l1.icon, l1.title)
        local col2_txt = l2 and string.format("   [%s] %s %-16s", l2.key, l2.icon, l2.title) or ""
        local full_line = indent .. col1_txt .. string.rep(" ", math.max(36 - #col1_txt, 2)) .. col2_txt

        add_interactive(full_line, function()
            local col = vim.fn.col(".")
            if l2 and col > (pad_l + 32) then
                l2.fn()
            else
                l1.fn()
            end
        end, { type = "launcher", l1 = l1, l2 = l2 }, {
            { start_col = pad_l + 4, end_col = pad_l + 7, group = "DashKey" },
            { start_col = pad_l + 8, end_col = pad_l + 11, group = "DashIcon" },
            { start_col = pad_l + 11, end_col = pad_l + 30, group = "DashDesc" },
            l2 and { start_col = pad_l + 40, end_col = pad_l + 43, group = "DashKey" } or nil,
            l2 and { start_col = pad_l + 44, end_col = pad_l + 47, group = "DashIcon" } or nil,
            l2 and { start_col = pad_l + 47, end_col = pad_l + 66, group = "DashDesc" } or nil,
        })
    end

    add_line("")

    -- 5. ARCHIVOS FIJADOS (PINNED FILES / TO-DO)
    render_section_title("ARCHIVOS FIJADOS & PENDIENTES [a: Fijar | m: Marcar | d: Desanclar]", "📌")
    local pins = M.get_pins()

    if #pins == 0 then
        local empty_line = indent .. "   󰄱 Ningún archivo fijado. Presiona [a] para fijar archivos clave a tu lista."
        add_interactive(empty_line, function()
            M.prompt_add_pin()
        end, { type = "pin_empty" }, {
            { start_col = pad_l + 3, end_col = -1, group = "DashPath" },
        })
    else
        local ok_dev, devicons = pcall(require, "nvim-web-devicons")
        for idx, pin in ipairs(pins) do
            local mark = pin.done and "[✔]" or "[ ]"
            local ext = vim.fn.fnamemodify(pin.path, ":e")
            local icon = ok_dev and devicons.get_icon(pin.name, ext, { default = true }) or "󰈚"
            local status_text = pin.done and " (Editado)" or ""
            local display = string.format("   %s %s %-24s %s", mark, icon, pin.name .. status_text, pin.path)
            local line_hl = pin.done and "DashPinDone" or "DashPinPending"

            add_interactive(indent .. display, function()
                if uv.fs_stat(pin.path) then
                    vim.cmd("edit " .. vim.fn.fnameescape(pin.path))
                else
                    vim.notify("Archivo no encontrado: " .. pin.path, vim.log.levels.ERROR)
                end
            end, { type = "pin", index = idx, pin = pin }, {
                { start_col = pad_l + 3, end_col = pad_l + 6, group = pin.done and "DashGitClean" or "DashKey" },
                { start_col = pad_l + 7, end_col = pad_l + 10, group = "DashIcon" },
                { start_col = pad_l + 10, end_col = pad_l + 36, group = line_hl },
                { start_col = pad_l + 36, end_col = -1, group = "DashPath" },
            })
        end
    end

    add_line("")

    -- 6. GESTOR DE PROYECTOS Y DIRECTORIOS RECIENTES
    render_section_title("PROYECTOS & DIRECTORIOS RECIENTES [p: Selector]", "📂")
    local projects = M.get_projects()
    for idx = 1, math.min(#projects, 5) do
        local proj = projects[idx]
        local is_current = (proj.path == cwd)
        local curr_marker = is_current and " 󰄬 (Actual)" or ""
        local p_disp = string.format("   [%d] 󰉋 %-22s %s", idx, proj.name .. curr_marker, proj.path)

        add_interactive(indent .. p_disp, function()
            M.select_project(proj.path)
        end, { type = "project", index = idx, path = proj.path }, {
            { start_col = pad_l + 3, end_col = pad_l + 7, group = "DashKey" },
            { start_col = pad_l + 8, end_col = pad_l + 11, group = "DashIcon" },
            { start_col = pad_l + 11, end_col = pad_l + 35, group = is_current and "DashBranch" or "DashTitle" },
            { start_col = pad_l + 35, end_col = -1, group = "DashPath" },
        })
    end

    add_line("")

    -- 7. HISTORIAL GLOBAL DE ARCHIVOS RECIENTES
    render_section_title("HISTORIAL RECIENTE [r: Ver Todos]", "🕒")
    local recents = M.get_recent_files(6)
    local ok_dev, devicons = pcall(require, "nvim-web-devicons")

    for idx, f in ipairs(recents) do
        local ext = vim.fn.fnamemodify(f.name, ":e")
        local icon = ok_dev and devicons.get_icon(f.name, ext, { default = true }) or "󰈚"
        local f_disp = string.format("   [%d] %s %-22s %s", idx, icon, f.name, f.rel_path)

        add_interactive(indent .. f_disp, function()
            vim.cmd("edit " .. vim.fn.fnameescape(f.path))
        end, { type = "recent", index = idx, path = f.path }, {
            { start_col = pad_l + 3, end_col = pad_l + 7, group = "DashKey" },
            { start_col = pad_l + 8, end_col = pad_l + 11, group = "DashIcon" },
            { start_col = pad_l + 11, end_col = pad_l + 35, group = "DashDesc" },
            { start_col = pad_l + 35, end_col = -1, group = "DashPath" },
        })
    end

    add_line("")

    -- 8. PIE DE PÁGINA CON ATAJOS FÁCILES DE RECORDAR
    local footer_text = "hjkl / flechas: mover • Enter: abrir • f/w/b: buscar • a: fijar • m: toggle pin • q: salir"
    add_centered(footer_text, "DashPath")
    add_line("")

    vim.api.nvim_buf_set_lines(dashboard_buf, 0, -1, false, lines)

    local ns = vim.api.nvim_create_namespace("dashboard_hl")
    for _, hl in ipairs(highlights) do
        pcall(vim.api.nvim_buf_add_highlight, dashboard_buf, ns, hl.hl_group, hl.line, hl.col_start, hl.col_end)
    end

    vim.bo[dashboard_buf].modifiable = false
end

-- ── NAVEGACIÓN Y ACCIONES DEL TECLADO (BUFFER-LOCAL) ────────────────

local function setup_buffer_keymaps(buf)
    local function bmap(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, nowait = true, desc = desc })
    end

    local function activate_current()
        local line = vim.fn.line(".")
        local action = line_actions[line]
        if action then
            action()
        end
    end
    bmap("<CR>", activate_current, "Dashboard: Abrir / Ejecutar")
    bmap("<Space>", activate_current, "Dashboard: Abrir / Ejecutar")

    -- Tab / S-Tab para saltar entre opciones interactivas
    bmap("<Tab>", function()
        local current = vim.fn.line(".")
        for _, l in ipairs(interactive_lines) do
            if l > current then
                vim.api.nvim_win_set_cursor(0, { l, 0 })
                return
            end
        end
        if #interactive_lines > 0 then
            vim.api.nvim_win_set_cursor(0, { interactive_lines[1], 0 })
        end
    end, "Dashboard: Siguiente opción")

    bmap("<S-Tab>", function()
        local current = vim.fn.line(".")
        for i = #interactive_lines, 1, -1 do
            local l = interactive_lines[i]
            if l < current then
                vim.api.nvim_win_set_cursor(0, { l, 0 })
                return
            end
        end
        if #interactive_lines > 0 then
            vim.api.nvim_win_set_cursor(0, { interactive_lines[#interactive_lines], 0 })
        end
    end, "Dashboard: Opción anterior")

    -- Atajos directos sin combinaciones complejas:
    bmap("f", function() require("telescope.builtin").find_files() end, "Dashboard: Buscar archivos")
    bmap("w", function() require("telescope.builtin").live_grep() end, "Dashboard: Buscar texto en código")
    bmap("b", function() require("telescope.builtin").buffers() end, "Dashboard: Ver buffers")
    bmap("r", function() require("telescope.builtin").oldfiles() end, "Dashboard: Historial reciente")
    bmap("s", function() require("persistence").load() end, "Dashboard: Restaurar sesión del directorio")
    bmap("l", function() require("persistence").load({ last = true }) end, "Dashboard: Restaurar última sesión")
    bmap("g", function() vim.cmd("LazyGit") end, "Dashboard: Lazygit")
    bmap("n", function() vim.cmd("enew") end, "Dashboard: Nuevo archivo")
    bmap("p", function() M.prompt_projects() end, "Dashboard: Selector de proyectos")
    bmap("a", function() M.prompt_add_pin() end, "Dashboard: Fijar archivo")

    -- Marcar / alternar pin como completado
    bmap("m", function()
        local line = vim.fn.line(".")
        local info = line_item_info[line]
        if info and info.type == "pin" then
            M.toggle_pin(info.index)
        else
            for _, l in ipairs(interactive_lines) do
                local inf = line_item_info[l]
                if inf and inf.type == "pin" then
                    M.toggle_pin(inf.index)
                    return
                end
            end
        end
    end, "Dashboard: Marcar/Desmarcar pin como editado")

    -- Eliminar pin
    bmap("d", function()
        local line = vim.fn.line(".")
        local info = line_item_info[line]
        if info and info.type == "pin" then
            M.remove_pin(info.index)
        end
    end, "Dashboard: Desanclar archivo")

    -- Teclas numéricas 1-5: abrir proyecto o reciente correspondiente
    for num = 1, 5 do
        bmap(tostring(num), function()
            local line = vim.fn.line(".")
            local info = line_item_info[line]
            if info and info.type == "recent" then
                local recents = M.get_recent_files(6)
                if recents[num] then
                    vim.cmd("edit " .. vim.fn.fnameescape(recents[num].path))
                    return
                end
            end
            local projects = M.get_projects()
            if projects[num] then
                M.select_project(projects[num].path)
            end
        end, "Dashboard: Acceso numérico rápido")
    end

    bmap("q", function()
        vim.cmd("qa")
    end, "Dashboard: Salir")

    bmap("R", function()
        M.render()
        vim.notify("Dashboard actualizado", vim.log.levels.INFO)
    end, "Dashboard: Refrescar")
end

-- ── APERTURA Y CONTROL DEL DASHBOARD ────────────────────────────────

function M.open()
    if dashboard_buf and vim.api.nvim_buf_is_valid(dashboard_buf) then
        if vim.api.nvim_get_current_buf() == dashboard_buf then
            M.render()
            return
        end
    end

    dashboard_buf = vim.api.nvim_create_buf(false, true)
    dashboard_win = vim.api.nvim_get_current_win()

    vim.bo[dashboard_buf].buftype = "nofile"
    vim.bo[dashboard_buf].filetype = "dashboard"
    vim.bo[dashboard_buf].bufhidden = "wipe"
    vim.bo[dashboard_buf].swapfile = false
    vim.bo[dashboard_buf].buflisted = false
    vim.api.nvim_buf_set_name(dashboard_buf, "Dashboard")

    vim.api.nvim_win_set_buf(dashboard_win, dashboard_buf)

    local wo = vim.wo[dashboard_win]
    wo.wrap = false
    wo.cursorline = true
    wo.number = false
    wo.relativenumber = false
    wo.foldenable = false
    wo.signcolumn = "no"
    wo.statuscolumn = ""

    setup_buffer_keymaps(dashboard_buf)
    M.render()

    if #interactive_lines > 0 then
        pcall(vim.api.nvim_win_set_cursor, dashboard_win, { interactive_lines[1], 0 })
    end
end

-- ── INICIALIZACIÓN AUTOMÁTICA EN ARRANQUE ───────────────────────────

function M.setup()
    vim.api.nvim_create_user_command("Dashboard", function()
        M.open()
    end, { desc = "Abrir Dashboard profesional" })

    vim.api.nvim_create_autocmd("VimEnter", {
        nested = true,
        callback = function()
            if vim.fn.argc() == 0 then
                local buf = vim.api.nvim_get_current_buf()
                local name = vim.api.nvim_buf_get_name(buf)
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                local is_empty = (name == "" and #lines <= 1 and (lines[1] == nil or lines[1] == ""))
                if is_empty then
                    M.open()
                end
            end
        end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            if dashboard_buf and vim.api.nvim_buf_is_valid(dashboard_buf) then
                if vim.api.nvim_get_current_buf() == dashboard_buf then
                    M.render()
                end
            end
        end,
    })
end

return M
