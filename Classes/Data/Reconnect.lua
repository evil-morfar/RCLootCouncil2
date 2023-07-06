--- Reconnect.lua Helper for transmitting data for Voting Frame when reconnecting
-- @author Potdisc
-- Create Date: 11/12/2022

--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Data.Reconnect
local Reconnect = addon.Init("Data.Reconnect")
local Player = addon.Require "Data.Player"

-- Pseudo private functions - not meant for use
Reconnect.private = {}

--- Modifies reconnect data (lootTable) so that it may be
--- transmitted through comms.
--- @param data LootTable LootTable as fetched from VotingFrame:GetLootTable
--- @return TransmittableReconnectData
function Reconnect:GetForTransmit(data)
    self.private.data = CopyTable(data) or {}
    return self.private
        :OptimizeItemLinks()
        :RestructureData()
        :ConvertResponses()
        :ReplaceKeys()
        :ReplacePlayerNames()
        :GetResult()
end

--- Restores TransmittableReconnectData to a usable format.
--- @param data TransmittableReconnectData
--- @return ReconnectTable
function Reconnect:RestoreFromTransmit(data)
    self.private.restore = CopyTable(data) or {}
    return self.private
        :UndoReplacePlayerNames()
        :UndoReplaceKeys()
        :UndoConvertResponses()
        :UndoOptimizeItemLinks()
        :ExtractHaveVoted()
        :GetResult("undo")
end

function Reconnect:MergeWithLootTable(reconnectData, lootTable)
	for name, data in pairs(reconnectData) do
		for session, sessionData in ipairs(lootTable) do
			if sessionData.candidates[name] then -- Should always be there
				sessionData.candidates[name].ilvl = data.ilvl and data.ilvl[session] or 0
				sessionData.candidates[name].gear1 = data.gear1 and data.gear1[session]
				sessionData.candidates[name].gear2 = data.gear2 and data.gear2[session]
				sessionData.candidates[name].voters = data.voters and data.voters[session]
				sessionData.candidates[name].haveVoted = data.haveVoted and data.haveVoted[session]
				sessionData.candidates[name].response = data.response and data.response[session] or "NOTANNOUNCED"
			end
		end
		if UnitIsUnit("player", name) then
			for session, val in pairs(data.haveVoted) do
				lootTable[session].haveVoted = val
			end
		end
	end
	return lootTable
end

---------------------------------------------------------
-- "Private" functions doing the actual work
-- These are made chain able for seperation purposes, and must be called
-- in a specifc order, as they rely on previous conversions.
-- They're also not *pure* as they rely on either `data` or `restore`
-- being set on the object.
---------------------------------------------------------

--- Only needed to make function chaining above prettier.
--- @param undo? boolean Select between restore or data
--- @return TransmittableReconnectData | ReconnectTable data
function Reconnect.private:GetResult(undo)
    return undo and self.restore or self.data
end

--- Removes all redundant information from item links.
--- The new string is *not* a valid itemstring.
function Reconnect.private:OptimizeItemLinks()
    for _, data in ipairs(self.data) do
        for _, v in pairs(data.candidates) do
            v.gear1 = v.gear1 and addon.Utils:GetTransmittableItemString(v.gear1)
            v.gear2 = v.gear2 and addon.Utils:GetTransmittableItemString(v.gear2)
        end
    end
    return self
end

--- Restructures lootTable data and removes unnecessary fields.
--- Converts from `lootTable[session].candidates[name] = data` to
--- `reconnect[name].field[session] = data`.
--- This makes the table take up less space when serialized.
function Reconnect.private:RestructureData()
    local ret = {}
    for session, d in ipairs(self.data) do
        for name, candData in pairs(d.candidates) do
            if not ret[name] then
                ret[name] = {
                    ilvl = candData.ilvl,
                    gear1 = {
                    },
                    gear2 = {
                    },
                    voters = {
                    },
                    response = {
                    }
                }
            end
            ret[name].gear1[session] = candData.gear1
            ret[name].gear2[session] = candData.gear2
            ret[name].voters[session] = #candData.voters > 0 and candData.voters or nil
            ret[name].response[session] = candData.response
        end
    end
    self.data = ret
    return self
end

--- Converts common responses to a shorter version.
--- "AUTOPASS" becomes `true` while
--- "PASS" becomes `false`.
function Reconnect.private:ConvertResponses()
    local convertResponse = function(response)
        if response == "AUTOPASS" then
            return true
        elseif response == "PASS" then
            return false
        else
            return response
        end
    end
    for _, data in pairs(self.data) do
        for session, response in pairs(data.response) do
            data.response[session] = convertResponse(response)
        end
    end
    return self
end

local key = "|"
-- Yes this is more efficient than an array
local replacements = {
    [key .. "1"] = "ilvl",
    [key .. "2"] = "gear1",
    [key .. "3"] = "gear2",
    [key .. "4"] = "voters",
    [key .. "5"] = "haveVoted",
    [key .. "6"] = "response",
}
local replacements_inv = tInvert(replacements)

--- Replaces names keys with a shortned version using a replacement table.
function Reconnect.private:ReplaceKeys()
    for name, data in pairs(self.data) do
        local new = {}
        for k, v in pairs(data) do
            -- this will also remove any empty values
            if (type(v) == "table" and #v > 0) then
                new[replacements_inv[k]] = v
            end
        end
        self.data[name] = new
    end
    return self, data
end

--- Replaces player names with their shortened guid.
--- If player is from the same realm as us, only the last 8 guid digits is kept.
--- Otherwise we also keep the realm part, ending with 13 bytes (including the '-').
function Reconnect.private:ReplacePlayerNames()
    local ourRealm = addon.player:GetRealm()
    for name, data in pairs(CopyTable(self.data)) do
        local player = Player:Get(name)
        local id = ""
        if player:GetRealm() == ourRealm then
            -- Skip realm part of GUID
            id = player:GetGUID():match("%-([%x]+)$")
        else
            -- Keep realm part
            id = player:GetGUID():match("%-([%d%-%x]+)$")
        end
        self.data[name] = nil
        self.data[id] = data
    end
    return self
end

--- Reverts itemlink shortening, making them useable again.
function Reconnect.private:UndoOptimizeItemLinks()
    local uncleanItems = function(items)
		if not items then return end
        -- items in "gear2" might not be an array, so use pairs
        for k, v in pairs(items) do
            items[k] = addon.Utils:UncleanItemString(v)
        end
    end
    for _, data in pairs(self.restore) do
        uncleanItems(data.gear1)
        if data.gear2 then
            uncleanItems(data.gear2)
        end
    end
    return self
end

--- Reverts our table key replacements.
function Reconnect.private:UndoReplaceKeys()
    for name, data in pairs(self.restore) do
        local new = {}
        for k, v in pairs(data) do
            new[replacements[k]] = v
        end
        self.restore[name] = new
    end
    return self
end

--- Converts shortened responses back to normal.
function Reconnect.private:UndoConvertResponses()
    local convertResponse = function(response)
        if response == true then
            return "AUTOPASS"
        elseif response == false then
            return "PASS"
        else
            return response
        end
    end
    for _, data in pairs(self.restore) do
        for session, response in pairs(data.response) do
            data.response[session] = convertResponse(response)
        end
    end
    return self
end

--- Converts shortened player guid's to their names.
function Reconnect.private:UndoReplacePlayerNames()
    local ourRealmId = addon.player:GetGUID():match("%-([%x]+%-)")
    for id, data in pairs(CopyTable(self.restore)) do
        local guid = ""
        if id:find("-") then
            -- Includes realm, so just insert "Player"
            guid = "Player-" .. id
        else
            -- We also need to insert our realm
            guid = "Player-" .. ourRealmId .. id
        end
        self.restore[id] = nil
        self.restore[Player:Get(guid):GetName()] = data
    end
    return self
end

--- `haveVoted` is removed during restructuring.
--- This function restores it based on voters.
function Reconnect.private:ExtractHaveVoted()
    for name, data in pairs(self.restore) do
        for session, voter in pairs(data.voters or {}) do
            if addon:UnitIsUnit("player", voter) then
                if not data.haveVoted then
                    data.haveVoted = {}
                end
                data.haveVoted[session] = true
            end
        end
    end
    return self
end
