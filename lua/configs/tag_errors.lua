-- lua/configs/tag_errors.lua
-- Pinta en rojo los delimitadores `<  >  </  />` cuando Tree-sitter detecta una etiqueta mal formada
-- (cierre que no corresponde, `>` faltante, `<` suelto, JSX/XML sin cerrar...). Funciona para cualquier
-- gramática con etiquetas: html, xml, vue, svelte, astro, jsx/tsx, templ, ... y también para HTML
-- inyectado (markdown, php, etc.) porque recorre todo el LanguageTree.
--
-- Diseño: decoration provider con extmarks *efímeros* -> solo se calcula lo visible, nada se
-- guarda en el buffer, cero autocmds y cero latencia al teclear (reutiliza el árbol del highlighter).
local M = {}

local ns = vim.api.nvim_create_namespace "tag_errors"
local HL = "TagDelimiterError"
local PRIORITY = 260 -- por encima de treesitter (100) y de LSP semantic tokens (125)

local FT = {
    html = true,
    xml = true,
    xsl = true,
    xslt = true,
    svg = true,
    xhtml = true,
    vue = true,
    svelte = true,
    astro = true,
    javascriptreact = true,
    typescriptreact = true,
    javascript = true,
    templ = true,
    htmldjango = true,
    heex = true,
    eruby = true,
    php = true,
    markdown = true,
    mdx = true,
    razor = true,
    angular = true,
    htmlangular = true,
    twig = true,
}

-- Tokens anónimos que son delimitadores de etiqueta
local DELIM = { ["<"] = true, [">"] = true, ["</"] = true, ["/>"] = true }
-- Nodos "de etiqueta" (se pintan sus delimitadores si cuelgan de un ERROR)
local function tag_like(t)
    return t:find("tag", 1, true)
        or t:find("STag", 1, true)
        or t:find("ETag", 1, true)
        or t:find("opening_element", 1, true)
        or t:find("closing_element", 1, true)
        or t:find("self_closing", 1, true)
end

-- ── Reglas SOLO para HTML (en XML/JSX/Vue/Svelte `<x />` y `<Comp />` son válidos) ──────────────
-- Elementos void: únicos que pueden escribirse `<br>` / `<img />` sin cierre en HTML
local VOID = {}
for t in ("area base br col embed hr img input link meta param source track wbr keygen"):gmatch "%S+" do
    VOID[t] = true
end
-- Elementos con etiqueta de cierre opcional (WHATWG "optional tags")
local OPTIONAL_END = {}
for t in ("html head body p li dt dd rt rp optgroup option colgroup caption thead tbody tfoot tr td th"):gmatch "%S+" do
    OPTIONAL_END[t] = true
end
local FOREIGN = { svg = true, math = true } -- aquí `<path />` sí es válido

local function tag_name_of(node, buf)
    for child in node:iter_children() do
        if child:type() == "tag_name" then
            return child, vim.treesitter.get_node_text(child, buf):lower()
        end
    end
end

local function in_foreign(node, buf)
    local p = node:parent()
    while p do
        if p:type() == "element" then
            local first = p:child(0)
            if first and (first:type() == "start_tag" or first:type() == "self_closing_tag") then
                local _, name = tag_name_of(first, buf)
                if name and FOREIGN[name] then
                    return true
                end
            end
        end
        p = p:parent()
    end
    return false
end

local queries = {} -- lang -> Query|false
local query_for_html
local function query_for(lang)
    local q = queries[lang]
    if q ~= nil then
        return q
    end
    -- Cada patrón es opcional: no todas las gramáticas tienen erroneous_end_tag
    local ok, parsed = pcall(vim.treesitter.query.parse, lang, "(ERROR) @err (MISSING) @miss (erroneous_end_tag) @bad")
    if not ok then
        ok, parsed = pcall(vim.treesitter.query.parse, lang, "(ERROR) @err (MISSING) @miss")
    end
    queries[lang] = ok and parsed or false
    return queries[lang]
end

local function mark(out, node)
    local sr, sc, er, ec = node:range()
    out[#out + 1] = { sr, sc, er, ec }
end

-- delimitadores directos de `node`
local function delims_of(out, node)
    for child in node:iter_children() do
        if not child:named() and DELIM[child:type()] then
            mark(out, child)
        end
    end
end

-- Marca `<`, nombre y delimitador de cierre de una etiqueta
local function mark_tag(out, tag, buf)
    for child in tag:iter_children() do
        if (not child:named() and DELIM[child:type()]) or child:type() == "tag_name" then
            mark(out, child)
        end
    end
end

local function html_rules(out, root, buf, top, bot)
    local q = query_for_html
    for id, node in q:iter_captures(root, buf, top, bot + 1) do
        local cap = q.captures[id]
        if cap == "sct" then
            -- `<h1/>`, `<div />`: auto-cierre en un elemento que no es void ni SVG/MathML
            local _, name = tag_name_of(node, buf)
            if name and not VOID[name] and not in_foreign(node, buf) then
                mark_tag(out, node, buf)
            end
        else -- element
            local first, last = node:child(0), node:child(node:child_count() - 1)
            if first and first:type() == "start_tag" and last and last:type() ~= "end_tag" then
                local has_end = false
                for child in node:iter_children() do
                    if child:type() == "end_tag" then
                        has_end = true
                    end
                end
                local _, name = tag_name_of(first, buf)
                if not has_end and name and not VOID[name] and not OPTIONAL_END[name] and not in_foreign(node, buf) then
                    -- no molestar mientras se escribe en esa misma línea (modo insertar)
                    local row = first:range()
                    local typing = vim.fn.mode():sub(1, 1) == "i" and vim.api.nvim_win_get_cursor(0)[1] - 1 == row
                    if not typing then
                        mark_tag(out, first, buf)
                    end
                end
            end
        end
    end
end

---@return integer[][] rangos {sr, sc, er, ec} a pintar en rojo (sin duplicados)
function M.collect(buf, top, bot)
    local out = {}
    local ok, parser = pcall(vim.treesitter.get_parser, buf, nil, { error = false })
    if not ok or not parser then
        return out
    end
    parser:for_each_tree(function(tree, ltree)
        if ltree:lang() == "html" then
            query_for_html = query_for_html
                or vim.treesitter.query.parse("html", "(element) @el (self_closing_tag) @sct")
            html_rules(out, tree:root(), buf, top, bot)
        end
        local q = query_for(ltree:lang())
        if not q then
            return
        end
        for id, node in q:iter_captures(tree:root(), buf, top, bot + 1) do
            local cap = q.captures[id]
            if cap == "bad" then
                -- </span> sin pareja: todo el cierre
                mark(out, node)
            elseif cap == "miss" then
                local t = node:type()
                local parent = node:parent()
                if parent and (DELIM[t] or t:match "^[<>/]") then
                    -- `>` faltante: se pinta el `<` de apertura de la misma etiqueta
                    for child in parent:iter_children() do
                        if not child:named() and (child:type() == "<" or child:type() == "</") then
                            mark(out, child)
                            break
                        end
                    end
                end
            else -- ERROR
                delims_of(out, node)
                for child in node:iter_children() do
                    if child:named() and tag_like(child:type()) then
                        delims_of(out, child)
                    end
                end
            end
        end
    end)
    return out
end

-- Rojo propio e independiente del tema: más "puro" que el rojo láser/rosa del tema, con fondo
-- rojo oscuro y subrayado ondulado, para que NUNCA se confunda con la sintaxis normal.
local COLOR = { fg = "#FF3B3B", bg = "#3D0A10", sp = "#FF3B3B" }
local function define_hl()
    vim.api.nvim_set_hl(0, HL, { fg = COLOR.fg, bg = COLOR.bg, sp = COLOR.sp, bold = true, undercurl = true })
end

function M.setup()
    define_hl()
    local group = vim.api.nvim_create_augroup("TagErrors", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_hl })
    vim.api.nvim_create_autocmd("User", { group = group, pattern = "NvChadThemeReload", callback = define_hl })

    vim.api.nvim_set_decoration_provider(ns, {
        on_win = function(_, win, buf, top, bot)
            if not FT[vim.bo[buf].filetype] or vim.b[buf].tag_errors == false then
                return false
            end
            local seen = {}
            for _, r in ipairs(M.collect(buf, top, bot)) do
                local key = r[1] .. ":" .. r[2]
                if not seen[key] then
                    seen[key] = true
                    pcall(vim.api.nvim_buf_set_extmark, buf, ns, r[1], r[2], {
                        end_row = r[3],
                        end_col = r[4],
                        hl_group = HL,
                        priority = PRIORITY,
                        ephemeral = true,
                    })
                end
            end
        end,
    })
end

return M
