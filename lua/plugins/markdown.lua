return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ---@module 'render-markdown'
        opts = {
            file_types = { "markdown" },
            latex = { enabled = false },
            completions = { blink = { enabled = true } },
            code = { sign = false, width = "block", right_pad = 1 },
            heading = { sign = false },
        },
        keys = {
            { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Markdown: toggle render" },
        },
    },

    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
        build = "cd app && npm install && git checkout -- yarn.lock",
        init = function()
            vim.g.mkdp_auto_close = 0
            vim.g.mkdp_theme = "dark"
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_browser = "firefox"
            vim.g.mkdp_echo_preview_url = 1
        end,
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown: preview navegador" },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline", "html", "yaml" })
        end,
    },
}
