# User Guide `exasollog`

The `exasollog` is a Lua module that provides logging capabilities. While it supports regular logging to `STDOUT` too, 
it is mainly targeted at systems where a log receiver must be on a different machine, especially when debugging problems
in server processes.

The module is designed to be easily usable, compact and fast. It was originally created to allow remote logging from Lua
scripts running inside an [Exasol](https://www.exasol.com) database, but works in other context as well.

## Installing `exasollog` on a Regular Machine

On a developer machine or any host that has a standard Lua setup, installing the module is straight forward. You install it like any other Lua module.

`exasollog` is available on [GitHub](https://www.github.com/exasol/log-lua) or as a [LuaRocks](https://luarocks.org/) package.

The module is 100% native Lua code in a single file, so the source code is at the same time the actual module.

To install the package via LuaRocks, issue the following command:

```bash
luarocks install exasollog
```

## Embedding `exasollog` into Exasol Lua Scripts

Up to and including Exasol Version 7, the embedded Lua has no access to the filesystem on the Exasol cluster. This rules out installation via LuaRocks on the cluster.

Instead we recommend to directly bundle the module into your Lua scripts before you install them using [`amalg`](https://github.com/siffiejoe/lua-amalg/) (as [LuaRocks package](https://luarocks.org/modules/siffiejoe/amalg)). Check the [README](https://github.com/siffiejoe/lua-amalg/blob/master/README.md) for instructions on how to use `amalg`.

In order to be able to use embedded packages on Exasol, you need to start your script with the following loader code:

```lua
table.insert(package.loaders,
    function (module_name)
        local loader = package.preload[module_name]
        if not loader then
            error("F-ML-1: Module " .. module_name .. " not found in package.preload.")
        else
            return loader
        end
    end
)
```

## Using `exasollog`

### Loading the Module

The first thing you need is obviously a `require` instruction. In the simplest possible case, that is:

```lua
local log = require("exasollog")
```

### Configuring `exasollog`

There are two ways to configure the module. One is regular configuration through setters.

The other one is through an `init()` function. You will rarely ever need the second one. It is intended for one-time settings and mainly exists to make unit testing easier. You can control the timestamp pattern and use of the high-resolution timer through `init()`.

While this is optional, we recommend using `set_client_name()` before your first log message, so that you get nice environment information at the beginning of each log. The client name should identify the application that uses the log and it's version number. But you could also write any other environment information into it that you want to appear right in front of the log.

```lua
log.set_client_name("my-script 1.3.0")
```

`exasollog` supports the following log levels:

<dl>
<dt>NONE</dt><dd>no log entries are generated on this level.</dd>
<dt>FATAL</dt><dd>should be used for in cases of errors that require immediate program termination.</dd>
<dt>ERROR</dt><dd>is best used in cases where the calling code should be given a chance to deal with the error or at least clean up before termination.</dd>
<dt>WARN</dt><dd>stands for situations that don't have an immediate adverse effect, but might cause an error later.</dd>
<dt>INFO</dt><dd>is for sparse log information that you want to appear in a standard log. This is also the default log level.</dd>
<dt>CONFIG</dt><dd>should be used to log parameters and environment of the client.</dd>
<dt>DEBUG</dt><dd>is targeted at developers when trying to analyze problems.</dd>
<dt>TRACE</dt><dd>is showing details of internal state.</dd>
</dl>

You can change the log level with the function `set_level()`:

```lua
log.set_level("DEBUG")
```

### Writing log Messages

Writing log messages is as easy as it gets:

```lua
log.debug("Initialization complete.")
```

If your provide more than one parameter, `exsollog` will interpret the first one as a format string (see [`string.format()`](https://www.lua.org/manual/5.1/manual.html#pdf-string.format) from the Lua standard library). All other parameters are then taken as values for the placeholders inside that string.

```lua
log.debug("Finished task '%s' after %07.3dms", task_name, elapsed_time)
```

### Connecting to a Remote log Receiver

The most important part of `exasollog` is that it supports remote logging. Using that feature is trivial.

To try it out, first start a socket listener on a remote machine, for example using `netcat` on port 3000:

```bash
nc -lkp 3000
```

Lets assume the remote machines IP address is `10.0.0.1` and the host name is `earth.example.org`.

Now before the first log message connect the logger to that listener.

```lua
log.connect("10.0.0.1:3000")
```

or

```lua
log.connect("earth.example.org:3000")
```

That's it. If the connection cannot be established, the logger falls back to console logging.

Additionally console logging checks whether the global `print()` function really exists. In case it doesn't, the log entries are discarded. This ensures that a program using `exasollog` and falling back to console logging still works even if the Lua environment does not support writing to `STDOUT` (like on an Exasol database).

Don't forget to close the connection before you terminate your program:

```lua
log.disconnect()
```