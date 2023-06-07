require "busted.runner" ()


local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
local VotingFrame = addon.modules.RCVotingFrame

dofile(".specs/EmulatePlayerLogin.lua")



--- Returns a random guid
function GetRandomGUID(size)
	size = size or 8
	local guid = ""
	for i = 1, size do
		guid = guid .. string.format("%x", math.random(0, 0xf))
	end
	return guid
end

describe("#VotingFrame #RandomRolls", function()
	it("should execute without errors", function()
		assert.has_no.errors(function ()
			VotingFrame:DoAllRandomRolls()
			VotingFrame:DoRandomRolls(1)
			VotingFrame:DoRandomRolls()
		end)
	end)

	it("GenerateNoRepeatRollTable should return a comma seperated string of rolls", function()
		local rolls = VotingFrame:GenerateNoRepeatRollTable(3)
		assert.is_string(rolls)
		assert.is_not_nil(rolls:match("%d+,%d+,%d+"))
		assert.equals(3, #{string.split(",", rolls)})
	end)

	it("should do", function()
		-- local Council = addon.Require "Data.Council"
		-- Council:Add(addon.player)
		local origWowApi = WoWAPI_FireEvent

		function _G.WoWAPI_FireEvent(event, ...)
			if event == "CHAT_MSG_ADDON" then
				local prefix, message, distribution = ...
				return origWowApi(event, prefix, message, distribution, addon.player:GetName())
			end
			return origWowApi(event, ...)
		end
		function addon:GetNumGroupMembers() return 10 end
		addon:Test(1, true)
		WoWAPI_FireUpdate(GetTime() + 1)
		-- WoWAPI_FireUpdate(GetTime() + 10)
		RCLootCouncilML:StartSession()
		WoWAPI_FireUpdate(GetTime() + 10)
		VotingFrame:DoAllRandomRolls()
		WoWAPI_FireUpdate(GetTime() + 10)
		-- WoWAPI_FireUpdate(GetTime() + 1)
		-- WoWAPI_FireUpdate(GetTime() + 1)
		-- WoWAPI_FireUpdate(GetTime() + 1)
		printtable(addon.db.global.log)

	end)
end)
