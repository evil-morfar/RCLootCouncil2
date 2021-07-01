--- TempTable.lua Class providing temporary/reuseable tables.
-- Heavily inspired by TSM's implementation.
-- @author Potdisc
-- Create date: 14/04/2020

local _, addon = ...
---@class Utils.TempTable
local TempTable = addon.Init("Utils.TempTable")

local private = {
   availableTables = {},
   unavailableTables = {}
}
local head = 0
local NUM_TEMP_TABLES = 100
local RELEASED_TEMP_TABLE_MT = {
   __index = function()
      error("Attempt to read temp table after release", 2)
   end,
   __newindex = function()
      error("Attempt to index temp table after release", 2)
   end
}

-----------------------------------------------------------
-- Module Functions
-----------------------------------------------------------

--- Acquires a temporary table.
--- Temporary tables are recycled instead of creating new ones.
--- Should be used for tables with a short and defined life cycle.
--- @vararg any @Any number of values to insert into the table (numerically).
--- @return TempTable @The temporary table.
function TempTable:Acquire (...)
   ---@class TempTable : table
   local t = private:GetTable()
   for i = 1, select("#", ...) do
      t[i] = select(i, ...)
   end
   return t
end

--- Releases a temporary table for recycling.
--- Don't access the table after calling this.
--- @param tbl TempTable The temorary table to release.
function TempTable:Release (tbl)
   private:Release(tbl)
end

--- Releases a TempTable and returns it's content.
--- @param tbl TempTable @The temporary table.
--- @return List<any> @The tables' contents.
function TempTable:UnpackAndRelease (tbl)
   return private:Release(tbl, unpack(tbl))
end

function TempTable:DumpAvailableTablesCount()
   local count = private:CountAvailableTables()
   addon.Log:F("<TempTable>", "Available tables:", count)
end
-----------------------------------------------------------
-- Private Functions
-----------------------------------------------------------

function private:GetTable ()
   assert(head > 0, "No TempTables available!")
   local t = self.availableTables[head]
   setmetatable(t, nil)
   self.unavailableTables[t] = true
   head = head - 1
   return t
end

function private:Release (tbl, ...)
   assert(self.unavailableTables[tbl], "Table already released!")
   self.unavailableTables[tbl] = nil
   head = head + 1
   wipe(tbl)
   setmetatable(tbl, RELEASED_TEMP_TABLE_MT)
   self.availableTables[head] = tbl
   return ...
end

function private:CountAvailableTables()
   local count = 0
   for _ in pairs(self.availableTables) do
      count = count + 1
   end
   return count
end


-----------------------------------------------------------
-- Init TempTables
-----------------------------------------------------------
do
   for i = 1, NUM_TEMP_TABLES do
      private.availableTables[i] = setmetatable({}, RELEASED_TEMP_TABLE_MT)
   end
   head = NUM_TEMP_TABLES
end
