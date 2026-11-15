-- ── MASON BINARY PERMISSIONS ─────────────────────────────────────
-- Mason occasionally extracts a tool without the executable bit (Kali and
-- Debian packages, and a few Arch updates). Instead of spawning
-- `chmod -R +x` on every start, inspect the directory and only fix it when a
-- tool is actually missing the bit; the common case does no work at all.
local M = {}

local uv = vim.uv or vim.loop

-- 0o111: any of the three execute bits.
local EXEC_BITS = 73
local bin_dir = vim.fn.stdpath "data" .. "/mason/bin"

-- Scans `dir` so tests can point it at a throwaway directory.
local function ensure_dir(dir)
    if vim.fn.isdirectory(dir) == 0 then
        return false
    end

    local broken = false
    local handle = uv.fs_scandir(dir)
    while handle do
        local name = uv.fs_scandir_next(handle)
        if not name then
            break
        end

        -- fs_stat follows symlinks, which is what Mason installs.
        local stat = uv.fs_stat(dir .. "/" .. name)
        if stat and stat.type == "file" and bit.band(stat.mode, EXEC_BITS) == 0 then
            broken = true
            break
        end
    end

    if broken then
        vim.fn.system { "chmod", "-R", "+x", dir }
        return true
    end
    return false
end

function M.ensure()
    return ensure_dir(bin_dir)
end

-- Test-only internals
M._ensure_dir = ensure_dir

return M
