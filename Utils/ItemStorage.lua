--- ItemStorage.lua Class mock for handling stored items
-- @author Potdisc
-- Create Date : 29/5/2018 18:28:51

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local db = addon:Getdb()
local Storage = {}
addon.ItemStorage = Storage

local StoredItems = {}

Storage.AcceptedTypes = {
   "to_trade",    -- Items that should be traded to another player
   "award_later", -- Items that should be used in a later session
   "other",       -- Unspecified
}

local item_prototype = {
   type = "other", -- Default to unspecified
   time_remaining = 0,
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
local error, table, tostring, tinsert, tremove, type, select, FindInTableIf, GetTime, tFilter
    = error, table, tostring, tinsert, tremove, type, select, FindInTableIf, GetTime, tFilter


do -- Extract items from our SV to
   for k, v in ipairs(db.itemStorage) do
      Storage:StoreItem(v.link, v.type, "restored", v)
   end
end

local function findItemInBags(link)
   addon:DebugLog("Storage: searching for item:",link)
   if link and link ~= "" then
      for container=0, NUM_BAG_SLOTS do
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
   Item.time_added = GetTime()
   return Item
end

--- Pesistantly store an item
-- Item is stored in Ace3 db and an internal db for future use. The internal item object is returned
-- @param item ItemLink|ItemString|ItemID of the item
-- @param type The storage type. Used for different handlers, @see Storage.AcceptedTypes
-- @param ... Userdata stored in the returned 'Item.args'
-- @returns Item @see 'item_prototype' when the item is stored succesfully.
function Storage:StoreItem(item, type, ...)
   if not type then type = "other" end
   if not self.AcceptedTypes[type] then error("Type: " .. tostring(type) .. " is not accepted. Accepted types are: " .. table.concat(self.AcceptedTypes, ", "),2) end
   addon:Debug("Storage:StoreItem",item,type,...)
   local c,s = findItemInBags(item)
   if not (c and s) then
      -- IDEA Throw error?
      addon:Debug("Error - Unable to store item")
      return
   end
   local time_remaining = addon:GetContainerItemTradeTimeRemaining(c,s)
   local Item = newItem(item, type, time_remaining)
   if select(1, ...) == "restored" then
      local OldItem = select(2, ...)
      Item.time_added = OldItem.time_added -- Restore original time added
      Item.args = OldItem.args
   else -- We need to store it in db as well
      Item.args = ...
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
         tremove(StoredItems, item)
         tremove(db.itemStorage, item)
         return true
      else -- Item didn't exist, try to extract itemlink
         return self:RemoveItem(item.link)
      end
   elseif type(item) == "string" then -- item link (hopefully)
      local key = FindInTableIf(StoredItems, function(v) return v.link == item end)
      if key then
         tremove(StoredItems, key)
         tremove(db.itemStorage, key)
         return true
      end
   end
   addon:Debug("Error - Couldn't remove item")
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
   return select(2, FindInTableIf(StoredItems, function(v) return v == item end))
end

--- Returns all stored Items of a specific type
-- @param type The item type, @see Storage.AcceptedTypes. Defaults to "other".
-- @return An Item table
function Storage:GetAllItemsOfType(type)
   type = type or "other"
   return tFilter(StoredItems,
   function(v)
      return v.type == type
   end)
end

--- Returns all stored items with less/equal time remaining
-- @param time Seconds to check for (defaults to 0)
-- @return An Item table consisting of items with less or equal, time remaining than 'time'.
function Storage:GetAllItemsLessTimeRemaining(time)
   time = time or 0
   return tFilter(StoredItems,
   function(v)
      return v.time_remaining <= time
   end)
end
