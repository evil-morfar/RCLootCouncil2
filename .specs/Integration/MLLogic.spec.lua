require "busted.runner"()
-- Just load everything
local addon = dofile(".specs/AddonLoader.lua").LoadToc("RCLootCouncil.toc")
dofile ".specs/EmulatePlayerLogin.lua"
function _G.GetNumGroupMembers() return 3 end
function _G.GetRaidRosterInfo(raidIndex)
    local info = {
        {"Player1-Realm1", 2}, -- us leader
        {"Player2-Realm1", 1},
        {"Player3-Realm2", 1},
    }
    return unpack(info[raidIndex] or info[1])
end

-- function _G.IsLoggedIn() return true end
function _G.UnitIsGroupLeader() return true end
local function ResetMLStuff()
	addon.masterLooter = nil
	addon.isMasterLooter = nil
	addon.isCouncil = false
	addon.handleLoot = false
end

describe("#Integration #MLLogic", function ()

    it("call NewMLCheck", function()
        RCLootCouncil:NewMLCheck()
    end)

	it("should reenable ML stuff on reload", function()
		_G.IsInRaidVal = true
		addon.db.profile.usage = {
			ask_gl = false,
			gl = true,
			state = "gl"
		}
		WoWAPI_FireUpdate(1)
		WoWAPI_FireEvent("PLAYER_ENTERING_WORLD", false, false)
		WoWAPI_FireEvent("RAID_INSTANCE_WELCOME")
		_ADVANCE_TIME(4)
		assert.True(addon.handleLoot)
		assert.True(addon.isMasterLooter)
		assert.are.equal(addon.player, addon.masterLooter)
		assert.is_not.Nil(next(addon.mldb))
		addon:OnEvent("PLAYER_LOGOUT")
		ResetMLStuff()
		WoWAPI_FireUpdate(10)
		WoWAPI_FireEvent("PLAYER_ENTERING_WORLD", false, true)
		_ADVANCE_TIME(3)
		assert.True(addon.handleLoot)
		assert.True(addon.isMasterLooter)
		assert.are.equal(addon.player, addon.masterLooter)
		assert.is_not.Nil(next(addon.mldb))

		-- print ("ML:", addon.masterLooter, addon.player)
		-- printtable(addon.db.global.log)
	end)

	it("should fire ML usage on party leader changed", function()
		_G.IsInRaidVal = true
		addon.db.profile.usage = {
			ask_gl = false,
			gl = true,
			state = "gl"
		}

		-- Player2 is ML initially
		addon.masterLooter = addon.Require "Data.Player":Get("Player2")
		addon.handleLoot = true
		spy.on(addon, "OnStartHandleLoot")
		WoWAPI_FireEvent("PARTY_LEADER_CHANGED")
		_ADVANCE_TIME(1)
		assert.are.equal(addon.player, addon.masterLooter)
		assert.True(addon.isMasterLooter)
		assert.True(addon.handleLoot)
		assert.spy(addon.OnStartHandleLoot).was.called(1)
	end)
end)
