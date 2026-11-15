local ok_dap, dap = pcall(require, "dap")
if not ok_dap then
    return
end

local ok_dapui, dapui = pcall(require, "dapui")
if not ok_dapui then
    return
end

-- ── DEBUGGER UI ──────────────────────────────────────────────────
dapui.setup {
    controls = {
        enabled = true,
        -- Known dapui issue: toggling the panel with no active session and no
        -- breakpoint can crash. Set at least one breakpoint (F9) before the
        -- first <leader>du if you hit it.
    },
}

-- ── ONE STATUSLINE IN THE DEBUGGER ───────────────────────────────
-- With `laststatus=2`, every DAP panel gets its own statusline in addition
-- to its title, which produces the empty bars between Scopes/Breakpoints/
-- Stacks/Watches. Keep the single global bar; the panel names stay in the
-- winbar. Some DAP/terminal transitions can set laststatus back to 2, so
-- re-assert it whenever a DAP buffer is entered.
local dapui_status_group = vim.api.nvim_create_augroup("DapUiStatusline", { clear = true })

local function is_dapui(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return false
    end
    local ft = vim.bo[buf].filetype
    return ft:match "^dapui_" ~= nil or ft == "dap-repl"
end

local function has_dapui_window()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if is_dapui(vim.api.nvim_win_get_buf(win)) then
            return true
        end
    end
    return false
end

local function keep_one_statusline(buf)
    -- Terminal windows are handled by configs/terminal_statusline.lua, which
    -- keeps the same global statusline.
    if vim.bo[buf].buftype == "terminal" then
        return
    end

    if not (is_dapui(buf) or has_dapui_window()) then
        return
    end

    vim.schedule(function()
        if vim.o.laststatus ~= 3 and vim.bo.buftype ~= "terminal" then
            vim.o.laststatus = 3
            pcall(vim.cmd, "redrawstatus")
        end
    end)
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter" }, {
    group = dapui_status_group,
    callback = function(args)
        keep_one_statusline(args.buf)
    end,
})

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

-- ── HELPERS ──────────────────────────────────────────────────────
local function exists(path)
    return vim.fn.executable(path) == 1
end

local function mason_bin(name)
    return vim.fn.stdpath "data" .. "/mason/bin/" .. name
end

--- Resolve a Python interpreter: project venv first, then debugpy's venv,
--- then the system python3.
local function get_python_path()
    local candidates = {
        vim.fn.getcwd() .. "/.venv/bin/python",
        vim.fn.getcwd() .. "/venv/bin/python",
        vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python",
    }
    for _, path in ipairs(candidates) do
        if exists(path) then
            return path
        end
    end
    return vim.fn.exepath "python3" or "/usr/bin/python3"
end

--- Prompt for an executable path, starting from a sensible default.
local function prompt_program(default_dir)
    return vim.fn.input("Executable: ", default_dir, "file")
end

-- ── ADAPTERS ─────────────────────────────────────────────────────
dap.adapters.python = function(cb, config)
    if config.request == "attach" then
        local port = (config.connect or config).port
        local host = (config.connect or config).host or "127.0.0.1"
        cb {
            type = "server",
            port = assert(port, "`connect.port` is required for python `attach`"),
            host = host,
            options = { source_filetype = "python" },
        }
    else
        cb {
            type = "executable",
            command = get_python_path(),
            args = { "-m", "debugpy.adapter" },
            options = { source_filetype = "python" },
        }
    end
end

dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = { command = mason_bin "codelldb", args = { "--port", "${port}" } },
}

dap.adapters.cppdbg = { type = "executable", command = mason_bin "OpenDebugAD7" }

dap.adapters.rust = dap.adapters.codelldb

dap.adapters.delve = {
    type = "server",
    port = "${port}",
    executable = { command = mason_bin "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}

-- Node/TypeScript: one adapter, one shared launch template (pwa-node).
dap.adapters["pwa-node"] = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
        command = "node",
        args = { vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
    },
}

-- Bash: bashdb through the mason bash-debug-adapter package.
if exists(mason_bin "bash-debug-adapter") then
    dap.adapters.bashdb = {
        type = "executable",
        command = mason_bin "bash-debug-adapter",
        name = "bashdb",
    }

    local bashdb_dir = vim.fn.stdpath "data" .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir"
    dap.configurations.sh = {
        {
            type = "bashdb",
            request = "launch",
            name = "Launch current file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            pathBash = "/bin/bash",
            pathCat = "cat",
            pathMkfifo = "mkfifo",
            pathPkill = "pkill",
            pathBashdb = bashdb_dir .. "/bashdb",
            pathBashdbLib = bashdb_dir,
            env = {}, -- the adapter dereferences it unconditionally
            args = {},
        },
    }
    dap.configurations.bash = dap.configurations.sh
end

-- .NET: netcoredbg (installed through mason-nvim-dap).
if exists(mason_bin "netcoredbg") then
    dap.adapters.coreclr = {
        type = "executable",
        command = mason_bin "netcoredbg",
        args = { "--interpreter=vscode" },
    }
end

-- ── LAUNCH CONFIGURATIONS ────────────────────────────────────────
dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch current file",
        program = "${file}",
        pythonPath = get_python_path,
        console = "internalConsole",
    },
}

dap.configurations.c = {
    {
        name = "Launch (codelldb)",
        type = "codelldb",
        request = "launch",
        program = function()
            return prompt_program(vim.fn.getcwd() .. "/")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}
dap.configurations.cpp = dap.configurations.c

dap.configurations.rust = {
    {
        name = "Launch (codelldb)",
        type = "codelldb",
        request = "launch",
        program = function()
            -- The DAP callback must return the binary synchronously, so wait
            -- here; vim.system avoids the shell and keeps errors in one place.
            vim.system({ "cargo", "build" }):wait()
            return prompt_program(vim.fn.getcwd() .. "/target/debug/")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

dap.configurations.go = {
    { type = "delve", name = "Debug current file", request = "launch", program = "${file}" },
    { type = "delve", name = "Debug package", request = "launch", program = "${workspaceFolder}" },
}

local node_configs = {
    {
        type = "pwa-node",
        request = "launch",
        name = "Launch current file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**" },
    },
    {
        type = "pwa-node",
        request = "attach",
        name = "Attach to process (port 9229)",
        port = 9229,
        cwd = "${workspaceFolder}",
        skipFiles = { "<node_internals>/**" },
    },
}

dap.configurations.javascript = node_configs
dap.configurations.typescript = node_configs
dap.configurations.javascriptreact = node_configs
dap.configurations.typescriptreact = node_configs

local function csharp_configs()
    if not dap.adapters.coreclr then
        return {}
    end
    return {
        {
            type = "coreclr",
            name = "Launch (netcoredbg)",
            request = "launch",
            program = function()
                return prompt_program(vim.fn.getcwd() .. "/bin/Debug/")
            end,
        },
    }
end

dap.configurations.cs = csharp_configs()

-- ── DAP-PYTHON: venv-aware, adds test/module configurations ──────
local ok_dap_python, dap_python = pcall(require, "dap-python")
if ok_dap_python then
    dap_python.setup(get_python_path())
    -- Adds extra entries (module, args, remote attach) without replacing the
    -- "Launch current file" configuration above.
end

-- ── INLINE VARIABLE VALUES ───────────────────────────────────────
local ok_virtual_text, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
if ok_virtual_text then
    dap_virtual_text.setup {
        commented = true,
        virt_text_pos = "eol",
    }
end
