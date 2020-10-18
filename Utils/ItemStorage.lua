--- ItemStorage.lua Class mock for handling stored items
-- Creates 'RCLootCouncil.ItemStorage' as a namespace for storage functions.
-- @author Potdisc
-- Create Date : 29/5/2018 18:28:51

local _,addon = ...
local db = addon:Getdb()
local Storage = {}
local TT = addon.Require "Utils.TempTable"
addon.ItemStorage = Storage

local StoredItems = {}
local private = {
   ITEM_WATCH_DELAY = 1
}

--[[
   Each entry index marks the type of item, and can have following fields:
      'bagged' - Must be in player's bags to be initialized on login?
]]
Storage.AcceptedTypes = {
   ["to_trade"]    = { -- Items that should be traded to another player
      bagged = true,
   },
   ["award_later"] = { -- Items that should be used in a later session
      bagged = false,
   },
   ["temp"]        = { -- Items we're temporarily storing
      bagged = true
   },
   ["other"]       = { -- Unspecified
      bagged = false
   },
}

-- Item Class:
local item_class = {
   type = "other", -- Default to unspecified
   time_remaining = 0, -- NOTE For now I rely on this not being updated for timeout checks. It should be precise enough, but needs testing
   time_added = 0,
   inBags = false,
   link = "",
   args = {}, -- User args

   Store = function(self)
      tinsert(db.itemStorage, self)
      return self
   end,
   Unstore = function(self)
      tDeleteItem(db.itemStorage, self)
      return self
   end,
   -- Items shouldn't be removed whilst itemWatch is working it.
   -- This functions checks that.
   SafeToRemove = function(self)
      return self.args.itemWatch == nil
   end
}

-- lua
local error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable, CopyTable, ipairs
    = error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable, CopyTable, ipairs

-- GLOBALS: GetContainerNumSlots, GetContainerItemLink, _G

function addon:InitItemStorage()-- Extract items from our SV. Could be more elegant
   db = self:Getdb()
   local Item;
   local toBeRemoved = TT:Acquire()
   for i, v in ipairs(db.itemStorage) do
      -- v3.0: Noticed some items didn't have a link - check for that.
      if not v.link then 
         tinsert(toBeRemoved, i)
      else 
         Item = Storage:New(v.link, v.type, "restored", v)
         if not Item.inBags and Storage.AcceptedTypes[Item.type] then -- Item probably no longer exists?
            addon.Log:W("ItemStorage, db item no longer in bags", v.link)
            Storage:RemoveItem(Item)
         end
      end
   end
   for _, num in ipairs(toBeRemoved) do
      tremove(db.itemStorage, num)
   end
   TT:Release(toBeRemoved)
end

--- Initiates a new item of item_class
-- @param item ItemLink|ItemString|ItemID of the item
-- @param type Optional type for used in various functions, @see Storage.AcceptedTypes
-- @param ... Userdata stored in the returned 'Item.args'. Directly stored if provided as table, otherwise as '{...}'.
-- @returns Item @see 'item_class' when the item is stored succesfully. Has flag Item.inBags if present in bags.
function Storage:New(item, typex, ...)
   if not typex then typex = "other" end
   if not self.AcceptedTypes[typex] then error("Type: " .. tostring(typex) .. " is not accepted. Accepted types are: " .. table.concat(self.AcceptedTypes, ", "),2) end
   addon.Log:D("Storage:New",item,typex,...)
   local c,s,time_remaining = private:findItemInBags(item)
   local Item
   if not (c and s) then
      -- The Item is not in our bags
      Item = private:newItem(item, typex)
   else
      Item = private:newItem(item, typex, time_remaining)
      Item.inBags = true -- The item is in our bags
   end
   if select(1, ...) == "restored" then -- Special case, gets stored
      local OldItem = select(2, ...)
      Item.time_added = OldItem.time_added -- Restore original time added
      Item.args = OldItem.args
   else
      Item.args = ... and type(...) == "table" and ... or {...}
   end
   tinsert(StoredItems, Item)
   return Item
end

--- Remove an item from storage
-- @param item Either an itemlink (@see GetItemInfo) or the Item object returned by :New
-- @return True if successful
function Storage:RemoveItem(item)
   addon.Log:D("Storage:RemoveItem", item)
   local item_link
   if type(item) == "table" then -- Maybe our Item object
      if not (item.type and item.link) then -- Nope
         return error("Item `item` is not the correct class", 2)
      end
      item_link = item.link
   elseif type(item) == "string" then -- item link (hopefully)
      item_link = item
   else
      return error("Unknown item")
   end
   -- Find and delete the item
   local key1 = private:FindItemInTable(db.itemStorage, item_link)
   local key2 = private:FindItemInTable(StoredItems, item_link)
   if key1 then tremove(db.itemStorage, key1) end
   if key2 then tremove(StoredItems, key2) end

   if not (key1 and key2) then
      addon.Log:E("Couldn't remove item", key1, key2)
      return false
   else
      return true
   end
end

--- Removes all items of a specific type
-- @param type The type to remove - @see Storage.AcceptedTypes
function Storage:RemoveAllItemsOfType(type)
   type = type or "other"
   -- Do it in reverse for speed
   for i = #StoredItems, 1, -1 do
      if StoredItems[i].type == type then
         self:RemoveItem(StoredItems[i])
      end
   end
end

--- Returns a numerical indexed table of all the stored items
-- Note: Each value in this table is the item object itself.
-- @return A copy of all stored items
function Storage:GetAllItems()
   return CopyTable(StoredItems)
end

--- Returns a specific item object.
-- Without type, returns the first found Item that matches the item link.
-- With type, returns the the first found item that matches both the item link and the type.
-- @param item ItemLink (@see GetItemInfo)
-- @tparam itemType string (Optional) The type of the item we want to find
-- @return The Item object, or nil if not found
function Storage:GetItem(item, itemType)
   if type(item) ~= "string" then return error("'item' is not a string/ItemLink", 2) end
   return select(2, private:FindItemInTable(StoredItems, item, itemType))
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
      return private:findItemInBags(item.link)
   elseif type(item) == "string" then
      return private:findItemInBags(item)
   end
end

--- Attempt to find the item in the players bags every 1 second.
-- Optional callback functions can be attached for once the item is found.
-- If the item is found, Item.time_remaining and Item.time_added are updated before callbacks.
-- @param input The item to find; either 'itemLink' or 'Item' object.
-- @param onFound (Optional) Function - called when the item is found. Params: Item, containerID, slotID, time_remaining
-- @param onFail (Optional) Function - called when the item isn't found after max_attempts. Params: Item.
-- @param max_attempts (Optional) number - maximum number of attempts to find the item. Defaults to 3.
function Storage:WatchForItemInBags (input, onFound, onFail, max_attempts)
   local Item
   if type(input) == "table" then
      Item = input
   elseif type(input) == "string" then
      Item = private:newItem(input, "temp") -- Item is not saved in storage
   else
      error(format("%s is not a valid input.", input))
   end
   private:InitWatchForItemInBags(Item, max_attempts or 3, onFound, onFail)
end

function private:FindItemInTable(table, item1, type)
   if type then
      return FindInTableIf(table, function(item2) return type == item2.type and addon:ItemIsItem(item1, item2.link) end)
   else
      return FindInTableIf(table, function(item2) return addon:ItemIsItem(item1, item2.link) end)
   end
end

function private:findItemInBags(link)
   addon.Log:D("Storage: searching for item:",gsub(link or "", "\124", "\124\124"))
   if link and link ~= "" then
      local c,s,t
      for container=0, _G.NUM_BAG_SLOTS do
         for slot=1, GetContainerNumSlots(container) or 0 do
            if addon:ItemIsItem(link, GetContainerItemLink(container, slot)) then -- We found it
               addon.Log:D("Found item at",container, slot)
               c, s = container, slot
               -- Now we need to ensure we don't have multiple of it
               t = addon:GetContainerItemTradeTimeRemaining(c,s)
               if t > 0 then
                  -- if the item is tradeable, then we've most likely just received it, and can safely return
                  return c,s,t
               end
            end
         end
      end
      addon.Log:D("Found:", c,s,t)
      return c,s,t
   end
end

function private:newItem(link, type, time_remaining)
   local Item = setmetatable({}, {
      __index = item_class,
      __tostring = function(self)
         return self.link
      end,
   })
   Item.link = link
   Item.type = type or Item.type
   Item.time_remaining = time_remaining or Item.time_remaining or 0
   Item.time_added = time()
   return Item
end

function private:itemWatcherScheduler (Item)
   local c,s,t = self:findItemInBags(Item.link)
   if c and s then
      Item.time_remaining = t
      Item.time_added = time() -- Needs updating now that we updated remaining time
      Item.inBags = true
      Item.args.itemWatch.onFound(Item,c,s,t)
   else
      Item.args.itemWatch.currentAttempt = Item.args.itemWatch.currentAttempt + 1
      if Item.args.itemWatch.currentAttempt > Item.args.itemWatch.max_attempts then
         Item.args.itemWatch.onFail(Item)
      else
         addon:ScheduleTimer(self.itemWatcherScheduler, self.ITEM_WATCH_DELAY, self, Item)
         return -- Don't do cleanup yet
      end
   end
   Item.args.itemWatch = nil
end

function private:InitWatchForItemInBags(Item, max_attempts, onFound, onFail)
   Item.args.itemWatch = {
      max_attempts = max_attempts or 3,
      currentAttempt = 1,
      onFound = onFound or addon.noop,
      onFail = onFail or addon.noop
   }
   addon:ScheduleTimer(self.itemWatcherScheduler, self.ITEM_WATCH_DELAY, self, Item)
end
