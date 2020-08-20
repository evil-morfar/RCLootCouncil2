--- UI.lua Handler for UI elements used in RCLootCouncil
-- Creates 'RCLootCouncil.UI' as a namespace for UI functions.
-- Acts (for now) as a simple entry way to creating/registering widgets.
-- TODO: Full on recycle/handling of all elements created.
-- @author Potdisc
-- Create Date : 31/7/2018 03:42:37

local _,addon = ...
local private = { elements = {}, num = {}, embeds = {}, }
addon.UI = {CreateFrame = _G.CreateFrame, private = private, minimizeableFrames = {}} -- Embed CreateFrame into UI as it's used by all elements

-- GLOBALS: _G
local error, format, type, pairs = error, format, type, pairs

--- Exposed function for creating new UI elements
-- @param type The type of the element.
-- @param parent The element's UI parant. Defaults to UIParent
-- @return The newly created UI element
function addon.UI:New(type, parent, ...)
   return private:New(type, parent, nil, ...)
end

--- Exposed function for creating new named UI elements
-- @param type The type of the element.
-- @param parent The element's UI parant. Defaults to UIParent
-- @param name The global name of the element.
-- @return The newly created UI element
function addon.UI:NewNamed(type, parent, name, ...)
   return private:New(type, parent, name, ...)
end

function addon.UI.HideTooltip()
   addon:HideTooltip()
end

-- Registers a new element
function addon.UI:RegisterElement(object, etype)
   if type(object) ~= "table" then error("RCLootCouncil.UI:RegisterElement() - 'object' isn't a table.") end
   if type(etype) ~= "string" then error("RCLootCouncil.UI:RegisterElement() - 'type' isn't a string.") end
   private.elements[etype] = object
end

function addon.UI:RegisterForCombatMinimize (frame)
   tinsert(self.minimizeableFrames, frame)
end
---------------------------------------------
-- Internal functions
---------------------------------------------
function private:New(type, parent, name, ...)
   if self.elements[type] then
      parent = parent or _G.UIParent
      if name then
         return self:Embed(self.elements[type]:New(parent, name, ...))
      else
         -- Create a name
         if not self.num[type] then self.num[type] = 0 end
         self.num[type] = self.num[type] + 1
         return self:Embed(self.elements[type]:New(parent, "RC_UI_"..type..self.num[type], ...))
      end
   else
      addon:Debug("UI Error in :New(): No such element", type, name)
      error(format("UI Error in :New(): No such element: %s %s", type, name))
   end
end

function private:Embed(object)
   for k,v in pairs(self.embeds) do
      object[k] = v
   end
   return object
end

private.embeds["SetMultipleScripts"] = function(object, scripts)
   for k,v in pairs(scripts) do
      object:SetScript(k,v)
   end
end
