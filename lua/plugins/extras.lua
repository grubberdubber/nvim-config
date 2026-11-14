return {
    {
        "Wansmer/treesj",
        cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
        keys = { { "<leader>J", "<cmd>TSJToggle<cr>", desc = "Split/join block" } },
        opts = { use_default_keymaps = false },
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        keys = {
            {
                "<leader>S",
                function()
                    require("grug-far").open { transient = true }
                end,
                desc = "Global search and replace",
            },
            {
                "<leader>sw",
                function()
                    require("grug-far").open { transient = true, prefills = { search = vim.fn.expand "<cword>" } }
                end,
                desc = "Replace word under cursor",
            },
        },
        opts = {},
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    },
    -- LSP progress in a small corner window. It only loads when an LSP
    -- attaches, so it costs nothing in plain text buffers.
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {
            -- Let only the progress text show over the editor; the old solid
            -- block above the statusline looked like a second bar. Completed
            -- startup tasks also disappear immediately instead of bouncing.
            notification = {
                window = {
                    winblend = 100,
                    normal_hl = "",
                },
            },
            progress = {
                suppress_on_insert = true,
                ignore_done_already = true,
                display = { done_ttl = 0.01 },
            },
        },
    },
}
