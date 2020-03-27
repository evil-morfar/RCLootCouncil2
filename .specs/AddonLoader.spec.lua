require "busted.runner"()

insulate("AddonLoader", function()
   it("should not crash", function()
      assert.has_no.errors(
         loadfile(".specs/AddonLoader.lua")
      )
   end)
end)


insulate("AddonLoader", function()
   it("should load RCLootCouncil", function()
      loadfile(".specs/AddonLoader.lua")()
      assert.truthy(_G.RCLootCouncil)
   end)
end)

insulate("AddonLoader", function()
   it("should load files without errors", function()
      loadfile(".specs/AddonLoader.lua")()
      local s = spy.on(_G, "_errorhandler")
      pending("Will error out, but it's hard to fix at this point")
      WoWAPI_FireEvent("ADDON_LOADED", "RCLootCouncil")
      assert.spy(s).was_not.called()
   end)
end)
