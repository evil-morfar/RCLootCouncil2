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
		elseif l:find("breast") or l:find("tunic") or l:find("robe") or l:find("chest") then
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
			slot = "WaitSlot"
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

	exports = exports.."-- Note: Item level data is manually entered."
	exports = exports.."\n_G.RCTokenIlvl = {\n"
	for _, entry in ipairs(sorted) do
		local name = entry[2]
		exports = exports.."\t["..entry[1].."] = 000,\t-- "..format("%s", name..",").."\n"
	end
	exports = exports.."}\n"
	frame.exportFrame.edit:SetText(exports)
end

function RCLootCouncil:ExportTokenDataSingle(id)
	if GetItemInfo(id) then
        local name, link, quality, _, _, _, _, maxStack = GetItemInfo(id)
        if self:GetItemClassesAllowedFlag(link) ~= 0xffffffff and maxStack == 1 and quality == 4 then
            DEFAULT_CHAT_FRAME:AddMessage(id.." "..name)
            tokenNames[id] = name
        end
    else
        return C_Timer.After(0, function() self:ExportTokenDataSingle(id) end)
    end
end
--@end-debug@

-- Equip locations
_G.RCTokenTable = {
	--[xxxxxx] = "ExampleSlot",

	-- TIER 21 Antorus, the Burning Throne
	[152515] = "BackSlot",
	[152516] = "BackSlot",
	[152517] = "BackSlot",

	[152518] = "ChestSlot",
	[152519] = "ChestSlot",
	[152520] = "ChestSlot",

	[152521] = "HandsSlot",
	[152522] = "HandsSlot",
	[152523] = "HandsSlot",

	[152524] = "HeadSlot",
	[152525] = "HeadSlot",
	[152526] = "HeadSlot",

	[152527] = "LegsSlot",
	[152528] = "LegsSlot",
	[152529] = "LegsSlot",

	[152530] = "ShoulderSlot",
	[152531] = "ShoulderSlot",
	[152532] = "ShoulderSlot",

	-- TIER 20 Tomb of Sargeres
	[147316] = "ChestSlot",
	[147317] = "ChestSlot",
	[147318] = "ChestSlot",

	[147319] = "HandsSlot",
	[147320] = "HandsSlot",
	[147321] = "HandsSlot",

	[147322] = "HeadSlot",
	[147323] = "HeadSlot",
	[147324] = "HeadSlot",

	[147325] = "LegsSlot",
	[147326] = "LegsSlot",
	[147327] = "LegsSlot",

	[147328] = "ShoulderSlot",
	[147329] = "ShoulderSlot",
	[147330] = "ShoulderSlot",

	[147331] = "BackSlot",
	[147332] = "BackSlot",
	[147333] = "BackSlot",

	-- TIER 19 The Nighthold
	[143562] = "ChestSlot",
	[143572] = "ChestSlot",
	[143571] = "ChestSlot",

	[143577] = "BackSlot",
	[143579] = "BackSlot",
	[143578] = "BackSlot",

	[143563] = "HandsSlot",
	[143573] = "HandsSlot",
	[143567] = "HandsSlot",

	[143565] = "HeadSlot",
	[143575] = "HeadSlot",
	[143568] = "HeadSlot",

	[143564] = "LegsSlot",
	[143574] = "LegsSlot",
	[143569] = "LegsSlot",

	[143566] = "ShoulderSlot",
	[143576] = "ShoulderSlot",
	[143570] = "ShoulderSlot",


	-- TIER 18	Hellfire Citadel
	[127962] = "ChestSlot",
	[127953] = "ChestSlot",
	[127963] = "ChestSlot",

	[127955] = "LegsSlot",
	[127960] = "LegsSlot",
	[127965] = "LegsSlot",

	[127956] = "HeadSlot",
	[127959] = "HeadSlot",
	[127966] = "HeadSlot",

	[127957] = "ShoulderSlot",
	[127961] = "ShoulderSlot",
	[127967] = "ShoulderSlot",

	[127958] = "HandsSlot",
	[127954] = "HandsSlot",
	[127964] = "HandsSlot",

	[127968] = "Trinket",
	[127969] = "Trinket",
	[127970] = "Trinket",

	-- TIER 17	 Blackrock Foundry ---------------------------
	-- Normal
	[119305] = "ChestSlot",
	[119318] = "ChestSlot",
	[119315] = "ChestSlot",

	[119307] = "LegsSlot",
	[119320] = "LegsSlot",
	[119313] = "LegsSlot",

	[119308] = "HeadSlot",
	[119321] = "HeadSlot",
	[119312] = "HeadSlot",

	[119309] = "ShoulderSlot",
	[119322] = "ShoulderSlot",
	[119314] = "ShoulderSlot",

	[119306] = "HandsSlot",
	[119319] = "HandsSlot",
	[119311] = "HandsSlot",


	-- Heroic
	[120227] = "ChestSlot",
	[120237] = "ChestSlot",
	[120236] = "ChestSlot",

	[120229] = "LegsSlot",
	[120239] = "LegsSlot",
	[120234] = "LegsSlot",

	[120230] = "HeadSlot",
	[120240] = "HeadSlot",
	[120233] = "HeadSlot",

	[120231] = "ShoulderSlot",
	[120241] = "ShoulderSlot",
	[120235] = "ShoulderSlot",

	[120228] = "HandsSlot",
	[120238] = "HandsSlot",
	[120232] = "HandsSlot",

	-- Mythic
	[120242] = "ChestSlot",
	[120252] = "ChestSlot",
	[120251] = "ChestSlot",

	[120244] = "LegsSlot",
	[120254] = "LegsSlot",
	[120249] = "LegsSlot",

	[120245] = "HeadSlot",
	[120255] = "HeadSlot",
	[120248] = "HeadSlot",

	[120246] = "ShoulderSlot",
	[120256] = "ShoulderSlot",
	[120250] = "ShoulderSlot",

	[120243] = "HandsSlot",
	[120253] = "HandsSlot",
	[120247] = "HandsSlot",

	-- TIER 16	 Siege of Orgrimmar ---------------------------
		-- Flexible
	[99742] = "ChestSlot",
	[99743] = "ChestSlot",
	[99744] = "ChestSlot",

	[99751] = "LegsSlot",
	[99752] = "LegsSlot",
	[99753] = "LegsSlot",

	[99748] = "HeadSlot",
	[99749] = "HeadSlot",
	[99750] = "HeadSlot",

	[99754] = "ShoulderSlot",
	[99755] = "ShoulderSlot",
	[99756] = "ShoulderSlot",

	[99745] = "HandsSlot",
	[99746] = "HandsSlot",
	[99747] = "HandsSlot",


		-- Normal
	[99696] = "ChestSlot",
	[99691] = "ChestSlot",
	[99686] = "ChestSlot",

	[99693] = "LegsSlot",
	[99684] = "LegsSlot",
	[99688] = "LegsSlot",

	[99683] = "HeadSlot",
	[99689] = "HeadSlot",
	[99694] = "HeadSlot",

	[99690] = "ShoulderSlot",
	[99685] = "ShoulderSlot",
	[99695] = "ShoulderSlot",

	[99682] = "HandsSlot",
	[99687] = "HandsSlot",
	[99692] = "HandsSlot",

		-- Heroic
	[99714] = "ChestSlot",
	[99715] = "ChestSlot",
	[99716] = "ChestSlot",

	[99712] = "LegsSlot",
	[99726] = "LegsSlot",
	[99713] = "LegsSlot",

	[99723] = "HeadSlot",
	[99724] = "HeadSlot",
	[99725] = "HeadSlot",

	[99717] = "ShoulderSlot",
	[99718] = "ShoulderSlot",
	[99719] = "ShoulderSlot",

	[99720] = "HandsSlot",
	[99721] = "HandsSlot",
	[99722] = "HandsSlot",


	-- TIER 15	 Throne of Thunder ----------------------------
		-- Normal
	[95569] = "ChestSlot",
	[95574] = "ChestSlot",
	[95579] = "ChestSlot",

	[95576] = "LegsSlot",
	[95572] = "LegsSlot",
	[95581] = "LegsSlot",

	[95571] = "HeadSlot",
	[95577] = "HeadSlot",
	[95582] = "HeadSlot",

	[95573] = "ShoulderSlot",
	[95578] = "ShoulderSlot",
	[95583] = "ShoulderSlot",

	[95575] = "HandsSlot",
	[95570] = "HandsSlot",
	[95580] = "HandsSlot",

		-- Heroic
	[96566] = "ChestSlot",
	[96567] = "ChestSlot",
	[96568] = "ChestSlot",

	[96631] = "LegsSlot",
	[96632] = "LegsSlot",
	[96633] = "LegsSlot",

	[96623] = "HeadSlot",
	[96624] = "HeadSlot",
	[96625] = "HeadSlot",

	[96699] = "ShoulderSlot",
	[96700] = "ShoulderSlot",
	[96701] = "ShoulderSlot",

	[96599] = "HandsSlot",
	[96600] = "HandsSlot",
	[96601] = "HandsSlot",


	-- TIER 14	- Heart of Fear, Terreace of Endless Springs---------------------
		--Normal
	[89238] = "ChestSlot",
	[89237] = "ChestSlot",
	[89239] = "ChestSlot",

	[89243] = "LegsSlot",
	[89244] = "LegsSlot",
	[89245] = "LegsSlot",

	[89234] = "HeadSlot",
	[89235] = "HeadSlot",
	[89236] = "HeadSlot",

	[89246] = "ShoulderSlot",
	[89247] = "ShoulderSlot",
	[89248] = "ShoulderSlot",

	[89240] = "HandsSlot",
	[89241] = "HandsSlot",
	[89242] = "HandsSlot",
		--Heroic
	[89250] = "ChestSlot",
	[89249] = "ChestSlot",
	[89251] = "ChestSlot",

	[89252] = "LegsSlot",
	[89253] = "LegsSlot",
	[89254] = "LegsSlot",

	[89258] = "HeadSlot",
	[89260] = "HeadSlot",
	[89259] = "HeadSlot",

	[89261] = "ShoulderSlot",
	[89262] = "ShoulderSlot",
	[89263] = "ShoulderSlot",

	[89255] = "HandsSlot",
	[89256] = "HandsSlot",
	[89257] = "HandsSlot",


	-- TIER 13 - Dragon Soul ---------------------------------
		-- Normal
	[78174] = "ChestSlot",
	[78179] = "ChestSlot",
	[78184] = "ChestSlot",

	[78176] = "LegsSlot",
	[78171] = "LegsSlot",
	[78181] = "LegsSlot",

	[78172] = "HeadSlot",
	[78177] = "HeadSlot",
	[78182] = "HeadSlot",

	[78170] = "ShoulderSlot",
	[78175] = "ShoulderSlot",
	[78180] = "ShoulderSlot",

	[78178] = "HandsSlot",
	[78173] = "HandsSlot",
	[78183] = "HandsSlot",
		-- Heroic
	[78847] = "ChestSlot",
	[78849] = "ChestSlot",
	[78848] = "ChestSlot",

	[78856] = "LegsSlot",
	[78857] = "LegsSlot",
	[78858] = "LegsSlot",

	[78850] = "HeadSlot",
	[78851] = "HeadSlot",
	[78852] = "HeadSlot",

	[78859] = "ShoulderSlot",
	[78860] = "ShoulderSlot",
	[78861] = "ShoulderSlot",

	[78853] = "HandsSlot",
	[78854] = "HandsSlot",
	[78855] = "HandsSlot",

	-- TIER 12 - Firelands -------------------------
		--Normal  (Some tiers where bought for JP)
	[71668] = "HeadSlot",
	[71675] = "HeadSlot",
	[71682] = "HeadSlot",

	[71674] = "ShoulderSlot",
	[71681] = "ShoulderSlot",
	[71688] = "ShoulderSlot",

		--Heroic
	[71672] = "ChestSlot",
	[71679] = "ChestSlot",
	[71686] = "ChestSlot",

	[71678] = "LegsSlot",
	[71671] = "LegsSlot",
	[71685] = "LegsSlot",

	[71677] = "HeadSlot",
	[71670] = "HeadSlot",
	[71684] = "HeadSlot",

	[71673] = "ShoulderSlot",
	[71680] = "ShoulderSlot",
	[71687] = "ShoulderSlot",

	[71669] = "HandsSlot",
	[71676] = "HandsSlot",
	[71683] = "HandsSlot",


	 -- TIER 8 - Ulduar -------------------------------
		-- Normal
	[45635] = "ChestSlot",
	[45636] = "ChestSlot",
	[45637] = "ChestSlot",

	[45647] = "HeadSlot",
	[45648] = "HeadSlot",
	[45649] = "HeadSlot",

	[45644] = "HandsSlot",
	[45645] = "HandsSlot",
	[45646] = "HandsSlot",

	[45650] = "LegsSlot",
	[45651] = "LegsSlot",
	[45652] = "LegsSlot",

	[45659] = "ShoulderSlot",
	[45660] = "ShoulderSlot",
	[45661] = "ShoulderSlot",

		-- Heroic
	[45632] = "ChestSlot",
	[45633] = "ChestSlot",
	[45634] = "ChestSlot",

	[45638] = "HeadSlot",
	[45639] = "HeadSlot",
	[45640] = "HeadSlot",

	[45641] = "HandsSlot",
	[45642] = "HandsSlot",
	[45643] = "HandsSlot",

	[45653] = "LegsSlot",
	[45654] = "LegsSlot",
	[45655] = "LegsSlot",

	[45656] = "ShoulderSlot",
	[45657] = "ShoulderSlot",
	[45658] = "ShoulderSlot",
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
