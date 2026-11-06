--- TempTable.lua Class providing temporary/reuseable tables.
-- Heavily inspired by TSM's implementation.
-- @author Potdisc
-- Create date: 14/04/2020

--- @type RCLootCouncil
local addon = select(2, ...)
---@class Utils.TempTable
local TempTable = addon.Init("Utils.TempTable")
local Pool = addon.Require "Utils.Pool"


local NUM_TEMP_TABLES = 100
local RELEASED_TEMP_TABLE_MT = {
   __index = function()
      error("Attempt to read temp table after release", 2)
   end,
   __newindex = function()
      error("Attempt to index temp table after release", 2)
   end
}
local createdTables = 0
local private = {
   availableTables = Pool:New(function()
      if createdTables >= NUM_TEMP_TABLES then
         error("No TempTables available!", 2)
      end
      createdTables = createdTables + 1
      return setmetatable({}, RELEASED_TEMP_TABLE_MT)
   end),
   unavailableTables = table.create and table.create(NUM_TEMP_TABLES) or {},
}

-----------------------------------------------------------
-- Module Functions
-----------------------------------------------------------

--- Acquires a temporary table.
--- Temporary tables are recycled instead of creating new ones.
--- Should be used for tables with a short and defined life cycle.
--- @generic T
--- @vararg any @Any number of values to insert into the table (numerically).
--- @return TempTable @The temporary table.
function TempTable:Acquire (...)
   ---@class TempTable<T> : { [integer] : T}
   local t = private:GetTable()
   for i = 1, select("#", ...) do
      t[i] = select(i, ...)
   end
   return t
end

--- Releases a temporary table for recycling.
--- Don't access the table after calling this.
--- @param tbl TempTable The temporary table to release.
function TempTable:Release (tbl)
   private:Release(tbl)
end

--- Releases a TempTable and returns it's content.
--- @param tbl TempTable @The temporary table.
--- @return List<any> @The tables' contents.
function TempTable:UnpackAndRelease(tbl)
	return private:Release(tbl, unpack(tbl))
end

--- Releases a TempTable and returns it's concatenation
---@param tbl TempTable
---@param seperator string?
---@return string @The tables' concatenation
function TempTable:ConcatAndRelease(tbl, seperator)
	return private:Release(tbl, table.concat(tbl, seperator))
end

function TempTable:DumpAvailableTablesCount()
   local count = private:CountAvailableTables()
   addon.Log:F("<TempTable>", "Available tables:", count)
   return count
end
-----------------------------------------------------------
-- Private Functions
-----------------------------------------------------------

function private:GetTable ()
   local t = self.availableTables:Acquire()
   setmetatable(t, nil)
   self.unavailableTables[t] = true
   return t
end

function private:Release (tbl, ...)
   assert(self.unavailableTables[tbl], "Table already released!")
   self.unavailableTables[tbl] = nil
   wipe(tbl)
   setmetatable(tbl, RELEASED_TEMP_TABLE_MT)
   self.availableTables:Release(tbl)
   return ...
end

function private:CountAvailableTables()
   return self.availableTables.head
end


-----------------------------------------------------------
-- Init TempTables
-----------------------------------------------------------
do
   private.availableTables:Initialize(NUM_TEMP_TABLES)
end
