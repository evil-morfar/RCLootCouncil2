require "busted.runner" ()

--- @type RCLootCouncil
local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")

local Council = addon.Require "Data.Council"
local Player = addon.Require "Data.Player"

dofile(".specs/EmulatePlayerLogin.lua")
describe("#VotingFrame #ReannounceOrRequestRoll", function()
	---@type RCVotingFrame
	local VotingFrame = addon.modules.RCVotingFrame
	addon.Print = addon.noop
	dofile(".specs/Helpers/SetupRaid.lua")(20)

	local snapshot
	before_each(function()
		snapshot = assert:snapshot()
		wipe(addon.db.global.verTestCandidates)
		wipe(addon.db.global.log)
		Council:Set({})
		addon.player = addon.Require "Data.Player":Get("player")
		WoWAPI_FireUpdate(GetTime() + 5000) -- Trigger "UpdateCandidatesInGroup"
		addon:CallModule("masterlooter")
		addon:GetActiveModule("masterlooter"):NewML(addon.player)
		addon:GetActiveModule("masterlooter"):Test { 159366, 165584, }
		WoWAPI_FireUpdate(GetTime() + 10)
		RCLootCouncilML:StartSession()
	end)

	after_each(function()
		RCLootCouncilML:EndSession()
		WoWAPI_FireUpdate()
		snapshot:revert()
	end)
	describe("change response", function()
		it("ReannounceOrRequestRoll should set responses to 'WAIT' when called as non-roll", function()
			local receivedSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "ResponseWait", receivedSpy)
			local rerollSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "reroll", rerollSpy)

			WoWAPI_FireUpdate(GetTime() + 20)
			VotingFrame:ReannounceOrRequestRoll(true, 1, false, false, false)
			WoWAPI_FireUpdate(GetTime() + 30)

			assert.spy(receivedSpy).was.called(1)
			assert.spy(rerollSpy).was.called(1)
			assert.spy(rerollSpy).was.called_with(match.table(), addon.player.name, "reroll", "RAID")
			local lootTable = VotingFrame:GetLootTable()
			for name, v in pairs(lootTable[1].candidates) do
				if name ~= addon.player.name then -- We might already have autopassed
					assert.Equal("WAIT", v.response)
				end
			end
			-- Session 2 should remain untouched.
			for name, v in pairs(lootTable[2].candidates) do
				if name ~= addon.player.name then -- We might already have autopassed
					assert.Equal("NOTHING", v.response)
				end
			end
		end)

		it("should send rerolls to specific players depending on namepred", function()
			local doRerollSpy = spy.on(addon, "DoReroll")
			local rerollSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "re_roll", rerollSpy)
			VotingFrame:ReannounceOrRequestRoll(addon.player.name, 1, false, false, false)
			WoWAPI_FireUpdate(GetTime() + 10)
			assert.spy(rerollSpy).was.called(1)
			assert.spy(doRerollSpy).was.called(1)
			assert.spy(rerollSpy).was.called_with(match.table(), addon.player.name, "re_roll", "RAID")

			VotingFrame:ReannounceOrRequestRoll((GetRaidRosterInfo(2)), 1, false, false, false)
			WoWAPI_FireUpdate(GetTime() + 10)
			assert.spy(rerollSpy).was.called(2)
			assert.spy(doRerollSpy).was.called(1)
			assert.spy(rerollSpy).was.called_with(match.table(), addon.player.name, "re_roll", "RAID")
		end)

		it("should not send out rerolls if there's no valid candidates", function()
			local doRerollSpy = spy.on(addon, "DoReroll")
			local rerollSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "re_roll", rerollSpy)
			VotingFrame:ReannounceOrRequestRoll("SomePlayer", 1, false, false, false)
			WoWAPI_FireUpdate(GetTime() + 10)
			assert.spy(rerollSpy).was.not_called()
			assert.spy(doRerollSpy).was.not_called()
		end)

		it("ReannounceOrRequestRoll should not touch responses when 'isRoll' is true", function()
			local receivedSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "ResponseWait", receivedSpy)

			WoWAPI_FireUpdate(GetTime() + 20)
			VotingFrame:ReannounceOrRequestRoll(true, 1, true, false, false)
			WoWAPI_FireUpdate(GetTime() + 30)

			assert.spy(receivedSpy).was.called(0)
			for _, data in ipairs(VotingFrame:GetLootTable()) do
				for name, v in pairs(data.candidates) do
					if name ~= addon.player.name then -- We might already have autopassed
						assert.Equal("NOTHING", v.response)
					end
				end
			end
		end)

		it("should change for everyone when both name- and sessionpred is true", function()
			local receivedSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "ResponseWait", receivedSpy)
			local rerollSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "reroll", rerollSpy)

			WoWAPI_FireUpdate(GetTime() + 20)
			WoWAPI_FireUpdate(GetTime() + 30)
			WoWAPI_FireUpdate(GetTime() + 40)
			VotingFrame:ReannounceOrRequestRoll(true, true, false, false, false)
			WoWAPI_FireUpdate(GetTime() + 50)

			assert.spy(receivedSpy).was.called(1)
			assert.spy(rerollSpy).was.called(1)
			assert.spy(rerollSpy).was.called_with(match.table(), addon.player.name, "reroll", "RAID")
			local lootTable = VotingFrame:GetLootTable()
			for name, v in pairs(lootTable[1].candidates) do
				if name ~= addon.player.name then -- We might already have autopassed
					assert.Equal("WAIT", v.response)
				end
			end
		end)
	end)

	describe("change rolls", function()
		it("ReannounceOrRequestRoll should reset rolls when 'isRoll' is true", function()
			local receivedSpy = spy.new()
			addon.Require "Services.Comms":Subscribe(addon.PREFIXES.MAIN, "reset_rolls", receivedSpy)

			WoWAPI_FireUpdate(GetTime())
			VotingFrame:DoRandomRolls(1)
			WoWAPI_FireUpdate()

			-- Everyone should have a roll in session 1:
			for ses, data in ipairs(VotingFrame:GetLootTable()) do
				for name, v in pairs(data.candidates) do
					if ses == 1 then
						if name ~= addon.player.name then -- We might have timedout our roll
							assert.are_not.equal("", v.roll)
							assert.is.Number(v.roll)
						end
					else
						assert.Nil(v.roll)
					end
				end
			end

			VotingFrame:ReannounceOrRequestRoll(true, 1, true, false, false)
			WoWAPI_FireUpdate()

			assert.spy(receivedSpy).was.called(1)
			-- Now rolls should be reset:
			for ses, data in ipairs(VotingFrame:GetLootTable()) do
				for _, v in pairs(data.candidates) do
					assert.Nil(v.roll)
				end
			end
		end)
	end)
end)
