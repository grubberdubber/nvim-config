local dap = require("dap")

-- 1. ADAPTADORES (Requieren instalación vía :Mason)
-- Se definen las rutas y comandos para cada ejecutable de debug
dap.adapters.lldb = { type = 'executable', command = 'lldb-vscode', name = 'lldb' }
dap.adapters.cppdbg = { type = 'executable', command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7" }
dap.adapters.python = { type = 'executable', command = 'python3', args = { '-m', 'debugpy.adapter' } }
dap.adapters.delve = { type = 'server', port = '${port}', executable = { command = 'dlv', args = { 'dap', '-l', '127.0.0.1:${port}' } } }
dap.adapters.node2 = { type = 'executable', command = 'node', args = { os.getenv("HOME") .. "/.vscode/extensions/ms-vscode.node-debug2-1.43.0/out/src/nodeDebug.js" } }
dap.adapters.coreclr = { type = 'executable', command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg", args = { '--interpreter=vscode' } }

-- 2. CONFIGURACIONES MAESTRAS (Mapeo por FileType)
dap.configurations = {
  -- Sistemas / Bajo Nivel
  c = { { name = 'Launch', type = 'cppdbg', request = 'launch', program = function() return vim.fn.input('Path: ', vim.fn.getcwd() .. '/', 'file') end, cwd = '${workspaceFolder}', stopAtEntry = true } },
  cpp = { { name = 'Launch', type = 'cppdbg', request = 'launch', program = function() return vim.fn.input('Path: ', vim.fn.getcwd() .. '/', 'file') end, cwd = '${workspaceFolder}', stopAtEntry = true } },
  rust = { { name = 'Launch', type = 'lldb', request = 'launch', program = function() return vim.fn.input('Path: ', vim.fn.getcwd() .. '/target/debug/', 'file') end, cwd = '${workspaceFolder}' } },
  asm = { { name = 'Launch', type = 'cppdbg', request = 'launch', program = function() return vim.fn.input('Path: ', vim.fn.getcwd() .. '/', 'file') end, cwd = '${workspaceFolder}' } },
  
  -- Web / Runtimes
  python = { { type = 'python', request = 'launch', name = 'Launch File', program = '${file}' } },
  javascript = { { type = 'node2', name = 'Launch', request = 'launch', program = '${file}', cwd = vim.fn.getcwd() } },
  typescript = { { type = 'node2', name = 'Launch', request = 'launch', program = '${file}', cwd = vim.fn.getcwd() } },
  php = { { name = 'Listen for Xdebug', type = 'php', request = 'launch', port = 9003 } },
  
  -- Móvil / Corporativo
  go = { { type = 'delve', name = 'Debug', request = 'launch', program = '${file}' } },
  cs = { { type = 'coreclr', name = 'Launch', request = 'launch', program = function() return vim.fn.input('Path: ', vim.fn.getcwd() .. '/bin/Debug/', 'file') end } },
  java = { { name = 'Debug', type = 'java', request = 'launch' } },
  
  -- Scripting / Datos
  ruby = { { type = 'ruby', name = 'debug', request = 'launch', program = '${file}' } },
  perl = { { type = 'perl', name = 'debug', request = 'launch', program = '${file}' } },
  r = { { type = 'r', name = 'debug', request = 'launch', program = '${file}' } },
  julia = { { type = 'julia', name = 'debug', request = 'launch', program = '${file}' } },
  scala = { { type = 'scala', name = 'debug', request = 'launch', program = '${file}' } },
  dart = { { type = 'dart', name = 'debug', request = 'launch', program = '${file}' } },
  kotlin = { { type = 'kotlin', name = 'debug', request = 'launch', program = '${file}' } },
  swift = { { type = 'swift', name = 'debug', request = 'launch', program = '${file}' } }
}
