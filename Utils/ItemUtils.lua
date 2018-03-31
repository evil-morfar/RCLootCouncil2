local MAJOR,MINOR = "RCItemUtils-1.0", 1
local RCItemUtils, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

local attributesName = {"numLines", "leftTexts", "rightTexts"}
local attributesDefault = {}
local attributesInfo = {}
local itemInfos = {}
local tempTable = {}

local error = error
local format = format
local getglobal = getglobal
local ipairs = ipairs
local pairs = pairs
local select = select
local string_gmatch = string.gmatch
local strmatch = string.match
local tconcat = table.concat
local tinsert = table.insert
local tostring = tostring
local type = type
local UIParent = UIParent
local unpack = unpack
local wipe = wipe

local tooltip = CreateFrame("GameTooltip", "RCItemUtils_Tooltip", nil, "GameTooltipTemplate")
tooltip:UnregisterAllEvents()
tooltip:Hide()

local function GetItemIDFromLink(link)
	return tonumber(strmatch(link or "", "item:(%d+):"))
end

local function GetItemStringFromLink(link)
	if link:find("|") then
		return strmatch(link or "", "(item:.-):*|h") -- trim trailing colons
	else
		return link
	end
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
	if type(needParse) ~= "boolean" then
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
			itemInfo[attr] = select(i, ...)
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

local function GetItemAttrNoCache(item, attribute)
	if type(item) ~= "string" then
		error(("Usage: GetItemAttrNoCache(item, attribute): 'item' - string expected got '%s' ('%s')."):format(type(item), tostring(item)), 2)
	end
	if type(attribute) ~= "string" then
		error(("Usage: GetItemAttrNoCache(item, attribute): 'attribute' - string expected got '%s' ('%s')."):format(type(attribute), tostring(attribute)), 2)
	end
	if not item:find("item:") then
		error(("Usage: GetItemAttrNoCache(item, attribute): 'item' is not an item string/link ('%s')."):format(item), 2)
	end
	if not attributesName[attribute] then
		error(("Usage: GetItemAttrNoCache(item, attribute): Attribute does not exist: '%s'."):format(tostring(attribute)), 2)
	end

	item = GetItemStringFromLink(item)

	return itemInfos[item][attribute] ~= nil and itemInfos[item][attribute] or attributesDefault[attribute]
end

_G.RCTrinketCategories = {
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

local function GetItemSpecString(item)
	wipe(tempTable)
	for classID = GetNumClasses(), 1, -1 do
		local numSpec = GetNumSpecializationsForClassID(classID)
		local classNum = 0
		for specIndex = 1, 4 do
			local specID = specIndex <= numSpec and GetSpecializationInfoForClassID(classID, specIndex)
			if specID and DoesItemContainSpec(item, classID, specID) then
				classNum = classNum + 2^(specIndex-1)
			end
		end
		tinsert(tempTable, format("%X", classNum))
	end
	return tconcat(tempTable)
end

local function GetItemClassesFlag(item)
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

-- AddAttributeByAPI(needLoad, api, attribute...)
AddAttributeByAPI(false, GetItemInfoInstant, "id", "type", "subType", "equipLoc", "texture", "typeID", "subTypeID")
AddAttributeByAPI(true, GetItemInfo, "name", "link", "quality", "ilvl", "reqLevel", "", "", "maxStack", "", "", "vendorPrice", "", "", "bindType", "expacID", "setID", "isCraftingReagent")
AddAttributeByAPI(true, function(item) return GetItemQualityColor(select(3, GetItemInfo(item)) or LE_ITEM_QUALITY_COMMON) end, "r", "g", "b", "qualityColorHex")
AddAttributeByAPI(true, GetItemFamily, "bagType")
AddAttributeByAPI(true, GetItemStats, "stats")
AddAttributeByAPI(true, GetItemSpell, "spellName")
AddAttributeByAPI(true, IsEquippableItem, "isEquippable")
AddAttributeByAPI(true, IsConsumableItem, "isConsumable")
AddAttributeByAPI(true, IsUsableItem, "isUsable")
AddAttributeByAPI(true, IsEquippedItem, "isEquipped")
AddAttributeByAPI(true, IsArtifactRelicItem, "isArtifactRelic")
for i=1, GetNumClasses() do
	AddAttributeByAPI(true, function(item) return DoesItemContainSpec(item, i) end, "class"..i)
end
AddAttributeByAPI(true, GetItemSpecString, "lootSpec")
AddAttributeByAPI(false, function(item) return RCTokenTable[GetItemIDFromLink(item)] end, "tokenSlot")
AddAttributeByAPI(true, function(item) return select(3, C_ArtifactUI.GetRelicInfoByItemID(GetItemIDFromLink(item))) end, "relicType")
AddAttributeByAPI(true, GetItemClassesFlag, "classesFlag")

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
for i=1, GetNumClasses() do
	SetAttributeDefault("class"..i, true)
end
SetAttributeDefault("lootSpec", "FFFFFFFFFFFF")
SetAttributeDefault("classesFlag", 0xffffffff)

-- Other functions in this file should not call this function. Infinite loop otherwise.
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

	if not itemInfos[item] or not itemInfos[item].cached then
		CacheItem(item)
	end

	return itemInfos[item][attribute] ~= nil and itemInfos[item][attribute] or attributesDefault[attribute]
end

-- APIs to be researched
-- true/false = DoesItemContainSpec(itemLink, classID, [specID])
-- {specID1, specID2, ...} = GetItemSpecInfo(itemLink)
-- {setSpellID1, setSpellID2} = GetSetBonusesForSpecializationByItemID(specID, itemID)
-- GetInventoryItemBroken  ???

----------------------------------------
-- Base library stuff
----------------------------------------

RCItemUtils.internals = {	-- for test purposes
	attributesName = attributesName,
	attributesDefault = attributesDefault,
	attributesInfo = attributesInfo,
	itemInfos = itemInfos,
	GetItemSpecString = GetItemSpecString,
}

local mixins = {
	GetItemAttr = GetItemAttr,
	CacheItem = CacheItem,
	GetItemStringFromLink = GetItemStringFromLink,
	GetItemIDFromLink = GetItemIDFromLink,
}

RCItemUtils.embeds = RCItemUtils.embeds or {}

function RCItemUtils:Embed(target)
	for k, v in pairs(mixins) do
		target[k] = mixins[k]
	end
	self.embeds[target] = true
	return target
end

-- Update embeds
for target, v in pairs(RCItemUtils.embeds) do
	RCItemUtils:Embed(target)
end
RCItemUtils:Embed(RCItemUtils)

--[[ WoW API that contains the word "item" in the function name

ActionBindsItem
AutoEquipCursorItem
AutoLootMailItem
AutoStoreGuildBankItem
BuyMerchantItem
BuybackItem
CalendarContextInviteModeratorStatus
CanAffordMerchantItem
CanComplainInboxItem
CanItemBeSocketedToArtifact
CancelItemTempEnchantment
ClearItemUpgrade
ClickAuctionSellItemButton
ClickSendMailItemButton
CloseItemText
CloseItemUpgrade
ComplainInboxItem
ContainerRefundItemPurchase
CursorHasItem
DeleteCursorItem
DeleteInboxItem
DoesItemContainSpec
DressUpItemLink
DropItemOnUnit
EquipCursorItem
EquipItemByName
EquipPendingItem
EquipmentSetContainsLockedItems
GMItemRestorationButtonEnabled
GetAbandonQuestItems
GetAuctionItemBattlePetInfo
GetAuctionItemInfo
GetAuctionItemLink
GetAuctionItemSubClasses
GetAuctionItemTimeLeft
GetAuctionSellItemInfo
GetAverageItemLevel
GetBidderAuctionItems
GetBuybackItemInfo
GetBuybackItemLink
GetContainerItemCooldown
GetContainerItemDurability
GetContainerItemEquipmentSetInfo
GetContainerItemID
GetContainerItemInfo
GetContainerItemLink
GetContainerItemPurchaseCurrency
GetContainerItemPurchaseInfo
GetContainerItemPurchaseItem
GetContainerItemQuestInfo
GetDetailedItemLevelInfo
GetEquipmentSetItemIDs
GetGuildBankItemInfo
GetGuildBankItemLink
GetInboxItem
GetInboxItemLink
GetInboxNumItems
GetInsertItemsLeftToRight
GetInventoryItemBroken
GetInventoryItemCooldown
GetInventoryItemCount
GetInventoryItemDurability
GetInventoryItemEquippedUnusable
GetInventoryItemID
GetInventoryItemLink
GetInventoryItemQuality
GetInventoryItemTexture
GetInventoryItemsForSlot
GetItemChildInfo
GetItemClassInfo
GetItemCooldown
GetItemCount
GetItemCreationContext
GetItemFamily
GetItemGem
GetItemIcon
GetItemInfo
GetItemInfoFromHyperlink
GetItemInfoInstant
GetItemInventorySlotInfo
GetItemLevelColor
GetItemLevelIncrement
GetItemQualityColor
GetItemSetInfo
GetItemSpecInfo
GetItemSpell
GetItemStatDelta
GetItemStats
GetItemSubClassInfo
GetItemUniqueness
GetItemUpdateLevel
GetItemUpgradeEffect
GetItemUpgradeItemInfo
GetItemUpgradeStats
GetLFGCompletionRewardItem
GetLFGCompletionRewardItemLink
GetLooseMacroItemIcons
GetLootRollItemInfo
GetLootRollItemLink
GetMacroItem
GetMacroItemIcons
GetMerchantItemCostInfo
GetMerchantItemCostItem
GetMerchantItemID
GetMerchantItemInfo
GetMerchantItemLink
GetMerchantItemMaxStack
GetMerchantNumItems
GetNumAuctionItems
GetNumBuybackItems
GetNumItemUpgradeEffects
GetNumLootItems
GetNumQuestItemDrops
GetNumQuestItems
GetNumTreasurePickerItems
GetOwnerAuctionItems
GetQuestChoiceRewardItem
GetQuestItemInfo
GetQuestItemLink
GetQuestLogItemDrop
GetQuestLogItemLink
GetQuestLogSpecialItemCooldown
GetQuestLogSpecialItemInfo
GetRewardPackItems
GetSelectedAuctionItem
GetSendMailItem
GetSendMailItemLink
GetSetBonusesForSpecializationByItemID
GetSocketItemBoundTradeable
GetSocketItemInfo
GetSocketItemRefundable
GetSpellBookItemInfo
GetSpellBookItemName
GetSpellBookItemTexture
GetTradePlayerItemInfo
GetTradePlayerItemLink
GetTradeTargetItemInfo
GetTradeTargetItemLink
GetTrainerServiceItemLink
GetTreasurePickerItemInfo
GetVoidItemHyperlinkString
GetVoidItemInfo
HandleModifiedItemClick
HasInboxItem
HasSendMailItem
InboxItemCanDelete
IsArtifactPowerItem
IsArtifactRelicItem
IsBattlePayItem
IsConsumableItem
IsContainerItemAnUpgrade
IsCurrentItem
IsDressableItem
IsEquippableItem
IsEquippedItem
IsEquippedItemType
IsHarmfulItem
IsHelpfulItem
IsInventoryItemAnUpgrade
IsInventoryItemLocked
IsInventoryItemProfessionBag
IsItemAction
IsItemInRange
IsQuestItemHidden
IsQuestLogSpecialItemInRange
IsSelectedSpellBookItem
IsUsableItem
ItemAddedToArtifact
ItemCanTargetGarrisonFollowerAbility
ItemHasRange
ItemTextGetCreator
ItemTextGetItem
ItemTextGetMaterial
ItemTextGetPage
ItemTextGetText
ItemTextHasNextPage
ItemTextIsFullPage
ItemTextNextPage
ItemTextPrevPage
LootSlotHasItem
PickupContainerItem
PickupGuildBankItem
PickupInventoryItem
PickupItem
PickupMerchantItem
PickupSpellBookItem
PutItemInBackpack
PutItemInBag
QueryAuctionItems
RemoveItemFromArtifact
RepairAllItems
RespondMailLockSendItem
ReturnInboxItem
SearchBagsForItem
SearchBagsForItemLink
SecureCmdItemParse
SecureCmdUseItem
SellCursorItem
SetBindingItem
SetGuildBankTabItemWithdraw
SetGuildTradeSkillItemNameFilter
SetInsertItemsLeftToRight
SetItemButtonCount
SetItemButtonDesaturated
SetItemButtonNameFrameVertexColor
SetItemButtonNormalTextureVertexColor
SetItemButtonQuality
SetItemButtonSlotVertexColor
SetItemButtonStock
SetItemButtonTexture
SetItemButtonTextureVertexColor
SetItemRef
SetItemSearch
SetItemUpgradeFromCursorItem
SetMacroItem
SetOverrideBindingItem
SetSelectedAuctionItem
SocketContainerItem
SocketInventoryItem
SocketItemToArtifact
SortAuctionItems
SpellCanTargetItem
SpellCanTargetItemID
SpellTargetItem
SplitContainerItem
SplitGuildBankItem
StoreSetItemTooltip
TakeInboxItem
TakeInboxTextItem
UpdateNewItemList
UpgradeItem
UseContainerItem
UseInventoryItem
UseItemByName
UseQuestLogSpecialItem
tDeleteItem
]]
