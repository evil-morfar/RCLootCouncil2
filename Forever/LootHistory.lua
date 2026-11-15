---@diagnostic disable: duplicate-set-field
--- @type RCLootCouncil
local addon = select(2, ...)
---@class RCLootHistory
local History = addon:GetModule "RCLootHistory"
local ItemUtils = addon.Require "Utils.Item"

History.wowheadBaseUrl = "https://www.wowhead.com/forever/item="

addon:SecureHook(History, "OnInitialize", function(self)
	self.exports.biscouncil = {
		func = self.ExportBisCouncil, name = "BisCouncil", tip = "BisCouncil formatted export.",
	}
end)

---Formats unix time as "YYYY-MM-DD"
---@param time integer Unix time
local function GetISODate(time)
	return date("%Y/%m/%d", time)
end

local export, ret = {}, {}
function History:ExportBisCouncil()
	wipe(export)
	wipe(ret)
	tinsert(ret, "player,date,itemID,response,class,id\r\n")
	for player, v in pairs(self:GetFilteredDB()) do
		for _, d in pairs(v) do
			tinsert(export, tostring(player))
			tinsert(export, GetISODate(strsplit("-", d.id, 2)))
			tinsert(export, ItemUtils:GetItemIDFromLink(d.lootWon))
			tinsert(export, tostring(d.response))
			tinsert(export, tostring(d.class))
			tinsert(export, tostring(d.id))
			tinsert(ret, table.concat(export, ","))
			tinsert(ret, "\r\n")
			wipe(export)
		end
	end
	return table.concat(ret)
end
