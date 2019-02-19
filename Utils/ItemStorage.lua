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
   ["temp"]        = true, -- Items we're temporarily storing
   ["other"]       = true, -- Unspecified
}

-- Item Class:
local item_class = {
   type = "other", -- Default to unspecified
   time_remaining = 0, -- NOTE For now I rely on this not being updated for timeout checks. It should be precise enough, but needs testing
   time_added = 0,
   exists = false,
   link = "",
   args = {}, -- User args

   Store = function(self)
      tinsert(db.itemStorage, self)
   end,
   Unstore = function(self)
      tDeleteItem(db.itemStorage, self)
   end,
}

-- lua
local error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable, CopyTable, tDeleteItem, ipairs
    = error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable, CopyTable, tDeleteItem, ipairs

-- GLOBALS: GetContainerNumSlots, GetContainerItemLink, _G

function addon:InitItemStorage()-- Extract items from our SV. Could be more elegant
   db = self:Getdb()
   local Item;
   for k, v in ipairs(db.itemStorage) do
      Item = Storage:StoreItem(v.link, v.type, "restored", v)
      if not Item.exists then -- Item probably no longer exists?
         addon:Debug("Error - ItemStorage, couldn't add db item:", v.link)
         local key = FindInTableIf(db.itemStorage, function(d) return addon:ItemIsItem(v.link, d.link) end)
         if key then
            tremove(db.itemStorage, key)
         else
            addon:Debug("Error - Unable to remove item from db?!")
         end
      end
   end
end

local function findItemInBags(link)
   addon:DebugLog("Storage: searching for item:",link)
   if link and link ~= "" then
      local c,s,t
      for container=0, _G.NUM_BAG_SLOTS do
   		for slot=1, GetContainerNumSlots(container) or 0 do
            if addon:ItemIsItem(link, GetContainerItemLink(container, slot)) then
               -- We found it
               c, s = container, slot
               -- Now we need to ensure we don't have multiple of it
               addon:DebugLog("Found item at",container, slot)
               t = addon:GetContainerItemTradeTimeRemaining(c,s)
               if t > 0 then
                  -- if the item is tradeable, then we've most likely just received it, and can safely return
                  return c,s,t
               end
            end
         end
      end
      return c,s,t
   end
   addon:DebugLog("Error - Couldn't find item")
end

local function newItem(link, type, time_remaining)
   local Item = setmetatable({}, {
      __index = item_class,
      __tostring = function(self)
         return self.link
      end,
   })
   Item.link = link
   Item.type = type and type or Item.type
   Item.time_remaining = time_remaining and time_remaining or Item.time_remaining
   Item.time_added = time()
   return Item
end


--- Initiates a new item of item_class
-- @param item ItemLink|ItemString|ItemID of the item
-- @param type Optional type for used in various functions, @see Storage.AcceptedTypes
-- @param ... Userdata stored in the returned 'Item.args'. Directly stored if provided as table, otherwise as '{...}'.
-- @returns Item @see 'item_class' when the item is stored succesfully. Has flag Item.exists if present in bags.
function Storage:New(item, typex, ...)
   if not typex then typex = "other" end
   if not self.AcceptedTypes[typex] then error("Type: " .. tostring(typex) .. " is not accepted. Accepted types are: " .. table.concat(self.AcceptedTypes, ", "),2) end
   addon:Debug("Storage:New",item,typex,...)
   local c,s,time_remaining = findItemInBags(item)
   local Item
   if not (c and s) then
      -- The Item is not in our bags
      Item = newItem(item, typex)
   else
      Item = newItem(item, typex, time_remaining)
      Item.exists = true -- The item is in our bags
   end
   if select(1, ...) == "restored" then -- Special case, gets stored
      local OldItem = select(2, ...)
      Item.time_added = OldItem.time_added -- Restore original time added
      Item.args = OldItem.args
      Item:Store()
   else
      Item.args = type(...) == "table" and ... or {...}
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
         tremove(db.itemStorage, i)
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

--- Returns Container and Slot ids of an item.
-- @param item The item to find slots for, either 'Item' object or ItemLink.
-- @return container,slot,time_remaining The position of the item in the player's bags and it's remaining trade time (if present).
function Storage:GetItemContainerSlot (item)
   if type(item) == "table" then -- Our Item object
      return findItemInBags(item.link)
   elseif type(item) == "string" then
      return findItemInBags(item)
   end
end
