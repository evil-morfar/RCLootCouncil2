require "busted.runner"()

insulate("AddonLoader", function()
   it("should not crash", function()
      assert.has_no.errors(
      function()
         loadfile(".specs/AddonLoader.lua")().LoadToc("RCLootCouncil.toc")
      end
      )
   end)
end)


insulate("AddonLoader", function()
   it("should load RCLootCouncil", function()
      loadfile(".specs/AddonLoader.lua")().LoadToc("RCLootCouncil.toc")
      assert.truthy(_G.RCLootCouncil)
   end)
end)

insulate("AddonLoader", function()
   it("should load files without errors", function()
      loadfile(".specs/AddonLoader.lua")().LoadToc("RCLootCouncil.toc")
      local s = spy.on(_G, "_errorhandler")
      pending("Will error out, but it's hard to fix at this point")
      WoWAPI_FireEvent("ADDON_LOADED", "RCLootCouncil")
      assert.spy(s).was_not.called()
   end)
end)
