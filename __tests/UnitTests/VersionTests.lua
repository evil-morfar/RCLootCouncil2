local lu = require("luaunit")

require("__tests/wow_api")
require("__tests/__load_libs")
require("__tests/AddonLoader")
local isLocalRun = not ...

local Utils = RCLootCouncil.Utils

TestVersionBasics = {
   TestEqualVersions = function (args)
      local a = Utils:CheckOutdatedVersion("2.15.1", "2.15.1")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,
   TestEqualVersions2 = function (args)
      local a = Utils:CheckOutdatedVersion("2.15.0", "2.15.0")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,
   TestEqualVersions3 = function (args)
      local a = Utils:CheckOutdatedVersion("3.0.0", "3.0.0")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,
   TestEqualVersionsWithDefault = function (args)
      RCLootCouncil.version = "2.14.0"
      local a = Utils:CheckOutdatedVersion(nil, "2.14.0")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,

   TestBaseVersionNewest = function (args)
      local a = Utils:CheckOutdatedVersion("2.14.1", "2.14.0")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,
   TestBaseVersionNewest2 = function (args)
      local a = Utils:CheckOutdatedVersion("2.15.1", "2.14.6")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,

   TestOutdated = function (args)
      local a = Utils:CheckOutdatedVersion("2.14.1", "2.14.6")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[2])
   end,
   TestOutdated2 = function (args)
      local a = Utils:CheckOutdatedVersion("2.14.1", "2.15.0")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[2])
   end,
   TestOutdated3 = function (args)
      local a = Utils:CheckOutdatedVersion("2.14.1", "3.0.0")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[2])
   end,

   TesttVersionOutdated = function (args)
      local a = Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.2")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[3])
   end,

   TesttVersionMainOutdated = function (args)
      local a = Utils:CheckOutdatedVersion("2.0.0", "2.1.0", "Alpha.1", "Alpha.1")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,

   TesttVersionEqual = function (args)
      local a = Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.1")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,
   TesttVersionOtherOutdated = function (args)
      local a = Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.2", "Alpha.1")
      lu.assertEquals(a, RCLootCouncil.VER_CHECK_CODES[1])
   end,
}

if isLocalRun then
   os.exit(lu.LuaUnit.run("-o", "tap"))
end
