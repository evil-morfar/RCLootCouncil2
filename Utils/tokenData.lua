--- tokenData.lua
-- Contains equip location and useable classes from tier tokens
-- @author Potdisc
-- Create Date : 3/11/2013 10:25:13 PM

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

--@debug@
-- This function is used for developer.
-- Export all POTENTIAL tokens. Manual modification is still required.
-- Only support Engish client
-- Note that only item type data is automatically(almost) exported.
-- Item level data need to be manually entered.
-- The format is {[itemID] = SLOT}
local tokenNames = {}
local tokenIlvls = {}

-- The params are used internally inside this function
function RCLootCouncil:ExportTokenData(nextID)
	if not nextID then 
		nextID = 1
		self:Print("Exporting the data of all potential token.\n"
			.."This command is intended to be run by the developer.\n"
			.."After exporting is done and copy and paste the data into Utils/tokenData.lua.\n"
			.."This is semi-automatic. Data (especially item level data) must be verified and modified manually later.\n"
			.."Only support English Client\n"
			.."Dont run any extra /rc exporttokendata when it is running."
			.."Commented lines in exports mean not sure and need to manually determine it.")
	end
	local LAST_ID = 250000
    for i = nextID, LAST_ID do
        local _, _, _, _, _, typeID, subTypeID = GetItemInfoInstant(i)
        if typeID == 15 and subTypeID == 0 then -- Miscellaneous, Junk
            self:ExportTokenDataSingle(i)
            return C_Timer.After(0, function() self:ExportTokenData(i + 1) end)
        end
    end
    if nextID < LAST_ID then
        return C_Timer.After(1, function() self:ExportTokenData(LAST_ID + 1) end) -- Extra delay so we don't lose data at the end.
    end

	local count = 0
	for id, name in pairs(tokenNames) do
		count = count + 1
	end
	self:Print(format("DONE. %d potential tokens total", count))
	self:Print("Copy and paste data to Util/tokenData.lua")
	self:Print("This is semi-automatic. Data must be verified and modified manually.")

	-- Hack that should only happen in developer mode.
	local frame = RCLootCouncil:GetActiveModule("history"):GetFrame()
	frame.exportFrame:Show()

	local exports ="_G.RCTokenTable = {\n"
	local sorted = {}
	for id, name in pairs(tokenNames) do
		tinsert(sorted, {id, name})
	end
	table.sort(sorted, function(a, b) return a[1] < b[1] end)
	for _, entry in ipairs(sorted) do
		local slot = ""
		local name = entry[2]
		local l = name:lower()
		if l:find("helm") or l:find("head") or l:find("crown") or l:find("circlet") then
			slot = "HeadSlot"
		elseif l:find("shoulder") or l:find("pauldron") or l:find("mantle") or l:find("spaulder") then
			slot = "ShoulderSlot"
		elseif l:find("cloak") then
			slot = "BackSlot"
		elseif l:find("breastplate") or l:find("tunic") or l:find("robe") or l:find("chest") then
			slot = "ChestSlot"
		elseif l:find("hand") or l:find("glove") or l:find("gauntlets") then
			slot = "HandsSlot"
		elseif l:find("leg") then
			slot = "LegsSlot"
		elseif l:find("badge") then
			slot = "Trinket"
		elseif l:find("essence") or l:find("regalia") or l:find("sanctification") then
			slot = "MultiSlots"
		elseif l:find("wrist") or l:find("bracer") or l:find("bindings") then
			slot = "WristSlot"
		elseif l:find("waist") or l:find("girdle") or l:find("belt") then
			slot = "WaistSlot"
		elseif l:find("feet") or l:find("sandal") or l:find("boot") or l:find("sabaton") then
			slot = "FeetSlot"
		end

		if slot == "" then
			exports = exports.."\t-- ".."["..entry[1].."] = "..format("%-11s", format("%q", slot))
					..",\t-- "..format("%s", name..",").."\n"
		else
			exports = exports.."\t["..entry[1].."] = "..format("%-14s", format("%q", slot))
					..",\t-- "..format("%s", name..",").."\n"
		end
	end
	exports = exports.."}\n\n"

	exports = exports.."-- Note: Some of item level data is manually entered."
	exports = exports.."\n_G.RCTokenIlvl = {\n"
	for _, entry in ipairs(sorted) do
		local id = entry[1]
		local name = entry[2]
		exports = exports.."\t["..id.."] = "..format("%03d", tokenIlvls[id])..",\t-- "..format("%s", name..",").."\n"
	end
	exports = exports.."}\n"
	frame.exportFrame.edit:SetText(exports)
end

function RCLootCouncil:ExportTokenDataSingle(id)
	if GetItemInfo(id) then
        local name, link, quality, ilvl, _, _, _, maxStack = GetItemInfo(id)
        if self:GetItemClassesAllowedFlag(link) ~= 0xffffffff and maxStack == 1 and quality == 4 then
            DEFAULT_CHAT_FRAME:AddMessage(id.." "..name)
            tokenNames[id] = name
            tokenIlvls[id] = ilvl
        end
    else
        return C_Timer.After(0, function() self:ExportTokenDataSingle(id) end)
    end
end
--@end-debug@

-- Equip locations
_G.RCTokenTable = {
	[22349] = "ChestSlot"   ,	-- Desecrated Breastplate,
	[22350] = "ChestSlot"   ,	-- Desecrated Tunic,
	[22351] = "ChestSlot"   ,	-- Desecrated Robe,
	[22352] = "LegsSlot"    ,	-- Desecrated Legplates,
	[22353] = "HeadSlot"    ,	-- Desecrated Helmet,
	[22354] = "ShoulderSlot",	-- Desecrated Pauldrons,
	[22355] = "WristSlot"   ,	-- Desecrated Bracers,
	[22356] = "WaistSlot"   ,	-- Desecrated Waistguard,
	[22357] = "HandsSlot"   ,	-- Desecrated Gauntlets,
	[22358] = "FeetSlot"    ,	-- Desecrated Sabatons,
	[22359] = "LegsSlot"    ,	-- Desecrated Legguards,
	[22360] = "HeadSlot"    ,	-- Desecrated Headpiece,
	[22361] = "ShoulderSlot",	-- Desecrated Spaulders,
	[22362] = "WristSlot"   ,	-- Desecrated Wristguards,
	[22363] = "WaistSlot"   ,	-- Desecrated Girdle,
	[22364] = "HandsSlot"   ,	-- Desecrated Handguards,
	[22365] = "FeetSlot"    ,	-- Desecrated Boots,
	[22366] = "LegsSlot"    ,	-- Desecrated Leggings,
	[22367] = "HeadSlot"    ,	-- Desecrated Circlet,
	[22368] = "ShoulderSlot",	-- Desecrated Shoulderpads,
	[22369] = "WristSlot"   ,	-- Desecrated Bindings,
	[22370] = "WaistSlot"   ,	-- Desecrated Belt,
	[22371] = "HandsSlot"   ,	-- Desecrated Gloves,
	[22372] = "FeetSlot"    ,	-- Desecrated Sandals,
	[29753] = "ChestSlot"   ,	-- Chestguard of the Fallen Defender,
	[29754] = "ChestSlot"   ,	-- Chestguard of the Fallen Champion,
	[29755] = "ChestSlot"   ,	-- Chestguard of the Fallen Hero,
	[29756] = "HandsSlot"   ,	-- Gloves of the Fallen Hero,
	[29757] = "HandsSlot"   ,	-- Gloves of the Fallen Champion,
	[29758] = "HandsSlot"   ,	-- Gloves of the Fallen Defender,
	[29759] = "HeadSlot"    ,	-- Helm of the Fallen Hero,
	[29760] = "HeadSlot"    ,	-- Helm of the Fallen Champion,
	[29761] = "HeadSlot"    ,	-- Helm of the Fallen Defender,
	[29762] = "ShoulderSlot",	-- Pauldrons of the Fallen Hero,
	[29763] = "ShoulderSlot",	-- Pauldrons of the Fallen Champion,
	[29764] = "ShoulderSlot",	-- Pauldrons of the Fallen Defender,
	[29765] = "LegsSlot"    ,	-- Leggings of the Fallen Hero,
	[29766] = "LegsSlot"    ,	-- Leggings of the Fallen Champion,
	[29767] = "LegsSlot"    ,	-- Leggings of the Fallen Defender,
	[30236] = "ChestSlot"   ,	-- Chestguard of the Vanquished Champion,
	[30237] = "ChestSlot"   ,	-- Chestguard of the Vanquished Defender,
	[30238] = "ChestSlot"   ,	-- Chestguard of the Vanquished Hero,
	[30239] = "HandsSlot"   ,	-- Gloves of the Vanquished Champion,
	[30240] = "HandsSlot"   ,	-- Gloves of the Vanquished Defender,
	[30241] = "HandsSlot"   ,	-- Gloves of the Vanquished Hero,
	[30242] = "HeadSlot"    ,	-- Helm of the Vanquished Champion,
	[30243] = "HeadSlot"    ,	-- Helm of the Vanquished Defender,
	[30244] = "HeadSlot"    ,	-- Helm of the Vanquished Hero,
	[30245] = "LegsSlot"    ,	-- Leggings of the Vanquished Champion,
	[30246] = "LegsSlot"    ,	-- Leggings of the Vanquished Defender,
	[30247] = "LegsSlot"    ,	-- Leggings of the Vanquished Hero,
	[30248] = "ShoulderSlot",	-- Pauldrons of the Vanquished Champion,
	[30249] = "ShoulderSlot",	-- Pauldrons of the Vanquished Defender,
	[30250] = "ShoulderSlot",	-- Pauldrons of the Vanquished Hero,
	[31089] = "ChestSlot"   ,	-- Chestguard of the Forgotten Conqueror,
	[31090] = "ChestSlot"   ,	-- Chestguard of the Forgotten Vanquisher,
	[31091] = "ChestSlot"   ,	-- Chestguard of the Forgotten Protector,
	[31092] = "HandsSlot"   ,	-- Gloves of the Forgotten Conqueror,
	[31093] = "HandsSlot"   ,	-- Gloves of the Forgotten Vanquisher,
	[31094] = "HandsSlot"   ,	-- Gloves of the Forgotten Protector,
	[31095] = "HeadSlot"    ,	-- Helm of the Forgotten Protector,
	[31096] = "HeadSlot"    ,	-- Helm of the Forgotten Vanquisher,
	[31097] = "HeadSlot"    ,	-- Helm of the Forgotten Conqueror,
	[31098] = "LegsSlot"    ,	-- Leggings of the Forgotten Conqueror,
	[31099] = "LegsSlot"    ,	-- Leggings of the Forgotten Vanquisher,
	[31100] = "LegsSlot"    ,	-- Leggings of the Forgotten Protector,
	[31101] = "ShoulderSlot",	-- Pauldrons of the Forgotten Conqueror,
	[31102] = "ShoulderSlot",	-- Pauldrons of the Forgotten Vanquisher,
	[31103] = "ShoulderSlot",	-- Pauldrons of the Forgotten Protector,
	[34848] = "WristSlot"   ,	-- Bracers of the Forgotten Conqueror,
	[34851] = "WristSlot"   ,	-- Bracers of the Forgotten Protector,
	[34852] = "WristSlot"   ,	-- Bracers of the Forgotten Vanquisher,
	[34853] = "WaistSlot"   ,	-- Belt of the Forgotten Conqueror,
	[34854] = "WaistSlot"   ,	-- Belt of the Forgotten Protector,
	[34855] = "WaistSlot"   ,	-- Belt of the Forgotten Vanquisher,
	[34856] = "FeetSlot"    ,	-- Boots of the Forgotten Conqueror,
	[34857] = "FeetSlot"    ,	-- Boots of the Forgotten Protector,
	[34858] = "FeetSlot"    ,	-- Boots of the Forgotten Vanquisher,
	[40610] = "ChestSlot"   ,	-- Chestguard of the Lost Conqueror,
	[40611] = "ChestSlot"   ,	-- Chestguard of the Lost Protector,
	[40612] = "ChestSlot"   ,	-- Chestguard of the Lost Vanquisher,
	[40613] = "HandsSlot"   ,	-- Gloves of the Lost Conqueror,
	[40614] = "HandsSlot"   ,	-- Gloves of the Lost Protector,
	[40615] = "HandsSlot"   ,	-- Gloves of the Lost Vanquisher,
	[40616] = "HeadSlot"    ,	-- Helm of the Lost Conqueror,
	[40617] = "HeadSlot"    ,	-- Helm of the Lost Protector,
	[40618] = "HeadSlot"    ,	-- Helm of the Lost Vanquisher,
	[40619] = "LegsSlot"    ,	-- Leggings of the Lost Conqueror,
	[40620] = "LegsSlot"    ,	-- Leggings of the Lost Protector,
	[40621] = "LegsSlot"    ,	-- Leggings of the Lost Vanquisher,
	[40622] = "ShoulderSlot",	-- Spaulders of the Lost Conqueror,
	[40623] = "ShoulderSlot",	-- Spaulders of the Lost Protector,
	[40624] = "ShoulderSlot",	-- Spaulders of the Lost Vanquisher,
	[40625] = "ChestSlot"   ,	-- Breastplate of the Lost Conqueror,
	[40626] = "ChestSlot"   ,	-- Breastplate of the Lost Protector,
	[40627] = "ChestSlot"   ,	-- Breastplate of the Lost Vanquisher,
	[40628] = "HandsSlot"   ,	-- Gauntlets of the Lost Conqueror,
	[40629] = "HandsSlot"   ,	-- Gauntlets of the Lost Protector,
	[40630] = "HandsSlot"   ,	-- Gauntlets of the Lost Vanquisher,
	[40631] = "HeadSlot"    ,	-- Crown of the Lost Conqueror,
	[40632] = "HeadSlot"    ,	-- Crown of the Lost Protector,
	[40633] = "HeadSlot"    ,	-- Crown of the Lost Vanquisher,
	[40634] = "LegsSlot"    ,	-- Legplates of the Lost Conqueror,
	[40635] = "LegsSlot"    ,	-- Legplates of the Lost Protector,
	[40636] = "LegsSlot"    ,	-- Legplates of the Lost Vanquisher,
	[40637] = "ShoulderSlot",	-- Mantle of the Lost Conqueror,
	[40638] = "ShoulderSlot",	-- Mantle of the Lost Protector,
	[40639] = "ShoulderSlot",	-- Mantle of the Lost Vanquisher,
	[45632] = "ChestSlot"   ,	-- Breastplate of the Wayward Conqueror,
	[45633] = "ChestSlot"   ,	-- Breastplate of the Wayward Protector,
	[45634] = "ChestSlot"   ,	-- Breastplate of the Wayward Vanquisher,
	[45635] = "ChestSlot"   ,	-- Chestguard of the Wayward Conqueror,
	[45636] = "ChestSlot"   ,	-- Chestguard of the Wayward Protector,
	[45637] = "ChestSlot"   ,	-- Chestguard of the Wayward Vanquisher,
	[45638] = "HeadSlot"    ,	-- Crown of the Wayward Conqueror,
	[45639] = "HeadSlot"    ,	-- Crown of the Wayward Protector,
	[45640] = "HeadSlot"    ,	-- Crown of the Wayward Vanquisher,
	[45641] = "HandsSlot"   ,	-- Gauntlets of the Wayward Conqueror,
	[45642] = "HandsSlot"   ,	-- Gauntlets of the Wayward Protector,
	[45643] = "HandsSlot"   ,	-- Gauntlets of the Wayward Vanquisher,
	[45644] = "HandsSlot"   ,	-- Gloves of the Wayward Conqueror,
	[45645] = "HandsSlot"   ,	-- Gloves of the Wayward Protector,
	[45646] = "HandsSlot"   ,	-- Gloves of the Wayward Vanquisher,
	[45647] = "HeadSlot"    ,	-- Helm of the Wayward Conqueror,
	[45648] = "HeadSlot"    ,	-- Helm of the Wayward Protector,
	[45649] = "HeadSlot"    ,	-- Helm of the Wayward Vanquisher,
	[45650] = "LegsSlot"    ,	-- Leggings of the Wayward Conqueror,
	[45651] = "LegsSlot"    ,	-- Leggings of the Wayward Protector,
	[45652] = "LegsSlot"    ,	-- Leggings of the Wayward Vanquisher,
	[45653] = "LegsSlot"    ,	-- Legplates of the Wayward Conqueror,
	[45654] = "LegsSlot"    ,	-- Legplates of the Wayward Protector,
	[45655] = "LegsSlot"    ,	-- Legplates of the Wayward Vanquisher,
	[45656] = "ShoulderSlot",	-- Mantle of the Wayward Conqueror,
	[45657] = "ShoulderSlot",	-- Mantle of the Wayward Protector,
	[45658] = "ShoulderSlot",	-- Mantle of the Wayward Vanquisher,
	[45659] = "ShoulderSlot",	-- Spaulders of the Wayward Conqueror,
	[45660] = "ShoulderSlot",	-- Spaulders of the Wayward Protector,
	[45661] = "ShoulderSlot",	-- Spaulders of the Wayward Vanquisher,
	[47557] = "MultiSlots"  ,	-- Regalia of the Grand Conqueror,
	[47558] = "MultiSlots"  ,	-- Regalia of the Grand Protector,
	[47559] = "MultiSlots"  ,	-- Regalia of the Grand Vanquisher,
	[52025] = "MultiSlots"  ,	-- Vanquisher's Mark of Sanctification,
	[52026] = "MultiSlots"  ,	-- Protector's Mark of Sanctification,
	[52027] = "MultiSlots"  ,	-- Conqueror's Mark of Sanctification,
	[52028] = "MultiSlots"  ,	-- Vanquisher's Mark of Sanctification,
	[52029] = "MultiSlots"  ,	-- Protector's Mark of Sanctification,
	[52030] = "MultiSlots"  ,	-- Conqueror's Mark of Sanctification,
	[63682] = "HeadSlot"    ,	-- Helm of the Forlorn Vanquisher,
	[63683] = "HeadSlot"    ,	-- Helm of the Forlorn Conqueror,
	[63684] = "HeadSlot"    ,	-- Helm of the Forlorn Protector,
	[64314] = "ShoulderSlot",	-- Mantle of the Forlorn Vanquisher,
	[64315] = "ShoulderSlot",	-- Mantle of the Forlorn Conqueror,
	[64316] = "ShoulderSlot",	-- Mantle of the Forlorn Protector,
	[65000] = "HeadSlot"    ,	-- Crown of the Forlorn Protector,
	[65001] = "HeadSlot"    ,	-- Crown of the Forlorn Conqueror,
	[65002] = "HeadSlot"    ,	-- Crown of the Forlorn Vanquisher,
	[65087] = "ShoulderSlot",	-- Shoulders of the Forlorn Protector,
	[65088] = "ShoulderSlot",	-- Shoulders of the Forlorn Conqueror,
	[65089] = "ShoulderSlot",	-- Shoulders of the Forlorn Vanquisher,
	[67423] = "ChestSlot"   ,	-- Chest of the Forlorn Conqueror,
	[67424] = "ChestSlot"   ,	-- Chest of the Forlorn Protector,
	[67425] = "ChestSlot"   ,	-- Chest of the Forlorn Vanquisher,
	[67426] = "LegsSlot"    ,	-- Leggings of the Forlorn Vanquisher,
	[67427] = "LegsSlot"    ,	-- Leggings of the Forlorn Protector,
	[67428] = "LegsSlot"    ,	-- Leggings of the Forlorn Conqueror,
	[67429] = "HandsSlot"   ,	-- Gauntlets of the Forlorn Conqueror,
	[67430] = "HandsSlot"   ,	-- Gauntlets of the Forlorn Protector,
	[67431] = "HandsSlot"   ,	-- Gauntlets of the Forlorn Vanquisher,
	[71668] = "HeadSlot"    ,	-- Helm of the Fiery Vanquisher,
	[71669] = "HandsSlot"   ,	-- Gauntlets of the Fiery Vanquisher,
	[71670] = "HeadSlot"    ,	-- Crown of the Fiery Vanquisher,
	[71671] = "LegsSlot"    ,	-- Leggings of the Fiery Vanquisher,
	[71672] = "ChestSlot"   ,	-- Chest of the Fiery Vanquisher,
	[71673] = "ShoulderSlot",	-- Shoulders of the Fiery Vanquisher,
	[71674] = "ShoulderSlot",	-- Mantle of the Fiery Vanquisher,
	[71675] = "HeadSlot"    ,	-- Helm of the Fiery Conqueror,
	[71676] = "HandsSlot"   ,	-- Gauntlets of the Fiery Conqueror,
	[71677] = "HeadSlot"    ,	-- Crown of the Fiery Conqueror,
	[71678] = "LegsSlot"    ,	-- Leggings of the Fiery Conqueror,
	[71679] = "ChestSlot"   ,	-- Chest of the Fiery Conqueror,
	[71680] = "ShoulderSlot",	-- Shoulders of the Fiery Conqueror,
	[71681] = "ShoulderSlot",	-- Mantle of the Fiery Conqueror,
	[71682] = "HeadSlot"    ,	-- Helm of the Fiery Protector,
	[71683] = "HandsSlot"   ,	-- Gauntlets of the Fiery Protector,
	[71684] = "HeadSlot"    ,	-- Crown of the Fiery Protector,
	[71685] = "LegsSlot"    ,	-- Leggings of the Fiery Protector,
	[71686] = "ChestSlot"   ,	-- Chest of the Fiery Protector,
	[71687] = "ShoulderSlot",	-- Shoulders of the Fiery Protector,
	[71688] = "ShoulderSlot",	-- Mantle of the Fiery Protector,
	[78170] = "ShoulderSlot",	-- Shoulders of the Corrupted Vanquisher,
	[78171] = "LegsSlot"    ,	-- Leggings of the Corrupted Vanquisher,
	[78172] = "HeadSlot"    ,	-- Crown of the Corrupted Vanquisher,
	[78173] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Vanquisher,
	[78174] = "ChestSlot"   ,	-- Chest of the Corrupted Vanquisher,
	[78175] = "ShoulderSlot",	-- Shoulders of the Corrupted Protector,
	[78176] = "LegsSlot"    ,	-- Leggings of the Corrupted Protector,
	[78177] = "HeadSlot"    ,	-- Crown of the Corrupted Protector,
	[78178] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Protector,
	[78179] = "ChestSlot"   ,	-- Chest of the Corrupted Protector,
	[78180] = "ShoulderSlot",	-- Shoulders of the Corrupted Conqueror,
	[78181] = "LegsSlot"    ,	-- Leggings of the Corrupted Conqueror,
	[78182] = "HeadSlot"    ,	-- Crown of the Corrupted Conqueror,
	[78183] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Conqueror,
	[78184] = "ChestSlot"   ,	-- Chest of the Corrupted Conqueror,
	[78847] = "ChestSlot"   ,	-- Chest of the Corrupted Conqueror,
	[78848] = "ChestSlot"   ,	-- Chest of the Corrupted Protector,
	[78849] = "ChestSlot"   ,	-- Chest of the Corrupted Vanquisher,
	[78850] = "HeadSlot"    ,	-- Crown of the Corrupted Conqueror,
	[78851] = "HeadSlot"    ,	-- Crown of the Corrupted Protector,
	[78852] = "HeadSlot"    ,	-- Crown of the Corrupted Vanquisher,
	[78853] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Conqueror,
	[78854] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Protector,
	[78855] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Vanquisher,
	[78856] = "LegsSlot"    ,	-- Leggings of the Corrupted Conqueror,
	[78857] = "LegsSlot"    ,	-- Leggings of the Corrupted Protector,
	[78858] = "LegsSlot"    ,	-- Leggings of the Corrupted Vanquisher,
	[78859] = "ShoulderSlot",	-- Shoulders of the Corrupted Conqueror,
	[78860] = "ShoulderSlot",	-- Shoulders of the Corrupted Protector,
	[78861] = "ShoulderSlot",	-- Shoulders of the Corrupted Vanquisher,
	[78862] = "ChestSlot"   ,	-- Chest of the Corrupted Vanquisher,
	[78863] = "ChestSlot"   ,	-- Chest of the Corrupted Conqueror,
	[78864] = "ChestSlot"   ,	-- Chest of the Corrupted Protector,
	[78865] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Vanquisher,
	[78866] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Conqueror,
	[78867] = "HandsSlot"   ,	-- Gauntlets of the Corrupted Protector,
	[78868] = "HeadSlot"    ,	-- Crown of the Corrupted Vanquisher,
	[78869] = "HeadSlot"    ,	-- Crown of the Corrupted Conqueror,
	[78870] = "HeadSlot"    ,	-- Crown of the Corrupted Protector,
	[78871] = "LegsSlot"    ,	-- Leggings of the Corrupted Vanquisher,
	[78872] = "LegsSlot"    ,	-- Leggings of the Corrupted Conqueror,
	[78873] = "LegsSlot"    ,	-- Leggings of the Corrupted Protector,
	[78874] = "ShoulderSlot",	-- Shoulders of the Corrupted Vanquisher,
	[78875] = "ShoulderSlot",	-- Shoulders of the Corrupted Conqueror,
	[78876] = "ShoulderSlot",	-- Shoulders of the Corrupted Protector,
	[89234] = "HeadSlot"    ,	-- Helm of the Shadowy Vanquisher,
	[89235] = "HeadSlot"    ,	-- Helm of the Shadowy Conqueror,
	[89236] = "HeadSlot"    ,	-- Helm of the Shadowy Protector,
	[89237] = "ChestSlot"   ,	-- Chest of the Shadowy Conqueror,
	[89238] = "ChestSlot"   ,	-- Chest of the Shadowy Protector,
	[89239] = "ChestSlot"   ,	-- Chest of the Shadowy Vanquisher,
	[89240] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Conqueror,
	[89241] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Protector,
	[89242] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Vanquisher,
	[89243] = "LegsSlot"    ,	-- Leggings of the Shadowy Conqueror,
	[89244] = "LegsSlot"    ,	-- Leggings of the Shadowy Protector,
	[89245] = "LegsSlot"    ,	-- Leggings of the Shadowy Vanquisher,
	[89246] = "ShoulderSlot",	-- Shoulders of the Shadowy Conqueror,
	[89247] = "ShoulderSlot",	-- Shoulders of the Shadowy Protector,
	[89248] = "ShoulderSlot",	-- Shoulders of the Shadowy Vanquisher,
	[89249] = "ChestSlot"   ,	-- Chest of the Shadowy Vanquisher,
	[89250] = "ChestSlot"   ,	-- Chest of the Shadowy Conqueror,
	[89251] = "ChestSlot"   ,	-- Chest of the Shadowy Protector,
	[89252] = "LegsSlot"    ,	-- Leggings of the Shadowy Vanquisher,
	[89253] = "LegsSlot"    ,	-- Leggings of the Shadowy Conqueror,
	[89254] = "LegsSlot"    ,	-- Leggings of the Shadowy Protector,
	[89255] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Vanquisher,
	[89256] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Conqueror,
	[89257] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Protector,
	[89258] = "HeadSlot"    ,	-- Helm of the Shadowy Vanquisher,
	[89259] = "HeadSlot"    ,	-- Helm of the Shadowy Conqueror,
	[89260] = "HeadSlot"    ,	-- Helm of the Shadowy Protector,
	[89261] = "ShoulderSlot",	-- Shoulders of the Shadowy Vanquisher,
	[89262] = "ShoulderSlot",	-- Shoulders of the Shadowy Conqueror,
	[89263] = "ShoulderSlot",	-- Shoulders of the Shadowy Protector,
	[89264] = "ChestSlot"   ,	-- Chest of the Shadowy Vanquisher,
	[89265] = "ChestSlot"   ,	-- Chest of the Shadowy Conqueror,
	[89266] = "ChestSlot"   ,	-- Chest of the Shadowy Protector,
	[89267] = "LegsSlot"    ,	-- Leggings of the Shadowy Vanquisher,
	[89268] = "LegsSlot"    ,	-- Leggings of the Shadowy Conqueror,
	[89269] = "LegsSlot"    ,	-- Leggings of the Shadowy Protector,
	[89270] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Vanquisher,
	[89271] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Conqueror,
	[89272] = "HandsSlot"   ,	-- Gauntlets of the Shadowy Protector,
	[89273] = "HeadSlot"    ,	-- Helm of the Shadowy Vanquisher,
	[89274] = "HeadSlot"    ,	-- Helm of the Shadowy Conqueror,
	[89275] = "HeadSlot"    ,	-- Helm of the Shadowy Protector,
	[89276] = "ShoulderSlot",	-- Shoulders of the Shadowy Vanquisher,
	[89277] = "ShoulderSlot",	-- Shoulders of the Shadowy Conqueror,
	[89278] = "ShoulderSlot",	-- Shoulders of the Shadowy Protector,
	[95569] = "ChestSlot"   ,	-- Chest of the Crackling Vanquisher,
	[95570] = "HandsSlot"   ,	-- Gauntlets of the Crackling Vanquisher,
	[95571] = "HeadSlot"    ,	-- Helm of the Crackling Vanquisher,
	[95572] = "LegsSlot"    ,	-- Leggings of the Crackling Vanquisher,
	[95573] = "ShoulderSlot",	-- Shoulders of the Crackling Vanquisher,
	[95574] = "ChestSlot"   ,	-- Chest of the Crackling Conqueror,
	[95575] = "HandsSlot"   ,	-- Gauntlets of the Crackling Conqueror,
	[95576] = "LegsSlot"    ,	-- Leggings of the Crackling Conqueror,
	[95577] = "HeadSlot"    ,	-- Helm of the Crackling Conqueror,
	[95578] = "ShoulderSlot",	-- Shoulders of the Crackling Conqueror,
	[95579] = "ChestSlot"   ,	-- Chest of the Crackling Protector,
	[95580] = "HandsSlot"   ,	-- Gauntlets of the Crackling Protector,
	[95581] = "LegsSlot"    ,	-- Leggings of the Crackling Protector,
	[95582] = "HeadSlot"    ,	-- Helm of the Crackling Protector,
	[95583] = "ShoulderSlot",	-- Shoulders of the Crackling Protector,
	[95822] = "ChestSlot"   ,	-- Chest of the Crackling Vanquisher,
	[95823] = "ChestSlot"   ,	-- Chest of the Crackling Conqueror,
	[95824] = "ChestSlot"   ,	-- Chest of the Crackling Protector,
	[95855] = "HandsSlot"   ,	-- Gauntlets of the Crackling Vanquisher,
	[95856] = "HandsSlot"   ,	-- Gauntlets of the Crackling Conqueror,
	[95857] = "HandsSlot"   ,	-- Gauntlets of the Crackling Protector,
	[95879] = "HeadSlot"    ,	-- Helm of the Crackling Vanquisher,
	[95880] = "HeadSlot"    ,	-- Helm of the Crackling Conqueror,
	[95881] = "HeadSlot"    ,	-- Helm of the Crackling Protector,
	[95887] = "LegsSlot"    ,	-- Leggings of the Crackling Vanquisher,
	[95888] = "LegsSlot"    ,	-- Leggings of the Crackling Conqueror,
	[95889] = "LegsSlot"    ,	-- Leggings of the Crackling Protector,
	[95955] = "ShoulderSlot",	-- Shoulders of the Crackling Vanquisher,
	[95956] = "ShoulderSlot",	-- Shoulders of the Crackling Conqueror,
	[95957] = "ShoulderSlot",	-- Shoulders of the Crackling Protector,
	[96194] = "ChestSlot"   ,	-- Chest of the Crackling Vanquisher,
	[96195] = "ChestSlot"   ,	-- Chest of the Crackling Conqueror,
	[96196] = "ChestSlot"   ,	-- Chest of the Crackling Protector,
	[96227] = "HandsSlot"   ,	-- Gauntlets of the Crackling Vanquisher,
	[96228] = "HandsSlot"   ,	-- Gauntlets of the Crackling Conqueror,
	[96229] = "HandsSlot"   ,	-- Gauntlets of the Crackling Protector,
	[96251] = "HeadSlot"    ,	-- Helm of the Crackling Vanquisher,
	[96252] = "HeadSlot"    ,	-- Helm of the Crackling Conqueror,
	[96253] = "HeadSlot"    ,	-- Helm of the Crackling Protector,
	[96259] = "LegsSlot"    ,	-- Leggings of the Crackling Vanquisher,
	[96260] = "LegsSlot"    ,	-- Leggings of the Crackling Conqueror,
	[96261] = "LegsSlot"    ,	-- Leggings of the Crackling Protector,
	[96327] = "ShoulderSlot",	-- Shoulders of the Crackling Vanquisher,
	[96328] = "ShoulderSlot",	-- Shoulders of the Crackling Conqueror,
	[96329] = "ShoulderSlot",	-- Shoulders of the Crackling Protector,
	[96566] = "ChestSlot"   ,	-- Chest of the Crackling Vanquisher,
	[96567] = "ChestSlot"   ,	-- Chest of the Crackling Conqueror,
	[96568] = "ChestSlot"   ,	-- Chest of the Crackling Protector,
	[96599] = "HandsSlot"   ,	-- Gauntlets of the Crackling Vanquisher,
	[96600] = "HandsSlot"   ,	-- Gauntlets of the Crackling Conqueror,
	[96601] = "HandsSlot"   ,	-- Gauntlets of the Crackling Protector,
	[96623] = "HeadSlot"    ,	-- Helm of the Crackling Vanquisher,
	[96624] = "HeadSlot"    ,	-- Helm of the Crackling Conqueror,
	[96625] = "HeadSlot"    ,	-- Helm of the Crackling Protector,
	[96631] = "LegsSlot"    ,	-- Leggings of the Crackling Vanquisher,
	[96632] = "LegsSlot"    ,	-- Leggings of the Crackling Conqueror,
	[96633] = "LegsSlot"    ,	-- Leggings of the Crackling Protector,
	[96699] = "ShoulderSlot",	-- Shoulders of the Crackling Vanquisher,
	[96700] = "ShoulderSlot",	-- Shoulders of the Crackling Conqueror,
	[96701] = "ShoulderSlot",	-- Shoulders of the Crackling Protector,
	[96938] = "ChestSlot"   ,	-- Chest of the Crackling Vanquisher,
	[96939] = "ChestSlot"   ,	-- Chest of the Crackling Conqueror,
	[96940] = "ChestSlot"   ,	-- Chest of the Crackling Protector,
	[96971] = "HandsSlot"   ,	-- Gauntlets of the Crackling Vanquisher,
	[96972] = "HandsSlot"   ,	-- Gauntlets of the Crackling Conqueror,
	[96973] = "HandsSlot"   ,	-- Gauntlets of the Crackling Protector,
	[96995] = "HeadSlot"    ,	-- Helm of the Crackling Vanquisher,
	[96996] = "HeadSlot"    ,	-- Helm of the Crackling Conqueror,
	[96997] = "HeadSlot"    ,	-- Helm of the Crackling Protector,
	[97003] = "LegsSlot"    ,	-- Leggings of the Crackling Vanquisher,
	[97004] = "LegsSlot"    ,	-- Leggings of the Crackling Conqueror,
	[97005] = "LegsSlot"    ,	-- Leggings of the Crackling Protector,
	[97071] = "ShoulderSlot",	-- Shoulders of the Crackling Vanquisher,
	[97072] = "ShoulderSlot",	-- Shoulders of the Crackling Conqueror,
	[97073] = "ShoulderSlot",	-- Shoulders of the Crackling Protector,
	[99667] = "HandsSlot"   ,	-- Gauntlets of the Cursed Protector,
	[99668] = "ShoulderSlot",	-- Shoulders of the Cursed Vanquisher,
	[99669] = "ShoulderSlot",	-- Shoulders of the Cursed Conqueror,
	[99670] = "ShoulderSlot",	-- Shoulders of the Cursed Protector,
	[99671] = "HeadSlot"    ,	-- Helm of the Cursed Vanquisher,
	[99672] = "HeadSlot"    ,	-- Helm of the Cursed Conqueror,
	[99673] = "HeadSlot"    ,	-- Helm of the Cursed Protector,
	[99674] = "LegsSlot"    ,	-- Leggings of the Cursed Vanquisher,
	[99675] = "LegsSlot"    ,	-- Leggings of the Cursed Conqueror,
	[99676] = "LegsSlot"    ,	-- Leggings of the Cursed Protector,
	[99677] = "ChestSlot"   ,	-- Chest of the Cursed Vanquisher,
	[99678] = "ChestSlot"   ,	-- Chest of the Cursed Conqueror,
	[99679] = "ChestSlot"   ,	-- Chest of the Cursed Protector,
	[99680] = "HandsSlot"   ,	-- Gauntlets of the Cursed Vanquisher,
	[99681] = "HandsSlot"   ,	-- Gauntlets of the Cursed Conqueror,
	[99682] = "HandsSlot"   ,	-- Gauntlets of the Cursed Vanquisher,
	[99683] = "HeadSlot"    ,	-- Helm of the Cursed Vanquisher,
	[99684] = "LegsSlot"    ,	-- Leggings of the Cursed Vanquisher,
	[99685] = "ShoulderSlot",	-- Shoulders of the Cursed Vanquisher,
	[99686] = "ChestSlot"   ,	-- Chest of the Cursed Conqueror,
	[99687] = "HandsSlot"   ,	-- Gauntlets of the Cursed Conqueror,
	[99688] = "LegsSlot"    ,	-- Leggings of the Cursed Conqueror,
	[99689] = "HeadSlot"    ,	-- Helm of the Cursed Conqueror,
	[99690] = "ShoulderSlot",	-- Shoulders of the Cursed Conqueror,
	[99691] = "ChestSlot"   ,	-- Chest of the Cursed Protector,
	[99692] = "HandsSlot"   ,	-- Gauntlets of the Cursed Protector,
	[99693] = "LegsSlot"    ,	-- Leggings of the Cursed Protector,
	[99694] = "HeadSlot"    ,	-- Helm of the Cursed Protector,
	[99695] = "ShoulderSlot",	-- Shoulders of the Cursed Protector,
	[99696] = "ChestSlot"   ,	-- Chest of the Cursed Vanquisher,
	[99712] = "LegsSlot"    ,	-- Leggings of the Cursed Conqueror,
	[99713] = "LegsSlot"    ,	-- Leggings of the Cursed Protector,
	[99714] = "ChestSlot"   ,	-- Chest of the Cursed Vanquisher,
	[99715] = "ChestSlot"   ,	-- Chest of the Cursed Conqueror,
	[99716] = "ChestSlot"   ,	-- Chest of the Cursed Protector,
	[99717] = "ShoulderSlot",	-- Shoulders of the Cursed Vanquisher,
	[99718] = "ShoulderSlot",	-- Shoulders of the Cursed Conqueror,
	[99719] = "ShoulderSlot",	-- Shoulders of the Cursed Protector,
	[99720] = "HandsSlot"   ,	-- Gauntlets of the Cursed Vanquisher,
	[99721] = "HandsSlot"   ,	-- Gauntlets of the Cursed Conqueror,
	[99722] = "HandsSlot"   ,	-- Gauntlets of the Cursed Protector,
	[99723] = "HeadSlot"    ,	-- Helm of the Cursed Vanquisher,
	[99724] = "HeadSlot"    ,	-- Helm of the Cursed Conqueror,
	[99725] = "HeadSlot"    ,	-- Helm of the Cursed Protector,
	[99726] = "LegsSlot"    ,	-- Leggings of the Cursed Vanquisher,
	[99742] = "ChestSlot"   ,	-- Chest of the Cursed Vanquisher,
	[99743] = "ChestSlot"   ,	-- Chest of the Cursed Conqueror,
	[99744] = "ChestSlot"   ,	-- Chest of the Cursed Protector,
	[99745] = "HandsSlot"   ,	-- Gauntlets of the Cursed Vanquisher,
	[99746] = "HandsSlot"   ,	-- Gauntlets of the Cursed Conqueror,
	[99747] = "HandsSlot"   ,	-- Gauntlets of the Cursed Protector,
	[99748] = "HeadSlot"    ,	-- Helm of the Cursed Vanquisher,
	[99749] = "HeadSlot"    ,	-- Helm of the Cursed Conqueror,
	[99750] = "HeadSlot"    ,	-- Helm of the Cursed Protector,
	[99751] = "LegsSlot"    ,	-- Leggings of the Cursed Vanquisher,
	[99752] = "LegsSlot"    ,	-- Leggings of the Cursed Conqueror,
	[99753] = "LegsSlot"    ,	-- Leggings of the Cursed Protector,
	[99754] = "ShoulderSlot",	-- Shoulders of the Cursed Vanquisher,
	[99755] = "ShoulderSlot",	-- Shoulders of the Cursed Conqueror,
	[99756] = "ShoulderSlot",	-- Shoulders of the Cursed Protector,
	[105857] = "MultiSlots"  ,	-- Essence of the Cursed Protector,
	[105858] = "MultiSlots"  ,	-- Essence of the Cursed Conqueror,
	[105859] = "MultiSlots"  ,	-- Essence of the Cursed Vanquisher,
	[105860] = "MultiSlots"  ,	-- Essence of the Cursed Protector,
	[105861] = "MultiSlots"  ,	-- Essence of the Cursed Conqueror,
	[105862] = "MultiSlots"  ,	-- Essence of the Cursed Vanquisher,
	[105863] = "MultiSlots"  ,	-- Essence of the Cursed Protector,
	[105864] = "MultiSlots"  ,	-- Essence of the Cursed Conqueror,
	[105865] = "MultiSlots"  ,	-- Essence of the Cursed Vanquisher,
	[105866] = "MultiSlots"  ,	-- Essence of the Cursed Protector,
	[105867] = "MultiSlots"  ,	-- Essence of the Cursed Conqueror,
	[105868] = "MultiSlots"  ,	-- Essence of the Cursed Vanquisher,
	[119305] = "ChestSlot"   ,	-- Chest of the Iron Conqueror,
	[119306] = "HandsSlot"   ,	-- Gauntlets of the Iron Conqueror,
	[119307] = "LegsSlot"    ,	-- Leggings of the Iron Conqueror,
	[119308] = "HeadSlot"    ,	-- Helm of the Iron Conqueror,
	[119309] = "ShoulderSlot",	-- Shoulders of the Iron Conqueror,
	[119310] = "MultiSlots"  ,	-- Essence of the Iron Conqueror,
	[119311] = "HandsSlot"   ,	-- Gauntlets of the Iron Vanquisher,
	[119312] = "HeadSlot"    ,	-- Helm of the Iron Vanquisher,
	[119313] = "LegsSlot"    ,	-- Leggings of the Iron Vanquisher,
	[119314] = "ShoulderSlot",	-- Shoulders of the Iron Vanquisher,
	[119315] = "ChestSlot"   ,	-- Chest of the Iron Vanquisher,
	[119316] = "MultiSlots"  ,	-- Essence of the Iron Vanquisher,
	[119318] = "ChestSlot"   ,	-- Chest of the Iron Protector,
	[119319] = "HandsSlot"   ,	-- Gauntlets of the Iron Protector,
	[119320] = "LegsSlot"    ,	-- Leggings of the Iron Protector,
	[119321] = "HeadSlot"    ,	-- Helm of the Iron Protector,
	[119322] = "ShoulderSlot",	-- Shoulders of the Iron Protector,
	[119323] = "MultiSlots"  ,	-- Essence of the Iron Protector,
	[120206] = "MultiSlots"  ,	-- Essence of the Iron Conqueror,
	[120207] = "MultiSlots"  ,	-- Essence of the Iron Protector,
	[120208] = "MultiSlots"  ,	-- Essence of the Iron Vanquisher,
	[120209] = "MultiSlots"  ,	-- Essence of the Iron Conqueror,
	[120210] = "MultiSlots"  ,	-- Essence of the Iron Protector,
	[120211] = "MultiSlots"  ,	-- Essence of the Iron Vanquisher,
	[120212] = "ChestSlot"   ,	-- Chest of the Iron Conqueror,
	[120213] = "HandsSlot"   ,	-- Gauntlets of the Iron Conqueror,
	[120214] = "LegsSlot"    ,	-- Leggings of the Iron Conqueror,
	[120215] = "HeadSlot"    ,	-- Helm of the Iron Conqueror,
	[120216] = "ShoulderSlot",	-- Shoulders of the Iron Conqueror,
	[120217] = "HandsSlot"   ,	-- Gauntlets of the Iron Vanquisher,
	[120218] = "HeadSlot"    ,	-- Helm of the Iron Vanquisher,
	[120219] = "LegsSlot"    ,	-- Leggings of the Iron Vanquisher,
	[120220] = "ShoulderSlot",	-- Shoulders of the Iron Vanquisher,
	[120221] = "ChestSlot"   ,	-- Chest of the Iron Vanquisher,
	[120222] = "ChestSlot"   ,	-- Chest of the Iron Protector,
	[120223] = "HandsSlot"   ,	-- Gauntlets of the Iron Protector,
	[120224] = "LegsSlot"    ,	-- Leggings of the Iron Protector,
	[120225] = "HeadSlot"    ,	-- Helm of the Iron Protector,
	[120226] = "ShoulderSlot",	-- Shoulders of the Iron Protector,
	[120227] = "ChestSlot"   ,	-- Chest of the Iron Conqueror,
	[120228] = "HandsSlot"   ,	-- Gauntlets of the Iron Conqueror,
	[120229] = "LegsSlot"    ,	-- Leggings of the Iron Conqueror,
	[120230] = "HeadSlot"    ,	-- Helm of the Iron Conqueror,
	[120231] = "ShoulderSlot",	-- Shoulders of the Iron Conqueror,
	[120232] = "HandsSlot"   ,	-- Gauntlets of the Iron Vanquisher,
	[120233] = "HeadSlot"    ,	-- Helm of the Iron Vanquisher,
	[120234] = "LegsSlot"    ,	-- Leggings of the Iron Vanquisher,
	[120235] = "ShoulderSlot",	-- Shoulders of the Iron Vanquisher,
	[120236] = "ChestSlot"   ,	-- Chest of the Iron Vanquisher,
	[120237] = "ChestSlot"   ,	-- Chest of the Iron Protector,
	[120238] = "HandsSlot"   ,	-- Gauntlets of the Iron Protector,
	[120239] = "LegsSlot"    ,	-- Leggings of the Iron Protector,
	[120240] = "HeadSlot"    ,	-- Helm of the Iron Protector,
	[120241] = "ShoulderSlot",	-- Shoulders of the Iron Protector,
	[120242] = "ChestSlot"   ,	-- Chest of the Iron Conqueror,
	[120243] = "HandsSlot"   ,	-- Gauntlets of the Iron Conqueror,
	[120244] = "LegsSlot"    ,	-- Leggings of the Iron Conqueror,
	[120245] = "HeadSlot"    ,	-- Helm of the Iron Conqueror,
	[120246] = "ShoulderSlot",	-- Shoulders of the Iron Conqueror,
	[120247] = "HandsSlot"   ,	-- Gauntlets of the Iron Vanquisher,
	[120248] = "HeadSlot"    ,	-- Helm of the Iron Vanquisher,
	[120249] = "LegsSlot"    ,	-- Leggings of the Iron Vanquisher,
	[120250] = "ShoulderSlot",	-- Shoulders of the Iron Vanquisher,
	[120251] = "ChestSlot"   ,	-- Chest of the Iron Vanquisher,
	[120252] = "ChestSlot"   ,	-- Chest of the Iron Protector,
	[120253] = "HandsSlot"   ,	-- Gauntlets of the Iron Protector,
	[120254] = "LegsSlot"    ,	-- Leggings of the Iron Protector,
	[120255] = "HeadSlot"    ,	-- Helm of the Iron Protector,
	[120256] = "ShoulderSlot",	-- Shoulders of the Iron Protector,
	[120277] = "MultiSlots"  ,	-- Essence of the Iron Conqueror,
	[120278] = "MultiSlots"  ,	-- Essence of the Iron Vanquisher,
	[120279] = "MultiSlots"  ,	-- Essence of the Iron Protector,
	[120280] = "MultiSlots"  ,	-- Essence of the Iron Conqueror,
	[120281] = "MultiSlots"  ,	-- Essence of the Iron Protector,
	[120282] = "MultiSlots"  ,	-- Essence of the Iron Vanquisher,
	[120283] = "MultiSlots"  ,	-- Essence of the Iron Conqueror,
	[120284] = "MultiSlots"  ,	-- Essence of the Iron Protector,
	[120285] = "MultiSlots"  ,	-- Essence of the Iron Vanquisher,
	[127953] = "ChestSlot"   ,	-- Chest of Hellfire's Conqueror,
	[127954] = "HandsSlot"   ,	-- Gauntlets of Hellfire's Conqueror,
	[127955] = "LegsSlot"    ,	-- Leggings of Hellfire's Conqueror,
	[127956] = "HeadSlot"    ,	-- Helm of Hellfire's Conqueror,
	[127957] = "ShoulderSlot",	-- Shoulders of Hellfire's Conqueror,
	[127958] = "HandsSlot"   ,	-- Gauntlets of Hellfire's Vanquisher,
	[127959] = "HeadSlot"    ,	-- Helm of Hellfire's Vanquisher,
	[127960] = "LegsSlot"    ,	-- Leggings of Hellfire's Vanquisher,
	[127961] = "ShoulderSlot",	-- Shoulders of Hellfire's Vanquisher,
	[127962] = "ChestSlot"   ,	-- Chest of Hellfire's Vanquisher,
	[127963] = "ChestSlot"   ,	-- Chest of Hellfire's Protector,
	[127964] = "HandsSlot"   ,	-- Gauntlets of Hellfire's Protector,
	[127965] = "LegsSlot"    ,	-- Leggings of Hellfire's Protector,
	[127966] = "HeadSlot"    ,	-- Helm of Hellfire's Protector,
	[127967] = "ShoulderSlot",	-- Shoulders of Hellfire's Protector,
	[127968] = "Trinket"     ,	-- Badge of Hellfire's Vanquisher,
	[127969] = "Trinket"     ,	-- Badge of Hellfire's Conqueror,
	[127970] = "Trinket"     ,	-- Badge of Hellfire's Protector,
	[143562] = "ChestSlot"   ,	-- Chest of the Foreseen Conqueror,
	[143563] = "HandsSlot"   ,	-- Gauntlets of the Foreseen Conqueror,
	[143564] = "LegsSlot"    ,	-- Leggings of the Foreseen Conqueror,
	[143565] = "HeadSlot"    ,	-- Helm of the Foreseen Conqueror,
	[143566] = "ShoulderSlot",	-- Shoulders of the Foreseen Conqueror,
	[143567] = "HandsSlot"   ,	-- Gauntlets of the Foreseen Vanquisher,
	[143568] = "HeadSlot"    ,	-- Helm of the Foreseen Vanquisher,
	[143569] = "LegsSlot"    ,	-- Leggings of the Foreseen Vanquisher,
	[143570] = "ShoulderSlot",	-- Shoulders of the Foreseen Vanquisher,
	[143571] = "ChestSlot"   ,	-- Chest of the Foreseen Vanquisher,
	[143572] = "ChestSlot"   ,	-- Chest of the Foreseen Protector,
	[143573] = "HandsSlot"   ,	-- Gauntlets of the Foreseen Protector,
	[143574] = "LegsSlot"    ,	-- Leggings of the Foreseen Protector,
	[143575] = "HeadSlot"    ,	-- Helm of the Foreseen Protector,
	[143576] = "ShoulderSlot",	-- Shoulders of the Foreseen Protector,
	[143577] = "BackSlot"    ,	-- Cloak of the Foreseen Conqueror,
	[143578] = "BackSlot"    ,	-- Cloak of the Foreseen Vanquisher,
	[143579] = "BackSlot"    ,	-- Cloak of the Foreseen Protector,
	[147316] = "ChestSlot"   ,	-- Chest of the Foregone Vanquisher,
	[147317] = "ChestSlot"   ,	-- Chest of the Foregone Conqueror,
	[147318] = "ChestSlot"   ,	-- Chest of the Foregone Protector,
	[147319] = "HandsSlot"   ,	-- Gauntlets of the Foregone Vanquisher,
	[147320] = "HandsSlot"   ,	-- Gauntlets of the Foregone Conqueror,
	[147321] = "HandsSlot"   ,	-- Gauntlets of the Foregone Protector,
	[147322] = "HeadSlot"    ,	-- Helm of the Foregone Vanquisher,
	[147323] = "HeadSlot"    ,	-- Helm of the Foregone Conqueror,
	[147324] = "HeadSlot"    ,	-- Helm of the Foregone Protector,
	[147325] = "LegsSlot"    ,	-- Leggings of the Foregone Vanquisher,
	[147326] = "LegsSlot"    ,	-- Leggings of the Foregone Conqueror,
	[147327] = "LegsSlot"    ,	-- Leggings of the Foregone Protector,
	[147328] = "ShoulderSlot",	-- Shoulders of the Foregone Vanquisher,
	[147329] = "ShoulderSlot",	-- Shoulders of the Foregone Conqueror,
	[147330] = "ShoulderSlot",	-- Shoulders of the Foregone Protector,
	[147331] = "BackSlot"    ,	-- Cloak of the Foregone Vanquisher,
	[147332] = "BackSlot"    ,	-- Cloak of the Foregone Conqueror,
	[147333] = "BackSlot"    ,	-- Cloak of the Foregone Protector,
	[152515] = "BackSlot"    ,	-- Cloak of the Antoran Protector,
	[152516] = "BackSlot"    ,	-- Cloak of the Antoran Conqueror,
	[152517] = "BackSlot"    ,	-- Cloak of the Antoran Vanquisher,
	[152518] = "ChestSlot"   ,	-- Chest of the Antoran Vanquisher,
	[152519] = "ChestSlot"   ,	-- Chest of the Antoran Conqueror,
	[152520] = "ChestSlot"   ,	-- Chest of the Antoran Protector,
	[152521] = "HandsSlot"   ,	-- Gauntlets of the Antoran Vanquisher,
	[152522] = "HandsSlot"   ,	-- Gauntlets of the Antoran Conqueror,
	[152523] = "HandsSlot"   ,	-- Gauntlets of the Antoran Protector,
	[152524] = "HeadSlot"    ,	-- Helm of the Antoran Vanquisher,
	[152525] = "HeadSlot"    ,	-- Helm of the Antoran Conqueror,
	[152526] = "HeadSlot"    ,	-- Helm of the Antoran Protector,
	[152527] = "LegsSlot"    ,	-- Leggings of the Antoran Vanquisher,
	[152528] = "LegsSlot"    ,	-- Leggings of the Antoran Conqueror,
	[152529] = "LegsSlot"    ,	-- Leggings of the Antoran Protector,
	[152530] = "ShoulderSlot",	-- Shoulders of the Antoran Vanquisher,
	[152531] = "ShoulderSlot",	-- Shoulders of the Antoran Conqueror,
	[152532] = "ShoulderSlot",	-- Shoulders of the Antoran Protector,
}

-- The base item level for the token on normal difficulty
_G.RCTokenIlvl = {
	--[xxxxxx] = ilvl,

	-- TIER 21 Antorus, the Burning Throne
	[152515] = 930,
	[152516] = 930,
	[152517] = 930,

	[152518] = 930,
	[152519] = 930,
	[152520] = 930,

	[152521] = 930,
	[152522] = 930,
	[152523] = 930,

	[152524] = 930,
	[152525] = 930,
	[152526] = 930,

	[152527] = 930,
	[152528] = 930,
	[152529] = 930,

	[152530] = 930,
	[152531] = 930,
	[152532] = 930,

	-- TIER 20 Tomb of Sargeras
	[147316] = 900,
	[147317] = 900,
	[147318] = 900,

	[147319] = 900,
	[147320] = 900,
	[147321] = 900,

	[147322] = 900,
	[147323] = 900,
	[147324] = 900,

	[147325] = 900,
	[147326] = 900,
	[147327] = 900,

	[147328] = 900,
	[147329] = 900,
	[147330] = 900,

	[147331] = 900,
	[147332] = 900,
	[147333] = 900,

	-- TIER 19 The Nighthold
	[143562] = 875,
	[143572] = 875,
	[143571] = 875,

	[143577] = 875,
	[143579] = 875,
	[143578] = 875,

	[143563] = 875,
	[143573] = 875,
	[143567] = 875,

	[143565] = 875,
	[143575] = 875,
	[143568] = 875,

	[143564] = 875,
	[143574] = 875,
	[143569] = 875,

	[143566] = 875,
	[143576] = 875,
	[143570] = 875,

	-- TIER 18	Hellfire Citadel
	[127953] = 695,
	[127962] = 695,
	[127963] = 695,

	[127955] = 695,
	[127960] = 695,
	[127965] = 695,

	[127956] = 695,
	[127959] = 695,
	[127966] = 695,

	[127957] = 695,
	[127961] = 695,
	[127967] = 695,

	[127954] = 695,
	[127958] = 695,
	[127964] = 695,

	[127968] = 695,
	[127969] = 695,
	[127970] = 695,
}

-- DEPRECATED. This data is generated by RC:GetItemClassesAllowedFlag() now.
-- Only Use this table in RC:PrepareLootTable for backward compatibility purpose.
-- Classes that can use the token
_G.RCTokenClasses = {
	--[xxxxxx] = {classes that can use the token},

	-- TIER 21 Antorus, the Burning Throne
	[152515] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
	[152516] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[152517] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},

	[152518] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[152519] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[152520] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[152521] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[152522] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[152523] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[152524] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[152525] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[152526] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[152527] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[152528] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[152529] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[152530] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[152531] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[152532] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	-- TIER 20 Tomb of Sargeras
	[147316] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[147317] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[147318] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[147319] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[147320] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[147321] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[147322] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[147323] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[147324] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[147325] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[147326] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[147327] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[147328] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[147329] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[147330] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[147331] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[147332] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[147333] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	-- TIER 19 The Nighthold
	[143562] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[143572] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
	[143571] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},

	[143577] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[143579] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
	[143578] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},

	[143563] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[143573] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
	[143567] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},

	[143565] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[143575] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
	[143568] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},

	[143564] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[143574] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
	[143569] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},

	[143566] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[143576] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
	[143570] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},

	-- TIER 18	Hellfire Citadel
	[127953] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[127962] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[127963] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[127955] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[127960] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[127965] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[127956] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[127959] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[127966] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[127957] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[127961] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[127967] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[127954] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[127958] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[127964] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},

	[127968] = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
	[127969] = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
	[127970] = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
}
