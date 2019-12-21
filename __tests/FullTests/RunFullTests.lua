require "luacov"
local lu = require("luaunit")
local path = ...

require("__tests/wow_api")
require("__tests/wow_item_api")
require("__tests/__load_libs")
if not path then -- local run
   RCLootCouncil = {}
   loadfile("__tests/RCLootCouncilMock.lua")("RCLootCouncil", RCLootCouncil)
end

-- run tests
dofile("__tests/FullTests/History/ImportTests.lua")


if not path then os.exit(lu.LuaUnit.run("-o", "tap")) end
