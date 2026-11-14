return {
    -- ── NEOVIM/LUA DEVELOPMENT ──────────────────────────────────────
    -- Gives lua_ls the Neovim runtime and plugin libraries, so the
    -- configuration and standalone plugins get accurate completions
    -- and fewer false diagnostics.
    {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {},
    },
}
