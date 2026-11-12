-- Headless dashboard test suite.
-- Run with: nvim --headless -u init.lua -c "luafile tests/dashboard_spec.lua"
local failures = 0
local checks = 0

local function check(name, condition, detail)
    checks = checks + 1
    if condition then
        print("ok   " .. name)
    else
        failures = failures + 1
        print("FAIL " .. name .. (detail and ("  -> " .. detail) or ""))
    end
end

local data = require "dashboard.data"
local sessions = require "dashboard.sessions"
local nav = require "dashboard.nav"

-- Isolate every storage file inside a throwaway directory.
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp .. "/sessions", "p")
data.set_paths {
    pins = tmp .. "/pins.json",
    projects = tmp .. "/projects.json",
    sessions = tmp .. "/sessions.json",
    session_dir = tmp .. "/sessions",
    last_build = tmp .. "/build.json",
}

local project = tmp .. "/project"
vim.fn.mkdir(project, "p")
local file = project .. "/main.lua"
vim.fn.writefile({ "-- TODO: sample task", "return true" }, file)

-- ── Boot the dashboard ───────────────────────────────────────────
vim.cmd "doautocmd VimEnter"
vim.wait(2500)
local dashboard = require "dashboard"

check("dashboard opens on VimEnter", dashboard.is_open())
check("dashboard filetype", vim.bo.filetype == "dashboard")
check("dashboard hides listchars", vim.wo.list == false)
check("dashboard hides indent guides", vim.wo.foldcolumn == "0" and vim.wo.statuscolumn == "")

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
check("dashboard rendered", #lines > 20, tostring(#lines))

local overflow = {}
for index, line in ipairs(lines) do
    if vim.fn.strdisplaywidth(line) > vim.api.nvim_win_get_width(0) then
        table.insert(overflow, index)
    end
end
check("no row exceeds the window width", #overflow == 0, table.concat(overflow, ","))

local rows = nav.rows()
check("interactive rows registered", #rows > 5, tostring(#rows))

local row_bg = vim.api.nvim_get_hl(0, { name = "DashRow" }).bg
local cursor_bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg
check("row highlight reuses the theme cursorline", row_bg ~= nil and row_bg == cursor_bg)

local first = nav.first_line()
vim.api.nvim_win_set_cursor(0, { first, 0 })
nav.move(1)
check("navigation moves the cursor", vim.fn.line "." > first)

-- ── Pins ─────────────────────────────────────────────────────────
data.add_pin(file)
check("pin added", #data.get_pins() == 1)
check("duplicate pin rejected", data.add_pin(file) == false)
data.toggle_pin(1)
check("pin toggled", data.get_pins()[1].done == true)
local removed = data.remove_pin(1)
check("pin removed", removed == true and #data.get_pins() == 0)

-- ── Sessions (project/branch) ────────────────────────────────────
vim.cmd("edit " .. vim.fn.fnameescape(file))
check("session saved", sessions.save(project, "test-branch") == true)
local entries = sessions.list(project)
check("session indexed", #entries == 1, tostring(#entries))
check("session file exists", vim.fn.filereadable(entries[1].file) == 1)

-- ── Projects ─────────────────────────────────────────────────────
vim.fn.mkdir(project .. "/.git", "p")
vim.fn.writefile({ '{"name":"project"}' }, project .. "/package.json")
vim.fn.chdir(project)
vim.api.nvim_exec_autocmds("DirChanged", { pattern = "global" })
vim.wait(800)
local projects = data.get_projects()
local found = false
for _, entry in ipairs(projects) do
    if entry.path == project then
        found = true
    end
end
check("current project discovered", found)

-- ── Diagnostics section ──────────────────────────────────────────
local diag_file = tmp .. "/diag.lua"
vim.fn.writefile({ "local x = 1" }, diag_file)
local diag_buf = vim.fn.bufadd(diag_file)
vim.fn.bufload(diag_buf)
local diag_ns = vim.api.nvim_create_namespace "dashboard_test_diag"
vim.diagnostic.set(diag_ns, diag_buf, {
    { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "boom" },
    { lnum = 0, col = 2, severity = vim.diagnostic.severity.WARN, message = "careful" },
    { lnum = 0, col = 3, severity = vim.diagnostic.severity.HINT, message = "psst" },
})
dashboard.open()
dashboard.render()
local diag_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
check("diagnostics section shows error count", diag_text:find("1 errors", 1, true) ~= nil)
check("diagnostics section shows warning count", diag_text:find("1 warnings", 1, true) ~= nil)
check("diagnostics section lists the file", diag_text:find("1E 1W 0I 1H", 1, true) ~= nil)

-- Troubled panel integration (v3 command API).
vim.cmd "Trouble diagnostics toggle focus=true win.position=bottom"
vim.wait(800)
check("Trouble opens the diagnostics panel", vim.bo.filetype == "trouble")
vim.cmd "Trouble close"

-- ── Vertical centering ───────────────────────────────────────────
local before_rows = nav.first_line()
vim.o.lines = 140
require("dashboard").render()
check("layout is vertically centered on tall windows", nav.first_line() > before_rows + 10)
vim.o.lines = 24

vim.api.nvim_buf_delete(diag_buf, { force = true })

-- ── Closing the dashboard restores window options ────────────────
dashboard.open()
check("dashboard reopened", dashboard.is_open())
vim.cmd("edit " .. vim.fn.fnameescape(file))
check("dashboard closes when a file opens", dashboard.is_open() == false)
check("listchars restored in file windows", vim.wo.list == true)

-- ── Listchars toggle ─────────────────────────────────────────────
local mapping = vim.fn.maparg("<leader>ul", "n", false, true)
check("listchars toggle exists", mapping.lhs ~= nil)
mapping.callback()
check("listchars toggle flips the option", vim.wo.list == false)
mapping.callback()

vim.fn.delete(tmp, "rf")
print(string.format("\n%d checks, %d failure(s)", checks, failures))
if failures > 0 then
    vim.cmd "cq"
else
    vim.cmd "qa!"
end
