--- MLDB.lua Class for mldb handling.
-- @author Potdisc
-- Create Date: 15/10/2020
---@type RCLootCouncil
local _, addon = ...
---@class Data.MLDB
local MLDB = addon.Init "Data.MLDB"
---@type Services.Comms
local Comms = addon.Require "Services.Comms"

local private = {
    ---@class MLDB
    mldb = {},
    isBuilt = false
}

local magicKey = "|"

local replacements = {
    [magicKey .. "1"] = "selfVote",
    [magicKey .. "2"] = "multiVote",
    [magicKey .. "3"] = "anonymousVoting",
    [magicKey .. "4"] = "sort",
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
--- @param input MLDB @MLDB to convert. Defaults to addon MLDB.
---@return table @MLDB that's ready for transmit.
function MLDB:GetForTransmit(input)
    local mldb = input or (private.isBuilt and private.mldb or private:BuildMLDB())
    return private:ReplaceMLDB(mldb, replacements_inv)
end

--- Restores a transmitted MLDB and returns it
---@param input table @Table as returned fr["m
---@see Data.MLDB#GetForTransmit
function MLDB:RestoreFromTransmit(input)
    private.mldb = private:ReplaceMLDB(input, replacements)
    return private.mldb
end

--- Sends the mldb to the target
--- @param target Player @The target to send to - defaults to "group"
function MLDB:Send(target)
    Comms:Send {
        target = target,
        command = "mldb",
        data = {self:GetForTransmit()}
    }
end

function MLDB:Get()
    return private.isBuilt and private.mldb or private:BuildMLDB()
end

function MLDB:Update()
    return private:BuildMLDB()
end

function private:ReplaceMLDB(mldb, replacement_table)
    local ret = {}
    for k, v in pairs(mldb) do
        if (type(v) == "table") then
            v = self:ReplaceMLDB(v, replacement_table)
        end
        if replacement_table[k] then
            ret[replacement_table[k]] = v
        else
            ret[k] = v
        end
    end
    return ret
end

function private:BuildMLDB()
    local db = addon:Getdb()
    -- Extract changes to responses/buttons
    local changedResponses = {}
    for type, responses in pairs(db.responses) do
        for i in ipairs(responses) do
            if i > db.buttons[type].numButtons then
                break
            end
            if
                not addon.defaults.profile.responses[type] or
                    db.responses[type][i].text ~= addon.defaults.profile.responses[type][i].text or
                    unpack(db.responses[type][i].color) ~= unpack(addon.defaults.profile.responses[type][i].color)
             then
                if not changedResponses[type] then
                    changedResponses[type] = {}
                end
                changedResponses[type][i] = db.responses[type][i]
            end
        end
    end
    local changedButtons = {default = {}}
    for type, buttons in pairs(db.buttons) do
        for i in ipairs(buttons) do
            if i > db.buttons[type].numButtons then
                break
            end
            if
                not addon.defaults.profile.buttons[type] or
                    db.buttons[type][i].text ~= addon.defaults.profile.buttons[type][i].text
             then
                if not changedButtons[type] then
                    changedButtons[type] = {}
                end
                changedButtons[type][i] = {text = db.buttons[type][i].text}
            end
        end
    end
    changedButtons.default.numButtons = db.buttons.default.numButtons -- Always include this

    self.mldb = {
        selfVote = db.selfVote or nil,
        multiVote = db.multiVote or nil,
        anonymousVoting = db.anonymousVoting or nil,
        numButtons = db.buttons.default.numButtons, -- v2.9: Kept as to not break backwards compability on mldb comms. Not used any more
        hideVotes = db.hideVotes or nil,
        observe = db.observe or nil,
        buttons = changedButtons, -- REVIEW I'm not sure if it's feasible to nil out empty tables
        responses = changedResponses,
        timeout = db.timeout,
        rejectTrade = db.rejectTrade or nil,
        requireNotes = db.requireNotes or nil,
        outOfRaid = db.outOfRaid or nil
    }
    self.isBuilt = true
    return self.mldb
end
