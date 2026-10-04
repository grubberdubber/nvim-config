return {
    keymap = {
        preset = "default",

        -- ── Tab: SOLO skip de cierres (paréntesis/llaves/etiquetas HTML/puntuación) ──
        -- Nunca toca el menú de autocompletado.
        ["<Tab>"] = {
            function(_)
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local after_cursor = line:sub(col + 1)

                -- Etiqueta de cierre HTML/XML completa -> salta TODA la etiqueta
                -- de un tirón (esto sí mueve varios caracteres a propósito,
                -- porque es un bloque semántico, no un símbolo suelto)
                local closing_tag = after_cursor:match "^</[%w%-%.]+>"
                if closing_tag then
                    local right = vim.api.nvim_replace_termcodes(string.rep("<Right>", #closing_tag), true, false, true)
                    vim.api.nvim_feedkeys(right, "n", false)
                    return true
                end

                -- Cualquier símbolo/puntuación suelto -> avanza UN carácter
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
        -- ── Shift-Tab: recorrer el menú ──────────────────────────────
        ["<S-Tab>"] = { "select_next", "snippet_backward", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },

        -- ── Enter: SIEMPRE salto de línea, nunca acepta nada ─────────
        ["<CR>"] = { "fallback" },

        -- ── Ctrl-y: aceptar sugerencia resaltada (universal, sin líos de terminal) ──
        ["<C-y>"] = { "select_and_accept", "fallback" },

        ["<C-e>"] = { "hide", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    },

    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },

    completion = {
        list = {
            selection = { preselect = false },
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
            },
        },
        ghost_text = { enabled = true },
        accept = {
            auto_brackets = { enabled = true },
        },
    },

    sources = {
        default = { "lsp", "path", "snippets", "buffer", "dadbod" },
        providers = {
            dadbod = {
                name = "Dadbod",
                module = "vim_dadbod_completion.blink",
            },
        },
    },

    signature = { enabled = true },

    fuzzy = { implementation = "prefer_rust_with_warning" },
}
