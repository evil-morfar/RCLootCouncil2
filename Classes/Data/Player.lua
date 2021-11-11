--- Player.lua Class for holding player related data.
-- @author Potdisc
-- Create Date: 15/04/2020
--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Data.Player
local Player = addon.Init("Data.Player")
local Log = addon.Require("Utils.Log"):Get()
local ErrorHandler = addon.Require "Services.ErrorHandler"

local MAX_CACHE_TIME = 60 * 60 * 24 * 2 -- 2 days

local private = {
	--- @type table<string, Player>
	cache = setmetatable({}, {
		__index = function(_, id)
			if not addon.db.global.cache.player then addon.db.global.cache.player = {} end
			if id and id ~= "player" then return addon.db.global.cache.player[id] end
			return addon.db.global.cache.player
		end,
		__newindex = function(_, k, v) addon.db.global.cache.player[k] = v end,
	}),
}

---@class Player
---@field guid string
---@field name string
---@field class string
---@field realm string
local playerClass = {}
function playerClass:GetName() return self.name end
function playerClass:GetRealm() return self.realm end
function playerClass:GetClass() return self.class end
function playerClass:GetShortName() return Ambiguate(self.name, "short") end
function playerClass:GetGUID() return self.guid end
function playerClass:GetForTransmit() return (gsub(self.guid, "Player%-", "")) end
function playerClass:GetInfo() return GetPlayerInfoByGUID(self.guid) end
--- Update fields in the Player object
--- @param data table<string,any>
function playerClass:UpdateFields(data)
	for k, v in pairs(data) do self[k] = v end
	private:CachePlayer(self)
end

local PLAYER_MT = {
	__index = playerClass,
	--- @param self Player
	__tostring = function(self) return self.name end,
	--- @param a Player
	--- @param b Player
	__eq = function(a, b) return a.guid == b.guid end,
}

--- Fetches a player
--- @param input string A player name or GUID
function Player:Get(input)
	-- Decide if input is a name or guid
	local guid
	if input and not strmatch(input, "Player%-") and strmatch(input, "%d?%d?%d?%d%-%x%x%x%x%x%x%x%x") then
		-- GUID without "Player-"
		guid = "Player-" .. input
	elseif input and strmatch(input, "Player%-%d?%d?%d?%d%-%x%x%x%x%x%x%x%x") then
		-- GUID with player
		guid = input
	elseif type(input) == "string" then
		-- Assume UnitName
		local name = Ambiguate(input, "none")
		guid = UnitGUID(name)
		-- We can only extract GUID's from people we're grouped with.
		if not guid then
			guid = private:GetGUIDFromPlayerName(name)
			-- It's not in our cache, try the guild.
			if not guid then
				guid = private:GetGUIDFromPlayerNameByGuild(name)
				if not guid then
					-- Not much we can do at this point, so log an error
					ErrorHandler:ThrowSilentError("Couldn't produce GUID for " .. tostring(input))
					return private:GetNilPlayer()
				end
			end
		end

	else
		error(format("%s invalid player", tostring(input)), 2)
	end
	if private:IsCached(guid) then
		local player = private:GetFromCache(guid)
		private:UpdateCachedPlayer(player)
		return player
	else
		return private:CreatePlayer(guid)
	end
end

--- @param guid string
function private:CreatePlayer(guid)
	Log:f("<Data.Player>", "CreatePlayer", guid)
	if not guid then return private:GetNilPlayer() end -- TODO Ensure code can handle nil player objects

	local name, realm, class = private:GetPlayerInfoByGUID(guid)
	if not name then return private:GetNilPlayer() end

	local player = setmetatable({
		name = addon.Utils:UnitNameFromNameRealm(name, realm),
		guid = guid,
		class = class,
		realm = realm,
	}, PLAYER_MT)
	self:CachePlayer(player)
	return player
end

--- @return Player
function private:GetFromCache(guid)
	if self.cache[guid] then return setmetatable(CopyTable(self.cache[guid]), PLAYER_MT) end
end

--- Attempts to update the cached player with available data
--- @param player Player
--- @return nil
function private:UpdateCachedPlayer(player)
	if not player and player.guid then
		return Log:f("<Data.Player>", "UpdateCachedPlayer - no player or player guid", player.name, player.guid)
	end

	local name, realm, class = self:GetPlayerInfoByGUID(player.guid)
	if not name then
		return Log:f("<Data.Player>", "UpdateCachedPlayer - couldn't get PlayerInfoByGUID", player.name, player.guid)
	end -- Might not be available

	player.name = addon.Utils:UnitNameFromNameRealm(name, realm)
	player.class = class
	if realm == "" then -- Our realm isn't returned
		realm = GetRealmName()
	end
	player.realm = realm
	self:CachePlayer(player)
end

--- @param guid string
function private:GetPlayerInfoByGUID(guid)
	local _, class, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
	return name, realm, class
end

function private:IsCached(guid) return self.cache[guid] ~= nil end

--- @param player Player
function private:CachePlayer(player)
	self.cache[player.guid] = CopyTable(player)
	self.cache[player.guid].cache_time = GetServerTime()
end

--- @param name string
--- @return string|nil guid #GUID of Player if found otherwise nil
function private:GetGUIDFromPlayerName(name)
	for guid, player in pairs(self.cache.player) do
		if Ambiguate(player.name, "none") == name then return guid end
	end
end

--- @param name string
--- @return string|nil guid #GUID of Player if found otherwise nil
function private:GetGUIDFromPlayerNameByGuild(name)
	for i = 1, GetNumGuildMembers() do
		local name2, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
		if Ambiguate(name2, "none") == name then return guid end
	end
end

--- @return Player # A special `nil` player
function private:GetNilPlayer() return setmetatable({name = "Unknown"}, PLAYER_MT) end
