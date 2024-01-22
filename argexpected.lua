--
-- Copyright (C) 2024 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
--- assign to local
local type = type
local getinfo = debug.getinfo
local open = io.open
local match = string.match
local sub = string.sub
local format = require('string.format')

--- readline reads a line from file.
--- @param lineno integer line number
--- @param filename string file name
--- @return string? line
local function readline(lineno, filename)
    local f = open(filename, 'r')
    if f then
        local line = f:read('*l')
        while line and lineno > 1 do
            -- discard lines until lineno
            lineno = lineno - 1
            line = f:read('*l')
        end
        f:close()
        return line
    end
end

--- getfname returns function name.
--- @return string fname
local function getfname()
    local lv = 3
    local info = getinfo(lv, 'nS')
    if info.name then
        -- return function name
        return info.name
    end

    -- linedefined is <1 if the function is a C function or called by tail call
    -- read line of function definition from source file
    local line = info.linedefined > 0 and
                     readline(info.linedefined, sub(info.source, 2))
    -- return extracted function name or '?' (unnamed function)
    return line and match(line, 'function%s*([^(]+)') or '?'
end

--- argexpected that throws an error if the condition is false.
--- @param cond boolean condition to check argument validity
--- @param idx number argument index
--- @param extramsg? string extra message format
--- @param ... any arguments for extramsg format
--- @return any arg
local function argexpected(cond, idx, extramsg, ...)
    if type(idx) ~= 'number' then
        error(format('idx must be number (got %s)', type(idx)), 2)
    elseif extramsg and type(extramsg) ~= 'string' then
        error(format('extramsg must be string or nil (got %s)', type(extramsg)),
              2)
    end

    if cond ~= true then
        local fname = getfname()
        local msg = format("bad argument #%d to '%s'", idx, fname)
        if extramsg then
            msg = msg .. ' (' .. format(extramsg, ...) .. ')'
        end
        error(msg, 2)
    end
end

return argexpected
