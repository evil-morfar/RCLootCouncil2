--- Class containing various manipulations of ItemLinks/ItemStrings

--- @type RCLootCouncil
local addon = select(2, ...)
--- @class Utils.Item
local Item = addon.Init "Utils.Item"

---@alias ItemString string
---@alias ItemLink string

local gsub, strmatch = string.gsub, string.match

--- Convert to a comms optimized string
---@param link ItemLink
function Item:GetTransmittableItemString(link)
	return self:GetItemStringClean(self:NeutralizeItem(link or ""))
end

--- Convert to an ItemString with `"item:"` removed.
---@param link ItemLink
function Item:GetItemStringClean(link)
	return (gsub(self:GetItemStringFromLink(link) or "", "item:", ""))
end

---Reverts changes made by `GetItemStringClean`
---@param itemString string? As returned from `GetItemStringClean`
---@see Utils.Item.GetItemStringClean
function Item:UncleanItemString(itemString)
	return "item:" .. (itemString or "0")
end

---Converts an ItemLink to an ItemString.
---Note: Trailing `":"`s are removed.
---@param link ItemLink?
---@return ItemString?
function Item:GetItemStringFromLink(link)
	return strmatch(strmatch(link or "", "item:[%d:-]+") or "", "(item:.-):*$")
end

---@param link ItemLink
---@return string #Name of the item
function Item:GetItemNameFromLink(link)
	return strmatch(link or "", "%[(.+)%]")
end

---@param link ItemLink|ItemString
function Item:GetItemIDFromLink(link)
	return tonumber(strmatch(link or "", "item:(%d+):?"))
end

---Appends the item link with `" x ``count``"`, but only if count is defined, and greater than 1.
---@param link string
---@param count integer #Count to append
---@return string
function Item:GetItemTextWithCount(link, count)
	return link .. (count and count > 1 and (" x" .. count) or "")
end

local NEUTRALIZE_ITEM_PATTERN = "item:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):%d*:%d*:%d*:"
local NEUTRALIZE_ITEM_REPLACEMENT = "item:%1:%2:%3:%4:%5:%6:%7::::"

--- Removes any character specific data from an item
--- @param item string|ItemLink|ItemString Any itemlink, itemstring etc.
--- @return string #The same item with level, specID, uniqueID removed
function Item:NeutralizeItem(item)
	return (item:gsub(NEUTRALIZE_ITEM_PATTERN, NEUTRALIZE_ITEM_REPLACEMENT))
end

--- Creates a string with item icon in front of the item link.
---@param item string|ItemID|ItemLink|ItemString|Item
---@return string
function Item:GetItemTextWithIcon(item)
	local _, itemLink, _, _, _, _, _, _, _, texture = C_Item.GetItemInfo(type(item) == "string" and item or item.link)
	if not texture then return item end -- No icon found, return the item link
	return format("|T%s:0|t%s", texture, itemLink)
end

return Item
