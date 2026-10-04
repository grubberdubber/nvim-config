local plugins = {

  -- ══════════════════════════════════════════════════════════════
  --  DESACTIVAR PLUGINS QUE NO QUEREMOS
  -- ══════════════════════════════════════════════════════════════
  { "windwp/nvim-autopairs",  enabled = false }, -- sin cierres automáticos
  { "windwp/nvim-ts-autotag", enabled = false }, -- sin cierre de tags HTML

  -- ══════════════════════════════════════════════════════════════
  --  MASON — gestor de herramientas (LSP, DAP, linters, formatters)
  --  DEBE declararse antes que mason-lspconfig y mason-nvim-dap
  -- ══════════════════════════════════════════════════════════════
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
    opts = {},
    config = function(_, opts)
      require("mason").setup(opts)

      -- Instala formateadores disponibles en Mason
      -- NOTA: gofmt y dart_format NO van aquí (vienen con Go/Flutter)
      local tools = {
        -- Formateadores
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
        -- Adaptadores DAP que mason-nvim-dap no gestiona directamente
        "js-debug-adapter",
      }

      local ok, mr = pcall(require, "mason-registry")
      if not ok then return end

      -- Instala cada tool de forma individual con pcall
      -- si uno falla no rompe toda la lista
      mr.refresh(function()
        for _, tool in ipairs(tools) do
          local ok_pkg, pkg = pcall(mr.get_package, tool)
          if ok_pkg and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  MASON-LSPCONFIG — puente Mason ↔ nvim-lspconfig
  -- ══════════════════════════════════════════════════════════════
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Servidores LSP que se instalan automáticamente al abrir Neovim
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
  --  LSP UNIVERSAL — expone :LspInfo y :LspStart
  --  La lista de servidores está en lua/configs/lspconfig.lua
  -- ══════════════════════════════════════════════════════════════
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  TREESITTER — resaltado y sintaxis para los 30 lenguajes
  -- ══════════════════════════════════════════════════════════════
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    opts = {
      ensure_installed = {
        -- Base Neovim y Web
        "vim", "lua", "vimdoc",
        "html", "css", "javascript", "typescript", "php",
        -- Sistemas, Compilados y Bajo Nivel
        "c", "cpp", "rust", "go", "c_sharp",
        "swift", "kotlin", "java", "objc", "asm",
        -- Scripting y Automatización
        "python", "bash", "powershell", "ruby", "perl",
        -- Ciencia de Datos e IA
        "r", "julia", "matlab", "sql",
        -- Funcional y Empresarial
        "scala",
      },
      highlight = { enable = true },
      indent    = { enable = true },
    },
  },

  -- ══════════════════════════════════════════════════════════════
  --  CONFORM — formateo automático al guardar (:w)
  --  Formateadores configurados en lua/configs/conform.lua
  -- ══════════════════════════════════════════════════════════════
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts  = require "configs.conform",
  },

  -- ══════════════════════════════════════════════════════════════
  --  COLORIZER — vista previa de colores hex (#ff0000, rgb, hsl)
  --  Útil para CSS, Tailwind, configuraciones de temas, etc.
  -- ══════════════════════════════════════════════════════════════
  {
    "NvChad/nvim-colorizer.lua",
    event = "User FilePost",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  EMMET — abreviaciones HTML/CSS/JSX
  --  Instalar el binario con: :MasonInstall emmet-ls
  -- ══════════════════════════════════════════════════════════════
  {
    "aca/emmet-ls",
    ft = { "html", "css", "javascript", "typescript", "php" },
  },

  -- ══════════════════════════════════════════════════════════════
  --  CODEIUM — autocompletado con IA (gratuito, alternativa a Copilot)
  --  <C-g>  → aceptar sugerencia
  --  <C-]>  → descartar sugerencia
  -- ══════════════════════════════════════════════════════════════
  {
    "Exafunction/codeium.vim",
    event = "BufRead",
    config = function()
      vim.keymap.set("i", "<C-g>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-]>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true, silent = true })
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  WHICH-KEY — muestra atajos disponibles al presionar <leader>
  --  Imprescindible para memorizar el ecosistema de keymaps
  -- ══════════════════════════════════════════════════════════════
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      preset = "modern",
      delay  = 400, -- ms antes de mostrar el panel
    },
  },

  -- ══════════════════════════════════════════════════════════════
  --  GITSIGNS — indicadores de cambios Git en el gutter (columna izquierda)
  --  Muestra: + línea nueva  ~ línea modificada  - línea eliminada
  --  Atajos: ]c / [c → siguiente/anterior cambio  |  <leader>ph → preview hunk
  -- ══════════════════════════════════════════════════════════════
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▁" },
        topdelete    = { text = "▔" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function bmap(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- Navegar entre hunks (bloques de cambios)
        bmap("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, "Git: Siguiente hunk")
        bmap("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, "Git: Hunk anterior")
        -- Acciones sobre hunks
        bmap("n", "<leader>ph", gs.preview_hunk,        "Git: Preview hunk")
        bmap("n", "<leader>gs", gs.stage_hunk,          "Git: Stage hunk")
        bmap("n", "<leader>gr", gs.reset_hunk,          "Git: Reset hunk")
        bmap("n", "<leader>gS", gs.stage_buffer,        "Git: Stage buffer completo")
        bmap("n", "<leader>gb", gs.toggle_current_line_blame, "Git: Toggle blame línea")
      end,
    },
  },

  -- ══════════════════════════════════════════════════════════════
  --  COMMENT.NVIM — comentar/descomentar con estándar de IDE
  --  gcc     → comentar línea        (Normal mode)
  --  gc      → comentar selección    (Visual mode)
  --  gbc     → comentar en bloque    (Normal mode)
  --  Funciona con todos los lenguajes via Treesitter
  -- ══════════════════════════════════════════════════════════════
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- ══════════════════════════════════════════════════════════════
  --  SNIPRUN — ejecución inline de fragmentos sin salir de Neovim
  --  Soporta: C, C++, Rust, Go, Java, Assembly, Bash, Python...
  --  <leader>sr → ejecutar línea/bloque
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
  --  IRON.NVIM — REPL interactivo estilo Jupyter
  --  Python, Julia, R, Ruby, Perl, Lua, Scala, Node, PowerShell
  --  <leader>ro → abrir REPL  |  <leader>rs → enviar al REPL
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
          repl_open_cmd = "vsplit", -- abre el REPL en split vertical
        },
      }
    end,
  },

  -- ══════════════════════════════════════════════════════════════
  --  DADBOD — central de bases de datos multiprotocolo
  --  SQL / PL-SQL / T-SQL / MySQL / PostgreSQL / SQLite
  --  <leader>db → abrir UI de base de datos
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
  --  TROUBLE — radar de errores, warnings y diagnósticos LSP
  --  <leader>xx → toggle panel  |  <leader>xw → workspace
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
  --  LAZYGIT — control de versiones flotante dentro de Neovim
  --  <leader>gg → abrir Lazygit
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
  --  DAP — motor de debugging completo
  --  Atajos estándar de IDE: F5/F9/F10/F11/F12/Shift+F5
  --  Adaptadores instalados automáticamente por mason-nvim-dap:
  --    debugpy    → Python
  --    delve      → Go
  --    codelldb   → C / C++ / Rust / Assembly
  --    netcoredbg → C# / .NET
  --  js-debug-adapter (JS/TS) instalado vía Mason directamente
  --
  --  Toda la configuración de adaptadores está en configs/dap.lua
  --
  --  DEPENDENCIA CRÍTICA: mason.nvim DEBE estar cargado antes
  --  por eso está declarado explícitamente en dependencies
  -- ══════════════════════════════════════════════════════════════
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",       -- mason-core debe existir primero
      "rcarriga/nvim-dap-ui",          -- interfaz gráfica del debugger
      "nvim-neotest/nvim-nio",         -- async IO requerido por dap-ui
      "jay-babu/mason-nvim-dap.nvim",  -- auto-instalación de adaptadores
    },
    config = function()
      -- Instalación automática de adaptadores DAP vía Mason
      require("mason-nvim-dap").setup {
        ensure_installed = {
          "debugpy",    -- Python
          "delve",      -- Go
          "codelldb",   -- C / C++ / Rust / Assembly
          "netcoredbg", -- C# / .NET
        },
        automatic_installation = true,
      }

      -- Carga adaptadores, configuraciones por filetype y UI
      -- desde configs/dap.lua (archivo centralizado)
      require "configs.dap"
    end,
  },
}

return plugins
