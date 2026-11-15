return {
    -- ── TEST RUNNER ─────────────────────────────────────────────────
    -- One interface for running and inspecting tests across languages.
    -- Adapters are only loaded with the runner, so startup stays lazy.
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            -- Adapters for the toolchains available on this machine.
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-go",
            "rouge8/neotest-rust",
            "marilari88/neotest-vitest",
            "rcasia/neotest-java",
            "olimorris/neotest-phpunit",
            "olimorris/neotest-rspec",
            "sidlatau/neotest-dart",
        },
        keys = {
            {
                "<leader>Tt",
                function()
                    require("neotest").run.run()
                end,
                desc = "Test: run nearest",
            },
            {
                "<leader>Tf",
                function()
                    require("neotest").run.run(vim.fn.expand "%")
                end,
                desc = "Test: run current file",
            },
            {
                "<leader>Tl",
                function()
                    require("neotest").run.run_last()
                end,
                desc = "Test: run last",
            },
            {
                "<leader>Td",
                function()
                    require("neotest").run.run { strategy = "dap" }
                end,
                desc = "Test: debug nearest",
            },
            {
                "<leader>Ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Test: toggle summary",
            },
            {
                "<leader>To",
                function()
                    require("neotest").output.open { enter = true }
                end,
                desc = "Test: open output",
            },
            {
                "<leader>Tx",
                function()
                    require("neotest").run.stop()
                end,
                desc = "Test: stop run",
            },
        },
        opts = function()
            return {
                adapters = {
                    require "neotest-python" { dap = { justMyCode = false } },
                    require "neotest-go",
                    require "neotest-rust",
                    require "neotest-vitest",
                    require "neotest-java",
                    require "neotest-phpunit",
                    require "neotest-rspec",
                    require "neotest-dart" { command = "flutter" },
                },
                output = { open_on_run = false },
                quickfix = { enabled = false, open = false },
            }
        end,
        config = function(_, opts)
            require("neotest").setup(opts)
        end,
    },
}
