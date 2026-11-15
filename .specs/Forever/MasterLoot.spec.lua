require "busted.runner"()

local addon = loadfile(".specs/AddonLoader.lua")(false, "RCLootCouncil", nil, 18).LoadToc("RCLootCouncil.toc")
dofile(".specs/EmulatePlayerLogin.lua")

describe("#Forever #MasterLoot", function()
	local MasterLoot = addon.Require "Services.MasterLoot"
	local Council = addon.Require "Data.Council"
	local ML = _G.RCLootCouncilML

	local originalGetLootMethod
	local originalEnabled
	local originalHandleLoot
	local originalIsMasterLooter
	local sessionFrame

	before_each(function()
		addon.db:ResetDB()
		originalGetLootMethod = addon.GetLootMethod
		originalEnabled = addon.enabled
		originalHandleLoot = addon.handleLoot
		originalIsMasterLooter = addon.isMasterLooter
		sessionFrame = addon:GetActiveModule("sessionframe")

		MasterLoot:Enable()
		MasterLoot:OnLootClosed() -- wipe processed slots
		ML:Enable()
		ML.running = false
		wipe(ML.lootTable)
		addon.lootSlotInfo = {}
	end)

	after_each(function()
		addon.GetLootMethod = originalGetLootMethod
		addon.enabled = originalEnabled
		addon.handleLoot = originalHandleLoot
		addon.isMasterLooter = originalIsMasterLooter
		MasterLoot:OnLootClosed()
	end)

	describe("lifecycle and event registration", function()
		it("calls OnLootReady when LOOT_READY fires", function()
			local sLootReady = spy.on(MasterLoot, "OnLootReady")
			WoWAPI_FireEvent("LOOT_READY")
			assert.spy(sLootReady).was.called()
			sLootReady:revert()
		end)

		it("calls OnLootClosed when LOOT_CLOSED fires", function()
			local sLootClosed = spy.on(MasterLoot, "OnLootClosed")
			WoWAPI_FireEvent("LOOT_CLOSED")
			assert.spy(sLootClosed).was.called()
			sLootClosed:revert()
		end)

		it("schedules ProcessLoot on LOOT_READY", function()
			local sSchedule = spy.on(MasterLoot, "ScheduleTimer")
			MasterLoot:OnLootReady()
			assert.spy(sSchedule).was.called_with(MasterLoot, "ProcessLoot", 0)
			sSchedule:revert()
		end)
	end)

	describe("ProcessLoot guard conditions", function()
		it("does nothing if addon is disabled", function()
			addon.enabled = false
			addon.handleLoot = true
			addon.isMasterLooter = true
			addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end

			local sUpdate = spy.on(ML, "UpdateLootSlots")
			MasterLoot:ProcessLoot()
			assert.spy(sUpdate).was_not.called()
			sUpdate:revert()
		end)

		it("does nothing if not handling loot", function()
			addon.enabled = true
			addon.handleLoot = false
			addon.isMasterLooter = true
			addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end

			local sUpdate = spy.on(ML, "UpdateLootSlots")
			MasterLoot:ProcessLoot()
			assert.spy(sUpdate).was_not.called()
			sUpdate:revert()
		end)

		it("does nothing if not master looter", function()
			addon.enabled = true
			addon.handleLoot = true
			addon.isMasterLooter = false
			addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end

			local sUpdate = spy.on(ML, "UpdateLootSlots")
			MasterLoot:ProcessLoot()
			assert.spy(sUpdate).was_not.called()
			sUpdate:revert()
		end)

		it("does nothing if loot method is not master looter", function()
			addon.enabled = true
			addon.handleLoot = true
			addon.isMasterLooter = true
			addon.GetLootMethod = function() return Enum.LootMethod.Group end

			local sUpdate = spy.on(ML, "UpdateLootSlots")
			MasterLoot:ProcessLoot()
			assert.spy(sUpdate).was_not.called()
			sUpdate:revert()
		end)

		it("does nothing if ML module is disabled", function()
			addon.enabled = true
			addon.handleLoot = true
			addon.isMasterLooter = true
			addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
			ML:Disable()

			local sUpdate = spy.on(ML, "UpdateLootSlots")
			MasterLoot:ProcessLoot()
			assert.spy(sUpdate).was_not.called()
			sUpdate:revert()
		end)
	end)

	describe("ProcessLoot when ML or session frame is running", function()
		before_each(function()
			addon.enabled = true
			addon.handleLoot = true
			addon.isMasterLooter = true
			addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
		end)

		it("calls UpdateLootSlots when ML.running is true", function()
			ML.running = true
			local sUpdate = spy.on(ML, "UpdateLootSlots")

			MasterLoot:ProcessLoot()

			assert.spy(sUpdate).was.called()
			sUpdate:revert()
		end)

		it("calls UpdateLootSlots when sessionframe:IsRunning() is true", function()
			ML.running = false
			local sIsRunning = stub(sessionFrame, "IsRunning").returns(true)
			local sUpdate = spy.on(ML, "UpdateLootSlots")

			MasterLoot:ProcessLoot()

			assert.spy(sUpdate).was.called()
			sIsRunning:revert()
			sUpdate:revert()
		end)
	end)

	describe("ProcessLoot slot evaluation and actions", function()
		before_each(function()
			addon.enabled = true
			addon.handleLoot = true
			addon.isMasterLooter = true
			addon.GetLootMethod = function() return Enum.LootMethod.Masterlooter end
			ML.running = false
			stub(sessionFrame, "IsRunning").returns(false)
			stub(ML, "AutoAward")
			stub(ML, "AddItem")
			stub(ML, "DoAwardLater")
			stub(ML, "StartSession")
			stub(ML, "ShowSessionFrame")
		end)

		after_each(function()
			sessionFrame.IsRunning:revert()
			ML.AutoAward:revert()
			ML.AddItem:revert()
			ML.DoAwardLater:revert()
			ML.StartSession:revert()
			ML.ShowSessionFrame:revert()
		end)

		it("auto awards item when ShouldAutoAward returns true", function()
			local itemLink = "item:158355"
			addon.bossName = "TestBoss"
			addon.lootSlotInfo = {
				[1] = {
					link = itemLink,
					quality = 4,
					quantity = 1,
					isLooted = false,
					boss = "TestBoss",
				}
			}

			local sShouldAutoAward = stub(ML, "ShouldAutoAward").returns(true, "mode", "WinnerPlayer")

			MasterLoot:ProcessLoot()

			assert.stub(ML.AutoAward).was.called_with(ML, 1, itemLink, 4, "WinnerPlayer", "mode", "TestBoss")
			sShouldAutoAward:revert()
		end)

		it("adds item via AddItem when CanWeLootItem is true and auto award is false", function()
			local itemLink = "item:158355"
			addon.lootSlotInfo = {
				[1] = {
					link = itemLink,
					quality = 4,
					quantity = 1,
					isLooted = false,
					boss = "TestBoss",
				}
			}

			local sShouldAutoAward = stub(ML, "ShouldAutoAward").returns(false)
			local sCanWeLoot = stub(ML, "CanWeLootItem").returns(true)

			MasterLoot:ProcessLoot()

			assert.stub(ML.AddItem).was.called_with(ML, itemLink, nil, 1, nil, nil, "TestBoss")
			sShouldAutoAward:revert()
			sCanWeLoot:revert()
		end)

		it("does not reprocess already processed slot until loot closed", function()
			local itemLink = "item:158355"
			addon.lootSlotInfo = {
				[1] = {
					link = itemLink,
					quality = 4,
					quantity = 1,
					isLooted = false,
					boss = "TestBoss",
				}
			}

			local sShouldAutoAward = stub(ML, "ShouldAutoAward").returns(false)
			local sCanWeLoot = stub(ML, "CanWeLootItem").returns(true)

			MasterLoot:ProcessLoot()
			assert.stub(ML.AddItem).was.called(1)

			-- Second process without closing loot window should not add it again
			MasterLoot:ProcessLoot()
			assert.stub(ML.AddItem).was.called(1)

			-- After closing loot window and opening again, it can be processed
			MasterLoot:OnLootClosed()
			MasterLoot:ProcessLoot()
			assert.stub(ML.AddItem).was.called(2)

			sShouldAutoAward:revert()
			sCanWeLoot:revert()
		end)

		it("starts session when autoStart is enabled and data is ready", function()
			table.insert(ML.lootTable, { link = "item:158355" })
			addon:Getdb().autoStart = true
			addon:Getdb().awardLater = false
			addon.candidatesInGroup[addon.player:GetName()] = true
			stub(Council, "GetNum").returns(3)

			MasterLoot:ProcessLoot()

			assert.stub(ML.StartSession).was.called()
			assert.stub(ML.ShowSessionFrame).was_not.called()

			Council.GetNum:revert()
		end)

		it("calls DoAwardLater when awardLater is true", function()
			table.insert(ML.lootTable, { link = "item:158355" })
			addon:Getdb().autoStart = true
			addon:Getdb().awardLater = true
			addon.candidatesInGroup[addon.player:GetName()] = true
			stub(Council, "GetNum").returns(3)

			MasterLoot:ProcessLoot()

			assert.stub(ML.DoAwardLater).was.called_with(ML, ML.lootTable)
			assert.stub(ML.StartSession).was_not.called()

			Council.GetNum:revert()
		end)

		it("shows session frame when autoStart is false", function()
			table.insert(ML.lootTable, { link = "item:158355" })
			addon:Getdb().autoStart = false

			MasterLoot:ProcessLoot()

			assert.stub(ML.ShowSessionFrame).was.called_with(ML, ML.lootTable)
			assert.stub(ML.StartSession).was_not.called()
		end)
	end)
end)
