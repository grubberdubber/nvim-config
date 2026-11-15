local options = {
    formatters_by_ft = {
        -- ── Web and frontend ─────────────────────────────────────────
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
        graphql = { "prettier" },

        -- ── Systems and compiled languages ───────────────────────────
        python = { "black" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        java = { "google-java-format" },
        go = { "gofmt" }, -- ships with the system Go toolchain, not Mason

        -- ── Mobile ecosystem ─────────────────────────────────────────
        swift = { "swiftformat" },
        kotlin = { "ktlint" },
        dart = { "dart_format" }, -- ships with the Flutter SDK
        scala = { "scalafmt" },
        cs = { "csharpier" },
        zig = { "zigfmt" }, -- ships with the Zig toolchain
        elixir = { "mix" }, -- ships with Elixir
        haskell = { "fourmolu" },

        -- ── Scripting and automation ─────────────────────────────────
        bash = { "shfmt" },
        sh = { "shfmt" },
        ruby = { "rubyfmt" },

        yaml = { "yamlfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        toml = { "taplo" },
        terraform = { "terraform_fmt" },
        dockerfile = { "prettier" },
        xml = { "xmllint" }, -- ships with libxml2
        hurl = { "hurlfmt" }, -- ships with hurl

        -- ── Data science ─────────────────────────────────────────────
        r = { "styler" },
        sql = { "sql_formatter", "sqlfluff" },
        mysql = { "sql_formatter", "sqlfluff" },
        plsql = { "sql_formatter", "sqlfluff" },
    },

    -- Format on save without blocking the editor
    format_on_save = {
        timeout_ms = 1500,
        lsp_format = "fallback", -- use the LSP formatter when none is configured
    },
}

return options
