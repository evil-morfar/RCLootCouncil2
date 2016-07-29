-- Author      : Potdisc
-- Create Date : 3/11/2013 10:25:13 PM
-- tokenData.lua
-- Contains equip location and useable classes from tier tokens

-- Equip locations
RCTokenTable = {
	--[xxxxxx] = "ExampleSlot",

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

-- Classes that can use the token
RCTokenClasses = {
	--[xxxxxx] = {classes that can use the token},

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
