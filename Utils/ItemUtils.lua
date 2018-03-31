local MAJOR,MINOR = "RCItemUtils-1.0", 1
local RCItemUtils, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

local attributesName = {"numLines", "leftTexts", "rightTexts"}
local attributesDefault = {}
local attributesInfo = {}
local itemInfos = {}

local tempTable = {}

local strmatch = string.match
local select = select
local type = type
local error = error
local tinsert = table.insert
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local wipe = wipe
local UIParent = UIParent
local getglobal = getglobal
local string_gmatch = string.gmatch

local tooltip = CreateFrame("GameTooltip", "RCItemUtils_Tooltip", nil, "GameTooltipTemplate")
tooltip:UnregisterAllEvents()

local function GetItemStringFromLink(link)
	return strmatch(link or "", "(item:.-):*|h") -- trim trailing colons
end

local function _CheckNewAttributeInput(usage, ...)
	local nAttributes = select("#", ...)
	if nAttributes <= 0 then
		error(usage.." 'attribute' - need to specify at least one attribute.", 3)
	end
	wipe(tempTable)
	local nRealAttributes = 0
	for i = 1, nAttributes do
		local attribute = select(i, ...)
		if type(attribute) ~= "string" then
			error((usage.." 'attribute' - string expected got '%s' ('%s')."):format(type(attribute), tostring(attribute)), 3)
		end
		if attribute ~= "" then
			if attributesName[attribute] then
				error((usage.." attribute already exists: '%s'."):format(tostring(attribute)), 3)
			elseif tempTable[attribute] then
				error((usage.." Duplicate attribute: '%s'."):format(tostring(attribute)), 3)
			end
			tinsert(tempTable, attribute)
			nRealAttributes = nRealAttributes + 1
		end
	end
	if nRealAttributes <= 0 then
		error(usage.." Need to specify at one attribute that is not empty string.", 3)
	end
end

local function AddAttributeByAPI(needLoad, api, ...)
	if type(needLoad) ~= "boolean" then
		error(("Usage: AddAttributeByAPI(needLoad, api, attribute...): 'needLoad' - boolean expected got '%s' ('%s')."):format(type(needLoad), tostring(needLoad)), 2)
	end
	if type(api) ~= "function" then
		error(("Usage: AddAttributeByAPI(needLoad, api, attribute...): 'api' - function expected got '%s' ('%s')."):format(type(api), tostring(api)), 2)
	end
	for i = 1, #attributesInfo do
		local info = attributesInfo[i]
		if info.type == "api" and info.api == api then
			error(("Usage: AddAttributeByAPI(needLoad, api, attribute...): 'api' - api is already used."):format(tostring(api)), 2)
		end
	end
	_CheckNewAttributeInput("Usage: AddAttributeByAPI(needLoad, api, attribute...): ", ...)

	local info = {}
	info.type = "api"
	info.api = api

	for i = 1, select("#", ...) do
		local attribute = select(i, ...)
		info[i] = attribute
		attributesName[attribute] = true
	end
	tinsert(attributesInfo, info)
end

local function AddAttributeByTooltip(needParse, direction, pattern, ...)
	if type(needParse) ~= "string" then
		error(("Usage: AddAttributeByTooltip(needParse, direction, pattern, attribute...): 'needParse' - boolean expected got '%s' ('%s')."):format(type(needParse), tostring(needParse)), 2)
	end
	if direction ~= "left" and direction ~= "right" then
		error(("Usage: AddAttributeByTooltip(needParse, direction, pattern, attribute...): 'direction' must be 'left' or 'right'"), 2)
	end
	if type(pattern) ~= "string" then
		error(("Usage: AddAttributeByTooltip(needParse, direction, pattern, attribute...): 'pattern' - string expected got '%s' ('%s')."):format(type(pattern), tostring(pattern)), 2)
	end
	_CheckNewAttributeInput("Usage: AddAttributeByTooltip(needParse, direction, pattern, attribute...)", ...)
	if not needParse then
		if select("#", ...) > 1 then
			error(("Usage: AddAttributeByTooltip(needParse, direction, pattern, attribute...): if needParse is false, only 1 attribute can be specified."), 2)
		end
	end

	local info = {}
	info.type = "tooltip"
	info.needParse = needParse
	info.dir = direction
	info.pattern = pattern

	for i = 1, select("#", ...) do
		local attribute = select(i, ...)
		info[i] = attribute
		attributesName[attribute] = true
	end
	tinsert(attributesInfo, info)
end

local function SetAttributeDefault(attribute, default)
	if type(attribute) ~= "string" then
		error(("Usage: SetAttributeDefault(attribute, default): 'attribute' - string expected got '%s' ('%s')."):format(type(attribute), tostring(attribute)), 2)
	end
	if not attributesName[attribute] then
		error(("Usage: SetAttributeDefault(attribute, default): Attribute does not exist: '%s'."):format(tostring(attribute)), 2)
	end
	if attributesDefault[attribute] then
		error(("Usage: SetAttributeDefault(attribute, default): Attribute default had been set before: %s."):format(tostring(default)), 2)
	end
	if type(default) == "nil" then
		error(("Usage: SetAttributeDefault(attribute, default): 'default' must not be nil."), 2)
	end

	attributesDefault[attribute] = default
end

local function _AssignAPIReturnToAttr(itemInfo, apiInfo, ...)
	for i = 1 , select("#", ...) do
		local attr = apiInfo[i]
		if attr and attr ~= "" then
			itemInfo[attr] = attr
		end
	end
end

local function CacheItem(item)
	if type(item) ~= "string" then
		error(("Usage: CacheItem(item): 'item' - string expected got '%s' ('%s')."):format(type(item), tostring(item)), 2)
	end
	item = GetItemStringFromLink(item)
	if itemInfos[item] and itemInfos[item].cached then
		return
	else
		itemInfos[item] = itemInfos[item] or {}
		local itemInfo = itemInfos[item]
		local loaded = GetItemInfo(item) ~= nil -- TODO: Replace this function by cheaper version in BFA
		for _, apiInfo in ipairs(attributesInfo) do
			if apiInfo.type == "api" then
				if loaded or not apiInfo.needLoad then
					_AssignAPIReturnToAttr(itemInfo, apiInfo, apiInfo.api(item))
				end
			end
		end

		-- Store tooltip texts
		itemInfo.numLines = 0
		itemInfo.leftTexts = itemInfo.leftTexts or {}
		itemInfo.rightTexts = itemInfo.rightTexts or {}
		wipe(itemInfo.leftTexts)
		wipe(itemInfo.rightTexts)

		if loaded then
			tooltip:SetOwner(UIParent, "ANCHOR_NONE") -- This lines clear the current content of tooltip and set its position off-screen
			tooltip:SetHyperlink(item) -- Set the tooltip content and show it, should hide the tooltip before function ends
			itemInfo.numLines = tooltip:NumLines() or 0

			-- Store tooltip text
			for i = 1, itemInfo.numLines do
				local leftLine = getglobal(tooltip:GetName()..'TextLeft' .. i)
				local leftText = leftLine and leftLine.GetText and leftLine:GetText()
				itemInfo.leftTexts[i] = leftText

				local rightLine = getglobal(tooltip:GetName()..'TextRight' .. i)
				local rightText = rightLine and rightLine.GetText and rightLine:GetText() or ""
				itemInfo.rightTexts[i] = rightText
			end

			tooltip:Hide()
			itemInfos[item].cached = true

			-- String match tooltip texts to attributes
			for i = 1, itemInfo.numLines do
				local leftText = itemInfo.leftTexts[i]
				local rightText = itemInfo.rightTexts[i]

				for _, attrInfo in ipairs(attributesInfo) do
					if attrInfo.type == "tooltip" then
						local text = ""
						if attrInfo.dir == "left" and leftText then
							text = leftText
						elseif attrInfo.dir == "right" and rightText then
							text = rightText
						end
						if text ~= "" then
							if attrInfo.needParse then
								local index = 1
								for str in string_gmatch(text, attrInfo.pattern) do
									local attr = attrInfo[i]
									if attr and attr ~= "" then
										itemInfo[attr] = str
									end
									index = index + 1
								end
							else
								local attr = attrInfo[1]
								if strmatch(text, attrInfo.pattern) then
									itemInfo[attr] = true
								else
									itemInfo[attr] = false
								end
							end
						end
					end
				end
			end

		end
	end
end

local function GetItemAttr(item, attribute)
	if type(item) ~= "string" then
		error(("Usage: GetItemAttr(item, attribute): 'item' - string expected got '%s' ('%s')."):format(type(item), tostring(item)), 2)
	end
	if type(attribute) ~= "string" then
		error(("Usage: GetItemAttr(item, attribute): 'attribute' - string expected got '%s' ('%s')."):format(type(attribute), tostring(attribute)), 2)
	end
	if not item:find("item:") then
		error(("Usage: GetItemAttr(item, attribute): 'item' is not an item string/link ('%s')."):format(item), 2)
	end
	if not attributesName[attribute] then
		error(("Usage: GetItemAttr(item, attribute): Attribute does not exist: '%s'."):format(tostring(attribute)), 2)
	end

	item = GetItemStringFromLink(item)

	if itemInfos[item] then
		return itemInfos[item][attribute]
	else
		CacheItem(item)
		return itemInfos[item][attribute] ~= nil and itemInfos[item][attribute] or attributesDefault[attribute]
	end
end

----------------------------------------
-- Add item attributes here
----------------------------------------

-- AddAttributeByAPI(needLoad, api, attribute...)
AddAttributeByAPI(false, GetItemInfoInstant, "id", "type", "subType", "equipLoc", "texture", "typeID", "subTypeID")
AddAttributeByAPI(true, GetItemInfo, "name", "link", "quality", "ilvl", "reqLevel", "", "", "maxStack", "", "", "vendorPrice", "", "", "bindType", "expacID", "setID", "isCraftingReagent")
AddAttributeByAPI(true, function(item) return GetItemQualityColor(GetItemAttr(item, "quality")) end, "r", "g", "b", "qualityColorHex")
AddAttributeByAPI(true, GetItemFamily, "bagType")
AddAttributeByAPI(true, GetItemStats, "stats")
AddAttributeByAPI(true, GetItemSpell, "spellName")
AddAttributeByAPI(true, IsEquippableItem, "isEquippable")
AddAttributeByAPI(true, IsConsumableItem, "isConsumable")

-- AddAttributeByTooltip(needParse, direction, pattern, attribute...)
AddAttributeByTooltip(false, "left", "^"..ITEM_TOURNAMENT_GEAR.."$", "isTournamentGear")
AddAttributeByTooltip(false, "left", ITEM_SPELL_TRIGGER_ONEQUIP, "hasOnEquipEffect")
AddAttributeByTooltip(false, "left", ITEM_SPELL_TRIGGER_ONPROC, "hasProc")
AddAttributeByTooltip(false, "left", "^"..ITEM_SPELL_KNOWN.."$", "isSpellKnown")
AddAttributeByTooltip(false, "left", "^"..TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN.."$", "isAppearanceUnknown")

AddAttributeByTooltip(true, "right", "^(%d.%d)$", "weaponBaseSpeed") -- TODO: Need testing

-- SetAttributeDefault(attribute, default)
SetAttributeDefault("name", RETRIEVING_ITEM_INFO)
SetAttributeDefault("link", "-- "..RETRIEVING_ITEM_INFO.." --")
SetAttributeDefault("quality", LE_ITEM_QUALITY_COMMON)
SetAttributeDefault("ilvl", -1)
SetAttributeDefault("reqLevel", 0)
SetAttributeDefault("maxStack", 1)
SetAttributeDefault("vendorPrice", 1)
SetAttributeDefault("bindType", LE_ITEM_BIND_ON_ACQUIRE)

SetAttributeDefault("r", 1)
SetAttributeDefault("g", 1)
SetAttributeDefault("b", 1)
SetAttributeDefault("qualityColorHex", "ffffff")

SetAttributeDefault("bagType", 0)
SetAttributeDefault("stats", {})
SetAttributeDefault("isEquippable", false)
SetAttributeDefault("isConsumable", false)

SetAttributeDefault("texture", "Interface/ICONS/INV_Misc_QuestionMark")
SetAttributeDefault("isAppearanceUnknown", true)

----------------------------------------
-- Base library stuff
----------------------------------------

RCItemUtils.internals = {	-- for test scripts
}

local mixins = {
	"GetItemAttr",
	"CacheItem",
	"GetItemStringFromLink",
}

RCItemUtils.embeds = RCItemUtils.embeds or {}

function RCItemUtils:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

-- Update embeds
for target, v in pairs(RCItemUtils.embeds) do
	RCItemUtils:Embed(target)
end