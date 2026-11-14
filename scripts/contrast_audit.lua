-- ── WCAG CONTRAST AUDIT ──────────────────────────────────────────
-- Run from the config root:
--   nvim --headless -u init.lua "+lua dofile('scripts/contrast_audit.lua')" +qa
--
-- The script reads the actually loaded highlight groups, so it follows the
-- active theme and any later overrides. It only reports; it never changes a
-- color. Text uses the 4.5:1 threshold and decorative marks use 3:1. The
-- bottom HUD is held to 7:1 because it is read at a glance.
local function get(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function rgb(color)
    if type(color) == "string" then
        color = tonumber(color:gsub("^#", ""), 16)
    end
    if type(color) ~= "number" then
        return nil
    end
    return math.floor(color / 65536) % 256, math.floor(color / 256) % 256, color % 256
end

local function hex(color)
    local r, g, b = rgb(color)
    if not r then
        return "-------"
    end
    return string.format("#%02X%02X%02X", r, g, b)
end

local function luminance(color)
    local r, g, b = rgb(color)
    if not r then
        return nil
    end

    local function channel(value)
        value = value / 255
        if value <= 0.03928 then
            return value / 12.92
        end
        return ((value + 0.055) / 1.055) ^ 2.4
    end

    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
end

local function contrast(fg, bg)
    local a, b = luminance(fg), luminance(bg)
    if not a or not b then
        return nil
    end
    return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end

local function mix(a, b, amount)
    local ar, ag, ab = rgb(a)
    local br, bg, bb = rgb(b)
    local function lerp(x, y)
        return math.floor(x + (y - x) * amount + 0.5)
    end
    return string.format("#%02X%02X%02X", lerp(ar, br), lerp(ag, bg), lerp(ab, bb))
end

-- Find the first mix toward white/black that reaches the target. This keeps
-- the nearest passing hue instead of replacing it with a generic color.
local function suggestion(fg, bg, target)
    if not contrast(fg, bg) or contrast(fg, bg) >= target then
        return nil
    end
    local toward = (luminance(bg) or 0) < 0.5 and "#FFFFFF" or "#000000"
    for step = 1, 255 do
        local candidate = mix(fg, toward, step / 255)
        if (contrast(candidate, bg) or 0) >= target then
            return candidate
        end
    end
    return toward
end

local function color_of(name, fallback)
    local value = get(name).fg
    return value or fallback
end

local function bg_of(name, fallback)
    local value = get(name).bg
    return value or fallback
end

local function add(list, label, fg, bg, threshold)
    table.insert(list, {
        label = label,
        fg = fg,
        bg = bg,
        threshold = threshold,
        ratio = contrast(fg, bg),
    })
end

-- Render both bars once so their lazily-created groups (WinBarIndent,
-- StatusHud, etc.) have their final colors before the audit reads them.
pcall(vim.api.nvim_eval_statusline, vim.o.statusline, { winid = 0, fillchar = " " })
pcall(vim.api.nvim_eval_statusline, vim.o.winbar, { winid = 0, fillchar = " " })

local normal = get "Normal"
local normal_fg = normal.fg
local normal_bg = normal.bg
local visual_bg = bg_of("Visual", normal_bg)
local search = get "Search"
local cur_search = get "CurSearch"
local inc_search = get "IncSearch"
local pmenu = get "Pmenu"

if not normal_fg or not normal_bg then
    print "Normal has no concrete foreground/background; load a theme first."
    os.exit(1)
end

local pairs_to_check = {}
add(pairs_to_check, "Normal text", normal_fg, normal_bg, 4.5)
add(pairs_to_check, "Comments", color_of("Comment", normal_fg), normal_bg, 4.5)
add(pairs_to_check, "Line numbers", color_of("LineNr", normal_fg), normal_bg, 4.5)
add(pairs_to_check, "Whitespace / listchars", color_of("Whitespace", normal_fg), normal_bg, 3)
add(pairs_to_check, "NonText", color_of("NonText", normal_fg), normal_bg, 3)
add(pairs_to_check, "Visual selection", normal_fg, visual_bg, 4.5)
add(pairs_to_check, "Search", search.fg, search.bg, 4.5)
add(pairs_to_check, "Search inside Visual", search.fg, visual_bg, 4.5)
add(pairs_to_check, "CurSearch", cur_search.fg, cur_search.bg, 4.5)
add(pairs_to_check, "IncSearch", inc_search.fg, inc_search.bg, 4.5)
add(pairs_to_check, "DiagnosticError", color_of("DiagnosticError", normal_fg), normal_bg, 4.5)
add(pairs_to_check, "DiagnosticWarn", color_of("DiagnosticWarn", normal_fg), normal_bg, 4.5)
add(pairs_to_check, "DiagnosticInfo", color_of("DiagnosticInfo", normal_fg), normal_bg, 4.5)
add(pairs_to_check, "DiagnosticHint", color_of("DiagnosticHint", normal_fg), normal_bg, 4.5)
add(pairs_to_check, "Pmenu text", color_of("Pmenu", normal_fg), pmenu.bg, 4.5)
add(pairs_to_check, "Pmenu selected", color_of("PmenuSel", normal_fg), bg_of("PmenuSel", pmenu.bg), 4.5)
add(pairs_to_check, "Avante inline hint", color_of("AvanteInlineHint", normal_fg), normal_bg, 4.5)
add(pairs_to_check, "Statusline text", color_of("StatusLine", normal_fg), bg_of("StatusLine", normal_bg), 4.5)
add(pairs_to_check, "Winbar indent indicator", color_of("WinBarIndent", normal_fg), bg_of("WinBar", normal_bg), 7)
add(pairs_to_check, "Bottom HUD", color_of("StatusHud", normal_fg), normal_bg, 7)

local theme = "unknown"
local ok, nvconfig = pcall(require, "nvconfig")
if ok and nvconfig.base46 then
    theme = nvconfig.base46.theme or theme
end

print("WCAG contrast audit — theme: " .. theme)
print(string.format("%-32s %-9s %-9s %6s %5s  %s", "PAIR", "FG", "BG", "RATIO", "MIN", "STATUS"))
print(string.rep("-", 82))

local failures = 0
for _, item in ipairs(pairs_to_check) do
    local ratio = item.ratio
    local status = "ok"
    if ratio and ratio < item.threshold then
        status = "FAIL"
        failures = failures + 1
    elseif not ratio then
        status = "NO-COLOR"
        failures = failures + 1
    end

    print(
        string.format(
            "%-32s %-9s %-9s %6s %5.1f  %s",
            item.label,
            hex(item.fg),
            hex(item.bg),
            ratio and string.format("%.2f", ratio) or "-",
            item.threshold,
            status
        )
    )

    if status == "FAIL" then
        print(string.format("  → smallest proposed fg: %s", suggestion(item.fg, item.bg, item.threshold) or "n/a"))
    end
end

print(string.rep("-", 82))
print(string.format("%d pair(s) below threshold. No colors were applied.", failures))
