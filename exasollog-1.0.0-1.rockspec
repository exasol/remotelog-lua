package = "exasollog"
version = "1.0.0-1"
rockspec_format = "3.0"
source = {url = 'https://github.com/exasol/log-lua/releases/download/1.0.0/rock-exasollog-1.0.0.zip'}

description = {
    summary = "(Remote) logging for Exasol and other Lua contexts",
    detailed = [[`exasollog` provides a logger for Lua that can log message to a remote log receiver listening on a TCP
    port of a host reachable from the machine producing the log entries.
    
    It can also be used for simple console logging. If the connection cannot be established, the log automatically
    falls back to STDOUT (in some cases this will at least let the messages appear in a local log file).
     
    `exasollog` depends on [CSJON](https://github.com/openresty/lua-cjson) (MIT license). Note that on an Exasol
    cluster CJSON is pre-installed.

    You can find the [user guide](https://github.com/exasol/log-lua/blob/master/doc/user-guide/user-guide.md) in the
    projects GitHub repository.]],
    homepage = "https://github.com/exasol/log-lua",
    license = "MIT",
    maintainer = 'Exasol <opensource@exasol.com>'
}

dependencies = {"lua >= 5.1", "lua < 5.4", "luasocket > 2.0.2-6"}

build_dependencies = {"luaunit >= 3.3-1", "mockagne >= 1.0-1 "}

build = {
    type = "builtin",
    modules = {exasollog = "src/exasollog.lua"},
    copy_directories = { "doc", "test" }
}
