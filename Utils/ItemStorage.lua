--- ItemStorage.lua Class mock for handling stored items
-- Creates 'RCLootCouncil.ItemStorage' as a namespace for storage functions.
-- @author Potdisc
-- Create Date : 29/5/2018 18:28:51
--- @class RCLootCouncil
local addon = select(2, ...)
local db = addon:Getdb()
--- @class ItemStorage
local Storage = {}
addon.ItemStorage = Storage

--- @type Item[]
local StoredItems = {}
local private = { ITEM_WATCH_DELAY = 1 }


--- @alias AcceptedTypes
--- | "to_trade" 		Items that should be traded to another player
--- | "award_later"		Items that should be used in a later session
--- | "temp"			Items we're temporarily storing
--- | "other"			Unspecified
--[[
   Each entry index marks the type of item, and can have following fields:
      'bagged' - Must be in player's bags to be initialized on login?
]]
Storage.AcceptedTypes = {
   ["to_trade"] = {
      bagged = true,
   },
   ["award_later"] = {
      bagged = false,
   },
   ["temp"] = {
      bagged = true,
   },
   ["other"] = {
      bagged = false,
   },
}

-- Item Class:
--- @class Item
local item_class = {
   type = "other", -- Default to unspecified
   --- When was this registered (in seconds)
   time_added = 0,
   --- When did we last update `time_remaining`
   time_updated = 0,
   --- How many seconds left to trade when we last updated it.
   time_remaining = 0,
   inBags = false,
   link = "",
   args = {}, -- User args

   --- Stores Item in persistant db.
   --- @param self Item
   Store = function(self)
      tinsert(db.itemStorage, self)
      return self
   end,

   --- Removes Item from persistant db.
   --- @param self Item
   Unstore = function(self)
      tDeleteItem(db.itemStorage, self)
      return self
   end,

   --- Items shouldn't be removed whilst itemWatch is working it.
   --- This functions checks that.
   --- @param self Item
   SafeToRemove = function(self) return self.args.itemWatch == nil end,

   --- Updates time_remaining
   ---@param self Item
   UpdateTime = function(self)
      if not self.inBags then return end -- Don't do anything if we know we haven't stored it.
      local _, _, t = private:findItemInBags(self.link)
      self:SetUpdateTime(t)
   end,

   --- Actual time remaining.
   --- `self.time_remaining` is only acurate immediately after calling `self:UpdateTime()`.
   --- This always represents the accurate remaining time.
   --- @param self Item
   TimeRemaining = function(self)
      return self.time_remaining + self.time_updated - time()
   end,

   --- Utility function for consistantly updating time.
   --- @param self Item Item to set time for.
   --- @param timeRemaining? integer Remaining time
   --- @param fallbackTime? integer Used as `timeRemaining` if that's nil. Defaults to 0.
   SetUpdateTime = function(self, timeRemaining, fallbackTime)
      timeRemaining = timeRemaining or fallbackTime or 0
      -- Store BoEs (math.huge) as 24 hrs so we don't run into issues when displaying time.
      self.time_remaining = timeRemaining == math.huge and 86400 or timeRemaining
      self.time_updated = time()
      return self
   end
}

-- lua
local error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable, CopyTable,
ipairs = error, table, tostring, tinsert, tremove, type, select, FindInTableIf, time, tFilter, setmetatable,
    CopyTable, ipairs

function addon:InitItemStorage() -- Extract items from our SV. Could be more elegant
   db = self:Getdb()
   local Item;
   local toBeRemoved = {}
   for i, v in ipairs(db.itemStorage) do
      -- v3.0: Noticed some items didn't have a link - check for that.
      if not v.link or (v.time_remaining and v.time_updated and (v.time_remaining + v.time_updated - time() <= 0)) then
         addon:DebugLog("ItemStorage, db item no link or timeout", v.link, v.time_remaining, v.time_updated)
         tinsert(toBeRemoved, i)
      else
         local c, s = private:findItemInBags(v.link)
         if c and s and Storage.AcceptedTypes[v.type] then
            -- Reuse item table from db to restore the reference
            Item = private:newItem(v, v.link, v.type)
            -- Restore old time added
            Item.time_added = v.time_added
         else
            addon:DebugLog("ItemStorage, db item no longer in bags", v.link)
            tinsert(toBeRemoved, i)
         end
      end
   end
   for i = #toBeRemoved, 1, -1 do
      tremove(db.itemStorage, toBeRemoved[i])
   end
end

--- Initiates a new item of item_class
--- @param item ItemLink|ItemString|ItemID of the item
--- @param typex string Optional type for used in various functions, @see Storage.AcceptedTypes
--- @param ... any Userdata stored in the returned 'Item.args'. Directly stored if provided as table, otherwise as '{...}'.
--- @return Item #See 'item_class' when the item is stored succesfully. Has flag Item.inBags if present in bags.
function Storage:New(item, typex, ...)
   if not typex then typex = "other" end
   if not self.AcceptedTypes[typex] then
      error(
         "Type: " ..
         tostring(typex) .. " is not accepted. Accepted types are: " .. table.concat(self.AcceptedTypes, ", "),
         2)
   end
   addon:Debug("Storage:New", item, typex, ...)
   local Item = private:newItem({}, item, typex)
   Item.args = ... and type(...) == "table" and ... or { ... }
   return Item
end

--- Remove an item from storage
--- @param itemOrItemLink Item|ItemLink Either an itemlink (@see GetItemInfo) or the Item object returned by :New
--- @return boolean #True if successful
function Storage:RemoveItem(itemOrItemLink)
   addon:Debug("Storage:RemoveItem", itemOrItemLink)
   if type(itemOrItemLink) == "table" then -- Maybe our Item object
      if not (itemOrItemLink.type and itemOrItemLink.link) then -- Nope
         return error("Item `item` is not the correct class", 2)
      end
   elseif type(itemOrItemLink) ~= "string" then -- string == item link (hopefully)
      return error("Unknown item")
   end
   -- Find and delete the item
   local key1 = private:FindItemInTable(db.itemStorage, itemOrItemLink)
   local key2 = private:FindItemInTable(StoredItems, itemOrItemLink)
   if key1 then addon:DebugLog("Removed1:", tremove(db.itemStorage, key1).link) end
   if key2 then addon:DebugLog("Removed2:", tremove(StoredItems, key2)) end

   -- key1 might not be there if we haven't stored it
   if not key2 then
      addon:Debug("Error - Couldn't remove item", key1, key2)
      return false
   else
      return true
   end
end

function Storage:RemoveAllItems()
   db.itemStorage = {}
   StoredItems = {}
end

--- Removes all items of a specific type.
--- @param type AcceptedTypes The type to remove.
function Storage:RemoveAllItemsOfType(type)
   type = type or "other"
   -- Do it in reverse for speed
   for i = #StoredItems, 1, -1 do if StoredItems[i].type == type then self:RemoveItem(StoredItems[i]) end end
end

--- Returns a numerical indexed table of all the stored items
--- Note: Each value in this table is the item object itself.
--- @return Item[] #All stored items
function Storage:GetAllItems() return StoredItems end

--- Returns a specific item object.
--- Without type, returns the first found Item that matches the item link.
--- With type, returns the the first found item that matches both the item link and the type.
--- @param item ItemLink @see `GetItemInfo`
--- @param itemType? AcceptedTypes The type of the item we want to find
--- @return Item? Item The Item object, or nil if not found
function Storage:GetItem(item, itemType)
   if type(item) ~= "string" then return error("'item' is not a string/ItemLink", 2) end
   return select(2, private:FindItemInTable(StoredItems, item, itemType))
end

--- Returns all stored Items of a specific type
-- @param type The item type, @see Storage.AcceptedTypes. Defaults to "other".
--- @return Item[] # An Item table
function Storage:GetAllItemsOfType(type)
   type = type or "other"
   return tFilter(StoredItems, function(v) return v.type == type end, true)
end

--- Returns all stored Items with less/equal time remaining
--- @param time integer Seconds to check for (defaults to 0)
--- @return Item[] #A table consisting of items with less or equal, time remaining than 'time'.
function Storage:GetAllItemsLessTimeRemaining(time)
   time = time or 0
   return tFilter(StoredItems, function(v) return v:TimeRemaining() <= time end, true)
end

--- Returns all stored Items based on multiple predicates
-- @param ... Predicate functions.
-- @return The filtered list of times.
function Storage:GetAllItemsMultiPred(...)
   local args = { ... }
   return tFilter(StoredItems, function(v)
      for _, func in ipairs(args) do if not func(v) then return false end end
      return true
   end, true)
end

--- Returns Container and Slot ids of an item.
-- @param item The item to find slots for, either 'Item' object or ItemLink.
-- @return container,slot,time_remaining The position of the item in the player's bags and it's remaining trade time (if present).
function Storage:GetItemContainerSlot(item)
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
function Storage:WatchForItemInBags(input, onFound, onFail, max_attempts)
   local Item
   if type(input) == "table" then
      Item = input
   elseif type(input) == "string" then
      Item = private:newItem({}, input, "temp") -- Item is not saved in storage
   else
      error(format("%s is not a valid input.", input))
   end
   private:InitWatchForItemInBags(Item, max_attempts or 3, onFound, onFail)
end

--- Compares two of our items.
--- Compares all fields expect `time_added` and `time_remaining`.
---@param a Item
---@param b Item
function Storage:Compare(a, b)
   if type(a) ~= "table" or not a.type then error(format("%s is not a valid input.", tostring(a))) end
   if type(b) ~= "table" or not b.type then error(format("%s is not a valid input.", tostring(b))) end
   return a.type == b.type and
       a.inBags == b.inBags and
       a.link == b.link and
       tCompare(a.args, b.args, 1)
end

function private:FindItemInTable(table, item1, type)
   if type then
      return FindInTableIf(table, function(item2) return type == item2.type and addon:ItemIsItem(item1, item2.link) end)
   end
   if item1.type then
      -- Our item class
      return FindInTableIf(table, function(item2) return Storage:Compare(item1, item2) end)
   else
      -- Generic itemString
      return FindInTableIf(table, function(item2) return addon:ItemIsItem(item1, item2.link) end)
   end
end

function private:findItemInBags(link)
   addon:DebugLog("Storage: searching for item:", gsub(link or "", "\124", "\124\124"))
   if link and link ~= "" then
      local c, s, t
      for container = 0, _G.NUM_BAG_SLOTS do
         for slot = 1, addon.C_Container.GetContainerNumSlots(container) or 0 do

            if addon:ItemIsItem(link, addon.C_Container.GetContainerItemLink(container, slot)) then -- We found it

               addon:DebugLog("Found item at", container, slot)
               c, s = container, slot
               -- Now we need to ensure we don't have multiple of it
               t = addon:GetContainerItemTradeTimeRemaining(c, s)
               if t > 0 then
                  -- if the item is tradeable, then we've most likely just received it, and can safely return
                  return c, s, t
               end
            end
         end
      end
      addon:DebugLog("Found:", c, s, t)
      return c, s, t
   end
end

local mt = {
   __index = item_class,
   __tostring = function(self) return self.link end,
}

--- Creates a new item
--- @param base? table Used as the base table for the class. Defaults to new table.
--- @param link ItemLink
--- @param type AcceptedTypes
--- @return Item
function private:newItem(base, link, type)
   local c, s, time_remaining = self:findItemInBags(link)
   local Item = setmetatable(base or {}, mt)
   Item.link = link
   Item.type = type
   -- If item isn't in our bags, lets store it for 6 hours (21600 seconds)
   Item:SetUpdateTime(time_remaining, 21600)
   Item.time_added = time()
   Item.inBags = c and s
   tinsert(StoredItems, Item)
   return Item
end

function private:itemWatcherScheduler(Item)
   local c, s, t = self:findItemInBags(Item.link)
   if c and s then
      Item.time_remaining = t
      Item.time_added = time() -- Needs updating now that we updated remaining time
      Item.inBags = true
      Item.args.itemWatch.onFound(Item, c, s, t)
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
      onFail = onFail or addon.noop,
   }
   addon:ScheduleTimer(self.itemWatcherScheduler, self.ITEM_WATCH_DELAY, self, Item)
end
