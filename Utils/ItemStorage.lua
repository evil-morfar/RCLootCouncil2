--- ItemStorage.lua Class mock for handling stored items
-- Creates 'RCLootCouncil.ItemStorage' as a namespace for storage functions.
-- @author Potdisc
-- Create Date : 29/5/2018 18:28:51

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local db = addon:Getdb()
local Storage = {}
addon.ItemStorage = Storage

local StoredItems = {}

Storage.AcceptedTypes = {
   ["to_trade"]    = true, -- Items that should be traded to another player
   ["award_later"] = true, -- Items that should be used in a later session
   ["other"]       = true, -- Unspecified
}

local item_prototype = {
   type = "other", -- Default to unspecified
   time_remaining = 0, -- NOTE For now I rely on this not being updated for timeout checks. It should be precise enough, but needs testing
   time_added = 0,
   link = "",
   args = {}, -- User args
}

local item_methods = {
   GetTimeRemaining = function(self)
      return self.time_remaining
   end,
}
-- lua
local error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable, CopyTable, tDeleteItem, ipairs
    = error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable, CopyTable, tDeleteItem, ipairs

-- GLOBALS: GetContainerNumSlots, GetContainerItemLink, _G

function addon:InitItemStorage()-- Extract items from our SV. Could be more elegant
   db = self:Getdb()
   for k, v in ipairs(db.itemStorage) do
      Storage:StoreItem(v.link, v.type, "restored", v)
   end
end

local function findItemInBags(link)
   addon:DebugLog("Storage: searching for item:",link)
   if link and link ~= "" then
      for container=0, _G.NUM_BAG_SLOTS do
   		for slot=1, GetContainerNumSlots(container) or 0 do
            if addon:ItemIsItem(link, GetContainerItemLink(container, slot)) then
               addon:DebugLog("Found item at",container, slot)
               return container, slot
            end
         end
      end
   end
   addon:DebugLog("Error - Couldn't find item")
end

local function newItem(link, type, time_remaining)
   local Item = setmetatable({}, item_prototype)
   Item.link = link
   Item.type = type and type or Item.type
   Item.time_remaining = time_remaining and time_remaining or Item.time_remaining
   Item.time_added = time()
   return Item
end

--- Pesistantly store an item
-- Item is stored in Ace3 db and an internal db for future use. The internal item object is returned
-- @param item ItemLink|ItemString|ItemID of the item
-- @param type The storage type. Used for different handlers, @see Storage.AcceptedTypes
-- @param ... Userdata stored in the returned 'Item.args'. Directly stored if provided as table, otherwise as '{...}'.
-- @returns Item @see 'item_prototype' when the item is stored succesfully.
function Storage:StoreItem(item, typex, ...)
   if not typex then typex = "other" end
   if not self.AcceptedTypes[typex] then error("Type: " .. tostring(typex) .. " is not accepted. Accepted types are: " .. table.concat(self.AcceptedTypes, ", "),2) end
   addon:Debug("Storage:StoreItem",item,typex,...)
   local c,s = findItemInBags(item)
   if not (c and s) then
      -- IDEA Throw error?
      addon:Debug("Error - Unable to store item")
      return
   end
   local time_remaining = addon:GetContainerItemTradeTimeRemaining(c,s)
   local Item = newItem(item, typex, time_remaining)
   if select(1, ...) == "restored" then
      local OldItem = select(2, ...)
      Item.time_added = OldItem.time_added -- Restore original time added
      Item.args = OldItem.args
   else -- We need to store it in db as well
      Item.args = type(...) == "table" and ... or {...}
      tinsert(db.itemStorage, Item)
   end
   tinsert(StoredItems, Item)
   return Item
end

--- Remove an item from storage
-- @param item Either an itemlink (@see GetItemInfo) or the Item object returned by :StoreItem
-- @return True if successful
function Storage:RemoveItem(item)
   addon:Debug("Storage:RemoveItem", item)
   if type(item) == "table" then -- Our Item object
      if StoredItems[item] and db.itemStorage[item] then
         tDeleteItem(StoredItems, item)
         tDeleteItem(db.itemStorage, item)
         return true
      else -- Item didn't exist, try to extract itemlink
         return self:RemoveItem(item.link)
      end
   elseif type(item) == "string" then -- item link (hopefully)
      local key = FindInTableIf(StoredItems, function(v) return addon:ItemIsItem(v.link,item) end)
      if key then
         tremove(StoredItems, key)
         tremove(db.itemStorage, key)
         return true
      end
   end
   addon:Debug("Error - Couldn't remove item")
end

--- Removes all items of a specific type
-- @param type The type to remove - @see Storage.AcceptedTypes
function Storage:RemoveAllItemsOfType(type)
   type = type or "other"
   -- Do it in reverse for speed
   for i = #StoredItems, 1, -1 do
      if StoredItems[i].type == type then
         -- REVIEW Are we really guaranteed to have the same index in both tables?
         tremove(StoredItems, i)
         tremove(db.itemStorage)
      end
   end
end

--- Returns a numerical indexed table of all the stored items
-- Note: Each value in this table is the item object itself.
-- @return A copy of all stored items
function Storage:GetAllItems()
   return CopyTable(StoredItems)
end

--- Returns a specific item object
-- @param item ItemLink (@see GetItemInfo)
-- @return The Item object, or nil if not found
function Storage:GetItem(item)
   if type(item) ~= "string" then return error("'item' is not a string/ItemLink", 2) end
   return select(2, FindInTableIf(StoredItems, function(v) return addon:ItemIsItem(v.link, item) end))
end

--- Returns all stored Items of a specific type
-- @param type The item type, @see Storage.AcceptedTypes. Defaults to "other".
-- @return An Item table
function Storage:GetAllItemsOfType(type)
   type = type or "other"
   return tFilter(StoredItems,
      function(v)
         return v.type == type
      end, true)
end

--- Returns all stored Items with less/equal time remaining
-- @param time Seconds to check for (defaults to 0)
-- @return An Item table consisting of items with less or equal, time remaining than 'time'.
function Storage:GetAllItemsLessTimeRemaining(time)
   time = time or 0
   return tFilter(StoredItems,
      function(v)
         return v.time_remaining <= time
      end, true)
end

--- Returns all stored Items based on multiple predicates
-- @param ... Predicate functions.
-- @return The filtered list of times.
function Storage:GetAllItemsMultiPred(...)
   local vararg = ...
   return tFilter(StoredItems,
      function(v)
         for i = 1, select("#", vararg) do
            if not select(i, vararg)(v) then return false end
         end
         return true
      end, true)
end

--- Returns Container and Slot ids of the item.
-- @param item The item to find slots for, either 'Item' object or ItemLink.
-- @return container,slot The position of the item in the player's bags.
function Storage:GetItemContainerSlot (item)
   if type(item) == "table" then -- Our Item object
      return findItemInBags(item.link)
   elseif type(item) == "string" then
      return findItemInBags(item)
   end
end
