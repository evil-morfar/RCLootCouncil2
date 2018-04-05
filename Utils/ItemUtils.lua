local addon = select(2, ...)

local Item = addon:NewAPI("Item")
local private = {}

local _reserved = {"attrType", "api", "pattern", "dir", "loaded", "numLines", "leftTexts", "rightTexts", "needLoad", "needParse"}
local _attributesDefault = {}
local _attributesInfo = {}
local _itemInfos = {}
local _tempTable = {}
local _RC_ITEM_UTILS_NIL = function() end
local _tooltip = CreateFrame("GameTooltip", "RCItemUtils_Tooltip", nil, "GameTooltipTemplate")
_tooltip:UnregisterAllEvents()
_tooltip:Hide()

local error = error
local format = format
local getglobal = getglobal
local ipairs = ipairs
local pairs = pairs
local select = select
local string_gmatch = string.gmatch
local strmatch = string.match
local tconcat = table.concat
local tContains = tContains
local tinsert = table.insert
local tonumber = tonumber
local tostring = tostring
local type = type
local UIParent = UIParent
local unpack = unpack
local wipe = wipe

local DoesItemContainSpec = DoesItemContainSpec
local GetItemInfo = GetItemInfo
local GetNumClasses = GetNumClasses
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID

--- Convert an item string or link to item id.
--@tparam {string} link An item string or link.
--@treturn {number} The item id.
function Item:GetItemIDFromLink(link)
	if type(link) ~= "string" then
		error(("Usage: Item:GetItemIDFromLink(link): 'link' - string expected, got '%s' (%s)"):format(type(link), tostring(link)), 2)
	end
	local id = tonumber(strmatch(link or "", "item:(%d+)"))
	if not id then
		error(("Usage: Item:GetItemIDFromLink(link): 'link' - Invalid item string/link: %s"):format(tostring(link)), 2)
	end
	return id
end

--- Convert an item number/string/link to the an item string without trailing colons.
-- Note: Item link looks like "|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r"
-- Item string looks like "item:3299::::::::20:257::::::"
-- Return value looks like "item:3299::::::::20:257"
--@tparam {number, string} item An item number/string/link.
--@treturn {string} The item string without trailing colons.
function Item:GetShortItemString(item)
	if type(item) ~= "string" and type(item) ~= "number" then
		error(("Usage: Item:GetShortItemString(link): 'link' - string expected, got '%s' (%s)"):format(type(item), tostring(item)), 2)
	end
	if type(item) == "number" then
		return "item:"..item
	end
	if not item:find("item:%d+") then
		error(("Usage: Item:GetShortItemString(link): 'link' - Invalid item string/link: %s"):format(tostring(item)), 2)
	end
	if item:find("|") then -- item link
		return strmatch(item or "", "(item:.-):*|h") -- trim trailing colons
	else -- item string
		return item
	end
end

--- Send a request to cache the item info of an item, if it hasn't been cached. Do nothing if already cached.
--@tparam {number, string} item item id/string/link
--@treturn {boolean} true if the item has been cached, false otherwise.
function Item:CacheItem(item)
	if type(item) ~= "string" and type(item) ~= "number" then
		error(("Usage: CacheItem(item): 'item' - string/number expected got '%s' ('%s')."):format(type(item), tostring(item)), 2)
	end
	item = Item:GetShortItemString(item)
	if not item:find("item:") then
		error(("Usage: CacheItem(item): 'item' - invalid item id/string/link, got %s'."):format(tostring(item)), 2)
	end
	_itemInfos[item] = _itemInfos[item] or {}
	local itemInfo = _itemInfos[item]
	if itemInfo.loaded then
		return true
	else
		itemInfo.loaded = (GetItemInfo(item) ~= nil)
		return itemInfo.loaded
	end
end

--- Return if the item info has been already cached (fetched from the disk).
--@tparam {number, string} item item id/string/link
--@treturn {boolean} true if the item has been cached, false otherwise.
function Item:IsItemCached(item)
	return GetItemInfo(item) ~= nil
end

--- Get an item attribute WITHOUT storing the result inside the internal database of this API.
-- will fetch the result directly from the database without calling WoW CAPI if the result has been stored before.
--@tparam {number, string} item: item id/string/link
--@return the item attribute requested. return nil if the attribute wasn't stored, and the item info hasn't been cached and the attribute requires caching.
function Item:GetItemAttrNoCache(item, attribute)
	return private:GetItemAttrInternal(item, attribute, true)
end

--- Get an item attribute WITH storing the result inside the internal database of this API.
-- will fetch the result directly from the database without calling WoW CAPI if the result has been stored before.
--@tparam {number, string} item: item id/string/link
--@return the item attribute requested. return nil if the attribute wasn't stored, and the item info hasn't been cached and the attribute requires caching.
function Item:GetItemAttr(item, attribute)
	return private:GetItemAttrInternal(item, attribute, false)
end

local _trinketCategories = {
	["3F7777777777"] = ALL_CLASSES, -- All Classes
	["365002707767"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT, -- Strength/Agility
	["000000700067"] = ITEM_MOD_STRENGTH_SHORT, -- Strength
	["365002707467"] = MELEE, -- Melee
	["3F7777077710"] = ITEM_MOD_AGILITY_SHORT.."/"..ITEM_MOD_INTELLECT_SHORT, -- Agility/Intellect
	["365002007700"] = ITEM_MOD_AGILITY_SHORT, -- Agility
	["092775070010"] = ITEM_MOD_INTELLECT_SHORT, -- Intellect
	["241000100024"] = TANK, -- Tank
	["000000000024"] = TANK..", "..BLOCK, -- Tank, Block (Warrior, Paladin)
	["201000100024"] = TANK..", "..PARRY, -- Tank, Parry (Non-Druid)
	["082004030010"] = HEALER, -- Healer
	["124002607743"] = DAMAGER..", "..ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT, -- Damage, Strength/Agility
	["000000600043"] = DAMAGER..", "..ITEM_MOD_STRENGTH_SHORT, -- Damage, Strength
	["124002007700"] = DAMAGER..", "..ITEM_MOD_AGILITY_SHORT, -- Damage, Agility
	["124002607443"] = DAMAGER..", "..MELEE, -- Damage, Melee
	["124002007400"] = DAMAGER..", "..MELEE..", "..ITEM_MOD_AGILITY_SHORT, -- Damage, Melee, Agility
	["010771050300"] = DAMAGER..", "..RANGED, -- Damage, Ranged
	["010771050000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect
	["010671040000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (direct damage, no affliction warlock and shadow priest)
	["010771040000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT, -- Damage, Intellect (no discipline)

	-- The following categories does not make sense. Most likely a Blizzard error in the Encounter Journal for several old trinkets.
	-- Add "?" as a suffix to the description as the result
	["041000100024"] = ALL_CLASSES.."?", -- All Classes?
	["365002107467"] = MELEE.."?", -- Melee? （Missing Frost and Unholy DK)
	["241000100044"] = TANK.."?", -- Tank? (Ret instead of Pro?)
	["124002607703"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	["367002707767"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	["324001607743"] = ITEM_MOD_STRENGTH_SHORT.."/"..ITEM_MOD_AGILITY_SHORT.."?", -- Strength/Agility?
	["324002007700"] = ITEM_MOD_AGILITY_SHORT.."?", -- Agility? (Missing Brewmaster)
	["092775070310"] = ITEM_MOD_AGILITY_SHORT.."/"..ITEM_MOD_INTELLECT_SHORT.."?", -- Agility/Intellect?
	["092005070010"] = ITEM_MOD_INTELLECT_SHORT.."?", -- Intellect? (Missing Mage, Warlock)
	["092075070010"] = ITEM_MOD_INTELLECT_SHORT.."?", -- Intellect? (Missing Warlock)
	["010773050000"] = DAMAGER..", "..ITEM_MOD_INTELLECT_SHORT.."?", -- Damage, Intellect? (+Enhancement Shaman)
}

function Item:GetTrinketCategories()
	return _trinketCategories
end

-- ============================================================================
-- private functions
-- ============================================================================

function private:AddAttributeByAPI(needLoad, api, ...)
	if type(needLoad) ~= "boolean" then
		error(("Usage: private:AddAttributeByAPI(needLoad, api, attribute...): 'needLoad' - boolean expected got '%s' ('%s')."):format(type(needLoad), tostring(needLoad)), 2)
	end
	if type(api) ~= "function" then
		error(("Usage: private:AddAttributeByAPI(needLoad, api, attribute...): 'api' - function expected got '%s' ('%s')."):format(type(api), tostring(api)), 2)
	end
	for i = 1, #_attributesInfo do
		local info = _attributesInfo[i]
		if info.attrType == "api" and info.api == api then
			error(("Usage: private:AddAttributeByAPI(needLoad, api, attribute...): 'api' - api is already used."):format(tostring(api)), 2)
		end
	end
	private:CheckNewAttributeInput("Usage: private:AddAttributeByAPI(needLoad, api, attribute...): ", ...)

	local info = {}
	info.attrType = "api"
	info.api = api
	info.needLoad = needLoad

	for i = 1, select("#", ...) do
		local attribute = select(i, ...)
		if attribute ~= "" then
			info[i] = attribute
			info[attribute] = i
			_attributesInfo[attribute] = info
		end
	end
end

function private:AddAttributeByTooltip(needParse, direction, pattern, ...)
	if type(needParse) ~= "boolean" then
		error(("Usage: private:AddAttributeByTooltip(needParse, direction, pattern, attribute...): 'needParse' - boolean expected got '%s' ('%s')."):format(type(needParse), tostring(needParse)), 2)
	end
	if direction ~= "left" and direction ~= "right" then
		error(("Usage: private:AddAttributeByTooltip(needParse, direction, pattern, attribute...): 'direction' must be 'left' or 'right'"), 2)
	end
	if type(pattern) ~= "string" then
		error(("Usage: private:AddAttributeByTooltip(needParse, direction, pattern, attribute...): 'pattern' - string expected got '%s' ('%s')."):format(type(pattern), tostring(pattern)), 2)
	end
	for attr, info in pairs(_attributesInfo) do
		if info.pattern == pattern then
			error(("Usage: private:AddAttributeByTooltip(needParse, direction, pattern, attribute...): 'pattern' already used: '%s'."):format(tostring(pattern)), 2)
		end
	end
	private:CheckNewAttributeInput("Usage: private:AddAttributeByTooltip(needParse, direction, pattern, attribute...)", ...)
	if not needParse then
		if select("#", ...) > 1 then
			error(("Usage: private:AddAttributeByTooltip(needParse, direction, pattern, attribute...): if needParse is false, only 1 attribute can be specified."), 2)
		end
	end

	local info = {}
	info.attrType = "tooltip"
	info.needParse = needParse
	info.dir = direction
	info.pattern = pattern

	for i = 1, select("#", ...) do
		local attribute = select(i, ...)
		if attribute ~= "" then
			info[i] = attribute
			info[attribute] = i
			_attributesInfo[attribute] = info
		end
	end
end

function private:AssignAPIReturnToAttr(itemInfo, attrInfo, ...)
	for i = 1 , select("#", ...) do
		local attr = attrInfo[i]
		if attr and attr ~= "" then
			local value = select(i, ...)
			itemInfo[attr] = value == nil and _RC_ITEM_UTILS_NIL or value
		end
	end
end

function private:CheckNewAttributeInput(usage, ...)
	local nAttributes = select("#", ...)
	if nAttributes <= 0 then
		error(usage.." 'attribute' - need to specify at least one attribute.", 3)
	end
	wipe(_tempTable)
	local nRealAttributes = 0
	for i = 1, nAttributes do
		local attribute = select(i, ...)
		if type(attribute) ~= "string" then
			error((usage.." 'attribute' - string expected got '%s' ('%s')."):format(type(attribute), tostring(attribute)), 3)
		end
		if attribute ~= "" then
			if _attributesInfo[attribute] then
				error((usage.." attribute already exists: '%s'."):format(tostring(attribute)), 3)
			elseif _tempTable[attribute] then
				error((usage.." Duplicate attribute: '%s'."):format(tostring(attribute)), 3)
			elseif tContains(_reserved, attribute) then
				error((usage.." attribute is _reserved keyword: '%s'."):format(tostring(attribute)), 3)
			end
			tinsert(_tempTable, attribute)
			nRealAttributes = nRealAttributes + 1
		end
	end
	if nRealAttributes <= 0 then
		error(usage.." Need to specify at least one attribute that is not empty string.", 3)
	end
end

function private:SetAttributeDefault(attribute, default)
	if type(attribute) ~= "string" then
		error(("Usage: private:SetAttributeDefault(attribute, default): 'attribute' - string expected got '%s' ('%s')."):format(type(attribute), tostring(attribute)), 2)
	end
	if not _attributesInfo[attribute] then
		error(("Usage: private:SetAttributeDefault(attribute, default): Attribute does not exist: '%s'."):format(tostring(attribute)), 2)
	end
	if _attributesDefault[attribute] then
		error(("Usage: private:SetAttributeDefault(attribute, default): Attribute default had been set before: %s."):format(tostring(default)), 2)
	end
	if type(default) == "nil" then
		error(("Usage: private:SetAttributeDefault(attribute, default): 'default' must not be nil."), 2)
	end

	_attributesDefault[attribute] = default
end

function private:GetItemAttrInternal(item, attribute, noCache)
	if type(item) ~= "string" and type(item) ~= "number" then
		error(("Usage: GetItemAttr(item, attribute): 'item' - string/number expected got '%s' ('%s')."):format(type(item), tostring(item)), 3)
	end
	if type(attribute) ~= "string" then
		error(("Usage: GetItemAttr(item, attribute): 'attribute' - string expected got '%s' ('%s')."):format(type(attribute), tostring(attribute)), 3)
	end
	if type(item) == "string" and not item:find("item:") then
		error(("Usage: GetItemAttritem, attribute): 'item' is not an item string/link ('%s')."):format(item), 3)
	end
	if not _attributesInfo[attribute] then
		error(("Usage: GetItemAttr(item, attribute): Attribute does not exist: '%s'."):format(tostring(attribute)), 3)
	end

	item = Item:GetShortItemString(item)

	local itemInfo = _itemInfos[item] or {}
	local result = itemInfo[attribute]
	if result ~= nil then -- Attribute is already cached
		return result ~= _RC_ITEM_UTILS_NIL and result or nil
	end
	local attrInfo = _attributesInfo[attribute]
	if attrInfo.attrType == "api" then
		if noCache then
			return select(attrInfo[attribute], attrInfo.api(item))
		end
		if attrInfo.needLoad and not itemInfo.loaded then
			if GetItemInfo(item) then
				itemInfo.loaded = true
			end
		end
		if not attrInfo.needLoad or itemInfo.loaded then
			private:AssignAPIReturnToAttr(itemInfo, attrInfo, attrInfo.api(item))
			result = itemInfo[attribute]
			if result ~= nil then
				return result ~= _RC_ITEM_UTILS_NIL and result or nil
			end
		end
	elseif attrInfo.attrType == "tooltip" then
		if not itemInfo.loaded then
			if GetItemInfo(item) then
				itemInfo.loaded = true
			end
		end
		if itemInfo.loaded then
			local tooltipFrameUsed = false
			if not itemInfo.numLines then
				_tooltip:SetOwner(UIParent, "ANCHOR_NONE") -- This lines clear the current content of _tooltip and set its position off-screen
				_tooltip:SetHyperlink(item) -- Set the _tooltip content and show it, should hide the _tooltip before function ends
				tooltipFrameUsed = true
				if not noCache then
					itemInfo.numLines = _tooltip:NumLines() or 0
				end
			end

			-- String match _tooltip texts to attributes
			local dir = attrInfo.dir
			local needParse = attrInfo.needParse
			local pattern = attrInfo.pattern

			for i = 1, tooltipFrameUsed and _tooltip:NumLines() or itemInfo.numLines or 0 do
				local text = ""
				local leftText = ""
				local rightText = ""
				if tooltipFrameUsed then
					local leftLine = getglobal(_tooltip:GetName()..'TextLeft' .. i)
					leftText = leftLine and leftLine.GetText and leftLine:GetText() or ""
					local rightLine = getglobal(_tooltip:GetName()..'TextRight' .. i)
					rightText = rightLine and rightLine.GetText and rightLine:GetText() or ""
					if not noCache then
						itemInfo.leftTexts[i] = leftText
						itemInfo.rightTexts[i] = rightText
					end
				else
					leftText = itemInfo.leftTexts[i]
					rightText = itemInfo.rightTexts[i]
				end

				if dir == "left" then
					text = leftText
				elseif dir == "right" then
					text = rightText
				end

				if text ~= "" then
					if needParse then
						local index = 1
						for str in string_gmatch(text, pattern) do
							local attr = attrInfo[i]
							if attr and attr ~= "" then
								itemInfo[attr] = str
							end
							index = index + 1
						end
						return itemInfo[attribute] ~= nil and itemInfo[attribute] or _attributesDefault[attribute]
					else
						local attr = attrInfo[1]
						if strmatch(text, pattern) then
							itemInfo[attr] = true
							if tooltipFrameUsed then
								_tooltip:Hide()
							end
							return true
						end
					end
				end
			end
			if tooltipFrameUsed then
				_tooltip:Hide()
			end
			if not needParse then
				itemInfo[attribute] = false
				return false
			end
		end
	end

	return _attributesDefault[attribute]
end

function private._GetItemSpecString(item)
	wipe(_tempTable)
	for classID = GetNumClasses(), 1, -1 do
		local numSpec = GetNumSpecializationsForClassID(classID)
		local classNum = 0
		for specIndex = 1, 4 do
			local specID = specIndex <= numSpec and GetSpecializationInfoForClassID(classID, specIndex)
			if specID and DoesItemContainSpec(item, classID, specID) then
				classNum = classNum + 2^(specIndex-1)
			end
		end
		tinsert(_tempTable, format("%X", classNum))
	end
	return tconcat(_tempTable)
end

function private._GetItemClassesFlag(item)
	local flag = 0
	for classID = 1, GetNumClasses()do
		if DoesItemContainSpec(item, classID) then
			flag = flag + 2^(classID-1)
		end
	end
	return flag
end
----------------------------------------
-- Add item attributes here
----------------------------------------

-- private:AddAttributeByAPI(needLoad, api, attribute...)
private:AddAttributeByAPI(false, GetItemInfoInstant, "id", "type", "subType", "equipLoc", "texture", "typeID", "subTypeID")
private:AddAttributeByAPI(true, GetItemInfo, "name", "link", "quality", "ilvl", "reqLevel", "", "", "maxStack", "", "", "vendorPrice", "", "", "bindType", "expacID", "setID", "isCraftingReagent")
private:AddAttributeByAPI(true, function(item) return GetItemQualityColor(select(3, GetItemInfo(item)) or LE_ITEM_QUALITY_COMMON) end, "r", "g", "b", "qualityColorHex")
private:AddAttributeByAPI(true, GetItemFamily, "bagType")
private:AddAttributeByAPI(true, GetItemStats, "stats")
private:AddAttributeByAPI(true, GetItemSpell, "spellName")
private:AddAttributeByAPI(true, IsEquippableItem, "isEquippable")
private:AddAttributeByAPI(true, IsConsumableItem, "isConsumable")
private:AddAttributeByAPI(true, IsUsableItem, "isUsable")
private:AddAttributeByAPI(true, IsEquippedItem, "isEquipped")
private:AddAttributeByAPI(true, IsArtifactRelicItem, "isArtifactRelic")
private:AddAttributeByAPI(false, function(item) return RCTokenTable[Item:GetItemIDFromLink(item)] end, "tokenSlot")
private:AddAttributeByAPI(true, function(item) return select(3, C_ArtifactUI.GetRelicInfoByItemID(Item:GetItemIDFromLink(item))) end, "relicType")

private:AddAttributeByAPI(true, private._GetItemSpecString, "lootSpec")
private:AddAttributeByAPI(true, private._GetItemClassesFlag, "classesFlag")
for i=1, GetNumClasses() do
	private:AddAttributeByAPI(true, function(item) return DoesItemContainSpec(item, i) end, "class"..i)
end


-- private:AddAttributeByTooltip(needParse, direction, pattern, attribute...)
private:AddAttributeByTooltip(false, "left", "^"..ITEM_TOURNAMENT_GEAR.."$", "isTournamentGear")
private:AddAttributeByTooltip(false, "left", ITEM_SPELL_TRIGGER_ONEQUIP, "hasOnEquipEffect")
private:AddAttributeByTooltip(false, "left", ITEM_SPELL_TRIGGER_ONPROC, "hasProc")
private:AddAttributeByTooltip(false, "left", "^"..ITEM_SPELL_KNOWN.."$", "isSpellKnown")
private:AddAttributeByTooltip(false, "left", "^"..TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN.."$", "isAppearanceUnknown")

private:AddAttributeByTooltip(true, "right", "^(%d.%d)$", "weaponBaseSpeed") -- TODO: Need testing

-- private:SetAttributeDefault(attribute, default)
private:SetAttributeDefault("name", RETRIEVING_ITEM_INFO)
private:SetAttributeDefault("link", "-- "..RETRIEVING_ITEM_INFO.." --")
private:SetAttributeDefault("quality", LE_ITEM_QUALITY_COMMON)
private:SetAttributeDefault("ilvl", -1)
private:SetAttributeDefault("reqLevel", 0)
private:SetAttributeDefault("maxStack", 1)
private:SetAttributeDefault("vendorPrice", 1)
private:SetAttributeDefault("bindType", LE_ITEM_BIND_ON_ACQUIRE)

private:SetAttributeDefault("r", 1)
private:SetAttributeDefault("g", 1)
private:SetAttributeDefault("b", 1)
private:SetAttributeDefault("qualityColorHex", "ffffff")

private:SetAttributeDefault("bagType", 0)
private:SetAttributeDefault("stats", {})
private:SetAttributeDefault("isEquippable", false)
private:SetAttributeDefault("isConsumable", false)

private:SetAttributeDefault("texture", "Interface/ICONS/INV_Misc_QuestionMark")
private:SetAttributeDefault("isAppearanceUnknown", true)
for i=1, GetNumClasses() do
	private:SetAttributeDefault("class"..i, true)
end
private:SetAttributeDefault("lootSpec", "FFFFFFFFFFFF")
private:SetAttributeDefault("classesFlag", 0xffffffff)
