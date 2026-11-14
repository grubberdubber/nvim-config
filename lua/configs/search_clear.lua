-- ── SEARCH HIGHLIGHT LIFECYCLE ──────────────────────────────────
-- <Esc> already clears the highlight in mappings.lua. Keep the highlight
-- alive when switching buffers: the search is global, and the bottom HUD
-- must keep showing [N/M] after opening a terminal or a panel. Only entering
-- insert mode clears it, so normal n/N navigation is unaffected.
local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("SearchHighlight", { clear = true })

    local function clear()
        if vim.v.hlsearch == 1 then
            vim.cmd "nohlsearch"
        end
    end

    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        desc = "Clear search highlight when typing starts",
        callback = function()
            vim.schedule(clear)
        end,
    })
end

return M
