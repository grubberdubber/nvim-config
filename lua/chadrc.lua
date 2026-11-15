---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "falcon", -- Switched automatically by the theme picker
    hl_override = {
        -- Both bars use the theme's panel tone (base46 one_bg) and are
        -- normalized to one readable range in ensure_status_hl. The breadcrumb
        -- above the file is the same visual band as the statusline below it,
        -- not a transparent strip or a hardcoded gray.
        WinBar = { bg = "statusline_bg" },
        WinBarNC = { bg = "darker_black" },
        StatusLine = { bg = "statusline_bg" },
        StatusLineNC = { bg = "darker_black" },

        -- ── CONTRAST FOR LSP VIRTUAL TEXT ──
        -- Errors: soft, bright salmon red (highly legible)
        DiagnosticVirtualTextError = { fg = "#ff7a93", bg = "NONE", italic = true },
        -- Warnings: light warm gold
        DiagnosticVirtualTextWarn = { fg = "#ffc27d", bg = "NONE", italic = true },
        -- Info and hints: visible cyan and light grey
        DiagnosticVirtualTextInfo = { fg = "#78dce8", bg = "NONE", italic = true },
        DiagnosticVirtualTextHint = { fg = "#a9b1d6", bg = "NONE", italic = true },
    },
    -- ── NATIVE BLINK.CMP FIXES FROM NVCHAD STARTUP ──

    hl_add = {
        BlinkCmpMenu = { link = "Pmenu" },
        BlinkCmpMenuBorder = { link = "FloatBorder" },
        BlinkCmpMenuSelection = { link = "PmenuSel" },
        BlinkCmpScrollBarThumb = { link = "PmenuThumb" },
        BlinkCmpDoc = { link = "NormalFloat" },
        BlinkCmpDocBorder = { link = "FloatBorder" },
        BlinkCmpLabel = { link = "Pmenu" },
        BlinkCmpLabelDeprecated = { link = "Comment", strikethrough = true },
        BlinkCmpGhostText = { link = "Comment", italic = true }, -- Inline ghost text preview
        BlinkCmpSignatureHelpBorder = { link = "FloatBorder" }, -- Signature help window

        -- ── Colors per completion kind (skips CmpItemKind*, empty in this theme) ──
        BlinkCmpKindText = { link = "Normal" },
        BlinkCmpKindMethod = { link = "Function" },
        BlinkCmpKindFunction = { link = "Function" },
        BlinkCmpKindConstructor = { link = "Function" },
        BlinkCmpKindField = { link = "Identifier" },
        BlinkCmpKindVariable = { link = "Identifier" },
        BlinkCmpKindClass = { link = "Type" },
        BlinkCmpKindInterface = { link = "Type" },
        BlinkCmpKindModule = { link = "Include" },
        BlinkCmpKindProperty = { link = "Identifier" },
        BlinkCmpKindUnit = { link = "Number" },
        BlinkCmpKindValue = { link = "String" },
        BlinkCmpKindEnum = { link = "Type" },
        BlinkCmpKindKeyword = { link = "Keyword" },
        BlinkCmpKindSnippet = { link = "Special" },
        BlinkCmpKindColor = { link = "Special" },
        BlinkCmpKindFile = { link = "Directory" },
        BlinkCmpKindReference = { link = "Identifier" },
        BlinkCmpKindFolder = { link = "Directory" },
        BlinkCmpKindEnumMember = { link = "Constant" },
        BlinkCmpKindConstant = { link = "Constant" },
        BlinkCmpKindStruct = { link = "Type" },
        BlinkCmpKindEvent = { link = "Special" },
        BlinkCmpKindOperator = { link = "Operator" },
        BlinkCmpKindTypeParameter = { link = "Type" },
        -- ── TAG DELIMITERS: < > / </ /> in soft white ──
        ["@tag.delimiter"] = { fg = "#CFE3F7" },

        -- ── RAINBOW DELIMITERS (follow any theme automatically) ──
        RainbowDelimiterRed = { link = "Keyword" }, -- Keyword color
        RainbowDelimiterYellow = { link = "Type" }, -- Class/type color
        RainbowDelimiterBlue = { link = "Function" }, -- Function color
        RainbowDelimiterOrange = { link = "Constant" }, -- Constant color
        RainbowDelimiterGreen = { link = "String" }, -- String color
        RainbowDelimiterViolet = { link = "Statement" }, -- Statement color
        RainbowDelimiterCyan = { link = "Special" }, -- Special character color
    },
}

-- ── THEMED BAR HIGHLIGHTS ───────────────────────────────────────
-- NvChad compiles its own highlight groups, so define the few extra groups
-- used by the statusline and breadcrumb after the theme is active. Every
-- group gets the same background as the bottom statusline, which keeps the
-- two bars visually connected without hardcoding a hex color.
local status_hl_key

local function get_hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- Blend two 0xRRGGBB colors: t=0 -> a, t=1 -> b.
local function mix(a, b, t)
    local function ch(c, s)
        return math.floor(c / s) % 256
    end
    local function lerp(x, y)
        return math.floor(x + (y - x) * t + 0.5)
    end
    return lerp(ch(a, 65536), ch(b, 65536)) * 65536 + lerp(ch(a, 256), ch(b, 256)) * 256 + lerp(ch(a, 1), ch(b, 1))
end

local function blend_fg(a, b, t)
    if a and b then
        return mix(a, b, t)
    end
    return a or b
end

local function luminance(color)
    if not color then
        return 0
    end
    local r = math.floor(color / 65536) % 256
    local g = math.floor(color / 256) % 256
    local b = color % 256
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

-- Keep both bars in the tone the theme already uses for panels/statusline
-- (base46's one_bg, exposed as Pmenu). A small floor keeps absolute-black
-- themes readable; a ceiling avoids turning light themes into bright strips.
local function themed_bar_bg(panel_bg, normal_fg, normal_bg)
    local bg = panel_bg
    if not bg then
        return nil
    end

    local min_luminance, max_luminance = 24, 46
    local current = luminance(bg)
    local fg_luminance = luminance(normal_fg)
    if current < min_luminance and fg_luminance > current then
        bg = mix(bg, normal_fg, (min_luminance - current) / (fg_luminance - current))
    elseif current > max_luminance then
        local base_luminance = luminance(normal_bg)
        local new_current = luminance(bg)
        if base_luminance < new_current then
            bg = mix(bg, normal_bg, (new_current - max_luminance) / (new_current - base_luminance))
        end
    end

    -- Pull both bands slightly toward the editor background: the bars stay
    -- distinct, but read as muted chrome instead of colored strips.
    if normal_bg then
        bg = mix(bg, normal_bg, 0.25)
    end
    return bg
end

-- Reuse a language icon's foreground but force the bar background. Without
-- this, statusline blocks that inherit only a foreground turn dark.
local function set_icon_hl(name, icon_hl, bg)
    local fg = icon_hl and get_hl(icon_hl).fg
    if not fg then
        return nil
    end
    -- One group per language color: files mode draws several icons in the
    -- same redraw, so a single shared group would repaint all of them alike.
    local group = name .. "_" .. fg
    vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg })
    return group
end

local function ensure_status_hl()
    local status = get_hl "StatusLine"
    local bar = get_hl "WinBar"
    local normal = get_hl "Normal"
    local comment = get_hl "Comment"
    local line_nr = get_hl "LineNr"
    local pmenu = get_hl "Pmenu"
    local warn = get_hl "DiagnosticWarn"
    local info = get_hl "DiagnosticInfo"
    local hint = get_hl "DiagnosticHint"
    local err = get_hl "DiagnosticError"
    local file = get_hl "St_file"
    local file_txt = get_hl "St_file_txt"
    local pos = get_hl "St_pos_txt"
    local git_icons = get_hl "St_gitIcons"
    local lsp_info = get_hl "St_lspInfo"
    local lsp_warn = get_hl "St_lspWarning"
    local lsp_err = get_hl "St_lspError"
    local panel_bg = pmenu.bg or status.bg or bar.bg
    local bar_bg = themed_bar_bg(panel_bg, normal.fg, normal.bg) or panel_bg
    local bg = bar_bg
    local key = table.concat({
        bg or -1,
        bar_bg or -1,
        normal.fg or -1,
        comment.fg or -1,
        line_nr.fg or -1,
        pmenu.bg or -1,
        warn.fg or -1,
        info.fg or -1,
        hint.fg or -1,
        err.fg or -1,
        file.fg or -1,
        file_txt.fg or -1,
        pos.fg or -1,
        git_icons.fg or -1,
        lsp_info.fg or -1,
        lsp_warn.fg or -1,
        lsp_err.fg or -1,
    }, ":")
    if key == status_hl_key then
        return
    end
    status_hl_key = key

    local function set(name, opts)
        opts.bg = opts.bg or bg
        vim.api.nvim_set_hl(0, name, opts)
    end

    -- Both bands share one background; the statusline and winbar groups are
    -- refreshed here so a theme switch cannot leave the old color behind.
    vim.api.nvim_set_hl(0, "StatusLine", { fg = normal.fg, bg = bar_bg })
    vim.api.nvim_set_hl(0, "WinBar", { fg = normal.fg, bg = bar_bg })
    vim.api.nvim_set_hl(0, "StatusLineNC", { fg = comment.fg or normal.fg, bg = bar_bg })
    vim.api.nvim_set_hl(0, "WinBarNC", { fg = comment.fg or normal.fg, bg = bar_bg })

    -- The message separator is a full-width strip between the buffer and a
    -- scrolled message. It is linked to StatusLine by default, so the swap
    -- dialog showed it as an empty dark bar. Blend it into the editor.
    vim.api.nvim_set_hl(0, "MsgSeparator", { fg = normal.bg, bg = normal.bg })

    set("St_indent", { fg = comment.fg or normal.fg })

    -- The bottom bar must not reuse St_file_txt/St_pos_txt: those theme groups
    -- carry their own darker background. Keep their colors, replace the band.
    set("St_fileName", { fg = file.fg or normal.fg })
    set("St_gitBranch", { fg = git_icons.fg or normal.fg })
    set("St_gitAdd", { fg = lsp_info.fg or normal.fg })
    set("St_gitChange", { fg = lsp_warn.fg or warn.fg })
    set("St_gitDelete", { fg = lsp_err.fg or err.fg })
    set("St_pos", { fg = pos.fg or normal.fg })

    local function bar_set(name, fg)
        vim.api.nvim_set_hl(0, name, { fg = fg, bg = bar_bg })
    end

    -- Restore the original file-count color, but on the themed bar background.
    bar_set("WinBarCount", file_txt.fg or normal.fg)
    bar_set("WinBarIndent", blend_fg(line_nr.fg or comment.fg, normal.fg, 0.40))
    bar_set("WinBarDiagError", err.fg or normal.fg)
    bar_set("WinBarDiagWarn", warn.fg or normal.fg)
    bar_set("WinBarDiagInfo", info.fg or normal.fg)
    bar_set("WinBarDiagHint", hint.fg or normal.fg)
    bar_set("WinBarFile", normal.fg or comment.fg)
    bar_set("WinBarFileCurrent", blend_fg(comment.fg, normal.fg, 0.65))
    bar_set("WinBarFileSel", warn.fg or normal.fg)
    bar_set("WinBarFileSep", comment.fg or normal.fg)
end

M.ui = {
    statusline = {
        theme = "minimal",
        -- Diagnostics and indent style live in the winbar. Search count and
        -- visual selection size are rendered in the row below this bar by
        -- configs/status_hud.lua, never inside either statusline.
        order = {
            "mode",
            "file_and_path",
            "align",
            "git",
            "file_info",
        },
        modules = {
            -- 1. MODE (themed automatically)
            mode = function()
                local m = vim.api.nvim_get_mode().mode
                local modes = {
                    n = "NORMAL",
                    i = "INSERT",
                    v = "VISUAL",
                    V = "V-LINE",
                    ["\22"] = "V-BLOCK",
                    c = "COMMAND",
                    R = "REPLACE",
                    t = "TERMINAL",
                }
                local hl = {
                    n = "St_NormalMode",
                    i = "St_InsertMode",
                    v = "St_VisualMode",
                    V = "St_VisualMode",
                    ["\22"] = "St_VisualMode",
                    c = "St_CommandMode",
                    R = "St_ReplaceMode",
                    t = "St_InsertMode",
                }
                return "%#" .. (hl[m] or "St_NormalMode") .. "# 󰕮 " .. (modes[m] or string.upper(m)) .. " "
            end,

            -- 2. ICON + FILENAME (clean and guarded)
            file_and_path = function()
                ensure_status_hl()
                local fn = vim.fn.expand "%:t"
                local bt = vim.bo.buftype
                local ft = vim.bo.filetype

                -- DAP panels have names such as "DAP Scopes"; keep them
                -- visible instead of collapsing every panel to "PANEL".
                if ft:match "^dapui_" or ft == "dap-repl" then
                    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
                    return " %#St_fileName# " .. (name ~= "" and name or string.upper(ft)) .. " "
                end

                -- Guard for special panels (Lazy, Mason, terminal)
                if bt == "nofile" or bt == "terminal" or bt == "prompt" or ft == "lazy" then
                    return " %#St_fileName# 󰈚 " .. (ft ~= "" and string.upper(ft) or "PANEL") .. " "
                end

                if fn == "" then
                    return ""
                end

                local ok, devicons = pcall(require, "nvim-web-devicons")
                local icon, icon_hl = "󰈚", nil
                if ok then
                    icon, icon_hl = devicons.get_icon(fn, vim.fn.expand "%:e", { default = true })
                    icon = icon or "󰈚"
                end
                local mod = vim.bo.modified and " 󰏫" or ""
                local bar_bg = get_hl("StatusLine").bg or get_hl("WinBar").bg
                local icon_group = set_icon_hl("St_fileIcon", icon_hl, bar_bg) or "St_fileName"
                return " %#St_fileName# %#" .. icon_group .. "#" .. icon .. "%#St_fileName# " .. fn .. mod .. " "
            end,

            -- 3. ALIGNER
            align = function()
                return "%="
            end,

            -- 4. GIT
            git = function()
                if vim.bo.buftype ~= "" or vim.bo.filetype == "lazy" then
                    return ""
                end
                if not vim.b.gitsigns_head or vim.b.gitsigns_head == "" then
                    return ""
                end

                ensure_status_hl()
                local branch = "%#St_gitBranch# " .. vim.b.gitsigns_head
                local status = vim.b.gitsigns_status_dict or {}
                local added = (status.added and status.added > 0) and (" %#St_gitAdd#+" .. status.added) or ""
                local changed = (status.changed and status.changed > 0) and (" %#St_gitChange#~" .. status.changed)
                    or ""
                local removed = (status.removed and status.removed > 0) and (" %#St_gitDelete#-" .. status.removed)
                    or ""

                return " " .. branch .. added .. changed .. removed .. " "
            end,

            -- 5. FILE INFO (Line:Column/Total, bottom right)
            file_info = function()
                if vim.bo.buftype ~= "" or vim.bo.filetype == "lazy" then
                    return ""
                end

                local line = vim.fn.line "."
                local col = vim.fn.col "."
                local total_lines = vim.fn.line "$"
                local percentage = math.floor((line / total_lines) * 100)
                local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                return "%#St_pos# "
                    .. percentage
                    .. "%% 󰉋 "
                    .. root
                    .. "  "
                    .. line
                    .. ":"
                    .. col
                    .. "/"
                    .. total_lines
                    .. " "
            end,
        },
    },
}

-- TOP WINBAR — 2 modes: folder breadcrumb / sibling files
-- The pending selection (]f/[f) is highlighted separately from "where you are"
-- (St_NormalMode). <CR> confirms and only then opens; see mappings.lua for the
-- movement logic. Right side: diagnostics (errors/warnings/hints) + file count.
vim.g.winbar_mode = "path" -- "path" | "files"

-- Directory and project-root caches: the winbar is redrawn constantly, so
-- neither the folder scan nor the repository lookup may hit the disk on every
-- repaint.
local dir_cache = {}
local root_cache = {}

local function project_root(dir)
    if root_cache[dir] ~= nil then
        return root_cache[dir]
    end
    local root = vim.fs.root(dir, { ".git" }) or vim.fn.getcwd()
    root_cache[dir] = root
    return root
end

local function get_sibling_files(dir)
    if dir_cache[dir] then
        return dir_cache[dir]
    end
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
    dir_cache[dir] = files
    return files
end

vim.api.nvim_create_autocmd({ "DirChanged", "BufWritePost", "BufNewFile" }, {
    callback = function()
        dir_cache = {}
        root_cache = {}
    end,
})

-- ── Breadcrumb styling (discreet, VS Code style) ─────────────────
-- Colors come from the active theme (Comment / Normal / DiagnosticWarn /
-- WinBar) and are recomputed on theme change: there is no hardcoded hex.
local crumb_key

local function ensure_crumb_hl()
    local function get(name)
        return vim.api.nvim_get_hl(0, { name = name, link = false })
    end
    ensure_status_hl()
    local accent = get("LineNr").fg or get("Comment").fg or 0x6c7a96
    local normal = get("Normal").fg or 0xcccccc
    local warn = get("DiagnosticWarn").fg or 0xe0af68
    local bg = get("WinBar").bg or get("StatusLine").bg
    if bg and not get("WinBar").bg then
        vim.api.nvim_set_hl(0, "WinBar", { bg = bg })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = bg })
    end
    local key = table.concat({ accent, normal, warn, bg or -1 }, ":")
    if key == crumb_key then
        return
    end
    crumb_key = key
    local function set(name, opts)
        opts.bg = bg
        vim.api.nvim_set_hl(0, name, opts)
    end
    set("WinCrumb", { fg = mix(accent, normal, 0.25) }) -- folders
    set("WinCrumbSep", { fg = mix(accent, normal, 0.12) }) -- separator, slightly dimmer
    set("WinCrumbFile", { fg = mix(accent, normal, 0.65) }) -- current file
    set("WinCrumbSel", { fg = warn, bold = true, underline = true }) -- pending selection (]f / [f)
    set("WinCrumbMod", { fg = mix(normal, bg or 0x000000, 0.55) }) -- modified indicator
end

local function winbar_path_mode()
    local full_path = vim.fn.expand "%:p"
    if full_path == "" then
        return "%="
    end

    ensure_crumb_hl()

    local dir = vim.fn.expand "%:p:h"
    local root = project_root(dir)
    local prefix = root == "/" and "/" or (root .. "/")

    local rel
    if full_path:sub(1, #prefix) == prefix then
        rel = full_path:sub(#prefix + 1)
    else
        -- The buffer lives outside the project/cwd: show its parent folder as
        -- the root instead of prepending unrelated absolute path components.
        root = dir
        rel = vim.fn.expand "%:t"
    end

    local items = { { label = vim.fn.fnamemodify(root, ":t"), path = root } }
    local accum = root
    for part in rel:gmatch "[^/]+" do
        accum = accum .. "/" .. part
        table.insert(items, { label = part, path = accum })
    end

    local ok, devicons = pcall(require, "nvim-web-devicons")
    local state = _G.WinbarNavState or {}
    local nav_active = state.active and state.mode == "path"

    local crumbs = {}
    for i, item in ipairs(items) do
        local is_last = (i == #items)
        local is_selected = nav_active and state.index == i

        local hl = is_last and "WinCrumbFile" or "WinCrumb"
        if is_selected then
            hl = "WinCrumbSel" -- pending selection (moving with ]f/[f, not open yet)
        end

        if is_last then
            local icon, icon_hl = "󰈚", nil
            if ok then
                icon, icon_hl = devicons.get_icon(item.label, vim.fn.expand "%:e", { default = true })
                icon = icon or "󰈚"
            end
            local mod = vim.bo.modified and "%#WinCrumbMod# 󰏫" or ""
            local icon_group = set_icon_hl("WinBarIcon", icon_hl, get_hl("WinBar").bg) or hl
            table.insert(
                crumbs,
                "%#" .. hl .. "# %#" .. icon_group .. "#" .. icon .. "%#" .. hl .. "# " .. item.label .. mod
            )
        else
            table.insert(crumbs, "%#" .. hl .. "#" .. item.label)
        end
    end

    -- Left-aligned (like VS Code); the trailing `%=` pushes diagnostics/count right
    return " " .. table.concat(crumbs, " %#WinCrumbSep#›%#WinCrumb# ") .. "%="
end

local function winbar_files_mode()
    ensure_crumb_hl()
    local dir = vim.fn.expand "%:p:h"
    local files = get_sibling_files(dir)
    if #files == 0 then
        return "%="
    end

    local current_file = vim.fn.expand "%:t"
    local ok, devicons = pcall(require, "nvim-web-devicons")
    local state = _G.WinbarNavState or {}
    local nav_active = state.active and state.mode == "files"

    local parts = {}
    for i, fname in ipairs(files) do
        local icon, icon_hl = "󰈚", nil
        if ok then
            icon, icon_hl = devicons.get_icon(fname, vim.fn.fnamemodify(fname, ":e"), { default = true })
            icon = icon or "󰈚"
        end
        local is_selected = nav_active and state.index == i

        local hl = "WinBarFile"
        if is_selected then
            hl = "WinBarFileSel" -- pending selection
        elseif fname == current_file then
            hl = "WinBarFileCurrent" -- currently open file
        end

        local icon_group = set_icon_hl("WinBarIcon", icon_hl, get_hl("WinBar").bg) or hl
        table.insert(parts, "%#" .. hl .. "# %#" .. icon_group .. "#" .. icon .. "%#" .. hl .. "# " .. fname .. " ")
    end

    return "%=" .. table.concat(parts, "%#WinBarFileSep# | ") .. "%="
end

-- Right side of the winbar: indent style, diagnostics (numbers only) and
-- the file count for the folder.
local function winbar_right_section()
    ensure_crumb_hl()
    local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

    local width = vim.bo.shiftwidth ~= 0 and vim.bo.shiftwidth or vim.bo.tabstop
    local kind = vim.bo.expandtab and "Sp:" or "Tab:"
    local str = " %#WinBarIndent# " .. kind .. width
    if err > 0 then
        str = str .. " %#WinBarDiagError#" .. err
    end
    if warn > 0 then
        str = str .. " %#WinBarDiagWarn#" .. warn
    end
    if hint > 0 then
        str = str .. " %#WinBarDiagHint#" .. hint
    end
    -- Count files (not folders) in the current directory. Reuse the cached
    -- listing instead of scanning the folder again on every redraw.
    local dir = vim.fn.expand "%:p:h"
    local file_count = #get_sibling_files(dir)

    return str .. " %#WinBarCount#󰈚 " .. file_count .. " "
end

_G.WinBarDraw = function()
    local ft = vim.bo.filetype

    -- nvim-dap-ui keeps the panel titles in the window bar. The global
    -- winbar must preserve them; returning "" here removed "DAP Scopes",
    -- "DAP Breakpoints", etc. from every debugger panel.
    if ft:match "^dapui_" then
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
        return "%#WinBar# " .. (name ~= "" and name or string.upper(ft)) .. "%="
    end

    if vim.bo.buftype ~= "" or ft == "lazy" then
        return ""
    end

    local right = winbar_right_section()

    -- The breadcrumb is a full-width themed band: the leading and trailing
    -- WinBar groups fill both ends, while the crumbs set their own foreground.
    if vim.g.winbar_mode == "files" then
        return "%#WinBar#" .. winbar_files_mode() .. right .. "%#WinBar# "
    end

    return "%#WinBar#" .. winbar_path_mode() .. right .. "%#WinBar# "
end

-- NvChad uses its own reload event; ColorScheme covers external themes and
-- plugins. Both reset the caches and rebuild every themed bar group.
local function refresh_bar_highlights()
    status_hl_key = nil
    crumb_key = nil
    ensure_status_hl()
    ensure_crumb_hl()
    vim.cmd "redrawstatus"
end

local bar_hl_group = vim.api.nvim_create_augroup("ThemedBarHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = bar_hl_group, callback = refresh_bar_highlights })
vim.api.nvim_create_autocmd("User", {
    group = bar_hl_group,
    pattern = "NvThemeReload",
    callback = refresh_bar_highlights,
})

vim.opt.winbar = "%{%v:lua.WinBarDraw()%}"

return M
