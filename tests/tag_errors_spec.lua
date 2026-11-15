-- Headless checks for the malformed-tag highlighter.
-- Run with: nvim --headless -u init.lua -c "luafile tests/tag_errors_spec.lua"
local H = dofile "tests/helpers.lua"
local tags = require "configs.tag_errors"

-- The decoration provider reuses the highlighter tree, so a test buffer has to
-- be parsed explicitly before collecting the ranges.
local function marks(ft, text)
    vim.cmd "enew!"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { text })
    vim.bo.filetype = ft
    local ok, parser = pcall(vim.treesitter.get_parser, 0, nil, { error = false })
    if ok and parser then
        parser:parse(true)
    end
    return tags.collect(0, 0, -1)
end

local function has_mark(ranges, row, col)
    for _, r in ipairs(ranges) do
        if r[1] == row and r[2] == col then
            return true
        end
    end
    return false
end

-- CI installs these parsers; a local checkout without them skips instead of
-- reporting misleading failures.
local installed = {}
local function available(ft)
    if installed[ft] == nil then
        local ok, lang = pcall(vim.treesitter.language.get_lang, ft)
        installed[ft] = ok and lang ~= nil and (pcall(vim.treesitter.get_string_parser, "<a></a>", lang))
    end
    return installed[ft]
end

local function case(lang, name, text, predicate)
    if not available(lang) then
        print("skip " .. name .. " (no " .. lang .. " parser)")
        return
    end
    local ranges = marks(lang, text)
    H.check(name, predicate(ranges), vim.inspect(ranges))
end

local function none(ranges)
    return #ranges == 0
end

local function some(ranges)
    return #ranges > 0
end

-- ── HTML ─────────────────────────────────────────────────────────
case("html", "valid HTML has no marks", "<div><span>ok</span></div>", none)
case("html", "mismatched close is marked", "<div><span></div>", some)
case("html", "self-closing non-void element is marked", "<div />", some)
case("html", "void element without a close is fine", "<br>", none)
case("html", "optional end tag is fine", "<ul><li>one<li>two</ul>", none)
case("html", "missing '>' marks the opening delimiter", '<div class="x>', function(ranges)
    return has_mark(ranges, 0, 0)
end)

-- ── SVG / MathML and XML must not report false positives ─────────
case("html", "self-closing element inside <svg> is fine", "<svg><path d='M0 0' /></svg>", none)
case("xml", "valid XML has no marks", "<root><a/><b>text</b></root>", none)
case("xml", "malformed XML is marked", "<root><a></root>", some)

-- ── JSX and buffers without a tag grammar ────────────────────────
case("typescriptreact", "self-closing JSX component is fine", "const a = <Comp />;", none)
H.check("buffer without a tag grammar is skipped", none(marks("text", "<div><span></div>")))

H.finish()
