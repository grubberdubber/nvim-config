-- Pattern tables for the css_selectors blink source.
-- Kept apart from the index/scanning logic so the delicate per-language
-- rules can be reviewed, extended and tested on their own.
local M = {}

-- ── Ripgrep patterns (Rust regex) used to find USAGES ─────────────
-- Quote with up to 2 leading backslashes: "  \"  \\"  (escaped C/Java/Go/... strings)
local Q = [=[\\{0,2}["'`]]=]
local STR = Q .. [=[[^"'`\\\n]*]=] .. Q -- "texto"
local STRS = "(?:" .. STR .. [=[[\s,]*)+]=] -- one or more comma-separated strings

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
    -- Class API
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

-- head (lowercase) -> what gets extracted
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

M.use_patterns = USE_PATTERNS
M.head_kind = HEAD_KIND

-- ── Context detection (works for every language) ──────────
-- Qp: quote with optional backslashes (\" in escaped strings)   Cap: what was typed inside
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
-- Ambiguous attributes (for, list, form...): only inside a <... tag
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

M.class_pats = CLASS_PATS
M.id_pats = ID_PATS
M.id_colon_pats = ID_COLON_PATS
M.selector_pats = SELECTOR_PATS
M.var_pats = VAR_PATS
M.value_of = value_of

return M
