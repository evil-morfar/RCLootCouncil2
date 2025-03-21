require "busted.runner" ()

--- @type RCLootCouncil
local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")

dofile(".specs/EmulatePlayerLogin.lua")

describe("#VotingFrame #RandomRolls", function()
	---@type RCVotingFrame
	local VotingFrame = addon.modules.RCVotingFrame
	local Comms = addon.Require "Services.Comms"
	local snapshot
	-- Supress prints
	addon.Print = addon.noop
	before_each(function()
		addon.Require "Utils.Log":Clear()
		snapshot = assert:snapshot()
		addon.db.global.verTestCandidates = {}
		addon.Require "Data.Council":Set{}
	end)

	after_each(function()
		snapshot:revert()
		-- Occasionally items were left by previouss tests
		_ADVANCE_TIME(5)
		RCLootCouncilML:EndSession()
	end)

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

	it("it should use old 'rrolls' when version is below 3.13.0", function()
		dofile(".specs/Helpers/SetupRaid.lua")(20)
		addon.player = addon.Require "Data.Player":Get("player")
		-- Setting a verTestCandidate to be below 3.13.0 will force old method
		addon.db.global.verTestCandidates[(GetRaidRosterInfo(2))] = { "3.12.0", nil, time(), }

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
		local sub = Comms:Subscribe(addon.PREFIXES.MAIN, "rrolls", function(data)
			local _, rolls = unpack(data)
			receivedRolls = { string.split(",", rolls), }
		end)

		VotingFrame:DoAllRandomRolls()
		WoWAPI_FireUpdate(GetTime() + 10)

		assert.spy(generateNoRepeatRollTable).was.called_with(match.is_ref(VotingFrame), 20)
		assert.spy(doAllRandomRolls).was.called(1)
		-- Note the sort is weird due to the 'PlayerX' structure of names
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player1-Realm1", "roll",
			tonumber(receivedRolls[1]))
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player10-Realm1", "roll",
			tonumber(receivedRolls[2]))
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player11-Realm1", "roll",
			tonumber(receivedRolls[3]))
		-- and so on
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player9-Realm1", "roll",
			tonumber(receivedRolls[20]))

		sub:unsubscribe()
	end)

	it("should use 'srolls' when version is above 3.13.0", function()
		dofile(".specs/Helpers/SetupRaid.lua")(20)
		addon.player = addon.Require "Data.Player":Get("player")
		-- Test might pick the same item twice which screws with our intended result
		addon:Test(0, true)
		_ADVANCE_TIME(1)
		RCLootCouncilML:AddItem(159668)
		RCLootCouncilML:AddItem(155860)
		RCLootCouncilML:StartSession()
		_ADVANCE_TIME(2)

		-- Setup spies before doing rolls
		local generateNoRepeatRollTable = spy.on(VotingFrame, "GenerateNoRepeatRollTable")
		local doAllRandomRolls = spy.on(VotingFrame, "DoAllRandomRolls")
		local SetCandidateData = spy.on(VotingFrame, "SetCandidateData")
		local OnSessionRollsReceivedSpy = spy.on(VotingFrame, "OnSessionRollsReceived")

		-- Subscribe to the comms to store the rolls
		local receivedRolls = {}
		local recieverFunc = function(data)
			local rolls = unpack(data)
			for _, sessionRolls in ipairs { string.split("|", rolls), } do
				if sessionRolls == "" then break end
				local _, e, session = string.find(sessionRolls, "(%d+),")
				sessionRolls = string.sub(sessionRolls, e + 1)
				receivedRolls[tonumber(session)] = { string.split(",", sessionRolls), } end
		end
		local sub = Comms:Subscribe(addon.PREFIXES.MAIN, "srolls", recieverFunc)

		VotingFrame:DoAllRandomRolls()
		_ADVANCE_TIME(2)

		assert.spy(generateNoRepeatRollTable).was.called_with(match.is_ref(VotingFrame), 20)
		assert.spy(doAllRandomRolls).was.called(1)
		assert.spy(OnSessionRollsReceivedSpy).was.called(1)
		-- Note the sort is weird due to the 'PlayerX' structure of names
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player1-Realm1", "roll",
			tonumber(receivedRolls[1][1]))
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player10-Realm1", "roll",
			tonumber(receivedRolls[1][2]))
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player11-Realm1", "roll",
			tonumber(receivedRolls[1][3]))
		-- and so on
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 1, "Player9-Realm1", "roll",
			tonumber(receivedRolls[1][20]))

		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 2, "Player1-Realm1", "roll",
			tonumber(receivedRolls[2][1]))
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 2, "Player10-Realm1", "roll",
			tonumber(receivedRolls[2][2]))
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 2, "Player11-Realm1", "roll",
			tonumber(receivedRolls[2][3]))
		-- and so on
		assert.spy(SetCandidateData).was.called_with(match.is_ref(VotingFrame), 2, "Player9-Realm1", "roll",
			tonumber(receivedRolls[2][20]))

		sub:unsubscribe()
	end)

	it("should not override rolls for sessions that already has rolls", function()
		dofile(".specs/Helpers/SetupRaid.lua")(20)
		addon.player = addon.Require "Data.Player":Get("player")

		math.randomseed(2) -- For some reason, using default seed will create a session with 2 duplicate items
		addon:Test(3, true)
		WoWAPI_FireUpdate(GetTime() + 1)
		RCLootCouncilML:StartSession()
		WoWAPI_FireUpdate(GetTime() + 10)

		-- Setup spies before doing rolls
		local generateNoRepeatRollTable = spy.on(VotingFrame, "GenerateNoRepeatRollTable")
		local doAllRandomRolls = spy.on(VotingFrame, "DoAllRandomRolls")
		local OnSessionRollsReceivedSpy = spy.on(VotingFrame, "OnSessionRollsReceived")

		-- Subscribe to the comms to store the rolls
		local receivedRolls = {}
		local recieverFunc = function(data)
			local rolls = unpack(data)
			for sessionRolls in rolls:gmatch("(.-)|") do
				if sessionRolls:find("dupl") then
					local session, duplicateOf = sessionRolls:match("(%d+)dupl(%d+)")
					receivedRolls[tonumber(session)] = receivedRolls[tonumber(duplicateOf)]
				else
					local _, e, session = string.find(sessionRolls, "(%d+),")
					sessionRolls = string.sub(sessionRolls, e + 1)
					receivedRolls[tonumber(session)] = { string.split(",", sessionRolls), }
				end
			end
		end
		local sub = Comms:Subscribe(addon.PREFIXES.MAIN, "srolls", recieverFunc)

		-- First random roll session 2:
		VotingFrame:DoRandomRolls(2)
		WoWAPI_FireUpdate(GetTime() + 10)
		-- Then the rest:
		VotingFrame:DoAllRandomRolls()
		_ADVANCE_TIME(.5)

		assert.spy(generateNoRepeatRollTable).was.called_with(match.is_ref(VotingFrame), 20)
		assert.spy(generateNoRepeatRollTable).was.called(3) -- First 1 for session 2, then once for 1 & 3
		assert.spy(doAllRandomRolls).was.called(1)
		assert.spy(OnSessionRollsReceivedSpy).was.called(2) -- Once for DoRandomRolls and once for DoAllRandomRolls
		assert.is_table(receivedRolls[1])
		assert.is_table(receivedRolls[2])
		assert.is_table(receivedRolls[3])

		sub:unsubscribe()
	end)
	it("should handle duplicates", function()
		dofile(".specs/Helpers/SetupRaid.lua")(20)
		addon.player = addon.Require "Data.Player":Get("player")
		addon.db.profile.sortItems = false

		addon:CallModule("masterlooter")
		addon:GetActiveModule("masterlooter"):NewML(addon.player)
		addon:GetActiveModule("masterlooter"):Test { 159366, 165584, 159366, }
		_ADVANCE_TIME(1)
		RCLootCouncilML:StartSession()
		_ADVANCE_TIME(1)

		local generateNoRepeatRollTable = spy.on(VotingFrame, "GenerateNoRepeatRollTable")
		local OnSessionRollsReceivedSpy = spy.on(VotingFrame, "OnSessionRollsReceived")
		_ADVANCE_TIME(.1)
		VotingFrame:DoRandomRolls(1)
		_ADVANCE_TIME(1)
		assert.spy(generateNoRepeatRollTable).was.called(1)
		assert.spy(OnSessionRollsReceivedSpy).was.called(1)
		-- All rolls in session 1 & 3 should be the same
		for name in addon:GroupIterator() do
			assert.is_number(VotingFrame:GetCandidateData(1, name, "roll"))
			assert.equal(VotingFrame:GetCandidateData(1, name, "roll"),
				VotingFrame:GetCandidateData(3, name, "roll"))
		end
	end)
end)
