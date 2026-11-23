---@diagnostic disable: duplicate-set-field
--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

function addon:IsCorrectVersion() return WOW_PROJECT_ID == WOW_PROJECT_CAMELOT end

-- Basically only here to project ForeverDB changes
---@return RCLootCouncilForeverDB
function addon:Getdb() return addon.db.profile end

-- Retail version uses EJ_ stuff which isn't available in Forever.
function addon:Test(num, fullTest, trinketTest)
	self.Log:d("Test", num)
	local testItems = {
		284716, 279260, 279259, 279262, 279261, 279273, 21395, 12640, 279253, 279246, 18713, 18608, 19169, 19323, 250599, 252605, 280304, 252485, 18168, 17193, 873, 21134, 272851, 22383, 18821, 252484, 252483, 8708, 279266, 252561, 252604, 279265, 19147, 19168, 18609, 240993, 871, 9372, 18876, 14152, 279255, 279269, 14153, 272108, 272105, 276540, 271959, 22384, 227810,
	}
	local items = {};
	-- pick "num" random items
	for i = 1, num do -- luacheck: ignore
		local j = math.random(1, #testItems)
		tinsert(items, testItems[j])
	end
	self.testMode = true;
	self.isMasterLooter, self.masterLooter = self:GetML()
	-- We must be in a group and not the ML
	if not self.isMasterLooter then
		self:Print(L.error_test_as_non_leader)
		self.testMode = false
		return
	end
	self:SnapshotInstanceData()
	-- Call ML module and let it handle the rest
	self:CallModule("masterlooter")
	self:GetActiveModule("masterlooter"):NewML(self.masterLooter)
	self:GetActiveModule("masterlooter"):Test(items)
end

local noCache = { "player", "npc", "target", }
---@param key string
---@param name string
local function cacheUnitName(key, name)
	if noCache[key:lower()] or key:sub(1, 4 ) == "raid" or key:sub(1,5) == "party" then return name end
	local find = strfind(name, "-", nil, true)
	if find and find < #name then
		addon.Utils.unitNameLookup[key] = name
	end
	return name
end

-- In Forever, we should remove realm name, as "First Last" name is the unique identifier for a player. This is different from Retail where "Name-Realm" is the unique identifier.
function addon.Utils:UnitName(unit)
	if self:IsSecretValue(unit) then return unit end
	if self.unitNameLookup[unit] then return self.unitNameLookup[unit] end
	if not unit or unit == "" then return "" end
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		local name = strsplit("-", unit, 2)
		return cacheUnitName(unit, name)
	elseif find and find == #unit then -- trailing '-'
		return cacheUnitName(unit, string.sub(unit, 1, -2))
	end
	local first,last = UnitName(unit)
	return cacheUnitName(unit, last and (first.." "..last) or unit)
end