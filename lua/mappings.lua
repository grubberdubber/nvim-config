---@diagnostic disable: undefined-global
require "nvchad.mappings"

local map = vim.keymap.set

-- ── AI COMPLETION (WINDSURF, CTRL+G ONLY) ───────────────────────
-- Link instead of a hardcoded dark hex: the suggestion stays readable when
-- the theme changes. The plugin spec installs <C-g>/<C-]>.
vim.api.nvim_set_hl(0, "CodeiumSuggestion", { link = "Comment", force = true })

-- ── CORE ─────────────────────────────────────────────────────────
map("n", ";", ":", { desc = "Command: enter command-line mode" })
map("i", "jk", "<ESC>", { desc = "Insert: exit to normal mode" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "File: save" })
map("i", "<C-s>", "<ESC><cmd>w<CR>", { desc = "File: save from insert mode" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Window: close" })

-- Wrap-aware j/k that still honours counts: with a count (5j) the motion
-- stays line-based; without one it moves by screen line.
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move: down (wrap-aware, keeps count)" })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move: up (wrap-aware, keeps count)" })

map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move: selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move: selection up" })
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move: line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move: line up" })
map("v", "<", "<gv", { desc = "Indent: left" })
map("v", ">", ">gv", { desc = "Indent: right" })
map("v", "p", '"_dP', { desc = "Paste: keep register" })

map("n", "<C-h>", "<C-w>h", { desc = "Window: focus left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window: focus right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window: focus below" })
map("n", "<C-k>", "<C-w>k", { desc = "Window: focus above" })

map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Buffer: next" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Buffer: previous" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Buffer: delete current" })

-- ── LSP ──────────────────────────────────────────────────────────
map("n", "gd", vim.lsp.buf.definition, { desc = "LSP: go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: go to declaration" })
map("n", "gR", vim.lsp.buf.references, { desc = "LSP: list references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "LSP: hover documentation" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: code actions" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP: format file" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostics: previous" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostics: next" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Diagnostics: show float" })

-- ── SYMBOLS (TELESCOPE + LSP) ────────────────────────────────────
map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Symbols: document" })
map("n", "<leader>sS", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Symbols: workspace" })

-- ── QUICKFIX ─────────────────────────────────────────────────────
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Quickfix: next item" })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Quickfix: previous item" })

-- ── CODE EXECUTION ───────────────────────────────────────────────
map("n", "<leader>sr", "<cmd>SnipRun<CR>", { desc = "SnipRun: run line" })
map("v", "<leader>sr", "<cmd>'<,'>SnipRun<CR>", { desc = "SnipRun: run selection" })
map("n", "<leader>sc", "<cmd>SnipReset<CR>", { desc = "SnipRun: clear output" })

map("n", "<leader>ro", "<cmd>IronRepl<CR>", { desc = "REPL: open" })
map("n", "<leader>rr", "<cmd>IronRestart<CR>", { desc = "REPL: restart" })
map("n", "<leader>rc", function()
    require("iron.core").close_repl()
end, { desc = "REPL: close" })
map("n", "<leader>rs", function()
    require("iron.core").send_line()
end, { desc = "REPL: send line" })
map("v", "<leader>rs", function()
    require("iron.core").visual_send()
end, { desc = "REPL: send selection" })

-- ── DATABASES (VIM-DADBOD) ───────────────────────────────────────
map("n", "<leader>db", "<cmd>DBUI<CR>", { desc = "Database: focus or open UI" })
map("n", "<leader>dq", "<cmd>%DB<CR>", { desc = "Database: execute buffer" })
map("v", "<leader>dq", ":'<,'>DB<CR>", { desc = "Database: execute selection" })

-- ── TROUBLE (TRIAGE PANELS) ──────────────────────────────────────
map(
    "n",
    "<leader>tt",
    "<cmd>Trouble diagnostics toggle focus=true win.position=bottom<CR>",
    { desc = "Trouble: project diagnostics" }
)
map(
    "n",
    "<leader>tx",
    "<cmd>Trouble diagnostics toggle focus=true win.position=bottom<CR>",
    { desc = "Trouble: project diagnostics" }
)
map(
    "n",
    "<leader>td",
    "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<CR>",
    { desc = "Trouble: buffer diagnostics" }
)
map("n", "<leader>tq", "<cmd>Trouble qflist toggle<CR>", { desc = "Trouble: quickfix list" })
map("n", "<leader>tl", "<cmd>Trouble loclist toggle<CR>", { desc = "Trouble: location list" })
map(
    "n",
    "<leader>ts",
    "<cmd>Trouble symbols toggle focus=false win.position=right<CR>",
    { desc = "Trouble: document symbols" }
)
map(
    "n",
    "<leader>tL",
    "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
    { desc = "Trouble: LSP definitions/references" }
)
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "TODO/FIXME: search the project" })

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Git: open Lazygit" })
map("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "Buffers: pick with Telescope" })

-- ── DEBUGGER (DAP) ───────────────────────────────────────────────
map("n", "<F5>", function()
    require("dap").continue()
end, { desc = "Debug: start / continue" })
map("n", "<F9>", function()
    require("dap").toggle_breakpoint()
end, { desc = "Debug: toggle breakpoint" })
map("n", "<F10>", function()
    require("dap").step_over()
end, { desc = "Debug: step over" })
map("n", "<F11>", function()
    require("dap").step_into()
end, { desc = "Debug: step into" })
map("n", "<F12>", function()
    require("dap").step_out()
end, { desc = "Debug: step out" })
map("n", "<S-F5>", function()
    require("dap").terminate()
end, { desc = "Debug: terminate session" })
map("n", "<leader>B", function()
    require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, { desc = "Debug: conditional breakpoint" })
map("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Debug: toggle UI" })
map("n", "<leader>dr", function()
    require("dap").repl.open()
end, { desc = "Debug: open REPL" })
map("n", "<leader>dl", function()
    require("dap").run_last()
end, { desc = "Debug: rerun last session" })
map("n", "<leader>dpt", function()
    require("dap-python").test_method()
end, { desc = "Debug: Python test method" })
map("n", "<leader>dpc", function()
    require("dap-python").test_class()
end, { desc = "Debug: Python test class" })

-- ── FILESYSTEM (OIL) ─────────────────────────────────────────────
map("n", "-", "<CMD>Oil<CR>", { desc = "Files: open parent directory (Oil)" })

-- ── HARPOON ──────────────────────────────────────────────────────
local harpoon = require "harpoon"
map("n", "<leader>ha", function()
    harpoon:list():add()
end, { desc = "Harpoon: pin current file" })
map("n", "<leader>hm", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: quick menu" })
map("n", "<leader>1", function()
    harpoon:list():select(1)
end, { desc = "Harpoon: jump to file 1" })
map("n", "<leader>2", function()
    harpoon:list():select(2)
end, { desc = "Harpoon: jump to file 2" })
map("n", "<leader>3", function()
    harpoon:list():select(3)
end, { desc = "Harpoon: jump to file 3" })
map("n", "<leader>4", function()
    harpoon:list():select(4)
end, { desc = "Harpoon: jump to file 4" })

-- ── TODO COMMENTS ────────────────────────────────────────────────
map("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "TODO: next comment" })
map("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "TODO: previous comment" })

-- ── RENAME CURRENT FILE WITHOUT A FILE MANAGER ───────────────────
map("n", "<leader>rf", function()
    local current_file = vim.fn.expand "%:p"
    if current_file == "" then
        vim.notify("No file open to rename.", vim.log.levels.WARN)
        return
    end

    local new_name = vim.fn.input("Rename to: ", current_file, "file")
    if new_name ~= "" and new_name ~= current_file then
        vim.cmd("saveas " .. vim.fn.fnameescape(new_name))
        vim.fn.delete(current_file)
        vim.cmd "bd #"
        vim.notify("Renamed to " .. vim.fn.fnamemodify(new_name, ":t"), vim.log.levels.INFO)
    end
end, { desc = "File: rename current file" })

-- ── TERMINALS ────────────────────────────────────────────────────
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal: exit to normal mode" })
map("t", "<leader>q", "<C-\\><C-n><cmd>quit<CR>", { desc = "Terminal: close window" })

-- ── WINDOW MANAGEMENT ────────────────────────────────────────────
-- `q` closes any auxiliary window/panel. It never quits Neovim: when it is
-- the last normal file window, `q` is fed back so macro recording still works.
map("n", "q", function()
    local panels = require "configs.panels"
    if panels.can_close() then
        panels.close()
    else
        vim.api.nvim_feedkeys("q", "n", false)
    end
end, { desc = "Window: close panel (records macro if it is the only window)" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Window: close current" })
map("n", "<leader>Q", "<cmd>only<CR>", { desc = "Window: close all others" })

map("n", "<leader>wh", "<cmd>leftabove vsplit<CR>", { desc = "Split: open left" })
map("n", "<leader>wl", "<cmd>rightbelow vsplit<CR>", { desc = "Split: open right" })
map("n", "<leader>wk", "<cmd>aboveleft split<CR>", { desc = "Split: open above" })
map("n", "<leader>wj", "<cmd>belowright split<CR>", { desc = "Split: open below" })

-- ── OUTLINE (AERIAL) ─────────────────────────────────────────────
local aerial_excluded_ft = { sql = true, mysql = true, plsql = true }

map("n", "<leader>o", function()
    if aerial_excluded_ft[vim.bo.filetype] then
        vim.notify("Aerial has no outline backend for SQL.", vim.log.levels.WARN)
        return
    end
    local ok = pcall(require, "aerial")
    if ok then
        require("configs.panels").aerial_focus()
    else
        vim.notify("Aerial is not installed. Run :Lazy and press 'I'.", vim.log.levels.ERROR)
    end
end, { desc = "Aerial: focus or open outline" })

map("n", "[s", function()
    local ok, aerial = pcall(require, "aerial")
    if ok then
        aerial.prev()
    end
end, { desc = "Aerial: previous symbol" })

map("n", "]s", function()
    local ok, aerial = pcall(require, "aerial")
    if ok then
        aerial.next()
    end
end, { desc = "Aerial: next symbol" })

map("v", "y", '"+y', { desc = "Yank: selection to system clipboard" })
map("n", "<leader>Y", ":%y+<CR>", { desc = "Yank: whole buffer to system clipboard" })

-- ── SCROLLING ────────────────────────────────────────────────────
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll: half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll: half page up (centered)" })
map("n", "<C-e>", "3<C-e>", { desc = "Scroll: down 3 lines" })
map("n", "<C-y>", "3<C-y>", { desc = "Scroll: up 3 lines" })
map("n", "n", "nzzzv", { desc = "Search: next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Search: previous match (centered)" })

-- ── WINDOW RESIZING (spatially aware) ────────────────────────────
local function smart_resize(direction)
    local amount = 3
    local cur = vim.fn.winnr()

    if direction == "right" then
        if vim.fn.winnr "l" ~= cur then
            vim.cmd("vertical resize +" .. amount)
        elseif vim.fn.winnr "h" ~= cur then
            vim.cmd("vertical resize -" .. amount)
        end
    elseif direction == "left" then
        if vim.fn.winnr "l" ~= cur then
            vim.cmd("vertical resize -" .. amount)
        elseif vim.fn.winnr "h" ~= cur then
            vim.cmd("vertical resize +" .. amount)
        end
    elseif direction == "down" then
        if vim.fn.winnr "j" ~= cur then
            vim.cmd("resize +" .. amount)
        elseif vim.fn.winnr "k" ~= cur then
            vim.cmd("resize -" .. amount)
        end
    elseif direction == "up" then
        if vim.fn.winnr "j" ~= cur then
            vim.cmd("resize -" .. amount)
        elseif vim.fn.winnr "k" ~= cur then
            vim.cmd("resize +" .. amount)
        end
    end
end

map("n", "<C-Left>", function()
    smart_resize "left"
end, { desc = "Resize: border left" })
map("n", "<C-Right>", function()
    smart_resize "right"
end, { desc = "Resize: border right" })
map("n", "<C-Up>", function()
    smart_resize "up"
end, { desc = "Resize: border up" })
map("n", "<C-Down>", function()
    smart_resize "down"
end, { desc = "Resize: border down" })

-- ── TERMINAL IN THE MISSING DIRECTIONS ───────────────────────────
-- <A-h> bottom, <A-v> right and <A-i> float come from NvChad and stay as-is.
local function git_cwd()
    return vim.fs.root(vim.fn.expand "%:p:h", { ".git" }) or vim.fn.getcwd()
end

map({ "n", "t" }, "<A-j>", function()
    require("nvchad.term").toggle { pos = "vsp", id = "leftTerm", cwd = git_cwd() }
    vim.cmd "wincmd H"
end, { desc = "Terminal: toggle left (repo root)" })

map({ "n", "t" }, "<A-k>", function()
    require("nvchad.term").toggle { pos = "sp", id = "upTerm", cwd = git_cwd() }
    vim.cmd "wincmd K"
end, { desc = "Terminal: toggle top (repo root)" })

-- ── WINBAR NAVIGATION STATE (pending selection, nothing opens yet) ─
_G.WinbarNavState = { active = false, mode = nil, index = 1, items = {} }

local function winbar_reset_nav()
    _G.WinbarNavState = { active = false, mode = nil, index = 1, items = {} }
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = winbar_reset_nav,
})

local function get_breadcrumb_items()
    local full_path = vim.fn.expand "%:p"
    if full_path == "" then
        return {}
    end

    local dir = vim.fn.expand "%:p:h"
    local root = vim.fs.root(dir, { ".git" }) or vim.fn.getcwd()
    local prefix = root == "/" and "/" or (root .. "/")

    local rel
    if full_path:sub(1, #prefix) == prefix then
        rel = full_path:sub(#prefix + 1)
    else
        root = dir
        rel = vim.fn.expand "%:t"
    end

    local items = { { label = vim.fn.fnamemodify(root, ":t"), path = root, is_dir = true } }
    local accum = root
    for part in rel:gmatch "[^/]+" do
        accum = accum .. "/" .. part
        local is_last = (accum == full_path)
        table.insert(items, { label = part, path = accum, is_dir = not is_last })
    end
    return items
end

local function get_sibling_file_items()
    local dir = vim.fn.expand "%:p:h"
    local files = {}
    local handle = vim.loop.fs_scandir(dir)
    if handle then
        while true do
            local name, ftype = vim.loop.fs_scandir_next(handle)
            if not name then
                break
            end
            if ftype == "file" and not name:match "^%." then
                table.insert(files, name)
            end
        end
    end
    table.sort(files)

    local items = {}
    for _, f in ipairs(files) do
        table.insert(items, { label = f, path = dir .. "/" .. f, is_dir = false })
    end
    return items
end

-- ]f / [f only move the pending selection (highlighted); they never open.
local function winbar_nav_move(direction)
    local mode = vim.g.winbar_mode or "path"
    local state = _G.WinbarNavState

    if not state.active or state.mode ~= mode then
        local items = (mode == "files") and get_sibling_file_items() or get_breadcrumb_items()
        if #items == 0 then
            return
        end

        local current_marker = (mode == "files") and vim.fn.expand "%:t" or vim.fn.expand "%:p:h"
        local start_idx = #items
        for i, item in ipairs(items) do
            if item.path == current_marker or item.label == current_marker then
                start_idx = i
                break
            end
        end

        state.active = true
        state.mode = mode
        state.items = items
        state.index = start_idx
    end

    state.index = math.max(1, math.min(state.index + direction, #state.items))
    vim.cmd "redrawstatus!"
end

-- <CR> confirms the pending selection; without one it keeps default behaviour.
local function winbar_nav_confirm()
    local state = _G.WinbarNavState
    if not state.active or #state.items == 0 then
        vim.cmd "normal! +"
        return
    end

    local item = state.items[state.index]
    winbar_reset_nav()
    vim.cmd "redrawstatus!"

    if item.is_dir then
        require("oil").open(item.path)
    else
        vim.cmd("edit " .. vim.fn.fnameescape(item.path))
    end
end

map("n", "]f", function()
    winbar_nav_move(1)
end, { desc = "Winbar: select next entry (<CR> opens)" })
map("n", "[f", function()
    winbar_nav_move(-1)
end, { desc = "Winbar: select previous entry (<CR> opens)" })
map("n", "<CR>", winbar_nav_confirm, { desc = "Winbar: confirm selection / default <CR>" })

map("n", "<leader>ww", function()
    vim.g.winbar_mode = (vim.g.winbar_mode == "path") and "files" or "path"
    winbar_reset_nav()
    vim.notify("Winbar mode: " .. vim.g.winbar_mode, vim.log.levels.INFO)
    vim.cmd "redrawstatus!"
end, { desc = "Winbar: switch mode (path / files)" })

-- ── WEB PREVIEW (LIVE SERVER) ────────────────────────────────────
map("n", "<F4>", "<cmd>LiveServerStart<CR>", { desc = "Web: start live server" })
map("n", "<S-F4>", "<cmd>LiveServerStop<CR>", { desc = "Web: stop live server" })

-- ── QUICK NOTES ──────────────────────────────────────────────────
map("n", "<leader>nn", "<cmd>GlobalNote<CR>", { desc = "Notes: global note" })
map("n", "<leader>np", "<cmd>ProjectNote<CR>", { desc = "Notes: project note" })

-- ── FOLDING (nvim-ufo) ───────────────────────────────────────────
map("n", "zR", function()
    require("ufo").openAllFolds()
end, { desc = "Folds: open all" })
map("n", "zM", function()
    require("ufo").closeAllFolds()
end, { desc = "Folds: close all" })

-- ── REFACTORING (VISUAL SELECTION) ───────────────────────────────
map("v", "<leader>rv", function()
    require("refactoring").refactor "Extract Variable"
end, { desc = "Refactor: extract variable" })
map("v", "<leader>rF", function()
    require("refactoring").refactor "Extract Function"
end, { desc = "Refactor: extract function" })
map("v", "<leader>ri", function()
    require("refactoring").refactor "Inline Variable"
end, { desc = "Refactor: inline variable" })

-- ── MULTI-CURSOR ─────────────────────────────────────────────────
local mc = require "multicursor-nvim"
mc.setup()
map({ "n", "v" }, "<leader>mj", function()
    mc.lineAddCursor(1)
end, { desc = "Multi-cursor: add cursor below" })
map({ "n", "v" }, "<leader>mk", function()
    mc.lineAddCursor(-1)
end, { desc = "Multi-cursor: add cursor above" })
map({ "n", "v" }, "<C-A-n>", function()
    mc.matchAddCursor(1)
end, { desc = "Multi-cursor: add cursor at next match" })

-- Single <Esc>: clear search highlight and manage multi-cursor state.
map("n", "<Esc>", function()
    vim.cmd "noh"
    if not mc.cursorsEnabled() then
        mc.enableCursors()
    else
        mc.clearCursors()
    end
end, { desc = "Clear search highlight / multi-cursor" })

-- ── ZEN MODE ─────────────────────────────────────────────────────
map("n", "<leader>zz", "<cmd>ZenMode<CR>", { desc = "Zen: focus mode" })

-- ── LATEX ────────────────────────────────────────────────────────
map("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "LaTeX: compile (continuous)" })
map("n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "LaTeX: view PDF" })
map("n", "<leader>lc", "<cmd>VimtexClean<CR>", { desc = "LaTeX: clean auxiliaries" })

-- ── AVANTE (AI ASSISTANT) ────────────────────────────────────────
map("n", "<leader>ag", function()
    require("configs.avante").select_model()
end, { desc = "Avante: select NVIDIA/OpenRouter model" })

map("n", "<leader>aR", function()
    require("configs.avante").reset()
end, { desc = "Avante: reset to default NVIDIA model" })

-- ── UI TOGGLES (<leader>u, same convention as LazyVim) ───────────
map("n", "<leader>us", "<cmd>set spell!<CR>", { desc = "UI: toggle spell checker" })
map("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "UI: toggle line wrap" })
map("n", "<leader>un", function()
    vim.wo.number = not vim.wo.number
    vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = "UI: toggle line numbers" })
map("n", "<leader>ud", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "UI: toggle diagnostics" })
map("n", "<leader>uc", "<cmd>TSContext toggle<CR>", { desc = "UI: toggle sticky context" })
map("n", "<leader>ul", function()
    vim.wo.list = not vim.wo.list
    vim.notify("listchars: " .. (vim.wo.list and "on" or "off"), vim.log.levels.INFO)
end, { desc = "UI: toggle listchars (indent dots)" })
map("n", "<leader>ui", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { bufnr = 0 })
end, { desc = "UI: toggle LSP inlay hints" })
map("n", "<leader>uC", function()
    vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled { bufnr = 0 }, { bufnr = 0 })
end, { desc = "UI: toggle LSP code lens" })
map("n", "<leader>uh", function()
    vim.lsp.enable("harper_ls", not vim.lsp.is_enabled "harper_ls")
end, { desc = "UI: toggle Harper grammar checker" })

-- ── SESSIONS (persistence.nvim) ──────────────────────────────────
map("n", "<leader>Ps", function()
    require("persistence").load()
end, { desc = "Session: restore this directory" })
map("n", "<leader>Pl", function()
    require("persistence").load { last = true }
end, { desc = "Session: restore last session" })
map("n", "<leader>Pd", function()
    require("persistence").stop()
end, { desc = "Session: do not save on exit" })

-- ── DASHBOARD ────────────────────────────────────────────────────
map("n", "<leader>;", function()
    require("dashboard").open()
end, { desc = "Dashboard: open IDE home" })
map("n", "<leader>D", function()
    require("dashboard").open()
end, { desc = "Dashboard: open IDE home" })
