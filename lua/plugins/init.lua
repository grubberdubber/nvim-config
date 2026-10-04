local plugins = {

  -- ══════════════════════════════════════════════════════════════
  --  1. DESACTIVAR AUTOPAIRS
  -- ══════════════════════════════════════════════════════════════
  {
    "windwp/nvim-autopairs",
    enabled = false,
  },

  -- ══════════════════════════════════════════════════════════════
  --  2. DESACTIVAR AUTOTAG
  -- ══════════════════════════════════════════════════════════════
  {
    "windwp/nvim-ts-autotag",
    enabled = false,
  },

  -- ══════════════════════════════════════════════════════════════
  --  3. MASON (Gestor de herramientas)
  -- ══════════════════════════════════════════════════════════════
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
    opts = {
      ensure_installed = {
        "stylua",
        "black",
        "prettier",
        "shfmt",
        "clang-format",
        "google-java-format",
        "php-cs-fixer",
        "rubyfmt",
        "ktlint",
        "scalafmt",
        "sql-formatter",
      },
    },
    config = function(_, opts)
      require("mason").setup()
      local ok, mr = pcall(require, "mason-registry")
      if not ok then return end
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local ok_pkg, p = pcall(mr.get_package, tool)
          if ok_pkg and not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  4. MASON-LSPCONFIG
  -- ══════════════════════════════════════════════════════════════
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

  -- ══════════════════════════════════════════════════════════════
  --  5. LSP UNIVERSAL
  -- ══════════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- CORRECCIÓN: Carga directa para evitar error de módulo nvchad.configs.lspconfig
      require "configs.lspconfig"
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  6. TREESITTER
  -- ══════════════════════════════════════════════════════════════
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "php",
        "c", "cpp", "rust", "go", "c_sharp", "swift",
        "kotlin", "java", "objc", "asm",
        "python", "bash", "powershell", "ruby", "perl",
        "r", "julia", "matlab", "sql",
        "scala",
      },
      highlight = { enable = true },
      indent    = { enable = true },
    },
  },

  -- ══════════════════════════════════════════════════════════════
  --  7. CONFORM
  -- ══════════════════════════════════════════════════════════════
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = require "configs.conform",
  },

  -- ══════════════════════════════════════════════════════════════
  --  8. COLORIZER
  -- ══════════════════════════════════════════════════════════════
  {
    "NvChad/nvim-colorizer.lua",
    event = "User FilePost",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  9. EMMET
  -- ══════════════════════════════════════════════════════════════
  {
    "aca/emmet-ls",
    ft = { "html", "css", "javascript", "typescript", "php" },
  },

  -- ══════════════════════════════════════════════════════════════
  --  10. CODEIUM
  -- ══════════════════════════════════════════════════════════════
  {
    "Exafunction/codeium.vim",
    event = "BufRead",
    config = function()
      vim.keymap.set("i", "<C-g>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  SNIPRUN
  -- ══════════════════════════════════════════════════════════════
  {
    "michaelb/sniprun",
    branch = "master",
    build  = "sh ./install.sh",
    cmd    = { "SnipRun", "SnipReset" },
    config = function()
      require("sniprun").setup {
        display      = { "VirtualTextOk", "Terminal" },
        live_display = { "VirtualTextOk" },
      }
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  IRON.NVIM
  -- ══════════════════════════════════════════════════════════════
  {
    "hkupty/iron.nvim",
    cmd = { "IronRepl", "IronFocus", "IronSend" },
    config = function()
      require("iron.core").setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh         = { command = { "bash" } },
            powershell = { command = { "pwsh" } },
            python     = { command = { "python3" } },
            dart       = { command = { "dart", "run" } },
            lua        = { command = { "lua" } },
            ruby       = { command = { "irb" } },
            perl       = { command = { "perl", "-de0" } },
            julia      = { command = { "julia" } },
            r          = { command = { "R", "--no-save" } },
            scala      = { command = { "scala" } },
            node       = { command = { "node" } },
          },
          repl_open_cmd = "vsplit",
        },
      }
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  DADBOD
  -- ══════════════════════════════════════════════════════════════
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
    init = function()
      vim.g.db_ui_save_location = vim.fn.stdpath "config" .. "/db_ui"
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  TROUBLE
  -- ══════════════════════════════════════════════════════════════
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    config = function()
      require("trouble").setup {
        position             = "bottom",
        use_diagnostic_signs = true,
      }
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  LAZYGIT
  -- ══════════════════════════════════════════════════════════════
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit", "LazyGitConfig", "LazyGitCurrentFile",
      "LazyGitFilter", "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- ══════════════════════════════════════════════════════════════
  --  DAP + UI
  -- ══════════════════════════════════════════════════════════════
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      -- CARGA TU CONFIGURACIÓN CENTRALIZADA
      require("configs.dap") 

      local dap  = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      require("mason-nvim-dap").setup {
        ensure_installed       = { "python", "delve", "codelldb" },
        automatic_installation = true,
      }
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
    end,
  },
}

return plugins
