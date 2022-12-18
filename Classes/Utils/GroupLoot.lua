--- GroupLoot.lua Class for handling Group Loot interactions.
-- @author Potdisc
-- Create Date: 09/11/2022

--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Utils.GroupLoot
local GroupLoot = addon.Init "Utils.GroupLoot"
local Subject = addon.Require("rx.Subject")

--- @class OnLootRoll
--- Called everytime we're auto rolling for loot.
--- Subscriber functions are called with args: `itemLink` ,`rollID`, `rollType`
--- @field subscribe fun(onNext: fun(link:ItemLink, rollID:integer, rollType:RollType), onError:fun(message:string), onComplete:fun()): rx.Subscription
GroupLoot.OnLootRoll = Subject.create()

function GroupLoot:OnInitialize()
	self.Log = addon.Require "Utils.Log":New "GroupLoot"
	addon:RegisterEvent("START_LOOT_ROLL", self.OnStartLootRoll, self)
end

function GroupLoot:OnStartLootRoll(_, rollID)
	if not addon.enabled then return self.Log:d("Addon disabled, ignoring group loot") end
	local link = GetLootRollItemLink(rollID)
	if self:ShouldPassOnLoot() then
		self.Log:d("Passing on loot", link)
		self:RollOnLoot(rollID, 0)
		self.OnLootRoll(link, rollID, 0)

	elseif self:ShouldGreedOnLoot() then
		self.Log:d("Greeding on loot", link)
		self:RollOnLoot(rollID, 2)
		self.OnLootRoll(link, rollID, 2)
	end
end

--- @alias RollType
--- | 0 #Pass
--- | 1 #Need
--- | 2 Greed
--- | 3 Disenchant

--- Rolls on all items in group loot frame.
--- Note this function doesn't check if the chosen type is valid
--- @param rollID integer Id of the loot roll.
--- @param rollType? RollType Type to roll
function GroupLoot:RollOnLoot(rollID, rollType)
	RollOnLoot(rollID, rollType)
	--ConfirmLootRoll(rollID, rollType)
end

function GroupLoot:ShouldPassOnLoot()
	local db = addon:Getdb()
	return addon.mldb and addon.mldb.autoGroupLoot and addon.handleLoot and
		addon.masterLooter and not addon.isMasterLooter and GetNumGroupMembers() > 1
		and (db.autoGroupLootGuildGroupOnly and addon.leaderIsFromGuild or not db.autoGroupLootGuildGroupOnly)
end

function GroupLoot:ShouldGreedOnLoot()
	return addon.mldb and addon.mldb.autoGroupLoot and addon.handleLoot and
		addon.masterLooter and addon.isMasterLooter and GetNumGroupMembers() > 1
end
