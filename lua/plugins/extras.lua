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
}
