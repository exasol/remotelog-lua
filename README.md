# `remotelog` - Remote logging for Lua

## Overview

The `remotelog` is a Lua module that provides logging capabilities. While it supports regular logging to `STDOUT` too, 
it is mainly targeted at systems where a log receiver must be on a different machine, especially when debugging problems
in server processes.

The module is designed to be easily usable, compact and fast. It was originally created to allow remote logging from Lua
scripts running inside an [Exasol](https://www.exasol.com) database, but works in other context as well.

## In a Nutshell

The following snippet demonstrates basic remote logging. Check the [user guide](doc/user_guide/user_guide.md) for more details.

```lua
local log = require("remotelog")
log.connect("thehost.example.org", 3000)
log.info("Hello world.")
log.disconnect()
```

## Features

* Logging to `STDOUT`
* Logging to remote log receiver via a TCP socket
* Configurable automatic fallback in case socket connection cannot be established
* Log level control
* Configurable timestamp format
* Optional high-resolution timer

# Table of Contents

## Information for Users

* [User Guide](doc/user_guide/user_guide.md)
* [Changelog](doc/changes/changelog.md)

### Run Time Dependencies

`remotelog` requires Lua 5.1 or later.

| Dependency                               | Purpose                                                | License                       |
|------------------------------------------|--------------------------------------------------------|-------------------------------|
| [LuaSocket][luasocket]                   | Socket communication                                   | MIT License                   |

Note that LuaSucket is pre-installed on an Exasol database. For local unit testing you need to install it on the test machine though.

[luasocket]: http://w3.impa.br/~diego/software/luasocket/

### Test Dependencies

| Dependency                               | Purpose                                                | License                       |
|------------------------------------------|--------------------------------------------------------|-------------------------------|
| [luaunit][luaunit]                       | Unit testing framework                                 | BSD License                   |
| [Mockagne][mockagne]                     | Mocking framework                                      | MIT License                   |

[luaunit]: https://github.com/bluebird75/luaunit
[mockagne]: https://github.com/vertti/mockagne

### Build Dependencies

| Dependency                               | Purpose                                                | License                       |
|------------------------------------------|--------------------------------------------------------|-------------------------------|
| [LuaRocks][luarocks]                     | Package management                                     | MIT License                   |

[luarocks]: https://luarocks.org/