--- GroupLoot.lua Class for handling Group Loot interactions.
-- @author Potdisc
-- Create Date: 09/11/2022

--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Utils.GroupLoot
local GroupLoot = addon.Init "Utils.GroupLoot"

function GroupLoot:OnInitialize()
    self.Log = addon.Require "Utils.Log":New "GroupLoot"
    addon:RegisterEvent("START_LOOT_ROLL", self.OnStartLootRoll, self)
end

function GroupLoot:OnStartLootRoll()
    if not addon.enabled then return self.Log:d("Addon disabled, ignoring group loot") end
    if self:ShouldPassOnLoot() then
        self.Log:d("Passing on loot")
        self:RollOnAllLoot(0)

    elseif self:ShouldGreedOnLoot() then
        self.Log:d("Greeding on loot")
        self:RollOnAllLoot(2)
    end
end

--- @alias RollType
--- | 0 #Pass
--- | 1 #Need
--- | 2 Greed
--- | 3 Disenchant

--- Rolls on all items in group loot frame.
--- Note this function doesn't check if the chosen type is valid
--- @param rollType? RollType Type to roll
function GroupLoot:RollOnAllLoot(rollType)
    for _, rollID in ipairs(GetActiveLootRollIDs()) do
        RollOnLoot(rollID, rollType)
        --ConfirmLootRoll(rollID, rollType)
    end
end

function GroupLoot:ShouldPassOnLoot()
    return addon.mldb and addon.mldb.autoGroupLoot and addon.handleLoot and
        addon.masterLooter and not addon.isMasterLooter and GetNumGroupMembers() > 1

end

function GroupLoot:ShouldGreedOnLoot()
    return addon.mldb and addon.mldb.autoGroupLoot and addon.handleLoot and
        addon.masterLooter and addon.isMasterLooter and GetNumGroupMembers() > 1
end
