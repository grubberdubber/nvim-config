local options = {
    formatters_by_ft = {
        -- ── Web & Frontend ───────────────────────────────────────────
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        php = { "php_cs_fixer" },
        markdown = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },

        -- ── Sistemas y Compilados ────────────────────────────────────
        python = { "black" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        java = { "google-java-format" },
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

        yaml = { "yamlfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        toml = { "taplo" },
        terraform = { "terraform_fmt" },
        dockerfile = { "prettier" },

        -- ── Ciencia de Datos ─────────────────────────────────────────
        r = { "styler" },
        sql = { "sql_formatter", "sqlfluff" },
        mysql = { "sql_formatter", "sqlfluff" },
        plsql = { "sql_formatter", "sqlfluff" },
    },

    -- Formatea al guardar sin bloquear el editor
    format_on_save = {
        timeout_ms = 1500,
        lsp_format = "fallback", -- si no hay formateador local, usa el del LSP
    },
}

return options
