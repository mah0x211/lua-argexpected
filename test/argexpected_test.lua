require('luacov')
local pcall = pcall
local assert = require('assert')
local format = require('string.format')
local argexpected = require('argexpected')
local ALLTESTS = {}
local testcase = setmetatable({}, {
    __newindex = function(_, name, fn)
        assert(type(name) == 'string', 'testcase name must be string')
        assert(type(fn) == 'function', 'testcase must be function')
        if ALLTESTS[name] then
            error(format('testcase %q already exists', name))
        end

        ALLTESTS[name] = fn
        ALLTESTS[#ALLTESTS + 1] = {
            name = name,
            func = fn,
        }
    end,
})

function testcase.throw_error()
    -- test that throws an error
    local err = assert.throws(function()
        local function foo(a, b)
            argexpected(type(a) == 'string', 1)
            argexpected(type(b) == 'number', 2)
        end
        foo('hello', 'world')
    end)
    assert.match(err, 'argexpected_test.lua:30: bad argument #2 to \'foo\'')

    err = assert.throws(function()
        (function(a, b)
            argexpected(type(a) == 'string', 1)
            argexpected(type(b) == 'number', 2)
        end)('hello', 'world')
    end)
    -- NOTE: lua throws error at line 35, but luajit throws error at line 38.
    assert.match(err, 'argexpected_test.lua:3[58]: bad argument #2 to \'?\'', false)
end

function testcase.throw_error_with_extramsg()
    -- test that throws an error with extramsg
    local err = assert.throws(function()
        local function foo(a, b)
            argexpected(type(a) == 'string', 1, 'string expected, got %s',
                        type(a))
            argexpected(type(b) == 'number', 2, 'number expected, got %s',
                        type(b))
        end
        foo('hello', 'world')
    end)
    assert.match(err,
                 'argexpected_test.lua:53: bad argument #2 to \'foo\' (number expected, got string)')
end

function testcase.fails_with_invalid_arguments()
    -- test that fails with invalid idx argument
    local err = assert.throws(function()
        local function foo(a, b)
            argexpected(type(a) == 'string', 1)
            argexpected(type(b) == 'number', 'bar')
        end
        foo('hello', 'world')
    end)
    assert.match(err, 'idx must be number (got string)')

    -- test that fails with invalid extramsg argument
    err = assert.throws(function()
        local function foo(a, b)
            argexpected(type(a) == 'string', 1)
            argexpected(type(b) == 'number', 2, 123)
        end
        foo('hello', 'world')
    end)
    assert.match(err, 'extramsg must be string or nil (got number)')
end

do
    local stdout = io.stdout
    local function printf(...)
        stdout:write(format(...))
    end
    printf("\nRun %d tests =============\n\n", #ALLTESTS)
    local errors = {}
    for _, t in ipairs(ALLTESTS) do
        printf(format('- %s ... ', t.name))
        local ok, err = pcall(t.func)
        if ok then
            printf('ok\n')
        else
            printf('failed\n')
            errors[#errors + 1] = {
                name = t.name,
                err = err,
            }
        end
    end
    printf('\n==========================\n')
    printf('Result: %d/%d tests passed\n', #ALLTESTS - #errors, #ALLTESTS)
    print('')

    if #errors > 0 then
        printf('Errors: %d tests failed\n', #errors)
        printf('\n')
        for _, err in ipairs(errors) do
            printf('--- testcase.%s ---\n', err.name)
            print(err.err)
        end
        os.exit(1)
    end
end
