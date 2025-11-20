--- Certain functions that are not interchangable between WoW versions are reimplemented here.

--- @class RCLootCouncil
local addon = select(2, ...)

addon.C_Container = C_Container or {
    GetContainerNumSlots = GetContainerNumSlots,
    GetContainerItemLink = GetContainerItemLink,
    GetContainerNumFreeSlots = GetContainerNumFreeSlots,
    GetContainerItemInfo = GetContainerItemInfo,
    PickupContainerItem = PickupContainerItem,
}

addon.C_Item = C_Item or {}
if not addon.C_Item.GetItemStats then
	addon.C_Item.GetItemStats = GetItemStats
end

addon.SendChatMessage = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage

local EnumLootMethod = Enum.LootMethod or {
	Freeforall = 0,
	Roundrobin = 1,
	Masterlooter = 2,
	Group = 3,
	Needbeforegreed = 4,
	Personal = 5,
}

addon.GetLootMethod = C_PartyInfo and C_PartyInfo.GetLootMethod or 
--- Shim between retail and classic and always return the Enum.
--- @return Enum.LootMethod method, integer? partyID, integer? raidId 
function()
	local method, partyID, raidId = GetLootMethod()
	if not method then
		method = EnumLootMethod.Personal
	elseif method == "freeforall" then
		method = EnumLootMethod.Freeforall
	elseif method == "roundrobin" then
		method = EnumLootMethod.Roundrobin
	elseif method == "master" then
		method = EnumLootMethod.Masterlooter
	elseif method == "group" then
		method = EnumLootMethod.Group
	elseif method == "needbeforegreed" then
		method = EnumLootMethod.Needbeforegreed
	elseif method == "personalloot" then
		method = EnumLootMethod.Personal
	end
	return method, partyID, raidId
end