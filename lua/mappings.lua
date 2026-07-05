---@diagnostic disable: undefined-global
require "nvchad.mappings"

local map = vim.keymap.set

-- ── BLINDAJE DE TAB: FORCE 4 ESPACIOS (NO IA) ────────────────────
-- Si el menú de autocompletado normal está abierto, Tab interactúa con él.
-- Si estás escribiendo un if y sale la IA en gris, Tab mete tus 4 espacios de forma obligatoria.
map("i", "<Tab>", function()
    local cmp_status, cmp = pcall(require, "cmp")
    if cmp_status and cmp.visible() then
        cmp.select_next_item()
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
    end
end, { silent = true, desc = "Tab estricto: Prioriza 4 espacios e impide secuestros" })

-- ── CONFIGURACIÓN DE CODEIUM (IA EXCLUSIVA EN CTRL+G) ────────────
vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = "#5c6370", italic = true })
map("i", "<C-g>", function()
    return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true, desc = "Codeium: Aceptar sugerencia" })
map("i", "<C-]>", function()
    return vim.fn["codeium#Clear"]()
end, { expr = true, silent = true, desc = "Codeium: Limpiar sugerencia" })

-- ── MAPEOS BASE ──────────────────────────────────────────────────
map("n", ";", ":", { desc = "CMD: modo comando" })
map("i", "jk", "<ESC>", { desc = "ESC rápido desde Insert" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Guardar archivo" })
map("i", "<C-s>", "<ESC><cmd>w<CR>", { desc = "Guardar desde Insert" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Cerrar ventana" })

map("n", "j", "gj", { desc = "Bajar (wrap-aware)" })
map("n", "k", "gk", { desc = "Subir (wrap-aware)" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Mover línea abajo" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Mover línea arriba" })
map("v", "<", "<gv", { desc = "Indentar izquierda" })
map("v", ">", ">gv", { desc = "Indentar derecha" })
map("v", "p", '"_dP', { desc = "Pegar sin perder registro" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Limpiar highlight de búsqueda" })

map("n", "<C-h>", "<C-w>h", { desc = "Ir a split izquierdo" })
map("n", "<C-l>", "<C-w>l", { desc = "Ir a split derecho" })
map("n", "<C-j>", "<C-w>j", { desc = "Ir a split abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ir a split arriba" })

map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Siguiente buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Cerrar buffer actual" })

-- ── LSP ──────────────────────────────────────────────────────────
map("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Ir a definición" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Ir a declaración" })
map("n", "gR", vim.lsp.buf.references, { desc = "LSP: Ver referencias" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Ver implementación" })
map("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover docs" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Renombrar símbolo" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code actions" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP: Formatear archivo" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP: Diagnóstico anterior" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "LSP: Diagnóstico siguiente" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "LSP: Ver diagnóstico flotante" })

-- ── PLUGINS VARIOS ───────────────────────────────────────────────
map("n", "<leader>sr", "<cmd>SnipRun<CR>", { desc = "Sniprun: Ejecutar línea" })
map("v", "<leader>sr", "<cmd>'<,'>SnipRun<CR>", { desc = "Sniprun: Ejecutar bloque" })
map("n", "<leader>sc", "<cmd>SnipReset<CR>", { desc = "Sniprun: Limpiar output" })

map("n", "<leader>ro", "<cmd>IronRepl<CR>", { desc = "Iron: Abrir REPL" })
map("n", "<leader>rr", "<cmd>IronRestart<CR>", { desc = "Iron: Reiniciar REPL" })
map("n", "<leader>rc", function()
    require("iron.core").close_repl()
end, { desc = "Iron: Cerrar REPL" })
map("n", "<leader>rs", function()
    require("iron.core").send_line()
end, { desc = "Iron: Enviar línea al REPL" })
map("v", "<leader>rs", function()
    require("iron.core").visual_send()
end, { desc = "Iron: Enviar bloque al REPL" })

map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "DB: Toggle UI base de datos" })

-- ── EJECUCIÓN DE QUERIES SQL (DADBOD) ────────────────────────────
map("n", "<leader>dq", "<cmd>%DB<CR>", { desc = "DB: Ejecutar buffer completo" })
map("v", "<leader>dq", ":'<,'>DB<CR>", { desc = "DB: Ejecutar selección" })

-- Trouble
map("n", "<leader>tx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Trouble: Toggle panel" })
map("n", "<leader>tw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble: Workspace" })
map("n", "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble: Documento" })

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Git: Abrir Lazygit" })
map("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "Telescope: Listar buffers" })

-- ── DAP DEBUGGER ─────────────────────────────────────────────────
map("n", "<F5>", function()
    require("dap").continue()
end, { desc = "DAP: Iniciar / Continuar" })
map("n", "<F9>", function()
    require("dap").toggle_breakpoint()
end, { desc = "DAP: Toggle Breakpoint" })
map("n", "<F10>", function()
    require("dap").step_over()
end, { desc = "DAP: Step Over" })
map("n", "<F11>", function()
    require("dap").step_into()
end, { desc = "DAP: Step Into" })
map("n", "<F12>", function()
    require("dap").step_out()
end, { desc = "DAP: Step Out" })
map("n", "<S-F5>", function()
    require("dap").terminate()
end, { desc = "DAP: Detener debugger" })
map("n", "<leader>B", function()
    require("dap").set_breakpoint(vim.fn.input "Condición del breakpoint: ")
end, { desc = "DAP: Breakpoint condicional" })
map("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "DAP: Toggle UI" })
map("n", "<leader>dr", function()
    require("dap").repl.open()
end, { desc = "DAP: Abrir REPL" })
map("n", "<leader>dl", function()
    require("dap").run_last()
end, { desc = "DAP: Re-ejecutar último" })

-- ── NAVEGACIÓN DE SISTEMA DE ARCHIVOS (OIL) ───────────────────
map("n", "-", "<CMD>Oil<CR>", { desc = "Abrir directorio padre (Oil)" })

-- ── NAVEGACIÓN ULTRARRÁPIDA (HARPOON) ─────────────────────────
local harpoon = require "harpoon"
map("n", "<leader>ha", function()
    harpoon:list():add()
end, { desc = "Harpoon: Agregar archivo" })
map("n", "<C-e>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: Menú rápido" })
map("n", "<leader>1", function()
    harpoon:list():select(1)
end, { desc = "Harpoon: Saltar al archivo 1" })
map("n", "<leader>2", function()
    harpoon:list():select(2)
end, { desc = "Harpoon: Saltar al archivo 2" })
map("n", "<leader>3", function()
    harpoon:list():select(3)
end, { desc = "Harpoon: Saltar al archivo 3" })
map("n", "<leader>4", function()
    harpoon:list():select(4)
end, { desc = "Harpoon: Saltar al archivo 4" })

-- ── ETIQUETAS DE AUDITORÍA (TODO COMMENTS) ─────────────────────
map("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "Saltar al siguiente TODO/FIXME" })
map("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "Saltar al anterior TODO/FIXME" })

-- ── RENOMBRADO RÁPIDO DEL ARCHIVO ACTUAL ─────────────────────────
map("n", "<leader>rf", function()
    local current_file = vim.fn.expand "%:p"
    if current_file == "" then
        print "No hay ningún archivo abierto para renombrar."
        return
    end

    -- Pedir el nuevo nombre (autocompleta con el actual)
    local new_name = vim.fn.input("Renombrar a: ", current_file, "file")

    -- Si el usuario no cancela y el nombre es distinto
    if new_name ~= "" and new_name ~= current_file then
        vim.cmd("saveas " .. vim.fn.fnameescape(new_name)) -- Guarda con el nuevo nombre
        vim.fn.delete(current_file) -- Elimina el archivo viejo del sistema
        vim.cmd "bd #" -- Cierra el buffer fantasma viejo
        print "\nArchivo renombrado con éxito."
    end
end, { desc = "Renombrar archivo actual sin abrir explorador" })

-- 1. SALIR DE LA TERMINAL AL MODO NORMAL
-- Esto es vital: te permite presionar <Esc> en la terminal y volver al modo normal
-- para poder moverte, copiar texto o cerrar la ventana.
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal: Salir al modo normal" })

-- 2. CERRAR CUALQUIER VENTANA (Incluyendo Terminal)
-- Usamos <leader>q. El <leader> suele ser la barra espaciadora.
-- Es un atajo seguro porque no interfiere con las letras normales de escritura.
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Cerrar ventana actual" })

-- 3. CERRAR TERMINAL DESDE MODO INSERT O NORMAL (Atajo directo)
-- Si estás dentro de la terminal y quieres cerrarla de un solo golpe sin salir a normal primero:
map("t", "<leader>q", "<C-\\><C-n><cmd>quit<CR>", { desc = "Terminal: Cerrar ventana rápido" })

-- Cerrar todo excepto la ventana actual
map("n", "<leader>Q", "<cmd>only<CR>", { desc = "Cerrar todas las demás ventanas" })

-- ── NAVEGADOR DE ESTRUCTURAS DE CÓDIGO Y SQL (AERIAL) ────────────
local aerial_excluded_ft = { sql = true, mysql = true, plsql = true }

map("n", "<leader>o", function()
    if aerial_excluded_ft[vim.bo.filetype] then
        vim.notify("Aerial no soporta outline en SQL (bug del backend LSP/Treesitter).", vim.log.levels.WARN)
        return
    end
    local ok, aerial = pcall(require, "aerial")
    if ok then
        aerial.toggle()
    else
        vim.notify("Aerial no está descargado. Abre :Lazy y presiona 'I' para instalarlo.", vim.log.levels.ERROR)
    end
end, { desc = "Aerial: Toggle árbol de tablas y símbolos" })

map("n", "[s", function()
    local ok, aerial = pcall(require, "aerial")
    if ok then
        aerial.prev()
    end
end, { desc = "Aerial: Siguiente símbolo/tabla" })

map("n", "]s", function()
    local ok, aerial = pcall(require, "aerial")
    if ok then
        aerial.next()
    end
end, { desc = "Aerial: Símbolo/tabla anterior" })

map("v", "y", '"+y', { desc = "Copiar selección al portapapeles" })
