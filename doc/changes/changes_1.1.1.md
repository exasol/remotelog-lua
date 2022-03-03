# remotelog-lua 1.1.1, released 2022-03-03

Code name: Fix filtering of `trace` messages and support Lua 5.4

## Summary

Version 1.1.1 of `remotelog-lua` fixes a bug that caused `trace` messages always being logged, independent of the log level. Additionally it also supports Lua 5.4.

### Feature

* #18: Added support for Lua 5.4.

### Bugfixes

* #19: Fixed filtering of `trace` messages

## Dependency Updates

* Added `lua:5.4`
