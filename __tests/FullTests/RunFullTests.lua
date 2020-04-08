require "luacov"
local lu = require("luaunit")
local path = ...

-- run tests
require("__tests/FullTests/History/ImportTests")


if not path then os.exit(lu.LuaUnit.run("-o", "tap")) end
