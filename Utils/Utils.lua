-- Utils.lua Utility functions for RCLootCouncil
-- Creates RCLootCouncil.Utils namespace for utility functions
-- @Author Potdisc
-- Create Date : 27/7/2018 20:49:10
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local db = addon:Getdb()
local Utils = {}
addon.Utils = Utils

--- Extracts the creature id from a guid
-- @param unitguid The UnitGUID
-- @return creatureID (string) or nil if nonexistant
function Utils:ExtractCreatureID (unitguid)
   local id = unitguid:match(".+(%b--)")
   return id and (id:gsub("-", "")) or nil
end
