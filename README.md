# lua-argexpected

[![test](https://github.com/mah0x211/lua-argexpected/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-argexpected/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-argexpected/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-argexpected)

Helper module to check arguments.


## Installation

```sh
luarocks install argexpected
```

## Usage

```lua
local argexpected = require('argexpected')

--- @param a string
--- @param b number
local function foo(a, b)
    argexpected(type(a) == 'string', 1, 'string expected, got %s', type(a))
    argexpected(type(b) == 'number', 2, 'number expected, got %s', type(b))
end

-- following call will throw an error
--  bad argument #2 to 'foo' (number expected, got string)
foo('hello', 'world') 
```

## argexpected(cond, idx, extramsg, ...)

Checks whether `cond` is `true`. If it is not, raises an error reporting a problem with extramsg as a comment:

```
bad argument #<idx> to 'funcname' (<extramsg>)
```

**Parameters**

- `cond:boolean`: if `true`, does nothing, otherwise raises an error with the message described above.
- `idx:number`: index of the argument.
- `extramsg:string`: extra message to be shown in the error message.
- `...`: arguments to be passed to `string.format` to format `extramsg`.


## License

MIT


