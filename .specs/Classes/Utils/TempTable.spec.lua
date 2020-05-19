require "busted.runner"()
require "__tests/wow_api"
-----------------------------------------------------------
-- Setup
-----------------------------------------------------------
local addon_name, addon = "RCLootCouncil", {}
loadfile("Classes/Core.lua")(addon_name, addon)
loadfile("Classes/Utils/TempTable.lua")(addon_name, addon)

-----------------------------------------------------------
-- Tests
-----------------------------------------------------------
describe("#Utils #TempTable", function()
   local TempTable = addon.Require("Utils.TempTable")

   it("should give a table", function()
      local t = TempTable:Acquire()
      assert.is_table(t)
      TempTable:Release(t)
   end)

   it("should insert provided arguments", function()
      local t = TempTable:Acquire(1,2, "3", {}, function() end)
      assert.is_table(t)
      assert.equals(5, #t)
      assert.is_number(t[1])
      assert.is_number(t[2])
      assert.is_string(t[3])
      assert.is_table(t[4])
      assert.is_function(t[5])
      TempTable:Release(t)
   end)

   it("should release a table", function()
      local t = TempTable.Acquire()
      TempTable:Release(t)
      assert.has_error(function() return t[1] end, "Attempt to read temp table after release")
      assert.has_error(function() t[6] = "test" end, "Attempt to index temp table after release")
      assert.equals(0, #t)
   end)

   it("UnpackAndRelease should return the content and release the table", function()
      local t = TempTable:Acquire(1,2,"3")
      local res = {TempTable:UnpackAndRelease(t)}
      assert.same({1,2,"3"}, res)
      assert.has_error(function() return t[1] end) -- Is released
   end)
end)

describe("#Utils #TempTable limits", function()
   local TempTable = addon.Require("Utils.TempTable")
   it("has a fixed amount of tables available", function()
      local t = {}
      for i = 1, 100 do
         t[i] = TempTable.Acquire()
      end
      assert.has_error(TempTable.Acquire, "No TempTables available!")
      TempTable:Release(t[100])
      -- one more avaiable
      assert.has_no_errors(TempTable.Acquire)
      assert.has_error(TempTable.Acquire, "No TempTables available!")
      for _,v in ipairs(t) do
         TempTable:Release(v)
      end
   end)

   it("can only be released once", function()
      local t = TempTable.Acquire()
      TempTable:Release(t)
      assert.has_error(function ()
         TempTable:Release(t)
      end, "Table already released!")
   end)
end)
