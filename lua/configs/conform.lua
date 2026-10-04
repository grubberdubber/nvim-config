local options = {
    formatters_by_ft = {
        -- ── Web & Frontend ───────────────────────────────────────────
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        php = { "php_cs_fixer" },

        -- ── Sistemas y Compilados ────────────────────────────────────
        python = { "black" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        java = { "google_java_format" },
        go = { "gofmt" }, -- viene con Go del sistema, no Mason

        -- ── Ecosistema Móvil ─────────────────────────────────────────
        swift = { "swiftformat" },
        kotlin = { "ktlint" },
        dart = { "dart_format" }, -- viene con Flutter SDK
        scala = { "scalafmt" },

        -- ── Scripting y Automatización ───────────────────────────────
        bash = { "shfmt" },
        sh = { "shfmt" },
        ruby = { "rubyfmt" },

        -- ── Ciencia de Datos ─────────────────────────────────────────
        r = { "styler" },
        sql = { "sql_formatter" },
        mysql = { "sql_formatter" },
        plsql = { "sql_formatter" },
    },

    -- Formatea al guardar sin bloquear el editor
    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true, -- si no hay formateador local, usa el del LSP
    },
}

return options
