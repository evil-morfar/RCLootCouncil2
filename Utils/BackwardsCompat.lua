--- BackwardsCompat.lua Entry point for running functions based on addon version.
-- Creates 'RCLootCouncil.Compat' as a namespace for compatibility functions.
-- @author Potdisc
-- Create Date : 31/5-2019 05:21:28
local _, addon = ...
local Compat = {}
addon.Compat = Compat

--- Runs all compability changes registered.
-- Initially called in `RCLootCouncil:OnEnable()`
-- Note: Nothing is run on first installs.
-- Each compat can only be run once per login, so feel free to call it again.
function Compat:Run()
	for k, v in ipairs(self.list) do
		if v.version == "always" or ((v.tVersion
						and addon.Utils:CheckOutdatedVersion(addon.db.global.version, v.version,
                                     						addon.db.global.tVersion, v.tVersion)
						== addon.VER_CHECK_CODES[3])
						or (addon.Utils:CheckOutdatedVersion(addon.db.global.version, v.version,
                                     						addon.db.global.tVersion, v.tVersion)
										== addon.VER_CHECK_CODES[2] or not addon.db.global.version))
						and not v.executed then
			addon.Log("<Compat>", "Executing:", k, v.name or "no_name")
			local check, err = pcall(v.func, addon, addon.version,
                         			addon.db.global.version, addon.db.global.oldVersion)
			v.executed = true
			if not check then addon.Log:E("<Compat>", err) end
		end
	end
end

-- List of backwards compatibility. Each entry is executed numerically, if allowed.
-- Fields:
--    name:    Optional - name that gets logged if the function is run.
--    version: If the user's last version is older than this, then the function is run.
--             `always` will always run the function.
--              Directly compared in `addon:VersionCompare(db.global.version, version_field)`
---   tVersion: Same as 'version' but for test version.
--    func:    The function to execute if the version predicate is met. Called with the following parameters:
--             (addon, addon.version, addon.db.global.version, addon.db.global.oldVersion)
Compat.list = {
	{
		name = "v3.0 Update",
		version = "3.0.0",
		func = function()
			for _, db in pairs(addon.db.profiles) do -- Needs to be cleared on all profiles
				db.itemStorage = {} -- Just in case
				db.council = {} -- Needs reset
				db.minRank = -1
				-- All enabled by default, just removed for cleanup
				db.altClickLooting = nil
				db.autolootEverything = nil
				db.autoLootOthersBoE = nil
				db.saveBonusRolls = nil
				db.allowNotes = nil

				if db.enabledButtons then db.enabledButtons.CORRUPTED = nil end
				if db.buttons then db.buttons.CORRUPTED = nil end
				if db.responses then db.responses.CORRUPTED = nil end
			end

			local global = addon.db.global
			global.errors = {} -- just reset
			global.localizedItemStatus = nil
			-- Cleanup old reports
			global["2.10.3"] = nil
			global["2.11.0"] = nil
			global["2.12.0"] = nil
			global["2.12.1"] = nil
			global["2.12.2"] = nil
			global["2.13.1"] = nil
			global["2.16.0"] = nil

			if addon.db.global.cache then
				addon.db.global.cache.player = {}
				addon.db.global.cache.players = nil -- Spelling mistake in one of the betas.
			end

			addon:ScheduleTimer("Print", 5,
                    			"Your Council has been reset as part of upgrading to v3.0")
		end
	}, {
		name = "Token button fix",
		version = "3.0.1",
		func = function()
			for _, db in pairs(addon.db.profiles) do
				if db.enabledButtons then db.enabledButtons.TOKEN = nil end
				if db.buttons then db.buttons.TOKEN = nil end
				if db.responses then db.responses.TOKEN = nil end
			end
		end
	}, 
	{
		name = "Cached players realm fix",
		version = "3.0.1",
		func = function()
			for _, data in pairs(addon.db.global.cache.player) do
				if data.realm then -- Should always be there
					data.name = string.gsub(data.name, "%-.+", "-"..data.realm, 1)
				end
			end
		end
	},

	{
		name = "Changes to auto awards",
		version = "3.1.0",
		func = function()
			for _,db in pairs(addon.db.profiles) do
				db.autoAwardTo = {}
				db.autoAwardBoETo = {}
			end
			addon:ScheduleTimer("Print", 5, "Auto Award options has been reset as part of upgrading to v3.1")
		end,
	},

	{
		name = "Corrupted cache fix",
		version = "3.1.0",
		func = function()
			local s,e
			for _, data in pairs(addon.db.global.cache.player) do
				s, e  = string.find(data.name, ".-%-.-%-")
				if s and e then
					data.name = string.sub(data.name, s, e - 1)
				end
			end
		end,
	},

	{
		name = "Clear anima from history",
		version = "3.1.0",
		func = function()
			local count = 0
			for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
				for _, data in pairs(factionrealm) do
					for i = #data, 1, -1 do
						if string.find(data[i].lootWon, "184286") then -- Extinguished Soul Anima
							tremove(data, i)
							count = count + 1
						end
					end
				end
			end
			if count > 0 then
				addon.Log:D(format("Cleaned %d occurances of anima in your history", count))
				addon:ScheduleTimer("Print", 10, format("Cleaned %d occurances of anima in your history", count))
			end
		end,
	},

	{
		name = "Missing class from player cache",
		version = "3.1.1",
		func = function()
			local count = 0
			for guid, data in pairs(addon.db.global.cache.player) do
				if not data.class then
					addon.db.global.cache.player[guid] = nil
					count = count + 1
				end
			end
			addon.Log:D(format("Fixed %d instances of missing cache class", count))
		end
	},

	{
		name = "Clear Errors",
		version = "3.1.1",
		func = function()
			addon.db.global.errors = {}
		end
	}
}
