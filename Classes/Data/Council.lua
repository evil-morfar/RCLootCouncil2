--- Council.lua Class for council handling.
-- @author Potdisc
-- Create Date: 15/04/2020
--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Data.Council
local Council = addon.Init("Data.Council")
local Player = addon.Require "Data.Player"
local TT = addon.Require "Utils.TempTable"

local private = {
	---@class Council : { [string] : Player}
	--- Format is
	--- ```
	--- {
	---    [guid: string] = player : Player
	--- }
	--- ```
	council = {},
}

--- Returns the current council
---@return Council
function Council:Get()
	return private.council
end

--- Sets the current council.
---@param council Council
function Council:Set(council)
	private.council = council
end

--- Returns the number of council members
function Council:GetNum()
	return private:GetCouncilSize()
end

--- Adds a Player to the council.
--- @param player Player @A 'Data.Player' object
--- @return number @The new council lenght
function Council:Add(player)
	if type(player) ~= "table" or not (player.name and player.guid) then error("Not a valid 'Player' object", 2) end
	private.council[player.guid] = player
	return private:GetCouncilSize()
end

--- Removes a Player from the council
--- @param player Player @A 'Data.Player' object
--- @return number @The new council lenght
function Council:Remove(player)
	if type(player) ~= "table" or not (player.name and player.guid) then error("Not a valid 'Player' object", 2) end
	private.council[player.guid] = nil
	return private:GetCouncilSize()
end

--- Checks if a "Player" is in the council
--- @param player Player A 'Data.Player' object
--- @return boolean
function Council:Contains(player)
	if not player.guid then return false end
	local result = private.council[player.guid] ~= nil
	if addon.isMasterLooter or addon.nnp then result = true end
	return result
end

--- Gets the council table optimized for comms.
--- @return TempTable<Council> @A "TempTable" with the council data.
function Council:GetForTransmit()
	local tt = TT:Acquire()
	local council = self:GetCouncilInGroup()
	for _, player in pairs(council) do
		tt[player:GetForTransmit()] = true
	end
	TT:Release(council)
	return tt
end

--- Sets the currrent council to the received council.
--- @return number @Lenght of the new council.
function Council:RestoreFromTransmit(council)
	wipe(private.council)
	for guid in pairs(council) do
		local player = Player:Get(guid)
		private.council[player.guid] = player
	end
	return private:GetCouncilSize()
end

---@return integer #Number of council members.
function private:GetCouncilSize()
	local size = 0
	for _ in pairs(self.council) do size = size + 1 end
	return size
end

--- A printable version of the council.
---@return string
function Council:GetForPrint()
	local temp = TT:Acquire()
	for _, v in pairs(private.council) do tinsert(temp, v.name) end
	local ret = table.concat(temp, ", ")
	TT:Release(temp)
	return ret
end

--- Fetches all council members currently in our group
---@return TempTable<Player>
function Council:GetCouncilInGroup()
	local ret = TT:Acquire()
	for _, player in pairs(private.council) do
		if addon.candidatesInGroup[player.name] then
			tinsert(ret, player)
		end
	end
	return ret;
end
