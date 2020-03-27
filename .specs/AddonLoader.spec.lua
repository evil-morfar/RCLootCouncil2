require "busted.runner"()

insulate("AddonLoader", function()
   it("should not crash", function()
      assert.has_no.errors(function ()
         loadfile(".specs/AddonLoader.lua")()
      end)
   end)
end)


insulate("AddonLoader", function()
   it("should load RCLootCouncil", function()
      loadfile(".specs/AddonLoader.lua")()
      assert.truthy(_G.RCLootCouncil)
   end)
end)
