return {
    -- ── RUST: rust-analyzer with the rustaceanvim UI ─────────────────
    -- rustaceanvim owns the rust-analyzer client, so rust_analyzer is
    -- deliberately not in configs/lspconfig.lua (that would start twice).
    {
        "mrcjkb/rustaceanvim",
        ft = "rust",
    },

    -- Cargo.toml completion, version updates and crate documentation.
    {
        "saecki/crates.nvim",
        ft = "toml",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },

    -- Flutter/Dart. Requires the Flutter SDK in PATH; without it the plugin
    -- stays disabled instead of failing on every .dart file.
    {
        "nvim-flutter/flutter-tools.nvim",
        ft = "dart",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        config = function(_, opts)
            if vim.fn.executable "flutter" == 1 then
                require("flutter-tools").setup(opts)
            end
        end,
    },
}
