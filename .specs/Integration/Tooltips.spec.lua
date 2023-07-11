require "busted.runner" ()
dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

local addon = RCLootCouncil

-- Following are gathered from https://www.townlong-yak.com/framexml/live/GlobalStrings.lua/LANGUAGE
local locales = {
	GB = {
		BIND_TRADE_TIME_REMAINING =
		"You may trade this item with players that were also eligible to loot this item for the next %s (including time offline).";
		INT_SPELL_DURATION_HOURS = "%d |4hour:hrs;";
		INT_SPELL_DURATION_MIN = "%d min";
		INT_SPELL_DURATION_SEC = "%d sec";
		TIME_UNIT_DELIMITER = " ",
	},
	TW = {
		BIND_TRADE_TIME_REMAINING = "你可以在接下來的%s內(包含離線時間)與同樣擁有拾取權的玩家交易此物品。";
		INT_SPELL_DURATION_HOURS = "%d小時";
		INT_SPELL_DURATION_MIN = "%d分鐘";
		INT_SPELL_DURATION_SEC = "%d秒";
		TIME_UNIT_DELIMITER = " ";
	},
	MX = {
		BIND_TRADE_TIME_REMAINING =
		"Podrás comerciar este objeto durante los siguientes %s (inclusive durante el tiempo fuera de línea) con jugadores que también reúnan los requisitos para quedárselo.";
		INT_SPELL_DURATION_HOURS = "%d |4h:h;";
		INT_SPELL_DURATION_MIN = "%d min";
		INT_SPELL_DURATION_SEC = "%d s";
		TIME_UNIT_DELIMITER = " ";
	},
	KR = {
		BIND_TRADE_TIME_REMAINING = "아이템 획득 자격이 있는 다른 플레이어와 앞으로 %s 동안 거래할 수 있습니다. (오프라인 시간 포함)";
		INT_SPELL_DURATION_HOURS = "%d시간";
		INT_SPELL_DURATION_MIN = "%d분";
		INT_SPELL_DURATION_SEC = "%d초";
		TIME_UNIT_DELIMITER = " ";
	},
	IT = {
		BIND_TRADE_TIME_REMAINING =
		"Questo oggetto può essere ceduto per ancora %s (incluso il tempo in cui si è disconnessi) ai personaggi che hanno partecipato al relativo evento.";
		INT_SPELL_DURATION_HOURS = "%d |4ora:ore;";
		INT_SPELL_DURATION_MIN = "%d min";
		INT_SPELL_DURATION_SEC = "%d s";
		TIME_UNIT_DELIMITER = " ";
	},
	RU = {
		BIND_TRADE_TIME_REMAINING =
		"Вы можете отдать этот предмет другому игроку, если тот тоже имеет право получить его, в течение %1$s (включая время, проведенное вне игры).";
		INT_SPELL_DURATION_HOURS = "%d ч";
		INT_SPELL_DURATION_MIN = "%d мин";
		INT_SPELL_DURATION_SEC = "%d сек";
		TIME_UNIT_DELIMITER = " ";
	},
	FR = {
		BIND_TRADE_TIME_REMAINING =
		"Il vous reste %s (temps réel) pour échanger cet objet avec les personnes qui avaient également la possibilité de le ramasser.";
		INT_SPELL_DURATION_HOURS = "%d |4heure:heures;";
		INT_SPELL_DURATION_MIN = "%d min";
		INT_SPELL_DURATION_SEC = "%d s";
		TIME_UNIT_DELIMITER = " ";
	},
	ES = {
		BIND_TRADE_TIME_REMAINING =
		"Puedes comerciar con este objeto durante %s (incluido el tiempo sin conexión) con jugadores que también reúnan los requisitos para quedárselo.";
		INT_SPELL_DURATION_HOURS = "%d |4h:h;";
		INT_SPELL_DURATION_MIN = "%d min";
		INT_SPELL_DURATION_SEC = "%d s";
		TIME_UNIT_DELIMITER = " ";
	},
	DE = {
		BIND_TRADE_TIME_REMAINING =
		"Ihr könnt diesen Gegenstand innerhalb von %s (inklusive Zeit offline) mit anderen Spielern handeln, die ebenfalls berechtigt waren, diesen Gegenstand zu plündern.";
		INT_SPELL_DURATION_HOURS = "%d |4Stunde:Stunden;";
		INT_SPELL_DURATION_MIN = "%d Min.";
		INT_SPELL_DURATION_SEC = "%d Sek.";
		TIME_UNIT_DELIMITER = " ";
	},
	CN = {
		BIND_TRADE_TIME_REMAINING = "你可以在接下来的%s内将这个物品交易给同样拥有资格拾取它的其他玩家（包括离线时间）。";
		INT_SPELL_DURATION_HOURS = "%d小时";
		INT_SPELL_DURATION_MIN = "%d分钟";
		INT_SPELL_DURATION_SEC = "%d秒";
		TIME_UNIT_DELIMITER = " ";
	},
	BR = {
		BIND_TRADE_TIME_REMAINING =
		"Você pode negociar este item com jogadores que também podiam saqueá-lo em até: %s (inclusive tempo offline).";
		INT_SPELL_DURATION_HOURS = "%d |4hora:horas;";
		INT_SPELL_DURATION_MIN = "%d min";
		INT_SPELL_DURATION_SEC = "%d s";
		TIME_UNIT_DELIMITER = " ";
	},
}


local function Setup(timeRemainingText, locale, notSoulbound)
	local tt = _G["RCLootCouncil_Tooltip_Parse"]
	tt:ClearLines()
	-- Add a few lines to emulate an actual item tooltip
	tt:AddLine("Some awesome item")
	tt:AddLine(notSoulbound and "" or ITEM_SOULBOUND)
	tt:AddLine("Item Level 100")
	tt:AddLine("+ 9000 intellect")
	tt:AddLine()
	tt:AddLine(timeRemainingText)
	tt:AddLine("What ever goes to the bottom of the tooltip")

	-- Setup locale globals
	locale = locale or "GB"
	for k, v in pairs(locales[locale]) do
		_G[k] = v
	end
end

local function BuildTimeText(hour, minute, localeData)
	local timeText = addon:CompleteFormatSimpleStringWithPluralRule(localeData.INT_SPELL_DURATION_HOURS, hour)
	return timeText ..
		localeData.TIME_UNIT_DELIMITER ..
		addon:CompleteFormatSimpleStringWithPluralRule(localeData.INT_SPELL_DURATION_MIN, minute)
end


describe("#Tooltip Parsing for trade time remaining", function()
	describe("should parse tooltips with trade times correctly", function()
		for lang, data in pairs(locales) do
			it("should handle " .. lang, function()
				local timeText = BuildTimeText(3, 54, data)

				local timeRemainingLine = data.BIND_TRADE_TIME_REMAINING
					:gsub("1%$", "") -- Handle weird insertion in RU
					:gsub("%%s", timeText)
				Setup(timeRemainingLine, lang)
				local result = addon:GetContainerItemTradeTimeRemaining()
				assert.is.equal(14040, result)
			end)
		end
	end)

	it("should handle soulbound items without trade timers", function()
		Setup("", "GB")
		local result = addon:GetContainerItemTradeTimeRemaining()
		assert.is.equal(0, result)
	end)

	it("should handle non-soulbound items without trade timers", function()
		Setup("", "GB", true)
		local result = addon:GetContainerItemTradeTimeRemaining()
		assert.is.equal(math.huge, result)
	end)
end)
