--- Certain functions that are not interchangable between WoW versions are reimplemented here.

local _, addon = ...

addon.C_Container = C_Container or {
    GetContainerNumSlots = GetContainerNumSlots,
    GetContainerItemLink = GetContainerItemLink,
    GetContainerNumFreeSlots = GetContainerNumFreeSlots,
    GetContainerItemInfo = GetContainerItemInfo,
    PickupContainerItem = PickupContainerItem,
}