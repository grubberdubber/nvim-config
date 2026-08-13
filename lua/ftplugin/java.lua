-- Java necesita arrancar vía nvim-jdtls (no vim.lsp.config genérico) porque
-- el debugger de Java corre DENTRO del propio LSP jdtls, usando extensiones
-- extra (java-debug-adapter, java-test) que hay que "inyectarle" al arrancar.
local ok_jdtls, jdtls = pcall(require, "jdtls")
if not ok_jdtls then
    return
end

local mason_registry = require "mason-registry"
local mason_path = vim.fn.stdpath "data" .. "/mason/packages/"

-- Workspace propio por proyecto (jdtls lo necesita para indexar)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath "data" .. "/jdtls-workspace/" .. project_name

-- Bundles de debug: el .jar de java-debug-adapter + los de java-test
local bundles = {}

local java_debug_path = mason_path .. "java-debug-adapter"
if vim.fn.isdirectory(java_debug_path) == 1 then
    vim.list_extend(
        bundles,
        vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true), "\n")
    )
end

local java_test_path = mason_path .. "java-test"
if vim.fn.isdirectory(java_test_path) == 1 then
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n"))
end

local jdtls_bin = mason_path .. "jdtls/bin/jdtls"

local config = {
    cmd = { jdtls_bin, "-data", workspace_dir },
    root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", "mvnw", ".git" }, { upward = true })[1]),

    settings = {
        java = {
            signatureHelp = { enabled = true },
            completion = { favoriteStaticMembers = { "org.junit.Assert.*", "org.junit.jupiter.api.Assertions.*" } },
        },
    },

    init_options = {
        bundles = bundles,
    },

    on_attach = function(client, bufnr)
        -- Habilita comandos de debug/test propios de Java sobre el DAP existente
        jdtls.setup_dap { hotcodereplace = "auto" }
        require("jdtls.dap").setup_dap_main_class_configs()

        -- Atajos SOLO en buffers Java, no globales (para no ensuciar mappings.lua
        -- con teclas que no aplican en otros lenguajes)
        local map = vim.keymap.set
        map("n", "<leader>jt", function()
            require("jdtls").test_class()
        end, { buffer = bufnr, desc = "Java: Debug clase de test" })
        map("n", "<leader>jm", function()
            require("jdtls").test_nearest_method()
        end, { buffer = bufnr, desc = "Java: Debug método de test más cercano" })
        map("n", "<leader>jo", function()
            require("jdtls").organize_imports()
        end, { buffer = bufnr, desc = "Java: Organizar imports" })
        map("n", "<leader>jv", function()
            require("jdtls").extract_variable()
        end, { buffer = bufnr, desc = "Java: Extraer variable" })
        map("n", "<leader>jc", function()
            require("jdtls").extract_constant()
        end, { buffer = bufnr, desc = "Java: Extraer constante" })
    end,
}

jdtls.start_or_attach(config)
