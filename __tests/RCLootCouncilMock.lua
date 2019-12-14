dofile "../../Locale/enUS.lua"

RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0")
RCLootCouncil.debug = false
local AceSer = LibStub("AceSerializer-3.0")
RCLootCouncil.Deserialize = AceSer.Deserialize
RCLootCouncil.Serialize = AceSer.Serialize

RCLootCouncil.db = {
   profile = {},
   global = {
      log = {},
   },
}
RCLootCouncil.lootDB = {
   factionrealm = {}
}
RCLootCouncil.defaults = {
   global = {
      logMaxEntries = 2000,
   },
}
RCLootCouncil.realmName = "Ravencrest"

function RCLootCouncil:Getdb (args)
   return self.db
end

function RCLootCouncil:GetHistoryDB ()
   return self.lootDB.factionrealm
end

function RCLootCouncil:Debug (...)
   if self.debug then print(...) end
   tinsert(self.db.global.log, table.concat({...}, ""))
end

function RCLootCouncil:UnitName(unit)
	unit = gsub(unit, " ", "")
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		local name, realm = strsplit("-", unit, 2)
		name = string.lower(name):gsub("^%l", string.upper)
		return name.."-"..realm
	end
	unit = string.lower(unit)
	local name, realm = UnitName(unit)
	if not realm or realm == "" then realm = self.realmName or "" end -- Extract our own realm
	if not name then
		name = unit
	end -- Below won't work without name
	name = string.lower(name):gsub("^%l", string.upper)
	return name and name.."-"..realm
end

function RCLootCouncil:ItemIsItem(item1, item2)
	if type(item1) ~= "string" or type(item2) ~= "string" then return item1 == item2 end
	item1 = self.Utils:GetItemStringFromLink(item1)
	item2 = self.Utils:GetItemStringFromLink(item2)
	if not (item1 and item2) then return false end -- KeyStones will fail the GetItemStringFromLink
	--[[ REVIEW Doesn't take upgradeValues into account.
		Doing that would require a parsing of the bonusIDs to check the correct positionings.
	]]
	return self.Utils:NeutralizeItem(item1) == self.Utils:NeutralizeItem(item2)
end

--- Compares two versions.
-- Assumes strings of format "x.y.z".
-- @return True if ver1 is older than ver2, otherwise false.
function RCLootCouncil:VersionCompare(ver1, ver2)
	if not ver1 or not ver2 then return end
	local a1,b1,c1 = string.split(".", ver1)
	local a2,b2,c2 = string.split(".", ver2)
	if not (c1 and c2) then return end -- Check if it exists
	if a1 ~= a2 then return  tonumber(a1) < tonumber(a2) elseif b1 ~= b2 then return tonumber(b1) < tonumber(b2) else return tonumber(c1) < tonumber(c2) end
end

loadfile("../../Core/Defaults.lua")("", RCLootCouncil)

-- Load utils last
local utils = assert(loadfile("../../Utils/Utils.lua"))
utils("",RCLootCouncil)
