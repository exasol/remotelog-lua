package.path = "?.lua;src/?.lua;" .. package.path

local trace = require("trace")
local luaunit = require("luaunit")
local mockagne = require("mockagne")

local when, any = mockagne.when, mockagne.any
local date_pattern = "%Y-%m-%d"

test_fallback = {}

function test_fallback:setUp()
    self.today = os.date(date_pattern)
    self.socket_mock = mockagne.getMock()
    self.tcp_mock = mockagne.getMock()
    self.client_mock = self.tcp_mock -- on connect(), the socket library promotes a TCP socket to a client socket
    when(self.socket_mock.tcp()).thenAnswer(self.tcp_mock)
    when(self.tcp_mock:connect(any(), any())).thenAnswer(false, "fake error") -- reject the connection
    when(self.socket_mock.gettime()).thenAnswer(1000000)
    package.preload["socket"] = function () return self.socket_mock end
    self.log = require("remotelog")
end

function test_fallback:tearDown()
    self.log.disconnect()
    package.loaded["socket"] = nil
    package.loaded["remotelog"] = nil
end

function test_fallback:test_fallback_to_console()
    local log = self.log
    log.init(date_pattern, false, self.log.FALLBACK_CONSOLE)
    log.set_client_name("Fallback-client")
    local arguments = trace.trace_print(log.connect, "localhost", 3000)
    luaunit.assertStrMatches(arguments, "Fallback%-client.*Caused by: fake error")
end

function test_fallback:test_fallback_discard()
    local log = self.log
    self.log.init(date_pattern, false, log.fallback_strategies.DISCARD)
    luaunit.assertNil(trace.trace_print(log.connect, "localhost", 3000))
end

function test_fallback:test_fallback_raise_error()
    local log = self.log
    self.log.init(date_pattern, false, log.fallback_strategies.ERROR)
    luaunit.assertErrorMsgContains("Unable to open socket connection to localhost:3000 for sending log messages",
        log.connect, "localhost", 3000)
end

function test_fallback:test_set_fallback_strategy()
    local log = self.log.init(date_pattern, false)
    log.set_fallback_strategy(log.fallback_strategies.ERROR)
    luaunit.assertError("Unable to open socket connection to localhost:3000 for sending log messages",
        log.connect, "localhost", 3000)
end

function test_fallback:test_fallback_on_info_message()
    local log = self.log
    log.init(date_pattern, false, self.log.FALLBACK_CONSOLE)
    log.connect("localhost", 3000)
    local arguments = trace.trace_print(log.info, "Catch me if you can!")
    luaunit.assertStrMatches(arguments, ".*%[INFO%].*Catch me if you can!")
end

os.exit(luaunit.LuaUnit.run())
