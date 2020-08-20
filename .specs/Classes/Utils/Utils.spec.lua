require "busted.runner"({["output"] = "gtest"})

dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")

local Utils

describe("#Utils :CheckOutdatedVersion", function()

   before_each(function()
      Utils = RCLootCouncil.Utils
   end)

   it("should exist", function()
      assert.is.Function(Utils.CheckOutdatedVersion)
   end)

   it("should not crash", function()
      assert.has_no.errors(function() Utils:CheckOutdatedVersion("","") end)
   end)

   it("should report equal version", function()
      local res = Utils:CheckOutdatedVersion("2.15.0","2.15.0")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
      res = Utils:CheckOutdatedVersion("2.15.1","2.15.1")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
      res = Utils:CheckOutdatedVersion("3.0.0","3.0.0")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
      res = Utils:CheckOutdatedVersion("999.999.999","999.999.999")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should default to addon version", function()
      RCLootCouncil.version = "2.14.0"
      assert.are.equal(Utils:CheckOutdatedVersion(nil, "2.14.0"), RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should report not-outdated versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.1", "2.14.0"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("2.15.1", "2.14.20"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("3.0.0", "2.14.20"), RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should report outdated versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "2.14.3"), RCLootCouncil.VER_CHECK_CODES[2])
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "2.15.1"), RCLootCouncil.VER_CHECK_CODES[2])
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "3.0.0"), RCLootCouncil.VER_CHECK_CODES[2])
   end)

   it("should handle test versions", function()
      assert.has_no.errors(function() Utils:CheckOutdatedVersion("2.0.0", "2.1.0", "Alpha.1", "Alpha.1") end)
   end)

   it("should handles outdated test versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.2"), RCLootCouncil.VER_CHECK_CODES[3])
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Beta.1"), RCLootCouncil.VER_CHECK_CODES[3])
   end)

   it("should handle non-outdated test versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.2", "Alpha.1"), RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should handle equal test versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.1"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("2.15.0", "2.15.0", "Alpha.1", "Alpha.1"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("2.15.0", "2.15.0", "Alpha.10", "Alpha.10"), RCLootCouncil.VER_CHECK_CODES[1])
   end)
end)
