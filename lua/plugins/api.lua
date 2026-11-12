-- lua/plugins/api.lua
-- HTTP client / API testing inside Neovim, built on Hurl (Rust CLI, Apache-2.0).
-- *.hurl files: requests + assertions + chained captures, also runnable in CI.
return {
    {
        "jellydn/hurl.nvim",
        -- nui and plenary already ship with avante.nvim / telescope; treesitter is installed.
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        ft = "hurl",
        cmd = {
            "HurlRunner",
            "HurlRunnerAt",
            "HurlRunnerToEntry",
            "HurlRunnerToEnd",
            "HurlToggleMode",
            "HurlVerbose",
            "HurlVeryVerbose",
            "HurlShowLastResponse",
            "HurlSetVariable",
            "HurlManageVariable",
        },
        init = function()
            -- Guaranteed filetype detection (independent of the Neovim version)
            vim.filetype.add { extension = { hurl = "hurl" } }

            -- :ApiScratch -> persistent scratch file outside your projects
            vim.api.nvim_create_user_command("ApiScratch", function()
                local dir = vim.fn.stdpath "data" .. "/api"
                vim.fn.mkdir(dir, "p")
                local file = dir .. "/scratch.hurl"
                if vim.fn.filereadable(file) == 0 then
                    vim.fn.writefile({
                        "# Run the request under the cursor:  <leader>Hr",
                        "GET https://jsonplaceholder.typicode.com/users/1",
                        "HTTP 200",
                        "[Asserts]",
                        'jsonpath "$.id" == 1',
                        "[Captures]",
                        'user_name: jsonpath "$.name"',
                        "",
                    }, file)
                end
                vim.cmd("edit " .. vim.fn.fnameescape(file))
            end, { desc = "API: open scratch .hurl file" })
        end,
        opts = {
            debug = false,
            show_notification = false,
            mode = "split", -- "split" | "popup"  (alternas con <leader>Hm)
            formatters = {
                json = { "jq" },
                html = { "prettier", "--parser", "html" },
            },
            mappings = { close = "q", next_panel = "<C-n>", prev_panel = "<C-p>" },
            env_file = { "vars.env" }, -- variables {{base_url}}, {{token}}... (no lo subas a git)
        },
        config = function(_, opts)
            require("hurl").setup(opts)

            -- Keymaps scoped to .hurl files only (never shadow global ones)
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("HurlKeymaps", { clear = true }),
                pattern = "hurl",
                callback = function(ev)
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = "Hurl: " .. desc })
                    end
                    map("n", "<leader>Hr", "<cmd>HurlRunnerAt<CR>", "run request under the cursor")
                    map("v", "<leader>Hr", ":HurlRunner<CR>", "run selection")
                    map("n", "<leader>Ha", "<cmd>HurlRunner<CR>", "ejecutar todo el archivo")
                    map("n", "<leader>He", "<cmd>HurlRunnerToEntry<CR>", "run up to this request")
                    map("n", "<leader>HE", "<cmd>HurlRunnerToEnd<CR>", "ejecutar desde esta hasta el final")
                    map("n", "<leader>Hv", "<cmd>HurlVerbose<CR>", "modo verbose")
                    map("n", "<leader>HV", "<cmd>HurlVeryVerbose<CR>", "modo muy verbose")
                    map("n", "<leader>Hl", "<cmd>HurlShowLastResponse<CR>", "show last response")
                    map("n", "<leader>Hm", "<cmd>HurlToggleMode<CR>", "alternar split/popup")
                    map("n", "<leader>Hs", "<cmd>HurlSetVariable<CR>", "definir variable")
                    map("n", "<leader>HM", "<cmd>HurlManageVariable<CR>", "ver/gestionar variables")
                end,
            })
        end,
    },
}
