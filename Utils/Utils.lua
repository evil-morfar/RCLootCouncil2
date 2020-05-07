-- Utils.lua Utility functions for RCLootCouncil
-- Creates RCLootCouncil.Utils namespace for utility functions
-- @Author Potdisc
-- Create Date : 27/7/2018 20:49:10
local _,addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
local db = addon:Getdb()
local Utils = {}
addon.Utils = Utils

local string, gsub, strmatch, tonumber, format, date, time, strsplit = string, gsub, strmatch, tonumber, format, date, time, strsplit
-- GLOBALS: IsInRaid, UnitGroupRolesAssigned

--- Extracts the creature id from a guid
-- @param unitguid The UnitGUID
-- @return creatureID (string) or nil if nonexistant
function Utils:ExtractCreatureID (unitguid)
   if not unitguid then return nil end
   local id = unitguid:match(".+(%b--)")
   return id and (id:gsub("-", "")) or nil
end

--- Shorthand for RCLootCouncil:HideTooltip()
-- This way we can use the function as a table reference
function Utils.HideTooltip()
   addon:HideTooltip()
end

function Utils:RGBToHex(r,g,b)
	return string.format("%02x%02x%02x",255*r, 255*g, 255*b)
end

function Utils:GetItemStringClean(link)
	return gsub(self:GetItemStringFromLink(link), "item:", "")
end

function Utils:GetItemNameFromLink(link)
	return strmatch(link or "", "%[(.+)%]")
end

function Utils:GetAnnounceChannel(channel)
	return channel == "group" and (IsInRaid() and "RAID" or "PARTY") or channel
end

function Utils:GetItemIDFromLink(link)
	return tonumber(strmatch(link or "", "item:(%d+):"))
end

function Utils:GetItemStringFromLink(link)
	return strmatch(strmatch(link or "", "item:[%d:-]+") or "", "(item:.-):*$")
end

function Utils:GetItemTextWithCount(link, count)
	return link..(count and count > 1 and (" x"..count) or "")
end

local NEUTRALIZE_ITEM_PATTERN = "item:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):%d*:%d*:%d*:%d*:(%d*):(%d*)"
local NEUTRALIZE_ITEM_REPLACEMENT = "item:%1:%2:%3:%4:%5:%6:%7::::%8:%9" -- 9: numBonusIDs

--- Removes any character specific data from an item
-- @param item Any itemlink, itemstring etc.
-- @return The same item with level, specID, uniqueID, upgradeTypeID removed
function Utils:NeutralizeItem (item)
	return item:gsub(NEUTRALIZE_ITEM_PATTERN, NEUTRALIZE_ITEM_REPLACEMENT)
end

function Utils:GetItemLevelText(ilvl, token)
	if not ilvl then return "" end
	if token and ilvl > 600 then -- Armor token warforged is introduced since WoD
		return ilvl.."+"
	else
		return ilvl
	end
end

function Utils:GetPlayerRole()
	return UnitGroupRolesAssigned("player")
end

function Utils:TranslateRole(role)
	return (role and role ~= "") and _G[role] or ""
end

-- REVIEW FrameXML/Utils have something like this
--- Calculates how long ago a given date was.
-- Assumes the date is of year 2000+.
-- @param oldDate A string specifying the date, formatted as "dd/mm/yy".
-- @return day, month, year.
function Utils:GetNumberOfDaysFromNow(oldDate)
	local d, m, y = strsplit("/", oldDate, 3)
	local sinceEpoch = time({year = "20"..y, month = m, day = d, hour = 0}) -- convert from string to seconds since epoch
	local diff = date("*t", math.abs(time() - sinceEpoch)) -- get the difference as a table
	-- Convert to number of d/m/y
	return diff.day - 1, diff.month - 1, diff.year - 1970
end

--- Takes the return value from :GetNumberOfDaysFromNow() and converts it to text.
-- @see RCLootCouncil:GetNumberOfDaysFromNow
-- @return A formatted string.
function Utils:ConvertDateToString(day, month, year)
	local text = format(L["x days"], day)
	if year > 0 then
		text = format(L["days, x months, y years"], text, month, year)
	elseif month > 0 then
		text = format(L["days and x months"], text, month)
	end
	return text;
end

--- Returns the number of available spaces in the players bags
function Utils:GetNumFreeBagSlots()
   local result = 0
   for i = 1, _G.NUM_BAG_SLOTS do
      result = result + (GetContainerNumFreeSlots(i))
   end
   return result
end

function Utils:IsInNonInstance()
   local instance_type = select(2, IsInInstance())
   if IsPartyLFG() or instance_type == "pvp" or instance_type == "arena" then
      return true
   else
      return false
   end
end


--- Checks if the item is in our blacklist
-- COMBAK Should be moved to it's own class in the future
-- @param item Any valid input for `GetItemInfoInstant`
-- @return boolean True if the item is blacklisted
function Utils:IsItemBlacklisted(item)
   if not item then return false end
   local _,_,_,_,_,itemClassID, itemsubClassID = GetItemInfoInstant(item)
   if not (itemClassID and itemsubClassID) then return false end
   if addon.blacklistedItemClasses[itemClassID] then
      if addon.blacklistedItemClasses[itemClassID].all or addon.blacklistedItemClasses[itemClassID][itemsubClassID] then
         return true
      end
   end
   return false
end

--- Checks for outdated versions.
-- Will prioritise test versions, so if the version contains a test version, the normal version test will be skipped.
function Utils:CheckOutdatedVersion (baseVersion, newVersion, basetVersion, newtVersion)
   baseVersion = baseVersion or addon.version

   if strfind(newVersion, "%a+") then return self:Debug("Someone's tampering with version?", newVersion) end

   if addon:VersionCompare(baseVersion,newVersion) and (not (basetVersion or newtVersion)) then
		return addon.VER_CHECK_CODES[2] -- Outdated

	elseif basetVersion and newtVersion and basetVersion < newtVersion then
		return addon.VER_CHECK_CODES[3] -- tVersion outdated

   else
      return addon.VER_CHECK_CODES[1] -- All fine
	end
end
