-- Headless checks for the CSS class/id/variable context detector.
-- Run with: nvim --headless -u init.lua -c "luafile tests/css_selectors_spec.lua"
local H = dofile "tests/helpers.lua"
local source = require "configs.css_selectors"
local detect = source._internal.detect

-- `detect` reads the filetype of the current buffer, so every case gets one.
local function kind_of(ft, line)
    vim.cmd "enew!"
    vim.bo.filetype = ft
    return detect(line, 1)
end

local function expect(ft, line, kind, name)
    local got_kind, got_name = kind_of(ft, line)
    H.check(
        string.format("%s: %q -> %s %s", ft, line, kind or "nil", name or ""),
        got_kind == kind and got_name == name,
        string.format("got %s %s", tostring(got_kind), tostring(got_name))
    )
end

-- ── Markup ───────────────────────────────────────────────────────
expect("html", '<div class="btn', "class", "btn")
expect("html", '<div id="main', "id", "main")
expect("html", '<div class="btn primary', "class", "primary")

-- ── Frameworks ───────────────────────────────────────────────────
expect("svelte", "<div class:active", "class", "active")
expect("typescriptreact", '<div className={cn("btn-', "class", "btn-")
expect("typescriptreact", 'const x = clsx("card', "class", "card")
expect("javascript", 'document.querySelector("#nav', "id", "nav")
expect("javascript", 'document.getElementById("root', "id", "root")
expect("ruby", 'link_to "x", id: "main', "id", "main")
expect("dart", '<div classes="card', "class", "card")

-- ── CSS itself ───────────────────────────────────────────────────
expect("css", ".btn", "class", "btn")
expect("scss", ".card__title", "class", "card__title")
expect("css", "#nav", "id", "nav")
expect("css", "var(--brand", "var", "--brand")

-- ── Non-completion contexts ──────────────────────────────────────
expect("html", '<div class="', "class", "")

vim.cmd "enew!"
vim.bo.filetype = "json"
H.check("enabled() is false in JSON", source.enabled() == false)
vim.bo.filetype = "html"
H.check("enabled() is true in HTML", source.enabled() == true)

H.finish()
