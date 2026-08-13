local ok_dap, dap = pcall(require, "dap")
if not ok_dap then
    return
end

local ok_dapui, dapui = pcall(require, "dapui")
if not ok_dapui then
    return
end

-- 1. CONFIGURACIÓN DE LA UI
dapui.setup {
    controls = {
        enabled = false, -- Bug conocido de dapui: crashea si togglés sin sesión activa.
        -- Usá F5/F9/F10/F11/F12/<S-F5> (ya mapeados) en vez de los botones clicables.
    },
}
-- 2. AUTO-OPEN BLINDADO
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

-- ── HELPER: Búsqueda dinámica de Python ──────────────────────────
local function get_python_path()
    local cwd_venv = vim.fn.getcwd() .. "/.venv/bin/python"
    if vim.fn.executable(cwd_venv) == 1 then
        return cwd_venv
    end
    local cwd_venv2 = vim.fn.getcwd() .. "/venv/bin/python"
    if vim.fn.executable(cwd_venv2) == 1 then
        return cwd_venv2
    end
    local mason_python = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
    if vim.fn.executable(mason_python) == 1 then
        return mason_python
    end
    return vim.fn.exepath "python3" or "/usr/bin/python3"
end

-- 3. ADAPTADORES
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
    executable = { command = vim.fn.stdpath "data" .. "/mason/bin/codelldb", args = { "--port", "${port}" } },
}
dap.adapters.cppdbg = { type = "executable", command = vim.fn.stdpath "data" .. "/mason/bin/OpenDebugAD7" }
dap.adapters.rust = dap.adapters.codelldb
dap.adapters.delve = {
    type = "server",
    port = "${port}",
    executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
}

-- 4. CONFIGURACIONES MAESTRAS
dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Lanzar archivo actual",
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
            return vim.fn.input("Ejecutable: ", vim.fn.getcwd() .. "/", "file")
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
            vim.fn.system "cargo build"
            return vim.fn.input("Ejecutable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}
dap.configurations.go = {
    { type = "delve", name = "Debug", request = "launch", program = "${file}" },
}

-- ── DAP-PYTHON: config mejorada, venv-aware, debug de tests ──────
local ok_dap_python, dap_python = pcall(require, "dap-python")
if ok_dap_python then
    dap_python.setup(get_python_path())
    -- Esto AGREGA configuraciones nuevas a dap.configurations.python
    -- (no reemplaza la tuya de "Lanzar archivo actual"): incluye debug
    -- de módulo, con argumentos, y attach remoto.
end

-- ── VALORES DE VARIABLES INLINE AL DEBUGGEAR ─────────────────────
local ok_virtual_text, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
if ok_virtual_text then
    dap_virtual_text.setup {
        commented = true,
        virt_text_pos = "eol",
    }
end
