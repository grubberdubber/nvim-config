local plugins = {
  { "windwp/nvim-autopairs",  enabled = false },
  { "windwp/nvim-ts-autotag", enabled = false },

  -- ── 1. HERRAMIENTAS GIT ────────────────────────────────────────
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {},
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim", 
    },
    cmd = "Neogit",
    opts = {
      integrations = { diffview = true },
    }
  },

  -- ── 2. COLOR PICKER PARA CSS ───────────────────────────────────
  {
    "uga-rosa/ccc.nvim",
    cmd = { "CccPick", "CccConvert" },
    keys = {
      { "<leader>cp", "<cmd>CccPick<cr>", desc = "Selector de Color Visual" },
    },
    config = function()
      require("ccc").setup({
        highlighter = { auto_enable = true, lsp = true }
      })
    end
  },

  -- ── 3. INDENT BLANKLINE (Líneas │ siempres visibles + Puntos ·) 
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- Color gris inactivo para las líneas verticales que no estás tocando
        vim.api.nvim_set_hl(0, "IblIndentOpaque", { fg = "#4b5263" })
        
        -- Colores del Scope Rainbow
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75", bold = true })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B", bold = true })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF", bold = true })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66", bold = true })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379", bold = true })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD", bold = true })
      end)

      require("ibl").setup {
        indent = { 
          char = "│", -- Dibuja SIEMPRE la línea vertical (los puntitos los pone Neovim en medio)
          highlight = "IblIndentOpaque", -- Las líneas inactivas son grises
        },
        scope = { 
          enabled = true, 
          char = "│",         
          show_start = false, -- Desactivado para que no estorbe (sin guiones arriba/abajo)
          show_end = false,   
          highlight = {
            "RainbowRed", "RainbowYellow", "RainbowBlue",
            "RainbowOrange", "RainbowGreen", "RainbowViolet",
          }
        },
      }
    end,
  },

  -- ── 4. BÚSQUEDA Y REEMPLAZO GLOBAL (Spectre) ───────────────────
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = {
      { "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', desc = "Buscar y reemplazar globalmente" },
    },
  },

  -- ── 5. MASON Y LSPs ────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
    opts = {},
    config = function(_, opts)
      require("mason").setup(opts)
      local tools = {
        "stylua", "black", "prettier", "shfmt", "clang-format",
        "google-java-format", "php-cs-fixer", "rubyfmt", "ktlint",
        "scalafmt", "sql-formatter", "js-debug-adapter",
      }
      local ok, mr = pcall(require, "mason-registry")
      if not ok then return end
      mr.refresh(function()
        for _, tool in ipairs(tools) do
          local ok_pkg, pkg = pcall(mr.get_package, tool)
          if ok_pkg and not pkg:is_installed() then pkg:install() end
        end
      end)
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua_ls", "html", "cssls", "ts_ls", "pyright",
        "rust_analyzer", "bashls", "clangd", "gopls",
        "intelephense", "jdtls", "omnisharp", "sqlls",
        "r_language_server", "kotlin_language_server",
      },
      automatic_installation = false,
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function() require "configs.lspconfig" end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "html", "css", "javascript", "typescript", "php",
        "c", "cpp", "rust", "go", "c_sharp", "swift", "kotlin", "java", "objc", "asm",
        "python", "bash", "powershell", "ruby", "perl",
        "r", "julia", "matlab", "sql", "scala",
      },
      highlight = { enable = true },
      indent    = { enable = true },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = require "configs.conform",
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = "User FilePost",
    config = function() require("colorizer").setup() end,
  },

  {
    "aca/emmet-ls",
    ft = { "html", "css", "javascript", "typescript", "php" },
  },

  {
    "Exafunction/codeium.vim",
    event = "BufRead",
    config = function()
      vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-]>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = { preset = "modern", delay  = 400 },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true, 
      current_line_blame_opts = { delay = 500 },
      signs = {
        add          = { text = "▎" }, change       = { text = "▎" },
        delete       = { text = "▁" }, topdelete    = { text = "▔" },
        changedelete = { text = "▎" }, untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function bmap(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
        bmap("n", "]c", function() if vim.wo.diff then return "]c" end vim.schedule(function() gs.next_hunk() end) return "<Ignore>" end, "Git: Siguiente hunk")
        bmap("n", "[c", function() if vim.wo.diff then return "[c" end vim.schedule(function() gs.prev_hunk() end) return "<Ignore>" end, "Git: Hunk anterior")
        bmap("n", "<leader>ph", gs.preview_hunk, "Git: Preview hunk")
        bmap("n", "<leader>gs", gs.stage_hunk, "Git: Stage hunk")
        bmap("n", "<leader>gr", gs.reset_hunk, "Git: Reset hunk")
      end,
    },
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  {
    "michaelb/sniprun",
    branch = "master",
    build  = "sh ./install.sh",
    cmd    = { "SnipRun", "SnipReset" },
    config = function()
      require("sniprun").setup { display = { "VirtualTextOk", "Terminal" }, live_display = { "VirtualTextOk" } }
    end,
  },

  {
    "hkupty/iron.nvim",
    cmd = { "IronRepl", "IronFocus", "IronSend" },
    config = function()
      require("iron.core").setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = { command = { "bash" } }, python = { command = { "python3" } }, 
            lua = { command = { "lua" } }, node = { command = { "node" } },
          },
          repl_open_cmd = "vsplit",
        },
      }
    end,
  },

  {
    "tpope/vim-dadbod",
    dependencies = { "kristijanhusak/vim-dadbod-ui", "kristijanhusak/vim-dadbod-completion" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    init = function() vim.g.db_ui_save_location = vim.fn.stdpath "config" .. "/db_ui" end,
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    config = function()
      require("trouble").setup { position = "bottom", use_diagnostic_signs = true }
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- ── 6. DAP DEBUGGER ────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      require("mason-nvim-dap").setup {
        ensure_installed = { "debugpy", "delve", "codelldb", "netcoredbg" },
        automatic_installation = true,
      }
      require "configs.dap"
    end,
  },
}

return plugins
