---@diagnostic disable: undefined-global
require "nvchad.mappings"

local map = vim.keymap.set

-- ── BLINDAJE DE TAB: FORCE 4 ESPACIOS (NO IA) ────────────────────
-- Si el menú de autocompletado normal está abierto, Tab interactúa con él.
-- Si estás escribiendo un if y sale la IA en gris, Tab mete tus 4 espacios de forma obligatoria.
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

-- ── SCROLL CENTRADO (lento línea a línea, rápido media página) ───
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll: Media página abajo (centrado)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll: Media página arriba (centrado)" })
map("n", "<C-e>", "3<C-e>", { desc = "Scroll: Lento hacia abajo (3 líneas)" })
map("n", "<C-y>", "3<C-y>", { desc = "Scroll: Lento hacia arriba (3 líneas)" })
map("n", "n", "nzzzv", { desc = "Búsqueda: Siguiente resultado (centrado)" })
map("n", "N", "Nzzzv", { desc = "Búsqueda: Anterior resultado (centrado)" })

-- ── REDIMENSIONAR VENTANAS (espacialmente consciente, estilo bspwm) ──
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
end, { desc = "Ventana: Mover borde a la izquierda" })
map("n", "<C-Right>", function()
    smart_resize "right"
end, { desc = "Ventana: Mover borde a la derecha" })
map("n", "<C-Up>", function()
    smart_resize "up"
end, { desc = "Ventana: Mover borde arriba" })
map("n", "<C-Down>", function()
    smart_resize "down"
end, { desc = "Ventana: Mover borde abajo" })

-- ── TERMINAL EN LAS 4 DIRECCIONES (extiende nvchad.term) ──────────
-- <A-h> abajo, <A-v> derecha, <A-i> flotante ya vienen de NvChad — no se tocan.
-- Acá solo agregamos las 2 direcciones que faltaban: izquierda y arriba.
local function git_cwd()
    local git_dir = vim.fn.systemlist("git -C " .. vim.fn.expand "%:p:h" .. " rev-parse --show-toplevel")[1]
    if vim.v.shell_error == 0 and git_dir then
        return git_dir
    end
    return vim.fn.getcwd()
end

map({ "n", "t" }, "<A-j>", function()
    require("nvchad.term").toggle { pos = "vsp", id = "leftTerm", cwd = git_cwd() }
    vim.cmd "wincmd H" -- Envía la terminal recién abierta al borde izquierdo
end, { desc = "Terminal: Toggle izquierda (raíz del repo)" })

map({ "n", "t" }, "<A-k>", function()
    require("nvchad.term").toggle { pos = "sp", id = "upTerm", cwd = git_cwd() }
    vim.cmd "wincmd K" -- Envía la terminal recién abierta al borde superior
end, { desc = "Terminal: Toggle arriba (raíz del repo)" })

-- ── ABRIR SPLIT DE CÓDIGO EN UNA DIRECCIÓN ESPECÍFICA ─────────────
map("n", "<leader>wh", "<cmd>leftabove vsplit<CR>", { desc = "Split: Abrir a la izquierda" })
map("n", "<leader>wl", "<cmd>rightbelow vsplit<CR>", { desc = "Split: Abrir a la derecha" })
map("n", "<leader>wk", "<cmd>aboveleft split<CR>", { desc = "Split: Abrir arriba" })
map("n", "<leader>wj", "<cmd>belowright split<CR>", { desc = "Split: Abrir abajo" })

-- ── ESTADO DE NAVEGACIÓN DEL WINBAR (selección pendiente, sin abrir aún) ──
_G.WinbarNavState = { active = false, mode = nil, index = 1, items = {} }

local function winbar_reset_nav()
    _G.WinbarNavState = { active = false, mode = nil, index = 1, items = {} }
end

-- Reinicia la selección pendiente al cambiar de buffer, para no arrastrar
-- una selección vieja de otro archivo/carpeta.
vim.api.nvim_create_autocmd("BufEnter", {
    callback = winbar_reset_nav,
})

local function get_breadcrumb_items()
    local full_path = vim.fn.expand "%:p"
    if full_path == "" then
        return {}
    end

    local git_root_list = vim.fn.systemlist("git -C " .. vim.fn.expand "%:p:h" .. " rev-parse --show-toplevel")
    local root = (vim.v.shell_error == 0 and git_root_list[1] and git_root_list[1] ~= "" and git_root_list[1])
        or vim.fn.getcwd()

    local rel = full_path
    if full_path:sub(1, #root) == root then
        rel = full_path:sub(#root + 2)
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

-- ]f / [f: SOLO mueven la selección (resaltada en otro color), no abren nada.
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

-- Enter: SOLO acá se abre lo seleccionado. Sin selección pendiente, Enter
-- se comporta como siempre (bajar a la primera columna no vacía de abajo).
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
end, { desc = "Winbar: Mover selección siguiente (Enter abre)" })
map("n", "[f", function()
    winbar_nav_move(-1)
end, { desc = "Winbar: Mover selección anterior (Enter abre)" })
map("n", "<CR>", winbar_nav_confirm, { desc = "Winbar: Confirmar selección / Enter normal" })

map("n", "<leader>ww", function()
    vim.g.winbar_mode = (vim.g.winbar_mode == "path") and "files" or "path"
    winbar_reset_nav()
    vim.notify("Winbar: modo " .. vim.g.winbar_mode, vim.log.levels.INFO)
    vim.cmd "redrawstatus!"
end, { desc = "Winbar: Alternar modo (ruta / archivos)" })

-- ── DAP-PYTHON: Debug de tests (pytest/unittest) ─────────────────
map("n", "<leader>dpt", function()
    require("dap-python").test_method()
end, { desc = "DAP: Debug método de test (Python)" })
map("n", "<leader>dpc", function()
    require("dap-python").test_class()
end, { desc = "DAP: Debug clase de test (Python)" })

-- ── VISTA PREVIA WEB (LIVE SERVER) ───────────────────────────────
map("n", "<F4>", "<cmd>LiveServerStart<CR>", { desc = "Web: Iniciar Live Server" })
map("n", "<S-F4>", "<cmd>LiveServerStop<CR>", { desc = "Web: Detener Live Server" })

-- ── TODO/FIXME: listado y navegación ─────────────────────────────
map("n", "<leader>ft", "<cmd>Trouble todo toggle<CR>", { desc = "Trouble: Listar TODO/FIXME/BUG del proyecto" })
map("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "TODO: Siguiente comentario" })
map("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "TODO: Comentario anterior" })

-- ── NOTAS RÁPIDAS (ventana flotante) ──────────────────────────────
map("n", "<leader>nn", "<cmd>GlobalNote<CR>", { desc = "Nota: Global (todas las sesiones)" })
map("n", "<leader>np", "<cmd>ProjectNote<CR>", { desc = "Nota: Del proyecto actual (por carpeta git)" })
