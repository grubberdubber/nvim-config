-- Shared harness for the headless suites.
-- Usage: local H = dofile("tests/helpers.lua")
local M = { checks = 0, failures = 0 }

function M.check(name, condition, detail)
    M.checks = M.checks + 1
    if condition then
        print("ok   " .. name)
    else
        M.failures = M.failures + 1
        print("FAIL " .. name .. (detail and ("  -> " .. detail) or ""))
    end
end

function M.finish()
    print(string.format("\n%d checks, %d failure(s)", M.checks, M.failures))
    vim.cmd(M.failures > 0 and "cq" or "qa!")
end

return M
