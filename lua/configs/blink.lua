-- Icons and colors for css_selectors. The icon is chosen from the custom
-- `sel_kind` rather than source_id, so it wins even when the LSP offers the same word.
local SELECTOR = {
    class = { icon = ".", hl = "BlinkCmpSelectorClass" },
    id = { icon = "#", hl = "BlinkCmpSelectorId" },
    var = { icon = "$", hl = "BlinkCmpSelectorVar" },
}
vim.api.nvim_set_hl(0, "BlinkCmpSelectorClass", { link = "Type", default = true })
vim.api.nvim_set_hl(0, "BlinkCmpSelectorId", { link = "Constant", default = true })
vim.api.nvim_set_hl(0, "BlinkCmpSelectorVar", { link = "Special", default = true })

-- In class/id/variable context: if css_selectors already knows the name, it
-- drop the LSP/buffer duplicate so a single row keeps its icon.
-- tailwindcss items are kept (they carry a color preview) and
-- receive the marker so they are painted with the icon.
local function force_selector_kind(ctx, items)
    local ok, cs = pcall(require, "configs.css_selectors")
    if not ok then
        return items
    end
    local kind = cs.kind_at(ctx.line:sub(1, ctx.cursor[2]))
    if not kind then
        return items
    end
    local out = {}
    for _, it in ipairs(items) do
        if cs.has(kind, it.label) then
            if it.client_name == "tailwindcss" then
                it.sel_kind = kind
                out[#out + 1] = it
            end
        else
            out[#out + 1] = it
        end
    end
    return out
end

-- blink clears the selection instead of cycling at the edges of the list when
-- `preselect = false` (completion.list.select_next only wraps when preselect or
-- auto_insert is enabled). Wrap explicitly so the first Tab after the last item
-- goes back to the first one, and S-Tab on the first item goes to the last one.
local function wrap_menu_selection(cmp, direction)
    if not cmp.is_menu_visible() then
        return false
    end

    local items = cmp.get_items()
    local idx = cmp.get_selected_item_idx()
    if idx == nil or #items == 0 then
        return false
    end

    if direction > 0 and idx == #items then
        require("blink.cmp.completion.list").select(1)
        return true
    end

    if direction < 0 and idx == 1 then
        require("blink.cmp.completion.list").select(#items)
        return true
    end

    return false
end

return {
    keymap = {
        preset = "default",

        -- ── Tab: next menu item (wrapping at the bottom); with the menu closed,
        -- closing-bracket jump (parentheses/braces/HTML tags/punctuation).
        ["<Tab>"] = {
            function(cmp)
                return wrap_menu_selection(cmp, 1)
            end,
            "select_next",
            function(_)
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local after_cursor = line:sub(col + 1)

                -- Full HTML/XML closing tag -> jump over the WHOLE tag
                -- in one go (this intentionally moves several characters,
                -- because it is a semantic block, not a single symbol)
                local closing_tag = after_cursor:match "^</[%w%-%.]+>"
                if closing_tag then
                    local right = vim.api.nvim_replace_termcodes(string.rep("<Right>", #closing_tag), true, false, true)
                    vim.api.nvim_feedkeys(right, "n", false)
                    return true
                end

                -- Any loose symbol/punctuation -> advance ONE character
                local next_char = after_cursor:sub(1, 1)
                if next_char ~= "" and next_char:match "%p" then
                    local right = vim.api.nvim_replace_termcodes("<Right>", true, false, true)
                    vim.api.nvim_feedkeys(right, "n", false)
                    return true
                end

                return false
            end,
            "snippet_forward",
            "fallback",
        },
        -- ── Shift-Tab: move up in the menu (and back through snippets) ──
        ["<S-Tab>"] = {
            function(cmp)
                return wrap_menu_selection(cmp, -1)
            end,
            "select_prev",
            "snippet_backward",
            "fallback",
        },
        ["<C-n>"] = {
            function(cmp)
                return wrap_menu_selection(cmp, 1)
            end,
            "select_next",
            "fallback",
        },
        ["<C-p>"] = {
            function(cmp)
                return wrap_menu_selection(cmp, -1)
            end,
            "select_prev",
            "fallback",
        },
        ["<Up>"] = {
            function(cmp)
                return wrap_menu_selection(cmp, -1)
            end,
            "select_prev",
            "fallback",
        },
        ["<Down>"] = {
            function(cmp)
                return wrap_menu_selection(cmp, 1)
            end,
            "select_next",
            "fallback",
        },
        -- ── Enter: ALWAYS a newline, never accepts a suggestion ─────────
        ["<CR>"] = { "fallback" },

        -- ── Ctrl-y: accept a blink item only when its menu is open ──
        -- No fallback: with the menu closed this must not insert a character
        -- from the line above or touch Minuet's inline AI suggestion.
        ["<C-y>"] = { "select_and_accept" },

        ["<C-e>"] = { "hide", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    },

    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },

    completion = {
        list = {
            -- Navigate the menu without inserting the highlighted item.
            -- auto_insert made <Tab> insert the first result and replace it
            -- on the next press, which looked like flickering.
            selection = { preselect = false, auto_insert = false },
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
            window = { border = "none" },
        },
        menu = {
            border = "none",
            draw = {
                treesitter = { "lsp" },
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local s = ctx.item.sel_kind and SELECTOR[ctx.item.sel_kind]
                            return (s and s.icon or ctx.kind_icon) .. ctx.icon_gap
                        end,
                        highlight = function(ctx)
                            local s = ctx.item.sel_kind and SELECTOR[ctx.item.sel_kind]
                            return s and s.hl or ctx.kind_hl
                        end,
                    },
                },
            },
        },
        -- Only Minuet may render inline gray text. Blink's own ghost preview
        -- made normal LSP/buffer items look like AI suggestions, especially
        -- while navigating the menu with <Tab>.
        ghost_text = { enabled = false },
        accept = {
            auto_brackets = { enabled = true },
        },
        trigger = {
            show_on_trigger_character = true,
            show_on_blocked_trigger_characters = {}, -- do not block any trigger (affects Emmet)
        },
    },

    cmdline = {
        enabled = true,
        keymap = { preset = "cmdline" },
        sources = { "cmdline", "buffer" },
        completion = {
            -- Show the command menu as soon as `:` is typed, but never
            -- preselect or auto-insert a command the user did not choose.
            menu = { auto_show = true },
            ghost_text = { enabled = false },
            list = { selection = { preselect = false, auto_insert = false } },
        },
    },

    sources = {
        -- Minuet/NVIDIA inline AI is intentionally absent: it lives in its own
        -- virtual-text frontend and accepts only with <C-g>, never with <Tab>.
        default = { "lsp", "path", "snippets", "buffer", "dadbod", "html_values", "css_selectors", "emoji" },
        min_keyword_length = 0,
        providers = {
            dadbod = {
                name = "Dadbod",
                module = "vim_dadbod_completion.blink",
            },
            html_values = {
                name = "HTML values",
                module = "configs.html_values",
            },
            css_selectors = {
                name = "CSS project",
                module = "configs.css_selectors",
                score_offset = 5,
            },
            -- Keep emoji completion out of code and out of every `:` use
            -- (YAML, CSS, URLs, ternaries). It only appears for `:sm`-style
            -- triggers in prose filetypes.
            emoji = {
                name = "Emoji",
                module = "blink-emoji",
                score_offset = 10,
                opts = { insert = true, trigger = { ":" } },
                should_show_items = function(ctx)
                    local ft = vim.bo[ctx.bufnr].filetype
                    if ft ~= "markdown" and ft ~= "gitcommit" then
                        return false
                    end
                    local before = ctx.line:sub(1, ctx.cursor[2])
                    return before:match "^:[%a][%a][%w_+%-]*$" ~= nil
                        or before:match "[%s\"'`]:[%a][%a][%w_+%-]*$" ~= nil
                end,
            },
            lsp = {
                fallbacks = {},
                transform_items = force_selector_kind,
                override = {
                    get_trigger_characters = function(self)
                        local chars = self:get_trigger_characters()
                        vim.list_extend(chars, { "!", ">", ".", "#", "*", "+", ":", "{", "}", "[", "]", "(", ")" })
                        return chars
                    end,
                },
            },
            buffer = {
                transform_items = force_selector_kind,
                opts = {
                    -- Search every open buffer, not only the current one
                    get_bufnrs = function()
                        return vim.tbl_filter(function(buf)
                            return vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
                        end, vim.api.nvim_list_bufs())
                    end,
                },
            },
        },
    },

    signature = { enabled = true },

    fuzzy = { implementation = "prefer_rust_with_warning" },
}
