-- Headless checks for the language tooling matrix: every formatter and linter
-- name must exist, and every enabled LSP must ship a config.
-- Run with: nvim --headless -u init.lua -c "luafile tests/languages_spec.lua"
local H = dofile "tests/helpers.lua"

local conform = require "conform"
local lint = require "lint"

local formatters_by_ft = require("configs.conform").formatters_by_ft
require "configs.lint"
local linters_by_ft = lint.linters_by_ft

-- ── Formatters resolve to builtins ──────────────────────────────
local seen = {}
for _, list in pairs(formatters_by_ft) do
    for _, name in ipairs(list) do
        if not seen[name] then
            seen[name] = true
            H.check("formatter exists: " .. name, conform.get_formatter_info(name, 0) ~= nil)
        end
    end
end

-- ── Linters resolve to nvim-lint entries ────────────────────────
seen = {}
for _, list in pairs(linters_by_ft) do
    for _, name in ipairs(list) do
        if not seen[name] then
            seen[name] = true
            H.check("linter exists: " .. name, lint.linters[name] ~= nil)
        end
    end
end

-- ── Filetypes added with the language pass ──────────────────────
for _, ft in ipairs { "zig", "elixir", "haskell", "cs", "xml", "hurl", "graphql" } do
    H.check("formatter configured for " .. ft, formatters_by_ft[ft] ~= nil)
end
H.check("rubocop runs for ruby", linters_by_ft.ruby and linters_by_ft.ruby[1] == "rubocop")
H.check("hlint runs for haskell", linters_by_ft.haskell and linters_by_ft.haskell[1] == "hlint")

-- ── LSP servers have a runtime config ───────────────────────────
-- nvim-lspconfig is lazy, so read its directory instead of loading it (which
-- would also start Mason installs).
local lspconfig_dir = require("lazy.core.config").plugins["nvim-lspconfig"].dir
for _, name in ipairs { "sqls", "taplo", "lemminx", "dockerls", "graphql", "hls" } do
    local files = vim.fn.globpath(lspconfig_dir .. "/lsp", name .. ".lua", false, true)
    H.check("LSP config exists: " .. name, #files > 0)
end

H.finish()
