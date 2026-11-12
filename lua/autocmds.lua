require "nvchad.autocmds"
require "configs.sql_dialect_picker"

-- ── DEFENSIVE PATCH: known Treesitter bug (Neovim 0.12 + master) ──
-- github.com/nvim-treesitter/nvim-treesitter/issues/8618 and #8636
-- get_node_text() calls node:range() on a nil node inside the injection
-- directives (#set! conceal_lines). It is a core Treesitter/nvim-treesitter
-- bug without a merged fix yet. We wrap the exact failing function in pcall
-- at its origin so the error never reaches the highlighter.
local orig_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
    local ok, result = pcall(orig_get_node_text, node, source, opts)
    if ok then
        return result
    end
    return ""
end

-- ── MASON PERMISSIONS FIX ────────────────────────────────────────
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    desc = "Fix Mason binary permissions on startup",
    callback = function()
        if vim.fn.isdirectory(mason_bin) == 1 then
            vim.fn.system { "chmod", "-R", "+x", mason_bin }
        end
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolInstalled",
    desc = "Fix Mason binary permissions after installing a tool",
    callback = function()
        if vim.fn.isdirectory(mason_bin) == 1 then
            vim.fn.system { "chmod", "-R", "+x", mason_bin }
        end
    end,
})

-- ── HIGHLIGHT ON YANK ───────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Briefly highlight yanked text",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 }
    end,
})

-- ── RESTORE CURSOR POSITION ON FILE OPEN ────────────────────────
vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Restore cursor to the last known position",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- ── STRIP TRAILING WHITESPACE ON SAVE ───────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Strip trailing whitespace on save",
    pattern = "*",
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd [[%s/\s\+$//e]]
        pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end,
})

-- ── HYBRID LINE NUMBERING ────────────────────────────────────────
local numbering_group = vim.api.nvim_create_augroup("HybridNumbering", { clear = true })

-- Insert mode: absolute numbers
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = numbering_group,
    pattern = "*",
    callback = function()
        vim.opt_local.relativenumber = false
    end,
})

-- Leaving insert mode or changing focus: relative numbers
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "FocusGained" }, {
    group = numbering_group,
    pattern = "*",
    callback = function()
        if vim.opt_local.number:get() then
            vim.opt_local.relativenumber = true
        end
    end,
})

-- ── TWO-SPACE INDENTATION FOR CSS / SCSS / LESS ONLY ────────────
vim.api.nvim_create_autocmd("FileType", {
    desc = "Force two-space indentation for stylesheets only",
    pattern = { "css", "scss", "less" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.expandtab = true
    end,
})

-- ── DYNAMIC BLINK COLORS: real white/purple from the active theme ──
-- NvChad does not fire the standard ColorScheme event (it uses base46's own
-- internal system), so we hook VimEnter instead. base46 has finished
-- compiling the theme long before VimEnter fires, so this always runs in
-- time, before blink.cmp loads (on the first InsertEnter) and applies its
-- own default colors.
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local ok, base46 = pcall(require, "base46")
        if not ok then
            return
        end
        local colors = base46.get_theme_tb "base_30"
        if not colors then
            return
        end

        -- Already typed prefix ("pri" of "print") -> fixed blue/cyan,
        -- VS Code style. Fixed on purpose: themes do not define this
        -- "completion match" shade on their own.
        vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#2AAAFF", bold = true, force = true })

        -- Remaining part of the word -> normal theme color
        if colors.white then
            vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = colors.white, force = true })
        end
    end,
})

-- ── SUBTLE CURSOR LINE (VS Code style) ───────────────────────────
-- Highlight the cursor line in Normal mode only; it disappears in Insert so
-- it does not distract while typing. Same pattern as the hybrid numbering.
vim.opt.cursorline = true

local cursorline_group = vim.api.nvim_create_augroup("CursorlineNormalOnly", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "FocusGained" }, {
    group = cursorline_group,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

-- ── CURSORLINE CONTRAST FIX (the theme color was invisible) ─────
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local ok, base46 = pcall(require, "base46")
        if not ok then
            return
        end
        local colors = base46.get_theme_tb "base_30"
        if colors and colors.one_bg then
            -- black2 is one shade lighter than the background (black),
            -- ideal for a subtle cursorline that is still visible.
            vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.black2 })
        end
    end,
})

-- ── FOLD COLUMN: always dim (no highlight on cursor) ─────────────
-- The "..." ellipsis of a folded line stays white so collapsed code is
-- easy to spot.
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local ok, base46 = pcall(require, "base46")
        if not ok then
            return
        end
        local colors = base46.get_theme_tb "base_30"
        if not colors then
            return
        end

        -- Fold triangle: always dim, never changes with the cursor
        if colors.grey then
            vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.grey })
            vim.api.nvim_set_hl(0, "CursorLineFold", { fg = colors.grey })
        end

        -- Folded-line ellipsis: white and clearly visible
        if colors.white then
            vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { fg = colors.white, bold = true })
        end
    end,
})

-- ── AVANTE: AUTOMATIC GEMINI MODEL FALLBACK ON QUOTA ERRORS ─────
-- Cascade: 3.1 Pro -> 3.8 Flash -> 3.7 Flash -> 3.6 Flash -> Flash-Lite.
-- A quota/rate-limit error demotes to the next model automatically.
local avante_cascade = { "gemini", "gemini_flash38", "gemini_flash37", "gemini_flash36", "gemini_flash_lite" }
local avante_cascade_labels = {
    gemini = "Gemini 3.1 Pro",
    gemini_flash38 = "Gemini 3.8 Flash",
    gemini_flash37 = "Gemini 3.7 Flash",
    gemini_flash36 = "Gemini 3.6 Flash",
    gemini_flash_lite = "Gemini 3.5 Flash-Lite",
}
_G.AvanteCascadeIndex = 1

local orig_notify_avante = vim.notify
vim.notify = function(msg, level, opts)
    if
        type(msg) == "string"
        and (msg:find "rate.?limit" or msg:find "quota" or msg:find "429" or msg:find "RESOURCE_EXHAUSTED")
    then
        if _G.AvanteCascadeIndex < #avante_cascade then
            _G.AvanteCascadeIndex = _G.AvanteCascadeIndex + 1
            local next_provider = avante_cascade[_G.AvanteCascadeIndex]
            vim.schedule(function()
                pcall(vim.cmd, "AvanteSwitchProvider " .. next_provider)
                orig_notify_avante(
                    "Avante: quota exhausted, falling back to " .. avante_cascade_labels[next_provider],
                    vim.log.levels.WARN
                )
            end)
        else
            orig_notify_avante("Avante: all Gemini models are out of quota for now", vim.log.levels.ERROR)
        end
    end
    orig_notify_avante(msg, level, opts)
end

-- ── SMART ENTER AND INDENTATION IN HTML/XML (VS Code style) ──────

local function smart_html_enter()
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1], cursor[2]
    local before = line:sub(1, col)
    local after = line:sub(col + 1)

    -- CASE 1: split between <tag> and </tag>
    if before:match ">%s*$" and after:match "^%s*</" then
        local indent = line:match "^%s*"
        local sw = vim.fn.shiftwidth()
        local inner_indent = indent .. string.rep(" ", sw)

        local clean_before = before:gsub("%s+$", "")
        clean_after = after:gsub("^%s+", "")

        vim.api.nvim_set_current_line(clean_before)
        vim.api.nvim_buf_set_lines(0, row, row, false, { inner_indent, indent .. clean_after })
        vim.api.nvim_win_set_cursor(0, { row + 1, #inner_indent })
        return true
    end

    -- CASE 2: repeated Enter on empty lines
    if line:match "^%s*$" then
        vim.api.nvim_set_current_line(before)
        vim.api.nvim_buf_set_lines(0, row, row, false, { before })
        vim.api.nvim_win_set_cursor(0, { row + 1, #before })
        return true
    end

    -- CASE 3: Enter after a bare opening tag (e.g. "<section>")
    if before:match "<[a-zA-Z0-9%-]+[^>]*>$" and not before:match "/>$" then
        local indent = line:match "^%s*"
        local sw = vim.fn.shiftwidth()
        local next_indent = indent .. string.rep(" ", sw)

        vim.api.nvim_set_current_line(before)
        vim.api.nvim_buf_set_lines(0, row, row, false, { next_indent .. after })
        vim.api.nvim_win_set_cursor(0, { row + 1, #next_indent })
        return true
    end

    return false
end

-- Column-aware Backspace (VS Code style)
local function smart_html_bs()
    local col = vim.fn.col "." - 1 -- Current column (0-indexed)
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, col)

    -- Only act when the cursor sits inside the leading indentation
    if col > 0 and before:match "^%s+$" then
        local sw = vim.fn.shiftwidth()
        local target_col

        if col % sw == 0 then
            target_col = col - sw
        else
            target_col = math.floor(col / sw) * sw
        end
        if target_col < 0 then
            target_col = 0
        end

        local count = col - target_col
        return string.rep(vim.api.nvim_replace_termcodes("<BS>", true, true, true), count)
    end

    return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "xml" },
    callback = function(args)
        local buf = args.buf

        -- Disable the native indentexpr to avoid odd de-indents
        vim.bo[buf].indentexpr = ""
        vim.bo[buf].tabstop = 4
        vim.bo[buf].shiftwidth = 4
        vim.bo[buf].softtabstop = 4
        vim.bo[buf].expandtab = true

        -- Smart Enter
        vim.keymap.set("i", "<CR>", function()
            if not smart_html_enter() then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", true)
            end
        end, { buffer = buf, desc = "HTML: smart Enter" })

        -- Column-aligned Backspace (expr = true)
        vim.keymap.set("i", "<BS>", smart_html_bs, { expr = true, buffer = buf, desc = "HTML: column-aware Backspace" })
    end,
})

-- ── RAINBOW-DELIMITERS IN BLINK.CMP DOCUMENTATION ────────────────
-- Blink paints that window with its own extmarks (no parser attached to the
-- buffer), so rainbow-delimiters cannot reach it. We wrap its highlight
-- function and paint the delimiters on top with the same RainbowDelimiter*
-- groups already linked to the theme in chadrc.lua.
local function patch_blink_docs_rainbow()
    local ok, docs = pcall(require, "blink.cmp.lib.window.docs")
    if not ok or docs._rainbow_patched then
        return
    end
    docs._rainbow_patched = true

    local ns = vim.api.nvim_create_namespace "blink_docs_rainbow"
    local groups = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
    }
    local priority = 400
    local original = docs.highlight_with_treesitter

    docs.highlight_with_treesitter = function(bufnr, filetype, start_line, end_line)
        original(bufnr, filetype, start_line, end_line)
        pcall(function()
            if start_line == 0 then
                vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
            else
                vim.api.nvim_buf_clear_namespace(bufnr, ns, start_line, end_line)
            end

            local lang = vim.treesitter.language.get_lang(filetype)
            if not lang or lang == "markdown" then
                return
            end

            -- Keep HTML/XML docs on their own tag colors
            if lang == "html" or lang == "xml" then
                return
            end
            -- ts_ls docs contain types (x?: number): parse them as TypeScript
            if lang == "javascript" then
                local ok_ts, q = pcall(vim.treesitter.query.get, "typescript", "rainbow-delimiters")
                if ok_ts and q then
                    lang = "typescript"
                end
            end
            local query = vim.treesitter.query.get(lang, "rainbow-delimiters")
            if not query then
                return
            end

            local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
            local src = table.concat(lines, "\n")
            local parser = vim.treesitter.get_string_parser(src, lang)
            local root = parser:parse()[1]:root()

            -- In Neovim 0.11+ every capture is a node list:
            -- "(" and ")" arrive together under @delimiter.
            local containers, matches = {}, {}
            for _, match in query:iter_matches(root, src, 0, -1) do
                local m = { delimiters = {} }
                for id, nodes in pairs(match) do
                    local name = query.captures[id]
                    if type(nodes) ~= "table" then
                        nodes = { nodes }
                    end
                    if name == "container" then
                        m.container = nodes[1]
                        containers[nodes[1]:id()] = true
                    elseif name == "delimiter" then
                        for _, n in ipairs(nodes) do
                            table.insert(m.delimiters, n)
                        end
                    end
                end
                table.insert(matches, m)
            end

            for _, m in ipairs(matches) do
                if m.container then
                    local level, p = 0, m.container:parent()
                    while p do
                        if containers[p:id()] then
                            level = level + 1
                        end
                        p = p:parent()
                    end
                    local group = groups[level % #groups + 1]
                    for _, d in ipairs(m.delimiters) do
                        local sr, sc, er, ec = d:range()
                        vim.api.nvim_buf_set_extmark(bufnr, ns, start_line + sr, sc, {
                            end_row = start_line + er,
                            end_col = ec,
                            hl_group = group,
                            priority = priority,
                        })
                    end
                end
            end
        end)
    end
end

vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = patch_blink_docs_rainbow,
})

-- ── CLOSE AUXILIARY WINDOWS WITH q ───────────────────────────────
local close_cmds = {
    NvimTree = "NvimTreeClose",
    aerial = "AerialClose",
    Avante = "AvanteToggle",
    AvanteInput = "AvanteToggle",
    AvanteSelectedFiles = "AvanteToggle",
    DiffviewFiles = "DiffviewClose",
    DiffviewFileHistory = "DiffviewClose",
}
local close_plain = { "trouble", "grug-far", "qf", "help", "man", "checkhealth", "dbui", "oil" }

local patterns = { "TelescopePrompt" }
vim.list_extend(patterns, close_plain)
for ft in pairs(close_cmds) do
    table.insert(patterns, ft)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("CloseAuxWithQ", { clear = true }),
    pattern = patterns,
    callback = function(args)
        local buf, ft = args.buf, args.match
        -- schedule: apply our mapping after each plugin sets its own
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            local rhs
            if ft == "TelescopePrompt" then
                rhs = function()
                    require("telescope.actions").close(buf)
                end
            elseif close_cmds[ft] then
                rhs = function()
                    pcall(vim.cmd, close_cmds[ft])
                end
            else
                rhs = function()
                    pcall(vim.cmd, "close")
                end
            end
            vim.keymap.set("n", "q", rhs, { buffer = buf, nowait = true, silent = true, desc = "Close window" })
        end)
    end,
})

require("configs.tag_errors").setup()
