--- Template for new tests.
-- Supports local run and with calls from other files.
-- Remember to import any non default things.
local lu = require("luaunit")
local isLocalRun = not ...

require("__tests/wow_api")
require("__tests/wow_item_api")
require("__tests/__load_libs")
require("__tests/AddonLoader")

-- LuaUnit tests:
Test_Template = {

}

-- Run tests
if isLocalRun then
   -- luacov: disable
   os.exit(lu.LuaUnit.run("-o", "tap"))
   -- luacov: enable
end
