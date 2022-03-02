package.path = "?.lua;src/?.lua;" .. package.path

local trace = require("trace")
local luaunit = require("luaunit")
local mockagne = require("mockagne")

local when, any = mockagne.when, mockagne.any
local date_pattern = "%d.%m.%Y"

test_console_log = {}

function test_console_log:setUp()
    self.today = os.date(date_pattern)
    self.socket_mock = mockagne.getMock()
    self.tcp_mock = mockagne.getMock()
    when(self.socket_mock.gettime()).thenAnswer(1000000)
    when(self.socket_mock.tcp()).thenAnswer(self.tcp_mock)
    when(self.tcp_mock:connect(any(), any())).thenAnswer(false, "Connection refused")
    package.preload["socket"] = function () return self.socket_mock end
    self.log = require("remotelog").init(date_pattern, false)
    self.log.set_client_name("Unit test console")
end

function test_console_log.tearDown()
    package.loaded["socket"] = nil
    package.loaded["remotelog"] = nil
end

local function assert_message(call, original_message, expected_message)
    local actual_message = trace.trace_print(call, original_message)
    luaunit.assertEquals(actual_message, expected_message)
end

local function assert_no_message(call)
    local actual_message = trace.trace_print(call, "This message is not sent.")
    luaunit.assertNil(actual_message)
end

function test_console_log:test_fatal()
    assert_message(self.log.fatal, "Good by, cruel world!", self.today .. " [FATAL]  Good by, cruel world!")
end

function test_console_log:test_fatal_exact_level()
    self.log.set_level("FATAL")
    assert_message(self.log.fatal, "Good by, cruel world!", self.today .. " [FATAL]  Good by, cruel world!")
end

function test_console_log:test_fatal_not_logged()
    self.log.set_level("NONE")
    assert_no_message(self.log.fatal)
end

function test_console_log:test_error()
    assert_message(self.log.error, "Oops!", self.today .. " [ERROR]  Oops!")
end

function test_console_log:test_error_exact_level()
    self.log.set_level("ERROR")
    assert_message(self.log.error, "Oops!", self.today .. " [ERROR]  Oops!")
end

function test_console_log:test_error_not_logged()
    self.log.set_level("FATAL")
    assert_no_message(self.log.error)
end

function test_console_log:test_warn()
    assert_message(self.log.warn, "This looks suspicious...", self.today .. " [WARN]   This looks suspicious...")
end

function test_console_log:test_warn_exact_level()
    self.log.set_level("WARN")
    assert_message(self.log.warn, "This looks suspicious...", self.today .. " [WARN]   This looks suspicious...")
end

function test_console_log:test_warn_not_logged()
    self.log.set_level("ERROR")
    assert_no_message(self.log.warn)
end

function test_console_log:test_info()
    assert_message(self.log.info, "Good to know.", self.today .. " [INFO]   Good to know.")
end

function test_console_log:test_info_exact_level()
    self.log.set_level("INFO")
    assert_message(self.log.info, "Good to know.", self.today .. " [INFO]   Good to know.")
end

function test_console_log:test_info_not_logged()
    self.log.set_level("WARN")
    assert_no_message(self.log.info)
end

function test_console_log:test_config()
    self.log.set_level("CONFIG")
    assert_message(self.log.config, "Life support enabled.", self.today .. " [CONFIG] Life support enabled.")
end

function test_console_log:test_config_not_logged()
    self.log.set_level("INFO")
    assert_no_message(self.log.config)
end

function test_console_log:test_debug()
    self.log.set_level("DEBUG")
    assert_message(self.log.debug, "Look what we have here.", self.today .. " [DEBUG]  Look what we have here.")
end

function test_console_log:test_debug_not_logged()
    self.log.set_level("INFO")
    assert_no_message(self.log.debug)
end

function test_console_log:test_trace()
    self.log.set_level("TRACE")
    assert_message(self.log.trace, "foo(bar)", self.today .. " [TRACE]  foo(bar)")
end

function test_console_log:test_trace_not_logged()
    self.log.set_level("DEBUG")
    assert_no_message(self.log.trace)
end

function test_console_log:test_set_log_level()
    self.log.set_level("WARN")
    assert_no_message(self.log.info)
    assert_message(self.log.warn, "send", self.today .. " [WARN]   send")
end

function test_console_log:test_logging_with_format_string()
    local formatted_message = trace.trace_print(self.log.info, '%s says "Mount Everest is %d meters high."', "Simon",
        8848)
    luaunit.assertEquals(formatted_message, self.today .. ' [INFO]   Simon says "Mount Everest is 8848 meters high."')
end

function test_console_log:test_set_level_to_illegal_value_results_in_warning()
    luaunit.assertEquals(trace.trace_print(self.log.set_level, "FOOBAR"),
        self.today .. ' [WARN]   W-LOG-1: Attempt to set illegal log level "FOOBAR". ' ..
        'Pick one of: NONE, FATAL, ERROR, WARN, INFO, CONFIG, DEBUG, TRACE. Falling back to level INFO.')
end

function test_console_log:test_unsetting_print_does_not_cause_error()
    local original_print = _G.print
    _G.print = nil
    self.log.error("This should be silently discarded without error.")
    _G.print = original_print
end

os.exit(luaunit.LuaUnit.run())
