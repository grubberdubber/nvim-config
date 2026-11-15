-- Headless checks for the BufWritePre cleanup (trailing spaces, NBSP, EOL).
-- Run with: nvim --headless -u init.lua -c "luafile tests/save_filters_spec.lua"
local H = dofile "tests/helpers.lua"

local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")

local function path(name)
    return tmp .. "/" .. name
end

local function edit(file, lines, ft)
    vim.fn.writefile(lines, file)
    vim.cmd("edit! " .. vim.fn.fnameescape(file))
    vim.bo.filetype = ft
end

local function save()
    local ok, err = pcall(vim.cmd, "silent write")
    return ok, err
end

-- ── Trailing whitespace is stripped outside Markdown ────────────
local text = path "notes.txt"
edit(text, { "one  ", "two\t" }, "text")
H.check("write succeeds", save())
local saved = vim.fn.readfile(text)
H.check("trailing spaces are stripped", saved[1] == "one", vim.inspect(saved))
H.check("trailing tabs are stripped", saved[2] == "two", vim.inspect(saved))

-- ── Non-breaking spaces are normalised ──────────────────────────
local nbsp = vim.fn.nr2char(0xA0)
local nbsp_file = path "nbsp.txt"
edit(nbsp_file, { "a" .. nbsp .. "b" }, "text")
H.check("write with NBSP succeeds", save())
H.check("NBSP becomes a regular space", vim.fn.readfile(nbsp_file)[1] == "a b")

-- ── Markdown hard breaks survive ────────────────────────────────
local md = path "doc.md"
edit(md, { "line one  ", "line two" }, "markdown")
H.check("markdown write succeeds", save())
local md_saved = vim.fn.readfile(md)
H.check("markdown keeps the two trailing spaces", md_saved[1] == "line one  ", vim.inspect(md_saved))

-- ── Line endings are normalised to LF ───────────────────────────
local crlf = path "crlf.txt"
edit(crlf, { "a", "b" }, "text")
vim.bo.fileformat = "dos"
H.check("write with fileformat=dos succeeds", save())
local blob = vim.fn.readblob(crlf)
H.check("no CR bytes are written", not blob:find("\r", 1, true))

-- ── Read-only and binary buffers are not rewritten ──────────────
local ro = path "readonly.txt"
edit(ro, { "keep  " }, "text")
vim.bo.modifiable = false
H.check("non-modifiable buffer can be written", save())
H.check("non-modifiable buffer keeps its text", vim.fn.readfile(ro)[1] == "keep  ")
vim.bo.modifiable = true

local bin = path "blob.bin"
edit(bin, { "keep  " }, "text")
vim.bo.binary = true
H.check("binary buffer can be written", save())

vim.fn.delete(tmp, "rf")
H.finish()
