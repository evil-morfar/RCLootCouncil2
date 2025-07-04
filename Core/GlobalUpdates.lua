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