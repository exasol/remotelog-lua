---
-- This module provides a tracing wrapper for function calls where you want to record the arguments
--
local M = {}

unpack = unpack or table.unpack -- Lua 5.3 compatibility

---
-- Trace a global function's parameters when used in the context of another function call
--
-- @param function_name name of the function to be traced inside the given function call
--
-- @param call call that serves as context
--
-- @param ... arguments of context call
--
-- @return parameter values
--
function M.trace(function_name, call, ...)
    local original_function = _G[function_name]
    local captured_arguments = {}
    _G[function_name] = function (...)
        captured_arguments = {...}
        original_function(...)
    end
    call(...)
    _G[function_name] = original_function
    return unpack(captured_arguments)
end

---
-- Convenience method for tracing print invocations.
--
-- @param call call that serves as context
--
-- @param ... arguments of context call
--
-- @return parameter values
--
function M.trace_print(call, ...)
    return M.trace("print", call, ...)
end

return M
