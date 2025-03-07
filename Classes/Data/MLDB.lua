--- MLDB.lua Class for mldb handling.
-- @author Potdisc
-- Create Date: 15/10/2020
--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Data.MLDB
local MLDB = addon.Init "Data.MLDB"
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
    [magicKey .. "16"] = "color",
    [magicKey .. "17"] = "autoGroupLoot",
    [magicKey .. "18"] = "requireNotes",
}

local replacements_inv = tInvert(replacements)

--- Gets a transmittable version of the MLDB
--- @param input MLDB? @MLDB to convert. Defaults to addon MLDB.
---@return table @MLDB that's ready for transmit.
function MLDB:GetForTransmit(input)
    local mldb
    if input then
        mldb = input
    else
        mldb = private.isBuilt and private.mldb or private:BuildMLDB()
    end
    
    if type(mldb) ~= "table" then
        addon.Log:D("MLDB:GetForTransmit received non-table input")
        return {}  -- Return empty table to avoid errors
    end
    
    return private:ReplaceMLDB(mldb, replacements_inv)
end

--- Restores a transmitted MLDB and returns it
---@param input table @Table as returned fr["m
---@see Data.MLDB#GetForTransmit
function MLDB:RestoreFromTransmit(input)
    if type(input) ~= "table" then
        addon.Log:D("MLDB:RestoreFromTransmit received non-table input")
        return {}  -- Return empty table to avoid errors
    end
    
    private.mldb = private:ReplaceMLDB(input, replacements)
    return private.mldb
end

--- Sends the mldb to the target
--- @param target Player|"group" @The target to send to - defaults to "group"
function MLDB:Send(target)
    local success, data = pcall(function() 
        return {self:GetForTransmit()}
    end)
    
    if not success then
        addon.Log:D("Error preparing MLDB data for transmission: " .. (data or "unknown error"))
        return
    end
    
    Comms:Send {
        target = target,
        command = "mldb",
        data = data
    }
end

function MLDB:Get()
    return private.isBuilt and private.mldb or private:BuildMLDB()
end

function MLDB:Update()
    return private:BuildMLDB()
end

--- Checks if a given value is part of the mldb
---@param val string Value to check
function MLDB:IsKey(val)
    return replacements_inv[val] and true or false
end

function private:ReplaceMLDB(mldb, replacement_table)
    if type(mldb) ~= "table" or type(replacement_table) ~= "table" then
        return {}
    end
    
    local ret = {}
    for k, v in pairs(mldb) do
        -- Handle recursive table replacement safely
        if type(v) == "table" then
            local success, result = pcall(function()
                return self:ReplaceMLDB(v, replacement_table)
            end)
            
            if success then
                v = result
            else
                addon.Log:D("Error in ReplaceMLDB recursion: " .. (result or "unknown error"))
                v = {} -- Fallback to empty table on error
            end
        end
        
        if replacement_table[k] then
            ret[replacement_table[k]] = v
        else
            ret[k] = v
        end
    end
    return ret
end

-- Helper function to check if a response has changed from defaults
function private:HasResponseChanged(respType, index, db)
    -- No defaults to compare against
    if not addon.defaults.profile.responses[respType] then
        return true
    end
    
    local response = db.responses[respType][index]
    local default = addon.defaults.profile.responses[respType][index]
    
    -- Check if text changed
    if response.text ~= default.text then
        return true
    end
    
    -- Check if color changed
    if unpack(response.color) ~= unpack(default.color) then
        return true
    end
    
    return false
end

-- Helper function to check if a button has changed from defaults
function private:HasButtonChanged(btnType, index, db)
    -- No defaults to compare against
    if not addon.defaults.profile.buttons[btnType] then
        return true
    end
    
    local button = db.buttons[btnType][index]
    local default = addon.defaults.profile.buttons[btnType][index]
    
    -- Check if text or requireNotes changed
    return button.text ~= default.text or button.requireNotes ~= default.requireNotes
end

function private:BuildMLDB()
    local db = addon:Getdb()
    -- Extract changes to responses/buttons
    local changedResponses = {}
    for respType, responses in pairs(db.responses) do
        if type(responses) == "table" then
            for i in ipairs(responses) do
                if i > db.buttons[respType].numButtons then
                    break
                end
                
                if self:HasResponseChanged(respType, i, db) then
                    if not changedResponses[respType] then
                        changedResponses[respType] = {}
                    end
                    changedResponses[respType][i] = db.responses[respType][i]
                end
            end
        end
    end
    
    local changedButtons = {default = {}}
    for btnType, buttons in pairs(db.buttons) do
        if type(buttons) == "table" then
            for i in ipairs(buttons) do
                if i > db.buttons[btnType].numButtons then
                    break
                end
                
                if self:HasButtonChanged(btnType, i, db) then
                    if not changedButtons[btnType] then
                        changedButtons[btnType] = {}
                    end
                    changedButtons[btnType][i] = { 
                        text = db.buttons[btnType][i].text, 
                        requireNotes = db.buttons[btnType][i].requireNotes 
                    }
                end
            end
        end
    end
    changedButtons.default.numButtons = db.buttons.default.numButtons -- Always include this

    self.mldb = {
        selfVote = db.selfVote,
        multiVote = db.multiVote,
        anonymousVoting = db.anonymousVoting,
        numButtons = db.buttons.default.numButtons, -- v2.9: Kept as to not break backwards compability on mldb comms. Not used any more
        hideVotes = db.hideVotes,
        observe = db.observe,
        buttons = changedButtons,
        responses = changedResponses,
        timeout = db.timeout,
        rejectTrade = db.rejectTrade,
        requireNotes = db.requireNotes,
        outOfRaid = db.outOfRaid,
        autoGroupLoot = db.autoGroupLoot
    }
    self.isBuilt = true
    return self.mldb
end
