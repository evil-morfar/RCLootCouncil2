require "busted.runner"()
require "__tests.wow_api"

-- Init some variables
local logTable = {
    a = function(self, key,value)
      rawset(self, key, value)
   end
}
local addon_name, addon = "RCLootCouncil", {
   -- Mock db object
   db = {
      global = {
         log = setmetatable({}, {__newindex = function(self, k,v) logTable.a(self,k,v) end})
      }
   },
   -- Mock defaults
   defaults = {
      global = {
         logMaxEntries = 4000
      }
   }
}

loadfile("Classes/Core.lua")(addon_name, addon)
loadfile("Classes/Utils/Log.lua")(addon_name, addon)
addon:InitLogging()

describe("#Utils #Log initilizing", function()
   it("should create Log module", function()
      assert.has_no.errors(function() addon.Require("Utils.Log") end)
      assert.is_table(addon.Require("Utils.Log"))
   end)

   it("should have certain functions", function()
      local log = addon.Require("Utils.Log")
      assert.is.Function(log.New)
      assert.is.Function(log.Clear)
      assert.is.Function(log.Get)
   end)
end)

describe("#Utils #Log", function()
   local match = require "luassert.match"
   addon.Log = addon.Require("Utils.Log"):New()
   describe("addon.Log", function()
      it("when called should print", function()
         local s = spy.on(logTable, "a")
         addon.Log:d("Debug test") -- Needs one call to init
         assert.has_no.errors(function() addon.Log("addon.Log Test") end)
         assert.spy(s).was_called(1)
         addon.Log("addon.Log Test2")
         assert.spy(s).was_called(2)
      end)
   end)

   describe("Class", function()
      it("is protected", function()
         local log = addon.Require("Utils.Log"):New()
         assert.has.errors(function()
            log.newValue = 1
         end, "Log cannot be modified")
      end)

      it("should create", function()
         assert.is_not.Nil(addon.Log)
         local log = addon.Require("Utils.Log"):New("log")
         assert.are.equal("[log]", log.prefix)
         assert.is.Function(getmetatable(log).__call)
      end)

      it("should have log functions", function()
         local loga = addon.Require("Utils.Log"):New("loga")
         assert.is.Function(loga.m)
         assert.is.Function(loga.d)
         assert.is.Function(loga.e)
         assert.is.Function(loga.w)
         assert.is.Function(loga.p)
         assert.is.Function(loga.f)
         assert.is.Function(loga.D)
         assert.is.Function(loga.E)
         assert.is.Function(loga.W)
         assert.is.Function(loga.M)
         assert.is.Function(loga.P)
         assert.is.Function(loga.F)
      end)

      it("new classes should print", function()
         local s = spy.on(logTable, "a")
         local log = addon.Require("Utils.Log"):New("Test")
         log("print Test 1")
         assert.spy(logTable.a).was_called(1)
         assert.spy(s).was_called_with(match.is_table(), match.is_number(), match.is_string())
         log:m("print Test 2")
         assert.spy(s).was_called(2)
      end)

      it("all log functions should work", function()
         local s = mock(logTable)
         local log = addon.Require("Utils.Log"):New("Test")
         log("All functions test")
         log:m("Test")
         log:d("Test")
         log:e("Test")
         log:w("Test")
         log:p("Test")
         log:f("Test")
         log:D("Test")
         log:E("Test")
         log:W("Test")
         log:M("Test")
         log:P("Test")
         log:F("Test")
         assert.spy(s.a).was_called(13)
      end)

      it("Clear should clear the log", function()
         local numBeforeClear = #addon.db.global.log
         addon.Require("Utils.Log"):Clear()
         local numAfterClear = #addon.db.global.log
         assert.is_not.same(numBeforeClear, numAfterClear)
         assert.is.equal(0, numAfterClear)
      end)

      it("created Logs are different", function()
         local Log = addon.Require("Utils.Log")
         local loga = Log:New()
         local logb = Log:New()
         assert.are.same(loga, logb)
         assert.are_not.equal(loga, logb)
      end)
   end)

   describe("static log", function()
      local log = addon.Require("Utils.Log"):Get()
      it("should be truly static", function()
         local log2 = addon.Require("Utils.Log"):Get()
         assert.are.same(log, log2)
      end)
   end)

   insulate("with tVersion", function()
      addon.tVersion = "Alpha.1"
      it("should bump logMaxEntries", function()
         -- Reload files
         loadfile("Classes/Core.lua")(addon_name, addon)
         loadfile("Classes/Utils/Log.lua")(addon_name, addon)
         assert.is.equal(4000,addon.db.global.logMaxEntries)
      end)
   end)
end)
