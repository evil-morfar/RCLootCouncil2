--- MLDB.lua Class for mldb handling.
-- @author Potdisc
-- Create Date: 15/10/2020

local _, addon = ...
--- @class MLDB
local MLDB = addon.Init "Data.MLDB"
local TT = addon.Require "Utils.TempTable"
local Comms = addon.Require "Services.Comms"

local private = {
    mldb = {}
}

local magicKey = "|"

local replacements = {
    [magicKey .. "1"] = "selfVote",
    [magicKey .. "2"] = "multiVote",
    [magicKey .. "3"] = "anonymousVoting",
    [magicKey .. "4"] = "allowNotes",
    [magicKey .. "5"] = "numButtons",
    [magicKey .. "6"] = "hideVotes",
    [magicKey .. "7"] = "observe",
    [magicKey .. "8"] = "buttons",

    [magicKey .. "9"] = "rejectTrade",
    [magicKey .. "10"] = "requireNotes",

    [magicKey .. "11"] = "responses",
    [magicKey .. "12"] = "timeout",
    [magicKey .. "13"] = "outOfRaid",

    [magicKey .. "14"] = "default",
    [magicKey .. "15"] = "text",
    [magicKey .. "16"] = "color"

}

local replacements_inv = tInvert(replacements)

--- Gets a transmittable version of the MLDB
--- @param input table @lol MLDB to convert. Defaults to addon MLDB. 
function MLDB:GetForTransmit(input)
    local mldb = input or private.mldb
    return private:ReplaceMLDB(mldb)
end

--- Sends the mldb to the target
--- @param target string @The target to send to - defaults to "group"
function MLDB:Send(target) 
    Comms:Send{
        target = target,
        command = "mldb",
        data = self:GetForTransmit()
    }
end

function private:ReplaceMLDB(mldb)
    local ret = {}
    for k, v in pairs(mldb) do
        if (type(v) == "table") then 
         v = private:ReplaceMLDB(v) end
        if replacements_inv[k] then
            ret[replacements_inv[k]] = v
        else
            ret[k] = v
        end
    end
    return ret
end