-- vim.schedule defers execution to the next event-loop tick so
-- lazy.nvim has finished loading nvim-jdtls
-- (triggered by the same FileType event) before we use it.
vim.schedule(function()
    local ok_jdtls, jdtls = pcall(require, "jdtls")
    if not ok_jdtls then
        vim.notify_once("ftplugin/java.lua: could not load nvim-jdtls - " .. tostring(jdtls), vim.log.levels.ERROR)
        return
    end

    local mason_path = vim.fn.stdpath "data" .. "/mason/packages/"

    -- Per-project workspace (jdtls needs it for indexing)
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = vim.fn.stdpath "data" .. "/jdtls-workspace/" .. project_name

    -- Debug bundles: the java-debug-adapter .jar plus the java-test ones
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

    -- Explicit check: if the bundles are empty, warn loudly
    -- instead of starting silently without working debug support
    -- doing this, which has cost hours of debugging in the past).
    if #bundles == 0 then
        vim.notify_once(
            "jdtls: java-debug-adapter/java-test bundles not found. Run :Mason and make sure both are installed.",
            vim.log.levels.WARN
        )
    end

    local jdtls_bin = mason_path .. "jdtls/bin/jdtls"

    -- Project root: real Java markers FIRST, .git as the LAST
    -- resort (never first, so it does not climb into an unrelated dotfiles repo
    -- as happened with nvim-java).
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
            -- Enable Java-specific debug/test commands on top of the existing DAP
            jdtls.setup_dap { hotcodereplace = "auto" }
            require("jdtls.dap").setup_dap_main_class_configs()

            -- Explicit confirmation that DAP was configured (no more guessing
            -- when something fails silently)
            vim.defer_fn(function()
                local configs = require("dap").configurations.java
                if configs and #configs > 0 then
                    vim.notify_once(
                        "jdtls: DAP configured correctly (" .. #configs .. " Java config(s))",
                        vim.log.levels.INFO
                    )
                else
                    vim.notify_once("jdtls: DAP started but no debug configuration was generated", vim.log.levels.WARN)
                end
            end, 3000)

            local map = vim.keymap.set
            map("n", "<leader>jt", function()
                require("jdtls").test_class()
            end, { buffer = bufnr, desc = "Java: debug test class" })
            map("n", "<leader>jm", function()
                require("jdtls").test_nearest_method()
            end, { buffer = bufnr, desc = "Java: debug nearest test method" })
            map("n", "<leader>jo", function()
                require("jdtls").organize_imports()
            end, { buffer = bufnr, desc = "Java: organize imports" })
            map("n", "<leader>jv", function()
                require("jdtls").extract_variable()
            end, { buffer = bufnr, desc = "Java: extract variable" })
            map("n", "<leader>jc", function()
                require("jdtls").extract_constant()
            end, { buffer = bufnr, desc = "Java: extract constant" })
        end,
    }

    jdtls.start_or_attach(config)
end)
