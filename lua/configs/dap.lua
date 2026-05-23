-- ╔══════════════════════════════════════════════════════════════╗
-- ║  DAP — Configuración maestra de debugging                    ║
-- ║  Cubre: Python, C/C++, Rust, Go, JS/TS, C#, Java, PHP       ║
-- ║  y configuraciones base para Ruby, Perl, R, Julia, etc.      ║
-- ╚══════════════════════════════════════════════════════════════╝

local ok_dap, dap = pcall(require, "dap")
if not ok_dap then return end

local ok_dapui, dapui = pcall(require, "dapui")
if not ok_dapui then return end

-- ── UI del debugger ───────────────────────────────────────────────
-- Layout inspirado en VS Code / IntelliJ: panel izquierdo + consola abajo
dapui.setup {
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▶" },
  layouts = {
    {
      -- Panel izquierdo: variables, breakpoints, call stack, watches
      elements = {
        { id = "scopes",      size = 0.30 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks",      size = 0.30 },
        { id = "watches",     size = 0.20 },
      },
      size     = 40,
      position = "left",
    },
    {
      -- Panel inferior: consola interactiva + REPL del debugger
      elements = {
        { id = "repl",    size = 0.5 },
        { id = "console", size = 0.5 },
      },
      size     = 10,
      position = "bottom",
    },
  },
}

-- Abre/cierra la UI automáticamente con el ciclo del debugger
dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

-- ══════════════════════════════════════════════════════════════
--  HELPER: Python path inteligente
--  Prioridad: .venv del proyecto → venv/ → Mason debugpy → sistema
--  SOLUCIÓN debugpy: Mason instala debugpy en su propio entorno.
--  get_python_path() devuelve el python que SÍ tiene debugpy.
-- ══════════════════════════════════════════════════════════════
local function get_python_path()
  -- 1. .venv en la raíz del proyecto (convención moderna)
  local cwd_venv = vim.fn.getcwd() .. "/.venv/bin/python"
  if vim.fn.executable(cwd_venv) == 1 then
    return cwd_venv
  end

  -- 2. venv/ sin punto (convención antigua)
  local cwd_venv2 = vim.fn.getcwd() .. "/venv/bin/python"
  if vim.fn.executable(cwd_venv2) == 1 then
    return cwd_venv2
  end

  -- 3. Python de Mason (instalado por mason-nvim-dap con debugpy incluido)
  local mason_python = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
  if vim.fn.executable(mason_python) == 1 then
    return mason_python
  end

  -- 4. Fallback al python3 del sistema
  return vim.fn.exepath "python3" or "/usr/bin/python3"
end

-- ══════════════════════════════════════════════════════════════
--  1. ADAPTADORES DAP
--     Cada adaptador conecta nvim-dap con el binario del debugger
-- ══════════════════════════════════════════════════════════════

-- ── Python (debugpy) ─────────────────────────────────────────────
-- Se usa función para resolver la ruta en tiempo de ejecución
-- garantizando que siempre apunte al python que tiene debugpy
dap.adapters.python = function(callback, _config)
  callback {
    type    = "executable",
    command = get_python_path(),
    args    = { "-m", "debugpy.adapter" },
  }
end

-- ── C / C++ / Assembly (codelldb vía Mason) ───────────────────────
-- codelldb es más moderno y confiable que cppdbg/OpenDebugAD7 en Linux
dap.adapters.codelldb = {
  type       = "server",
  port       = "${port}",
  executable = {
    command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
    args    = { "--port", "${port}" },
  },
}

-- ── cppdbg: alias de fallback (OpenDebugAD7) ─────────────────────
dap.adapters.cppdbg = {
  type    = "executable",
  command = vim.fn.stdpath "data" .. "/mason/bin/OpenDebugAD7",
}

-- ── Rust (codelldb — mismo adaptador que C/C++) ───────────────────
-- codelldb entiende los símbolos DWARF de Rust nativamente
dap.adapters.rust = dap.adapters.codelldb

-- ── Go (delve — el debugger oficial de Go) ───────────────────────
dap.adapters.delve = {
  type       = "server",
  port       = "${port}",
  executable = {
    command = "dlv",
    args    = { "dap", "-l", "127.0.0.1:${port}" },
  },
}

-- ── JavaScript / TypeScript (js-debug-adapter vía Mason) ─────────
-- Usa pwa-node (más moderno que node2 de la extensión de VS Code)
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      "${port}",
    },
  },
}
-- Alias para compatibilidad con configs que usen node2
dap.adapters.node2 = dap.adapters["pwa-node"]

-- ── C# (.NET — netcoredbg vía Mason) ─────────────────────────────
dap.adapters.coreclr = {
  type    = "executable",
  command = vim.fn.stdpath "data" .. "/mason/bin/netcoredbg",
  args    = { "--interpreter=vscode" },
}

-- ── Lua (nlua — para debuggear Neovim mismo) ─────────────────────
dap.adapters.nlua = function(callback, config)
  callback { type = "server", host = "127.0.0.1", port = config.port or 8086 }
end

-- ══════════════════════════════════════════════════════════════
--  2. CONFIGURACIONES MAESTRAS POR FILETYPE
--     Lo que aparece en el menú al presionar F5
-- ══════════════════════════════════════════════════════════════
dap.configurations = {

  -- ── Python ────────────────────────────────────────────────────
  python = {
    {
      type       = "python",
      request    = "launch",
      name       = "Launch File",
      program    = "${file}",
      pythonPath = get_python_path, -- función, se evalúa al lanzar
    },
    {
      type       = "python",
      request    = "launch",
      name       = "Launch con argumentos",
      program    = "${file}",
      args       = function()
        return vim.split(vim.fn.input "Argumentos: ", " ")
      end,
      pythonPath = get_python_path,
    },
  },

  -- ── C / C++ ───────────────────────────────────────────────────
  c = {
    {
      name        = "Launch (codelldb)",
      type        = "codelldb",
      request     = "launch",
      program     = function()
        return vim.fn.input("Ejecutable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd         = "${workspaceFolder}",
      stopOnEntry = false,
    },
  },

  cpp = {
    {
      name        = "Launch (codelldb)",
      type        = "codelldb",
      request     = "launch",
      program     = function()
        return vim.fn.input("Ejecutable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd         = "${workspaceFolder}",
      stopOnEntry = false,
    },
  },

  -- ── Rust ──────────────────────────────────────────────────────
  rust = {
    {
      name        = "Launch (codelldb)",
      type        = "codelldb",
      request     = "launch",
      program     = function()
        -- Compila en debug mode antes de lanzar
        vim.fn.system "cargo build"
        return vim.fn.input("Ejecutable: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd         = "${workspaceFolder}",
      stopOnEntry = false,
    },
  },

  -- ── Assembly ──────────────────────────────────────────────────
  -- stopOnEntry = true: detiene en la primera instrucción (útil para asm)
  asm = {
    {
      name        = "Launch (codelldb)",
      type        = "codelldb",
      request     = "launch",
      program     = function()
        return vim.fn.input("Ejecutable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd         = "${workspaceFolder}",
      stopOnEntry = true,
    },
  },

  -- ── Go ────────────────────────────────────────────────────────
  go = {
    {
      type    = "delve",
      name    = "Debug",
      request = "launch",
      program = "${file}",
    },
    {
      type    = "delve",
      name    = "Debug Package",
      request = "launch",
      program = "${fileDirname}",
    },
  },

  -- ── JavaScript ────────────────────────────────────────────────
  javascript = {
    {
      type    = "pwa-node",
      request = "launch",
      name    = "Launch File (Node)",
      program = "${file}",
      cwd     = "${workspaceFolder}",
    },
  },

  -- ── TypeScript ────────────────────────────────────────────────
  typescript = {
    {
      type        = "pwa-node",
      request     = "launch",
      name        = "Launch File (Node/TS)",
      program     = "${file}",
      cwd         = "${workspaceFolder}",
      runtimeArgs = { "-r", "ts-node/register" },
    },
  },

  -- ── C# ────────────────────────────────────────────────────────
  cs = {
    {
      type    = "coreclr",
      name    = "Launch",
      request = "launch",
      program = function()
        return vim.fn.input("DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      end,
    },
  },

  -- ── Java (usa el adaptador interno de jdtls — sin setup extra) ─
  java = {
    {
      name    = "Debug (jdtls)",
      type    = "java",
      request = "launch",
    },
  },

  -- ── PHP (Xdebug — requiere extensión en php.ini) ──────────────
  php = {
    {
      name    = "Listen for Xdebug",
      type    = "php",
      request = "launch",
      port    = 9003,
    },
  },

  -- ── Scripting / Datos ─────────────────────────────────────────
  -- Configs base listos para cuando el adaptador esté disponible
  ruby   = { { type = "ruby",   name = "Debug", request = "launch", program = "${file}" } },
  perl   = { { type = "perl",   name = "Debug", request = "launch", program = "${file}" } },
  r      = { { type = "r",      name = "Debug", request = "launch", program = "${file}" } },
  julia  = { { type = "julia",  name = "Debug", request = "launch", program = "${file}" } },
  scala  = { { type = "scala",  name = "Debug", request = "launch", program = "${file}" } },
  dart   = { { type = "dart",   name = "Debug", request = "launch", program = "${file}" } },
  kotlin = { { type = "kotlin", name = "Debug", request = "launch", program = "${file}" } },
  swift  = { { type = "swift",  name = "Debug", request = "launch", program = "${file}" } },

  -- ── Lua (debuggear Neovim mismo) ─────────────────────────────
  lua = {
    {
      type    = "nlua",
      request = "attach",
      name    = "Attach to running Neovim",
      port    = 8086,
    },
  },
}
