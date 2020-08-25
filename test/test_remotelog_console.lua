local luaunit = require("luaunit")
local mockagne = require("mockagne")

local when, verify, any = mockagne.when, mockagne.verify, mockagne.any
local date_pattern = "%d.%m.%Y"

test_log = {}

local last_message
local original_print = _G.print

local function print_spy(...)
    last_message = select(1, ...)
    original_print(...)
end

_G.print = print_spy

function test_log:setUp()
    self.today = os.date(date_pattern)
    self.socket_mock = mockagne.getMock()
    self.tcp_mock = mockagne.getMock()
    when(self.socket_mock.gettime()).thenAnswer(1000000)
    package.preload["socket"] = function () return self.socket_mock end
    self.log = require("remotelog").init(date_pattern, false)
    self.log.set_client_name("Unit test console")
end

function test_log:tearDown()
    package.loaded["socket"] = nil
    package.loaded["remotelog"] = nil
end

function test_log:assert_message(message)
    luaunit.assertEquals(message, last_message)
end

function test_log:assert_no_message()
    local actual = last_message
    last_message = nil
    luaunit.assertNil(last_message)
end

function test_log:test_fatal()
    self.log.fatal("Good by, cruel world!")
    self:assert_message(self.today .. " [FATAL]  Good by, cruel world!")
end

function test_log:test_error()
    self.log.error("Oops!")
    self:assert_message(self.today .. " [ERROR]  Oops!")
end

function test_log:test_warn()
    self.log.warn("This looks suspicious...")
    self:assert_message(self.today .. " [WARN]   This looks suspicious...")
end

function test_log:test_info()
    self.log.info("Good to know.")
    self:assert_message(self.today .. " [INFO]   Good to know.")
end

function test_log:test_config()
    self.log.set_level("CONFIG")
    self.log.config("Life support enabled.")
    self:assert_message(self.today .. " [CONFIG] Life support enabled.")
end

function test_log:test_debug()
    self.log.set_level("DEBUG")
    self.log.debug("Look what we have here.")
    self:assert_message(self.today .. " [DEBUG]  Look what we have here.")
end

function test_log:test_trace()
    self.log.set_level("TRACE")
    self.log.trace("foo(bar)")
    self:assert_message(self.today .. " [TRACE]  foo(bar)")
end

function test_log:test_set_log_level()
    self.log.set_level("WARN")
    self.log.info("don't send")
    self:assert_no_message()
    self.log.warn("send")
    self:assert_message(self.today .. " [WARN]   send")
end

function test_log:test_logging_with_format_string()
    self.log.info('%s says "Mount Everest is %d meters high."', "Simon", 8848)
    self:assert_message(self.today .. ' [INFO]   Simon says "Mount Everest is 8848 meters high."')
end

function test_log:test_set_level_to_illegal_value_throws_error()
    self.log.set_level("FOOBAR")
    self:assert_message(self.today .. ' [WARN]   W-LOG-1: Attempt to set illegal log level "FOOBAR". ' ..
        'Pick one of: NONE, FATAL, ERROR, WARN, INFO, CONFIG, DEBUG, TRACE. Falling back to level INFO.')
end

os.exit(luaunit.LuaUnit.run())
