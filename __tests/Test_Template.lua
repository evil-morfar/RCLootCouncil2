--- Template for new tests.
-- Supports local run and with calls from other files.
-- Remember to import any non default things.
local lu = require("luaunit")

require("__tests/wow_api")
require("__tests/wow_item_api")
require("__tests/__load_libs")

local isLocalRun = false

if not RCLootCouncil then -- Local run
   RCLootCouncil = {}
   isLocalRun = true
   loadfile("__tests/RCLootCouncilMock.lua")("RCLootCouncil", RCLootCouncil)
end

-- LuaUnit tests:
Test_Template = {

}


-- Run tests
if isLocalRun then
   os.exit(lu.LuaUnit.run("-o", "tap"))
end
