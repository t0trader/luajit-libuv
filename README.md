luajit-libuv
============

Status: *work in progress, just got started*

This project provides a [Luajit FFI] binding for the [libuv] library, which
powers the async I/O behind [Node.js] and others. In contrast to [luv], it
relies on Lua coroutines to generate provide asynchronous I/O behavior with
synchronous syntax.

The API is a thin wrapper around `libuv`. It frequently returns the `libuv` structs themselves with additional methods attached via `ffi.metatype`.

Usage
-----

```lua
local uv = require 'uv'

uv.run(function()
  local file = uv.fs():open('README.md')
  repeat
    local chunk = file:read()
    print(chunk)
  until chunk == ''
  file:close()
end)
```

Installation
------------

```bash
brew install libuv
git clone git@github.com:pguillory/luajit-libuv.git
cd luajit-libuv
make
LUA_PATH="src/?.lua;;" luajit examples/read_file.lua 
```

There's no `make install` yet.

[Luajit FFI]: http://luajit.org/ext_ffi.html
[libuv]: https://github.com/joyent/libuv
[Node.js]: http://nodejs.org/
[luv]: https://github.com/creationix/luv
