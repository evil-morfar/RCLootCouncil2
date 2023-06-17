require "busted.runner" ()

--- @type RCLootCouncil
local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
local VotingFrame = addon.modules.RCVotingFrame

dofile(".specs/EmulatePlayerLogin.lua")

describe("#VotingFrame #RandomRolls", function()
	it("should execute without errors", function()
		assert.has_no.errors(function()
			VotingFrame:DoAllRandomRolls()
			VotingFrame:DoRandomRolls(1)
			VotingFrame:DoRandomRolls()
		end)
	end)

	it("GenerateNoRepeatRollTable should return a comma seperated string of rolls", function()
		local rolls = VotingFrame:GenerateNoRepeatRollTable(3)
		assert.is_string(rolls)
		assert.is_not_nil(rolls:match("%d+,%d+,%d+"))
		assert.equals(3, #{ string.split(",", rolls), })
	end)

	it("GenerateNoRepeatRollTable only supports 100 numbers", function()
		assert.has_error(function()
			VotingFrame:GenerateNoRepeatRollTable(101)
		end, "Can't generate more than 100 rolls at a time.")
	end)

	it("full flow", function()
		dofile(".specs/Helpers/SetupRaid.lua")(20)
		addon.Require "Utils.Log":Clear()
		addon.player = addon.Require "Data.Player":Get("player")
		local origWowApi = WoWAPI_FireEvent

		-- Override msg events to add the player name
		function _G.WoWAPI_FireEvent(event, ...)
			if event == "CHAT_MSG_ADDON" then
				local prefix, message, distribution = ...
				return origWowApi(event, prefix, message, distribution, addon.player:GetName())
			end
			return origWowApi(event, ...)
		end

		addon:Test(1, true)
		WoWAPI_FireUpdate(GetTime() + 1)
		RCLootCouncilML:StartSession()
		WoWAPI_FireUpdate(GetTime() + 10)

		-- Setup spies before doing rolls
		local generateNoRepeatRollTable = spy.on(VotingFrame, "GenerateNoRepeatRollTable")
		local doAllRandomRolls = spy.on(VotingFrame, "DoAllRandomRolls")
		local SetCandidateData = spy.on(VotingFrame, "SetCandidateData")

		-- Subscribe to the comms to store the rolls
		local receivedRolls
		addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "rrolls", function (data)
			local _, rolls = unpack(data)
			receivedRolls = {string.split(",", rolls)}
		end)

		VotingFrame:DoAllRandomRolls()
		WoWAPI_FireUpdate(GetTime() + 10)

		assert.spy(generateNoRepeatRollTable).was.called_with(match.is_ref(VotingFrame),20)
		assert.spy(doAllRandomRolls).was.called(1)
		-- Note the sort is weird due to the 'PlayerX' structure of names
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player1-Realm1", "roll", receivedRolls[1])
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player10-Realm1", "roll", receivedRolls[2])
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player11-Realm1", "roll", receivedRolls[3])
		-- and so on
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player9-Realm1", "roll", receivedRolls[20])
	end)
end)
