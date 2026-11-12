---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "fluorodark", -- Switched automatically by the theme picker
    hl_override = {
        WinBar = { bg = "NONE" },
        WinBarNC = { bg = "NONE" },
        StatusLine = { bg = "NONE" },
        StatusLineNC = { bg = "NONE" },

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

M.ui = {
    statusline = {
        theme = "minimal",
        order = { "mode", "file_and_path", "align", "git", "file_info" },
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
                local fn = vim.fn.expand "%:t"
                local bt = vim.bo.buftype

                -- Guard for special panels (Lazy, Mason, terminal)
                if bt == "nofile" or bt == "terminal" or bt == "prompt" or vim.bo.filetype == "lazy" then
                    local ft = vim.bo.filetype
                    return " %#St_file_txt# 󰈚 " .. (ft ~= "" and string.upper(ft) or "PANEL") .. " "
                end

                if fn == "" then
                    return ""
                end
                local ok, devicons = pcall(require, "nvim-web-devicons")
                local icon = ok and devicons.get_icon(fn, vim.fn.expand "%:e", { default = true }) or "󰈚"
                local mod = vim.bo.modified and " 󰏫" or ""
                return " %#St_file_txt# " .. icon .. " " .. fn .. mod .. " "
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

                local branch = "%#St_gitIcons# " .. vim.b.gitsigns_head
                local status = vim.b.gitsigns_status_dict or {}
                local added = (status.added and status.added > 0) and (" %#St_lspInfo#+" .. status.added) or ""
                local changed = (status.changed and status.changed > 0) and (" %#St_lspWarning#~" .. status.changed)
                    or ""
                local removed = (status.removed and status.removed > 0) and (" %#St_lspError#-" .. status.removed) or ""

                return " " .. branch .. added .. changed .. removed .. " %#St_file_txt#│ "
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
                return "%#St_pos_txt# "
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

-- Directory listing cache: avoids hitting the disk on every redraw
local dir_cache = {}

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
    end,
})

-- ── Breadcrumb styling (discreet, VS Code style) ─────────────────
-- Colors come from the active theme (Comment / Normal / DiagnosticWarn /
-- WinBar) and are recomputed on theme change: there is no hardcoded hex.
local crumb_key

local function mix(a, b, t) -- blend two 0xRRGGBB colors: t=0 -> a, t=1 -> b
    local function ch(c, s)
        return math.floor(c / s) % 256
    end
    local function lerp(x, y)
        return math.floor(x + (y - x) * t + 0.5)
    end
    return lerp(ch(a, 65536), ch(b, 65536)) * 65536 + lerp(ch(a, 256), ch(b, 256)) * 256 + lerp(ch(a, 1), ch(b, 1))
end

local function ensure_crumb_hl()
    local function get(name)
        return vim.api.nvim_get_hl(0, { name = name, link = false })
    end
    local comment = get("Comment").fg or 0x6c7a96
    local normal = get("Normal").fg or 0xcccccc
    local warn = get("DiagnosticWarn").fg or 0xe0af68
    local bg = get("WinBar").bg
    local key = table.concat({ comment, normal, warn, bg or -1 }, ":")
    if key == crumb_key then
        return
    end
    crumb_key = key
    local function set(name, opts)
        opts.bg = bg
        vim.api.nvim_set_hl(0, name, opts)
    end
    set("WinCrumb", { fg = comment }) -- folders
    set("WinCrumbSep", { fg = mix(comment, bg or 0x000000, 0.1) }) -- separator, slightly dimmer
    set("WinCrumbFile", { fg = mix(comment, normal, 0.45) }) -- current file
    set("WinCrumbSel", { fg = warn, bold = true, underline = true }) -- pending selection (]f / [f)
    set("WinCrumbMod", { fg = mix(normal, bg or 0x000000, 0.55) }) -- modified indicator
end

local function winbar_path_mode()
    local full_path = vim.fn.expand "%:p"
    if full_path == "" then
        return "%="
    end

    ensure_crumb_hl()

    local git_root_list = vim.fn.systemlist("git -C " .. vim.fn.expand "%:p:h" .. " rev-parse --show-toplevel")
    local root = (vim.v.shell_error == 0 and git_root_list[1] and git_root_list[1] ~= "" and git_root_list[1])
        or vim.fn.getcwd()

    local rel = full_path
    if full_path:sub(1, #root) == root then
        rel = full_path:sub(#root + 2)
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
            local icon = ok and devicons.get_icon(item.label, vim.fn.expand "%:e", { default = true }) or "󰈚"
            local mod = vim.bo.modified and "%#WinCrumbMod# 󰏫" or ""
            table.insert(crumbs, "%#" .. hl .. "#" .. icon .. " " .. item.label .. mod)
        else
            table.insert(crumbs, "%#" .. hl .. "#" .. item.label)
        end
    end

    -- Left-aligned (like VS Code); the trailing `%=` pushes diagnostics/count right
    return " " .. table.concat(crumbs, " %#WinCrumbSep#›%#WinCrumb# ") .. "%="
end

local function winbar_files_mode()
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
        local icon = ok and devicons.get_icon(fname, vim.fn.fnamemodify(fname, ":e"), { default = true }) or "󰈚"
        local is_selected = nav_active and state.index == i

        local hl = "St_lspTxt"
        if is_selected then
            hl = "St_lspWarning" -- pending selection
        elseif fname == current_file then
            hl = "St_NormalMode" -- currently open file
        end

        table.insert(parts, "%#" .. hl .. "# " .. icon .. " " .. fname .. " %#St_file_txt#")
    end

    return "%=" .. table.concat(parts, "%#St_file_txt# │ ") .. "%="
end

-- Right side of the winbar: diagnostics + file count for the folder
local function winbar_right_section()
    local err = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    local hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

    local str = ""
    if err > 0 then
        str = str .. "%#DiagnosticError# " .. err .. " "
    end
    if warn > 0 then
        str = str .. "%#DiagnosticWarn# " .. warn .. " "
    end
    if info > 0 then
        str = str .. "%#DiagnosticInfo# " .. info .. " "
    end
    if hint > 0 then
        str = str .. "%#DiagnosticHint# " .. hint .. " "
    end
    -- Count files (not folders) in the current directory
    local dir = vim.fn.expand "%:p:h"
    local file_count = 0
    local handle = vim.loop.fs_scandir(dir)
    if handle then
        while true do
            local name, ftype = vim.loop.fs_scandir_next(handle)
            if not name then
                break
            end
            if ftype == "file" and not name:match "^%." then
                file_count = file_count + 1
            end
        end
    end

    return str .. "%#St_file_txt# 󰈚 " .. file_count .. " "
end

_G.WinBarDraw = function()
    if vim.bo.buftype ~= "" or vim.bo.filetype == "lazy" then
        return ""
    end

    local right = winbar_right_section()

    if vim.g.winbar_mode == "files" then
        return "%#St_file_txt#" .. winbar_files_mode() .. right
    end

    return "%#St_file_txt#" .. winbar_path_mode() .. right
end

vim.opt.winbar = "%{%v:lua.WinBarDraw()%}"

return M
