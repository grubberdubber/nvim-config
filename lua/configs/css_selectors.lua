-- Fuente de blink.cmp: clases, ids y variables CSS — BIDIRECCIONAL y multi-lenguaje.
--
--  · DEFINICIONES: *.css/scss/sass/less/pcss + bloques <style> de html/vue/svelte/astro/php...
--    (parseados y cacheados por mtime).
--  · USOS: class=, className=, class_=, :class="{...}", class:name (Svelte), clsx()/cn(),
--    classList.add(), addClass(), getElementById(), querySelector(), $(), By.ID,
--    hx-target="#x", .Class("x") (Go/Swift), classes!() (Rust), @class() (Blade)...
--    en TODO el código del proyecto (ripgrep, una pasada async). Entiende strings con
--    comillas escapadas (\"), como en C, C++, Java, C#, Go, Kotlin, Swift, Dart y Rust.
--
-- Todo vive en un índice por proyecto, con caché. Se calienta al abrir archivos y se
-- reindexa (con espera) al guardar un CSS o un archivo de código.
local source = {}
local uv = vim.uv or vim.loop

-- ── Ajustes ─────────────────────────────────────────────────────────
local SCAN_USAGE = true -- false = solo definiciones CSS (más ligero)
local STALE_MS = 30000
local DEBOUNCE_MS = 600
local MAX_STYLE_FILES = 3000
local MAX_EMBEDDED_FILES = 1500
local MAX_USE_HITS = 200000
local KIND = { class = 7, id = 21, var = 6 }

local ROOT_NAMES = {
    [".git"] = true,
    ["package.json"] = true,
    ["pyproject.toml"] = true,
    ["manage.py"] = true,
    ["requirements.txt"] = true,
    ["composer.json"] = true,
    ["Cargo.toml"] = true,
    ["go.mod"] = true,
    ["pom.xml"] = true,
    ["build.gradle"] = true,
    ["build.gradle.kts"] = true,
    ["pubspec.yaml"] = true,
    ["Package.swift"] = true,
    ["Gemfile"] = true,
    ["CMakeLists.txt"] = true,
}
local function is_root_marker(name)
    return ROOT_NAMES[name] == true or name:match "%.sln$" ~= nil or name:match "%.csproj$" ~= nil
end

local STYLE_FT = { css = true, scss = true, less = true, sass = true, postcss = true }
-- Archivos donde puede haber un bloque <style> (y completar . # dentro)
local EMBED_FT = {
    html = true,
    vue = true,
    svelte = true,
    astro = true,
    php = true,
    htmldjango = true,
    twig = true,
    eruby = true,
    xml = true,
    markdown = true,
    mdx = true,
}
local EMBED_EXTS = "html,htm,xhtml,vue,svelte,astro,php,phtml,twig,erb,ejs,hbs,njk,jinja,j2,cshtml,razor"
local SVELTE_FT = { svelte = true, astro = true }
-- Aquí `id: "x"` / `'id' => 'x'` sí es un id HTML (en otros lenguajes suele ser un dato)
local ID_COLON_FT = { ruby = true, eruby = true, haml = true, slim = true, php = true, lua = true }

local DISABLED_FT = {
    sql = true,
    mysql = true,
    plsql = true,
    json = true,
    jsonc = true,
    yaml = true,
    toml = true,
    tex = true,
    plaintex = true,
    bib = true,
    gitcommit = true,
    help = true,
    dbout = true,
    NvimTree = true,
    TelescopePrompt = true,
}

-- Archivos de código donde se buscan USOS. No se incluyen sh/bash/ps1: `$("...")` es
-- sustitución de comandos ahí, no jQuery, y solo generaría ruido.
local CODE_EXTS = {
    "html",
    "htm",
    "xhtml",
    "xml",
    "svg",
    "php",
    "phtml",
    "twig",
    "erb",
    "ejs",
    "hbs",
    "njk",
    "jinja",
    "j2",
    "haml",
    "slim",
    "vue",
    "svelte",
    "astro",
    "jsx",
    "tsx",
    "js",
    "mjs",
    "cjs",
    "ts",
    "py",
    "rb",
    "rs",
    "go",
    "templ",
    "cs",
    "razor",
    "cshtml",
    "java",
    "kt",
    "kts",
    "swift",
    "dart",
    "c",
    "cc",
    "cpp",
    "cxx",
    "h",
    "hpp",
    "hh",
    "lua",
    "nim",
    "scala",
    "md",
    "mdx",
}
local CODE_GLOB = "*.{" .. table.concat(CODE_EXTS, ",") .. "}"
local EXCLUDES = {
    "-g",
    "!*.min.*",
    "-g",
    "!**/node_modules/**",
    "-g",
    "!**/vendor/**",
    "-g",
    "!**/dist/**",
    "-g",
    "!**/build/**",
    "-g",
    "!**/target/**",
    "-g",
    "!**/.next/**",
    "-g",
    "!**/.nuxt/**",
    "-g",
    "!**/.venv/**",
    "-g",
    "!**/venv/**",
    "-g",
    "!**/__pycache__/**",
    "-g",
    "!**/.git/**",
}

-- ── Patrones de ripgrep (regex de Rust) para encontrar USOS ─────────
-- Comilla con hasta 2 barras delante: "  \"  \\"  (strings escapados de C/Java/Go/...)
local Q = [=[\\{0,2}["'`]]=]
local STR = Q .. [=[[^"'`\\\n]*]=] .. Q -- "texto"
local STRS = "(?:" .. STR .. [=[[\s,]*)+]=] -- uno o más strings separados por comas

local USE_PATTERNS = {
    -- class="a b"  className={`a`}  class_="a"  class: "a"  klass:  cssClass=
    [=[\b(?:class|classes|className|class_|klass|cssClass|styleClass)\s*[=:]\s*[{(@\[]?\s*]=] .. STR,
    [=[\bid=\s*[{(@]?\s*]=] .. STR,
    -- {"class": "a"}  ["class"] = "a"  'class' => 'a'
    [=[["'`]class["'`]\s*(?:=>|[:=])\s*]=] .. STR,
    -- Vue / Alpine / Angular:  :class="{ a: x }"  v-bind:class  [ngClass]  [class.foo]
    [=[(?:v-bind:|x-bind:|:|\[)(?:class|ngClass)\]?\s*=\s*(?:"[^"\n]*"|'[^'\n]*')]=],
    [=[\[class\.[A-Za-z_][\w-]*\]]=],
    -- Svelte / Astro:  class:active
    [=[\bclass:[A-Za-z_][\w-]*]=],
    -- Rust (Yew), Blade, Kotlin
    [=[classes!\([^)\n]*\)]=],
    [=[@class\(\[[^\]\n]*\]\)]=],
    [=[\bclasses\s*=\s*\w+\(\s*]=] .. STRS,
    -- clsx("a", "b")  cn(...)  classnames(...)  twMerge(...)  cva(...)
    [=[\b(?:clsx|cn|classnames|classNames|cx|twMerge|twJoin|cva|tv)\(\s*]=] .. STRS,
    -- API de clases
    [=[\b(?:classList|classes)\.\w+\(\s*]=] .. STRS,
    [=[\b(?:addClass|removeClass|toggleClass|hasClass|getElementsByClassName|getElementsByClass)\(\s*]=] .. STRS,
    [=[(?:\.class|\bClass)\(\s*]=] .. STRS, -- Go (gomponents), Swift (Plot)
    -- ids
    [=[(?:\bgetElementById|\bGetElementById|\bfindElementById|\bID|\bId|\.id)\(\s*]=] .. STR,
    -- Selenium / Playwright / jsoup / BeautifulSoup / AngleSharp
    [=[\bBy\.(?:ID|CLASS_NAME|CSS_SELECTOR|id|className|cssSelector|Id|ClassName|CssSelector)\s*[,(]\s*]=] .. STR,
    [=[\b(?:querySelector(?:All)?|QuerySelector(?:All)?|closest|selectFirst|locator)\(\s*]=] .. STR,
    [=[\.select(?:_one)?\(\s*]=] .. STR,
    [=[\$\$?\(\s*]=] .. STR, -- jQuery
    -- htmx / Bootstrap: hx-target="#x"
    [=[\b(?:hx-target|hx-include|hx-indicator|hx-select|data-bs-target|data-target|data-bs-parent)\s*=\s*]=] .. STR,
    -- setAttribute("class", "x") / .attr("id", "x")
    [=[\b(?:setAttribute|attr|setattr)\(\s*["'](?:class|id)["']\s*,\s*]=] .. STR,
}

-- head (en minúsculas) -> qué se extrae
local HEAD_KIND = {
    class = "class",
    classname = "class",
    class_ = "class",
    klass = "class",
    cssclass = "class",
    styleclass = "class",
    classes = "class",
    ["classes!"] = "class",
    ["@class"] = "class",
    clsx = "class",
    cn = "class",
    classnames = "class",
    cx = "class",
    twmerge = "class",
    twjoin = "class",
    cva = "class",
    tv = "class",
    addclass = "apiclass",
    removeclass = "apiclass",
    toggleclass = "apiclass",
    hasclass = "apiclass",
    getelementsbyclassname = "apiclass",
    getelementsbyclass = "apiclass",
    ["by.classname"] = "apiclass",
    ["by.class_name"] = "apiclass",
    getelementbyid = "id",
    findelementbyid = "id",
    ["by.id"] = "id",
    id = "id",
    queryselector = "sel",
    queryselectorall = "sel",
    closest = "sel",
    select = "sel",
    select_one = "sel",
    selectfirst = "sel",
    locator = "sel",
    ["$"] = "sel",
    ["$$"] = "sel",
    ["by.css_selector"] = "sel",
    ["by.cssselector"] = "sel",
    ["hx-target"] = "sel",
    ["hx-include"] = "sel",
    ["hx-indicator"] = "sel",
    ["hx-select"] = "sel",
    ["data-bs-target"] = "sel",
    ["data-target"] = "sel",
    ["data-bs-parent"] = "sel",
    setattribute = "attr",
    attr = "attr",
    setattr = "attr",
}

local cache = {} -- root -> { root, files, uses, items, sets, tailwind, at, scanning, dirty }

-- ── Parser de CSS ───────────────────────────────────────────────────
local function parse(text)
    local tailwind = text:find("@tailwind", 1, true) ~= nil or text:find "@import%s+[\"']tailwindcss" ~= nil
    text = text:gsub("/%*.-%*/", " ")
    text = text:gsub("url%b()", " ")
    text = text:gsub('"[^"\n]*"', " ")
    text = text:gsub("'[^'\n]*'", " ")
    text = text:gsub("//[^\n]*", " ")
    text = text:gsub("#%b{}", "")

    local classes, ids, vars = {}, {}, {}
    for sel in text:gmatch "([^{};]*){" do
        if not sel:match "^%s*@" then
            for c in sel:gmatch "%.(%-?[%a_][%w_-]*)" do
                classes[c] = true
            end
            for i in sel:gmatch "#(%-?[%a_][%w_-]*)" do
                ids[i] = true
            end
        end
    end
    for v in text:gmatch "(%-%-[%w_-]+)%s*:" do
        vars[v] = true
    end
    return classes, ids, vars, tailwind
end

-- ── Extracción de USOS desde la salida de ripgrep ───────────────────
local function valid(tok)
    return #tok > 0 and #tok <= 64 and tok:match "^%-?[%a_][%w_-]*$" ~= nil
end

local function collect(m, u)
    m = m:gsub("\\", "") -- \" -> "
    local l = m:lower()
    local head = (l:match "^[%w_$!.@:%-]+" or ""):gsub("^%.", "")
    if not head:match "^class:[%a_]" then
        head = head:gsub("[:]+$", "")
    end

    local function add(set, tok)
        if valid(tok) then
            set[tok] = true
        end
    end
    local function split_into(set, s)
        for t in s:gmatch "[^%s,]+" do
            add(set, t)
        end
    end
    local function quoted()
        return m:gmatch "[\"'`]([^\"'`]*)[\"'`]"
    end
    local function first_quoted()
        return m:match "[\"'`]([^\"'`]*)[\"'`]"
    end

    -- Svelte / Astro: class:active
    local sv = m:match "^class:([%a_][%w_-]*)"
    if sv then
        if sv ~= "list" then
            add(u.classes, sv)
        end
        return
    end

    -- Angular: [class.foo]="cond"
    local ang = m:match "^%[class%.([%w_-]+)%]"
    if ang then
        add(u.classes, ang)
        return
    end

    -- Vue / Alpine / Angular: :class="{ a: x, 'b': y }"  [ngClass]="['a']"
    if l:match "^%[" or head:match ":class$" then
        local inner = m:match '=%s*"(.-)"' or m:match "=%s*'(.-)'"
        if inner then
            for q in inner:gmatch "[\"'`]([^\"'`]+)[\"'`]" do
                split_into(u.classes, q)
            end
            if inner:match "^%s*{" then
                for k in inner:gmatch "([%a_][%w_-]*)%s*:" do
                    add(u.classes, k)
                end
            end
        end
        return
    end

    -- {"class": "a b"}   ["class"] = "a"   'class' => 'a'
    if l:match "^[\"'`]class[\"'`]" then
        local v = m:match "^[\"'`]class[\"'`]%s*[:=>]+%s*[\"'`]([^\"'`]*)"
        if v then
            split_into(u.classes, v)
        end
        return
    end

    local kind = HEAD_KIND[head]
    if not kind and (head:match "^classlist%." or head:match "^classes%.") then
        kind = "apiclass"
    end
    if not kind then
        return
    end

    if kind == "class" or kind == "apiclass" then
        local set = kind == "class" and u.classes or u.api_classes
        for q in quoted() do
            split_into(set, q)
        end
    elseif kind == "id" then
        local q = first_quoted()
        if q then
            add(u.ids, q)
        end
    elseif kind == "sel" then
        local q = first_quoted()
        if q then
            for c in q:gmatch "%.(%-?[%a_][%w_-]*)" do
                add(u.api_classes, c)
            end
            for i in q:gmatch "#(%-?[%a_][%w_-]*)" do
                add(u.ids, i)
            end
        end
    elseif kind == "attr" then
        local attr, val = m:match "[\"'`]([%w_-]+)[\"'`]%s*,%s*[\"'`]([^\"'`]*)"
        if attr then
            attr = attr:lower()
            if attr == "class" then
                split_into(u.classes, val)
            elseif attr == "id" then
                add(u.ids, val)
            end
        end
    end
end

-- ── Índice ──────────────────────────────────────────────────────────
local function rebuild(c)
    local seen = { class = {}, id = {}, var = {} }
    c.tailwind = c.tailwind_cfg or false
    for _, f in pairs(c.files) do
        if f.tailwind then
            c.tailwind = true
        end
    end
    for rel, f in pairs(c.files) do
        for kind, set in pairs { class = f.classes, id = f.ids, var = f.vars } do
            for name in pairs(set) do
                if not seen[kind][name] then
                    seen[kind][name] = { rel = rel, def = true }
                end
            end
        end
    end
    for rel, u in pairs(c.uses) do
        local class_sets = { u.api_classes }
        -- En proyectos Tailwind, class="flex px-4" son utilidades, no clases propias
        if not c.tailwind then
            class_sets[#class_sets + 1] = u.classes
        end
        for _, set in ipairs(class_sets) do
            for name in pairs(set) do
                if not seen.class[name] then
                    seen.class[name] = { rel = rel, def = false }
                end
            end
        end
        for name in pairs(u.ids) do
            if not seen.id[name] then
                seen.id[name] = { rel = rel, def = false }
            end
        end
    end
    c.items, c.sets = {}, { class = {}, id = {}, var = {} }
    for kind, map in pairs(seen) do
        local arr = {}
        for name, info in pairs(map) do
            arr[#arr + 1] = { name = name, rel = info.rel, def = info.def }
            c.sets[kind][name] = true
        end
        table.sort(arr, function(a, b)
            return a.name < b.name
        end)
        c.items[kind] = arr
    end
end

local function stat_stamp(path)
    local st = uv.fs_stat(path)
    return st and (st.mtime.sec .. ":" .. st.mtime.nsec) or nil
end

local function read_file(path, max)
    local fh = io.open(path, "r")
    if not fh then
        return nil
    end
    local text = fh:read(max or "*a")
    fh:close()
    return text
end

local function rg(cmd, root, cb)
    local ok = pcall(vim.system, cmd, { cwd = root, text = true }, vim.schedule_wrap(cb))
    return ok
end

local function list_lines(s)
    local out = {}
    for line in (s or ""):gmatch "[^\n]+" do
        out[#out + 1] = line
    end
    return out
end

-- Definiciones: hojas de estilo + bloques <style> embebidos
local function scan_styles(c, done)
    local alive = {}

    local function finish()
        for rel in pairs(c.files) do
            if not alive[rel] then
                c.files[rel] = nil
            end
        end
        done()
    end

    local function embedded()
        local cmd = {
            "rg",
            "-l",
            "--no-messages",
            "--max-filesize",
            "1M",
            "-g",
            "*.{" .. EMBED_EXTS .. "}",
            "<style",
        }
        vim.list_extend(cmd, EXCLUDES)
        local ok = rg(cmd, c.root, function(res)
            if res.code == 0 then
                local n = 0
                for _, rel in ipairs(list_lines(res.stdout)) do
                    n = n + 1
                    if n > MAX_EMBEDDED_FILES then
                        break
                    end
                    alive[rel] = true
                    local path = c.root .. "/" .. rel
                    local stamp = stat_stamp(path)
                    local f = c.files[rel]
                    if stamp and (not f or f.stamp ~= stamp) then
                        local text = read_file(path)
                        if text then
                            local cl, ids, vars = {}, {}, {}
                            for css in text:gmatch "<[Ss][Tt][Yy][Ll][Ee][^>]*>(.-)</[Ss][Tt][Yy][Ll][Ee]>" do
                                local a, b, v = parse(css)
                                for k in pairs(a) do
                                    cl[k] = true
                                end
                                for k in pairs(b) do
                                    ids[k] = true
                                end
                                for k in pairs(v) do
                                    vars[k] = true
                                end
                            end
                            c.files[rel] = { stamp = stamp, classes = cl, ids = ids, vars = vars }
                        end
                    end
                end
            end
            finish()
        end)
        if not ok then
            finish()
        end
    end

    local cmd = {
        "rg",
        "--files",
        "--no-messages",
        "--max-filesize",
        "2M",
        "-g",
        "*.{css,scss,less,sass,pcss,postcss}",
    }
    vim.list_extend(cmd, EXCLUDES)
    local ok = rg(cmd, c.root, function(res)
        if res.code == 0 or res.code == 1 then
            local n = 0
            for _, rel in ipairs(list_lines(res.stdout)) do
                n = n + 1
                if n > MAX_STYLE_FILES then
                    break
                end
                alive[rel] = true
                local path = c.root .. "/" .. rel
                local stamp = stat_stamp(path)
                local f = c.files[rel]
                if stamp and (not f or f.stamp ~= stamp) then
                    local text = read_file(path)
                    if text then
                        local cl, ids, vars, tw = parse(text)
                        c.files[rel] = { stamp = stamp, classes = cl, ids = ids, vars = vars, tailwind = tw }
                    end
                end
            end
        end
        embedded()
    end)
    if not ok then
        done() -- ripgrep no instalado
    end
end

-- Usos: una sola pasada de ripgrep sobre todo el código
local function scan_usage(c, done)
    if not SCAN_USAGE then
        c.uses = {}
        return done()
    end
    local cmd = {
        "rg",
        "--null",
        "-o",
        "-N",
        "--with-filename",
        "--no-heading",
        "--no-messages",
        "--max-filesize",
        "1M",
        "--max-columns",
        "1000",
        "-g",
        CODE_GLOB,
    }
    vim.list_extend(cmd, EXCLUDES)
    for _, p in ipairs(USE_PATTERNS) do
        vim.list_extend(cmd, { "-e", p })
    end
    local ok = rg(cmd, c.root, function(res)
        if res.code == 0 or res.code == 1 then
            local uses, n = {}, 0
            for _, line in ipairs(list_lines(res.stdout)) do
                n = n + 1
                if n > MAX_USE_HITS then
                    break
                end
                local sep = line:find("\0", 1, true)
                if sep then
                    local rel = line:sub(1, sep - 1)
                    local u = uses[rel] or { classes = {}, api_classes = {}, ids = {} }
                    uses[rel] = u
                    collect(line:sub(sep + 1), u)
                end
            end
            c.uses = uses
        end
        done()
    end)
    if not ok then
        done()
    end
end

local function refresh(c)
    if c.scanning then
        c.dirty = true
        return
    end
    c.scanning, c.dirty = true, false
    for _, name in ipairs { "js", "ts", "cjs", "mjs" } do
        if uv.fs_stat(c.root .. "/tailwind.config." .. name) then
            c.tailwind_cfg = true
        end
    end
    local pending = 2
    local function done()
        pending = pending - 1
        if pending == 0 then
            rebuild(c)
            c.at = uv.now()
            c.scanning = false
            if c.dirty then
                vim.schedule(function()
                    refresh(c)
                end)
            end
        end
    end
    scan_styles(c, done)
    scan_usage(c, done)
end

-- Raíz del proyecto, cacheada por buffer (se invalida al renombrar/guardar)
local root_cache = {}
local function project_root()
    local buf = vim.api.nvim_get_current_buf()
    local r = root_cache[buf]
    if not r then
        r = vim.fs.root(buf, is_root_marker) or vim.fn.getcwd()
        root_cache[buf] = r
    end
    return r
end

local function ensure(root, force)
    local c = cache[root]
    if not c then
        c = { root = root, files = {}, uses = {}, items = {}, sets = {}, at = 0, scanning = false, dirty = false }
        cache[root] = c
    end
    if force or uv.now() - c.at > STALE_MS then
        refresh(c)
    end
    return c
end

-- ── Detección de contexto (sirve para todos los lenguajes) ──────────
-- Qp: comilla con barras opcionales (\" en strings escapados)   Cap: lo tecleado dentro
local Qp = "\\*[\"'`]"
local Cap = "([^\"'`\\]*)$"
local OPEN = "[{(@%[]?%s*" .. Qp

local function esc(s)
    return (s:gsub("%-", "%%-"))
end

local function value_of(l, b, pat)
    local cap = (" " .. l):match(pat)
    if cap then
        return b:sub(#b - #cap + 1)
    end
end

local CLASS_PATS = {
    -- Vue / Alpine / Angular: :class="{ 'a': x, 'b   |   :class="['a', 'b
    "[^%w_%-]class%]?%s*=%s*\"[^\"]*'([^']*)$",
    "[^%w_%-]ngclass%]?%s*=%s*\"[^\"]*'([^']*)$",
    -- {"class": "a"}   ["class"] = "a"   'class' => 'a'
    "[\"'`]class[\"'`]%s*[:=]>?%s*" .. Qp .. Cap,
    -- Rust (Yew), Blade, Kotlin
    "classes!%([^)]*" .. Qp .. Cap,
    "@class%(%[[^%]]*" .. Qp .. Cap,
    "[^%w_]classes%s*=%s*%a+%([^)]*" .. Qp .. Cap,
    -- By.CLASS_NAME, "x"   By.className("x")
    "by%.class_?name%s*[,(]%s*" .. Qp .. Cap,
}
for _, name in ipairs { "class", "classes", "classname", "class_", "klass", "cssclass", "styleclass" } do
    CLASS_PATS[#CLASS_PATS + 1] = "[^%w_%-]" .. name .. "%s*[=:]%s*" .. OPEN .. Cap
end
-- Funciones: classList.add("a", "b   addClass("a   clsx("a", cond && "b   .class("a
for _, name in ipairs {
    "classlist%.%a+",
    "classes%.%a+",
    "addclass",
    "removeclass",
    "toggleclass",
    "hasclass",
    "getelementsbyclassname",
    "getelementsbyclass",
    "clsx",
    "cn",
    "classnames",
    "cx",
    "twmerge",
    "twjoin",
    "cva",
    "tv",
    "class",
} do
    CLASS_PATS[#CLASS_PATS + 1] = "[^%w_]" .. name .. "%([^)]*" .. Qp .. Cap
end

local ID_PATS = {
    "[^%w_%-:]id%s*=%s*" .. OPEN .. Cap,
    "[^%w_]getelementbyid%(%s*" .. Qp .. Cap,
    "[^%w_]findelementbyid%(%s*" .. Qp .. Cap,
    "by%.id%s*[,(]%s*" .. Qp .. Cap,
    "[^%w_]id%(%s*" .. Qp .. Cap,
    "[^%w_%-:]href%s*=%s*\\*[\"']#([^\"'\\]*)$",
}
for _, name in ipairs {
    "htmlfor",
    "aria-controls",
    "aria-owns",
    "aria-activedescendant",
    "aria-labelledby",
    "aria-describedby",
    "aria-details",
    "aria-errormessage",
    "aria-flowto",
    "popovertarget",
    "commandfor",
    "anchor",
} do
    ID_PATS[#ID_PATS + 1] = "[^%w_%-:]" .. esc(name) .. "%s*=%s*" .. OPEN .. Cap
end
-- Atributos ambiguos (for, list, form...): solo dentro de una etiqueta <...
for _, name in ipairs { "for", "list", "form", "headers" } do
    ID_PATS[#ID_PATS + 1] = "<[%w_%-]+[^<>]*%s" .. name .. "%s*=%s*" .. Qp .. Cap
end
local ID_COLON_PATS = {
    "[^%w_%-:]id%s*:%s*" .. Qp .. Cap,
    "[\"']id[\"']%s*=>%s*" .. Qp .. Cap,
    "%[[\"']id[\"']%]%s*=%s*" .. Qp .. Cap,
}

local SELECTOR_PATS = {}
for _, name in ipairs {
    "queryselector%a*",
    "closest",
    "select_one",
    "selectfirst",
    "select",
    "locator",
    "cssselector",
} do
    SELECTOR_PATS[#SELECTOR_PATS + 1] = "[^%w_]" .. name .. "%(%s*" .. Qp .. Cap
end
SELECTOR_PATS[#SELECTOR_PATS + 1] = "[^%w_]%$%$?%(%s*" .. Qp .. Cap
SELECTOR_PATS[#SELECTOR_PATS + 1] = "by%.css_selector%s*[,(]%s*" .. Qp .. Cap
for _, name in ipairs {
    "hx-target",
    "hx-include",
    "hx-indicator",
    "hx-select",
    "data-bs-target",
    "data-target",
    "data-bs-parent",
} do
    SELECTOR_PATS[#SELECTOR_PATS + 1] = "[^%w_%-]" .. esc(name) .. "%s*=%s*" .. Qp .. Cap
end

local VAR_PATS = {
    "var%(%s*(%-%-[%w_%-]*)$",
    "getpropertyvalue%(%s*" .. Qp .. "(%-*[%w_%-]*)$",
    "setproperty%(%s*" .. Qp .. "(%-*[%w_%-]*)$",
    "removeproperty%(%s*" .. Qp .. "(%-*[%w_%-]*)$",
}

local function last_pos(s, needle)
    local pos, i = nil, 1
    while true do
        local a = s:find(needle, i, true)
        if not a then
            return pos
        end
        pos, i = a, a + 1
    end
end

-- ¿El cursor está dentro de un bloque <style> de un html/vue/svelte/...?
local function in_style_block(b, row)
    local lb = b:lower()
    local s, e = last_pos(lb, "<style"), last_pos(lb, "</style")
    if s or e then
        return (s or 0) > (e or 0)
    end
    local first = math.max(0, row - 401)
    local lines = vim.api.nvim_buf_get_lines(0, first, row - 1, false)
    for i = #lines, 1, -1 do
        local s2 = lines[i]:lower()
        if s2:find("</style", 1, true) then
            return false
        end
        if s2:find("<style", 1, true) then
            return true
        end
    end
    return false
end

local function detect(b, row)
    local ft = vim.bo.filetype
    row = row or vim.api.nvim_win_get_cursor(0)[1]

    -- Dentro de CSS (archivo .css o bloque <style>)
    if STYLE_FT[ft] or (EMBED_FT[ft] and in_style_block(b, row)) then
        local seg = b:match "([^{};]*)$"
        local v = seg:match "var%(%s*(%-*[%w_-]*)$"
        if v then
            return "var", v
        end
        local decl = seg:match "^%s*[%a-][%w-]*%s*:%s" or seg:match "^%s*[%a-][%w-]*%s*:[#.%d%-%($]"
        if not decl then
            local t = seg:match "%.([%w_-]*)$"
            if t then
                return "class", t
            end
            t = seg:match "#([%w_-]*)$"
            if t then
                return "id", t
            end
        end
        return nil
    end

    local l = b:lower()

    -- var(--x) en cualquier lenguaje (style="...", CSS-in-JS, plantillas)
    local v = value_of(l, b, VAR_PATS[1])
    if v then
        return "var", v
    end

    -- Svelte / Astro: class:active
    if SVELTE_FT[ft] then
        v = value_of(l, b, "[^%w_%-]class:([%w_%-]*)$")
        if v then
            return "class", v
        end
    end

    for _, pat in ipairs(CLASS_PATS) do
        v = value_of(l, b, pat)
        if v then
            return "class", v:match "([^%s]*)$"
        end
    end
    for _, pat in ipairs(ID_PATS) do
        v = value_of(l, b, pat)
        if v then
            return "id", v:match "([^%s]*)$"
        end
    end
    if ID_COLON_FT[ft] then
        for _, pat in ipairs(ID_COLON_PATS) do
            v = value_of(l, b, pat)
            if v then
                return "id", v:match "([^%s]*)$"
            end
        end
    end
    for _, pat in ipairs(SELECTOR_PATS) do
        v = value_of(l, b, pat)
        if v then
            local tok = v:match "([^%s>+~,%[%(%)]*)$"
            local sym, name = tok:match "([.#])([%w_-]*)$"
            if sym == "." then
                return "class", name
            elseif sym == "#" then
                return "id", name
            end
        end
    end
    for i = 2, #VAR_PATS do
        v = value_of(l, b, VAR_PATS[i])
        if v then
            return "var", v
        end
    end
    return nil
end

-- ── API pública para blink.lua (iconos y deduplicado) ───────────────
function source.kind_at(line_before, row)
    return (detect(line_before, row))
end

function source.has(kind, name)
    local c = cache[project_root()]
    return c ~= nil and c.sets[kind] ~= nil and c.sets[kind][name] == true
end

-- Solo para pruebas
source._internal = { detect = detect, collect = collect, cache = cache, ensure = ensure, project_root = project_root }

-- ── API de blink.cmp ────────────────────────────────────────────────
function source.new(opts)
    local group = vim.api.nvim_create_augroup("CssSelectorsIndex", { clear = true })
    local timer = uv.new_timer()
    local pending_root

    local function schedule(root)
        pending_root = root
        timer:stop()
        timer:start(
            DEBOUNCE_MS,
            0,
            vim.schedule_wrap(function()
                ensure(pending_root, true)
            end)
        )
    end

    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function()
            if vim.bo.buftype == "" then
                ensure(project_root())
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "BufFilePost", "BufWritePost", "BufWipeout" }, {
        group = group,
        callback = function(args)
            root_cache[args.buf] = nil
        end,
    })
    local patterns = { "*.css", "*.scss", "*.less", "*.sass", "*.pcss", "*.postcss" }
    for _, ext in ipairs(CODE_EXTS) do
        patterns[#patterns + 1] = "*." .. ext
    end
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = patterns,
        callback = function()
            schedule(project_root())
        end,
    })
    vim.schedule(function()
        ensure(project_root())
    end)
    return setmetatable({ opts = opts or {} }, { __index = source })
end

function source:enabled()
    return not DISABLED_FT[vim.bo.filetype] and vim.bo.buftype ~= "prompt"
end

function source:get_trigger_characters()
    return { ".", "#", '"', "'", " ", "(", ":" }
end

function source:get_completions(ctx, callback)
    local row, col = ctx.cursor[1] - 1, ctx.cursor[2]
    local kind, typed = detect(ctx.line:sub(1, col), ctx.cursor[1])
    local items = {}

    if kind then
        local c = ensure(project_root())
        local range = {
            start = { line = row, character = col - #typed },
            ["end"] = { line = row, character = col },
        }
        for _, e in ipairs(c.items[kind] or {}) do
            items[#items + 1] = {
                label = e.name,
                kind = KIND[kind],
                sel_kind = kind, -- marca propia: de aquí sale el icono
                textEdit = { newText = e.name, range = range },
                labelDetails = { detail = e.def and "" or " ·not in CSS", description = e.rel },
            }
        end
    end

    callback { items = items, is_incomplete_backward = false, is_incomplete_forward = false }
    return function() end
end

return source
