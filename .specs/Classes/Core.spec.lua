require "busted.runner"()

describe("#Core", function()
   local addon = {}
   before_each(function()
      loadfile(".specs/AddonLoader.lua")(nil, "addon", addon).LoadArray{
         "Classes/Core.lua"
      }
   end)

   describe("Init", function()
      it("should fail without proper path", function()
         assert.has.errors(function() addon.Init(1) end)
         assert.has.errors(function() addon.Init({}) end)
         assert.has.errors(function() addon.Init(function() end) end)
      end)

      it("should not be able to create modules more than once", function()
         local module = addon.Init("new module")
         assert.is.table(module)
         assert.has.errors(function() addon.Init("new module") end, "Module already exists for path: new module")
      end)
   end)

   describe("Require", function()
      it("should return correct module", function()
         local module = addon.Init("mod")
         local mod = addon.Require("mod")
         assert.are.same(module, mod)
      end)

      it("should fail for uncreated modules", function()
         assert.has.errors(function() addon.Require("mod") end, "Module doesn't exist for path: mod")
      end)

   end)
end)
