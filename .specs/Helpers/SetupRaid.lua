--- Returns a random guid
local function GetRandomGUID(size)
	size = size or 8
	local guid = ""
	for i = 1, size do
		guid = guid .. string.format("%x", math.random(0, 0xf))
	end
	return guid
end

--- @type Player
--- @field guid string
--- @field name string
--- @field class string
--- @field realm string

--- @return Player
local function CreatePlayer(i)
	local class = CLASS_SORT_ORDER[math.random(1, #CLASS_SORT_ORDER)]
	return {
		guid = "Player-1001-" .. GetRandomGUID(8),
		name = "Player" .. i .. "-Realm1",
		class = class,
		realm = "Realm1",
	}
end

--- @param players Player[]
local function HookGlobals(players, size)
	function _G.GetNumGroupMembers() return size end

	function _G.GetPlayerInfoByGUID(guid)
		for _, v in ipairs(players) do
			if v.guid == guid then
				return v.class:lower(), v.class, "Human", "HUMAN", 2, v.name, v.realm
			end
		end
		error("Invalid guid: " .. guid, 2)
	end

	function _G.GetRaidRosterInfo(i)
		return players[i].name, i == 1 and 2 or 0
	end

	--- @param unit string
	function _G.UnitIsGroupLeader(unit)
		if unit == "player" then return true end
		for i, v in ipairs(players) do
			if v.name == unit then
				return i == 1
			end
		end
		error("Invalid unit: " .. unit, 2)
	end

	--- @param unit string
	function _G.UnitGUID(unit)
		if unit == "player" then
			return players[1].guid
		end
		for _, v in ipairs(players) do
			if v.name == unit then
				return v.guid
			end
		end
	end

	function IsInGroup()
		return #players > 1
	end

	function IsInRaid()
		return #players > 5
	end
end

--- Setup a raid with a number of players.
--- All players are named 'PlayerX-Realm1' where X is the index of the player in the raid.
--- First player is the group leader.
--- Don't forget to refresh 'addon.player' after calling this function, if you want `.player` to match this.
--- @param size integer Size of the raid
local function SetupRaid(size)
	size = size or 10
	local players = {}
	for i = 1, size do
		players[i] = CreatePlayer(i)
	end
	HookGlobals(players, size)
	WoWAPI_FireEvent("GROUP_ROSTER_UPDATE")
end

return SetupRaid
