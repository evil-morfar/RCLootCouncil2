-- Simulation of Blizzard Item functions.
-- Note: Only select return types are available, with the rest just being a string

local _G = getfenv(0)
_G.Items = {}

function GetItemInfo (item)
   local i = assert(_G.Items[item], "item "..item .." isn't registered for GetItemInfo")
   return i.itemName, i.itemLink, i.itemRarity, i.itemLevel, i.itemMinLevel, "itemType", "itemSubType", "itemStackCount",
i.itemEquipLoc, "itemIcon", "itemSellPrice", i.itemClassID, i.itemSubClassID, "bindType", "expacID", "itemSetID",
i.isCraftingReagent
end

function GetItemInfoInstant (item)
   local i = assert(_G.Items[item], "item "..item .." isn't registered for GetItemInfoInstant")
   return i.itemID, "itemType", "itemSubType", i.itemEquipLoc, "icon", i.itemClassID, i.itemSubClassID
end

----------------------------------------------------------------
-- List of predefined items the functions can handle
----------------------------------------------------------------
_G.Items = {
   ["item:166418::::::::120:104::5:4:4799:1808:1522:4786:::"] = {
      itemName = "Crest of Pa'ku",
      itemID = 166418,
      itemLink = "|cffa335ee|Hitem:166418::::::::120:104::5:4:4799:1808:1522:4786:::|h[Crest of Pa'ku]|h|r",
      itemString = "item:166418::::::::120:104::5:4:4799:1808:1522:4786:::",
      itemRarity = 4,
      itemLevel = 400,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_TRINKET",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 0, --LE_ITEM_ARMOR_GENERIC
      isCraftingReagent = false
   },
   ["item:160651::::::::120:104::6:3:4800:1512:4783:::"] = {
      itemName = "Vigilant's Bloodshaper",
      itemID = 160651,
      itemLink = "|cffa335ee|Hitem:160651::::::::120:104::6:3:4800:1512:4783:::|h[Vigilant's Bloodshaper]|h|r",
      itemString = "item:160651::::::::120:104::6:3:4800:1512:4783:::",
      itemRarity = 4,
      itemLevel = 400,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_TRINKET",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 0, --LE_ITEM_ARMOR_GENERIC
      isCraftingReagent = false
   },
   ["item:165818::::::::120:104::5:4:4823:1522:4786:5417:::"] = {
      itemName = "Crown of the Seducer",
      itemID = 165818,
      itemLink = "|cffa335ee|Hitem:165818::::::::120:104::5:4:4823:1522:4786:5417:::|h[Crown of the Seducer]|h|r",
      itemString = "item:165818::::::::120:104::5:4:4823:1522:4786:5417:::",
      itemRarity = 4,
      itemLevel = 385,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_HEAD",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 1, --LE_ITEM_ARMOR_CLOTH
      isCraftingReagent = false
   },
   ["item:165501::::::::120:104::5:3:4799:1522:4786:::"] = {
      itemName = "Bracers of Zealous Calling",
      itemID = 165501,
      itemLink = "|cffa335ee|Hitem:165501::::::::120:104::5:3:4799:1522:4786:::|h[Bracers of Zealous Calling]|h|r",
      itemString = "item:165501::::::::120:104::5:3:4799:1522:4786:::",
      itemRarity = 4,
      itemLevel = 385,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_WRIST",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 1, --LE_ITEM_ARMOR_CLOTH
      isCraftingReagent = false
   },
   ["item:168363::::::::120:256::3:4:4822:1487:4786:6263:::"] = {
      itemName = "Dark Passenger's Breastplate",
      itemID = 168363,
      itemLink = "|cffa335ee|Hitem:168363::::::::120:256::3:4:4822:1487:4786:6263:::|h[Dark Passenger's Breastplate]|h|r",
      itemString = "item:168363::::::::120:256::3:4:4822:1487:4786:6263:::",
      itemRarity = 4,
      itemLevel = 415,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_CHEST",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 4, --LE_ITEM_ARMOR_PLATE
      isCraftingReagent = false
   },
   ["item:168337::::::::120:104::3:4:4822:1487:4786:6263:::"] = {
      itemName = "Vestments of Creeping Terror",
      itemID = 168337,
      itemLink = "|cffa335ee|Hitem:168337::::::::120:104::3:4:4822:1487:4786:6263:::|h[Vestments of Creeping Terror]|h|r",
      itemString = "item:168337::::::::120:104::3:4:4822:1487:4786:6263:::",
      itemRarity = 4,
      itemLevel = 415,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_ROBE",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 1, --LE_ITEM_ARMOR_CLOTH
      isCraftingReagent = false
   },
   ["item:168882::::::::120:256::3:3:4798:1487:4786:::"] = {
      itemName = "Shackles of Dissonance",
      itemID = 168882,
      itemLink = "|cffa335ee|Hitem:168882::::::::120:256::3:3:4798:1487:4786:::|h[Shackles of Dissonance]|h|r",
      itemString = "item:168882::::::::120:256::3:3:4798:1487:4786:::",
      itemRarity = 4,
      itemLevel = 415,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_WRIST",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 3, --LE_ITEM_ARMOR_MAIL
      isCraftingReagent = false
   },
   --|cffa335ee|Hitem:168884::::::::120:256::3:3:4798:1487:4786:::|h[Bindings of the Herald]|h|r
   ["item:168884::::::::120:256::3:3:4798:1487:4786:::"] = {
      itemName = "Bindings of the Herald",
      itemID = 168884,
      itemLink = "|cffa335ee|Hitem:168884::::::::120:256::3:3:4798:1487:4786:::|h[Bindings of the Herald]|h|r",
      itemString = "item:168884::::::::120:256::3:3:4798:1487:4786:::",
      itemRarity = 4,
      itemLevel = 415,
      itemMinLevel = 120,
      itemEquipLoc = "INVTYPE_WRIST",
      itemClassID = 4, --LE_ITEM_CLASS_ARMOR
      itemSubClassID = 1, --LE_ITEM_ARMOR_CLOTH
      isCraftingReagent = false
   },
}

_G.Items_Array = {}

-- Create itemID indexes:
do
   local add = {}
   local add2 = {}
   for itemstring, item in pairs(_G.Items) do
      add[item.itemID] = item
      add2[item.itemLink] = item
      tinsert(_G.Items_Array, itemstring)
   end
   for a,b in pairs(add) do
      _G.Items[a] = b
   end
   for a,b in pairs(add2) do
      _G.Items[a] = b
   end
end
