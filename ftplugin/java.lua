vim.notify("ftplugin/java.lua: SE EJECUTÓ", vim.log.levels.WARN)
-- vim.schedule empuja la ejecución al siguiente ciclo del event loop,
-- garantizando que lazy.nvim ya haya terminado de cargar nvim-jdtls
-- (disparado por el mismo evento FileType) antes de intentar usarlo.
vim.schedule(function()
    local ok_jdtls, jdtls = pcall(require, "jdtls")
    if not ok_jdtls then
        vim.notify("ftplugin/java.lua: no se pudo cargar nvim-jdtls — " .. tostring(jdtls), vim.log.levels.ERROR)
        return
    end

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
            vim.split(
                vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
                "\n"
            )
        )
    end

    local java_test_path = mason_path .. "java-test"
    if vim.fn.isdirectory(java_test_path) == 1 then
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n"))
    end

    -- Verificación explícita: si los bundles quedaron vacíos, avisamos fuerte
    -- en vez de arrancar en silencio sin debug funcional (nos pasó antes con
    -- nvim-java y perdimos horas sin saberlo).
    if #bundles == 0 then
        vim.notify(
            "jdtls: no se encontraron los bundles de java-debug-adapter/java-test. Corré :Mason y confirmá que ambos estén instalados.",
            vim.log.levels.WARN
        )
    end

    local jdtls_bin = mason_path .. "jdtls/bin/jdtls"

    -- Raíz del proyecto: markers reales de Java PRIMERO, .git como ÚLTIMO
    -- recurso (nunca primero, evita que suba hasta un repo de dotfiles ajeno
    -- como pasó con nvim-java).
    local root_markers = { "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle" }
    local buf_dir = vim.fn.expand "%:p:h"
    local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true, path = buf_dir })[1])
    if not root_dir then
        root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true, path = buf_dir })[1])
    end
    if not root_dir then
        root_dir = buf_dir
    end
    local config = {
        cmd = { jdtls_bin, "-data", workspace_dir },
        root_dir = root_dir,

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

            -- Confirmación explícita de que quedó configurado (para no adivinar
            -- de nuevo si algo falla en silencio)
            vim.defer_fn(function()
                local configs = require("dap").configurations.java
                if configs and #configs > 0 then
                    vim.notify(
                        "jdtls: DAP configurado correctamente (" .. #configs .. " config/s de Java)",
                        vim.log.levels.INFO
                    )
                else
                    vim.notify(
                        "jdtls: DAP terminó de arrancar pero no se generó ninguna config de debug",
                        vim.log.levels.WARN
                    )
                end
            end, 3000)

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
end)
