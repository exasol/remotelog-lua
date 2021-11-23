# remotelog-lua 1.0.0, released 2020-08-26

## Summary

In this first release of remotelog, we added all features to have a functional equivalent in Lua to the existing
remote logging for Exasol in Java: logging via TCP socket and fallback to `STDOUT`, log level control, proper
timestamps and so on.

### Features

* Logging to `STDOUT`
* Logging to remote log receiver via a TCP socket
* Automatic fallback in case socket connection cannot be established
* Log level control
* Configurable timestamp format
* Optional high-resolution timer

## Dependency Updates

* Added `Mockagne:1.0-1` (or newer)
* Added `lua:5.1` to `lua:5.4`
* Added `LuaSocket:2.0.2-6` (or newer)
* Added `luauint:3.3-1` (or newer)