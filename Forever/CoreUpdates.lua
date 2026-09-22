--- Only loaded when playing Forever

---@class RCLootCouncil
local addon = select(2, ...)

-- Retail version uses EJ_ stuff which isn't available in Forever.
function addon:Test(num, fullTest, trinketTest)
	self.Log:d("Test", num)
	local testItems = {
		-- Tier21 Tokens (Head, Shoulder, Cloak, Chest, Hands, Legs)
		152524,
		152530,
		152517,
		152518,
		152521,
		152527, -- Vanquisher: DK, Druid, Mage, Rogue
		152525,
		152531,
		152516,
		152519,
		152522,
		152528, -- Conqueror : DH, Paladin, Priest, Warlock
		152526,
		152532,
		152515,
		152520,
		152523,
		152529, -- Protector : Hunder, Monk, Shaman, Warrior

		-- Tier21 Armors (Head, Shoulder, Chest, Wrist, Hands, Waist, Legs, Feet)
		152014,
		152019,
		152017,
		152023,
		152686,
		152020,
		152016,
		152009, -- Plate
		152423,
		152005,
		151994,
		152008,
		151998,
		152006,
		152002,
		151996, -- Mail
		151985,
		151988,
		151982,
		151992,
		151984,
		151986,
		151987,
		151981, -- Leather
		151943,
		151949,
		152679,
		151953,
		152680,
		151942,
		151946,
		151939, -- Cloth

		-- Tier21 Miscellaneous
		152283,
		151965,
		151973, -- Neck
		151937,
		151938,
		152062, -- Cloak
		151972,
		152063,
		152284, -- Rings

		-- Tier21 Relics
		152024,
		152025, -- Arcane
		152028,
		152029, -- Blood
		152031,
		152032, -- Fel
		152035,
		152036, -- Fire
		152039,
		152040, -- Frost
		152043,
		152044, -- Holy
		152047,
		152048, -- Iron
		152050,
		152051, -- Life
		152054,
		152055, -- Shadow
		152058,
		152059, -- Storm
	}

	local trinkets = {
		-- Tier21 Trinkets
		154172, -- All classes
		151975,
		151976,
		151977,
		151978,
		152645,
		153544,
		154173, -- Tank
		151974, -- Eye of Shatug. EJ item id is different with the item id actually drops
		151956,
		151957,
		151958,
		151960,
		152289,
		154175, -- Healer
		151964,
		152093, -- Melee DPS
		154176, -- Strength DPS
		154174, -- Agility DPS
		151970, -- Intellect DPS/Healer
		151955,
		151971,
		154177, -- Intellect DPS
		151963,
		151968, -- Melee and ranged attack DPS
		151962,
		151969, -- Ranged attack and spell DPS
	}

	if not trinketTest then for _, t in ipairs(trinkets) do tinsert(testItems, t) end end
	local items = {};
	-- pick "num" random items
	for i = 1, num do -- luacheck: ignore
		local j = math.random(1, #testItems)
		tinsert(items, testItems[j])
	end
	if trinketTest then -- Always test all trinkets.
		items = trinkets
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
	if noCache[key:lower()] then return name end
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
	return cacheUnitName(unit, unit)
end