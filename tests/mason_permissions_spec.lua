-- Headless checks for the Mason executable-bit fixer.
-- Run with: nvim --headless -u init.lua -c "luafile tests/mason_permissions_spec.lua"
local H = dofile "tests/helpers.lua"
local mason = require "configs.mason_permissions"

local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
local tool = tmp .. "/tool"
vim.fn.writefile({ "#!/bin/sh" }, tool)

-- 0644: only the owner can write; no execute bit anywhere.
vim.fn.setfperm(tool, "rw-r--r--")
H.check("broken tool is fixed", mason._ensure_dir(tmp) == true)
H.check("fix adds the execute bit", vim.fn.getfperm(tool) == "rwxr-xr-x", vim.fn.getfperm(tool))
H.check("a second run is a no-op", mason._ensure_dir(tmp) == false)

-- Already executable: the directory must not be touched.
vim.fn.setfperm(tool, "rwx------")
H.check("executable tool is left alone", mason._ensure_dir(tmp) == false)
H.check("its mode is unchanged", vim.fn.getfperm(tool) == "rwx------", vim.fn.getfperm(tool))

H.check("a missing directory is ignored", mason._ensure_dir(tmp .. "/absent") == false)

vim.fn.delete(tmp, "rf")
H.finish()
