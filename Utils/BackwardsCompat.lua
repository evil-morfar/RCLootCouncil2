--- BackwardsCompat.lua Entry point for running functions based on addon version.
-- Creates 'RCLootCouncil.Compat' as a namespace for compatibility functions.
-- @author Potdisc
-- Create Date : 31/5-2019 05:21:28
--- @class RCLootCouncil
local addon = select(2, ...)
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
				db.itemStorage = {}         -- Just in case
				db.council = {}             -- Needs reset
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
		end,
	}, {
	name = "Token button fix",
	version = "3.0.1",
	func = function()
		for _, db in pairs(addon.db.profiles) do
			if db.enabledButtons then db.enabledButtons.TOKEN = nil end
			if db.buttons then db.buttons.TOKEN = nil end
			if db.responses then db.responses.TOKEN = nil end
		end
	end,
},
	{
		name = "Cached players realm fix",
		version = "3.0.1",
		func = function()
			for _, data in pairs(addon.db.global.cache.player) do
				if data.realm then -- Should always be there
					data.name = string.gsub(data.name, "%-.+", "-" .. data.realm, 1)
				end
			end
		end,
	},

	{
		name = "Changes to auto awards",
		version = "3.1.0",
		func = function()
			for _, db in pairs(addon.db.profiles) do
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
			local s, e
			for _, data in pairs(addon.db.global.cache.player) do
				s, e = string.find(data.name, ".-%-.-%-")
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
		end,
	},

	{
		name = "Clear Errors",
		version = "3.1.1",
		func = function()
			addon.db.global.errors = {}
		end,
	},
	{
		name = "Group Loot",
		version = "3.6.0",
		func = function()
			for _, db in pairs(addon.db.profiles) do
				for i in pairs(db.usage) do
					-- Just remove everything, which will reset it to the new defaults
					db.usage[i] = nil
				end
			end
		end,
	},

	{
		name = "Removed 'Require Notes' option", -- now handled per response
		version = "3.8.0",
		func = function()
			addon.db.profile.requireNotes = nil
		end,
	},
	{
		name = "Remove green items from history (Aberrus)",
		version = "3.8.1",
		func = function()
			local count = 0
			for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
				for _, data in pairs(factionrealm) do
					for i = #data, 1, -1 do
						if data[i].mapID == 2569 and data[i].responseID == "PL" then -- Azerite
							tremove(data, i)
							count = count + 1
						end
					end
				end
			end
			if count > 0 then
				addon.Log:D(format("Cleaned %d occurances of Uncommon items in your history", count))
				addon:ScheduleTimer("Print", 10, format("Cleaned %d occurances of Uncommon items in your history", count))
			end
		end,
	},

	{
		name = "Reset auto add rolls",
		version = "3.12.0",
		func = function()
			for _, db in pairs(addon.db.profiles) do
				db.autoAddRolls = false
			end
			addon.db.global.errors = {}
		end,
	},

	{
		-- Response generator removed long ago, but option was still present
		name = "Reset CONTEXT_TOKEN buttons/response options",
		version = "3.13.0",
		func = function ()
			for _, db in pairs(addon.db.profiles) do
				if db.buttons then
					db.buttons.CONTEXT_TOKEN = nil
				end
				if db.enabledButtons then
					db.enabledButtons.CONTEXT_TOKEN = nil
				end
				if db.responses then
					db.responses.CONTEXT_TOKEN = nil
				end
			end
		end
	},
	{
		name = "Reset UI",
		version = "3.13.0",
		func = function ()
			addon:ResetUI()
		end
	},

	{
		name = "Update 'tierToken' in history",
		version = "3.13.2",
		func = function ()
			local Item = addon.Require "Utils.Item"
			for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
				for _, data in pairs(factionrealm) do
					for _, v in ipairs(data) do
						v.tierToken = RCTokenTable[Item:GetItemIDFromLink(v.lootWon)] and true
					end
				end
			end
		end
	},
	{
		name = "Removed Azerite button group",
		version = "3.14.0",
		func = function ()
			for _, db in pairs(addon.db.profiles) do
				if db.buttons then
					db.buttons.AZERITE = nil
				end
				if db.enabledButtons then
					db.enabledButtons.AZERITE = nil
				end
				if db.responses then
					db.responses.AZERITE = nil
				end
			end
		end
	},
	{
		name = "Update history times to ISO",
		version = "3.15.4", -- Originially v3.15.0
		func = function ()
			for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
				for _, data in pairs(factionrealm) do
					for _, v in ipairs(data) do
						-- We can't really guesstimate the time difference from who ML'd the item and realm time, so just update the date 
						local d,m,y = strsplit("/", v.date, 3)
						-- Ensure we're not trying to convert something that's already in ISO format
						if #tostring(d) < 4 then
							v.date = string.format("%04d/%02d/%02d", "20"..y, m, d)
						end
					end
				end
			end
		end,
	},
	{
		name = "Remove S3 raid transmog currencies",
		version = "3.17.2",
		func = function ()
			local count = 0
			for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
				for _, data in pairs(factionrealm) do
					for i = #data, 1, -1 do
						if string.find(data[i].lootWon, "245510") or
						string.find(data[i].lootWon, "246727") then
							tremove(data, i)
						end
					end
				end
			end
			if count > 0 then
				addon.Log:D(format("Cleaned %d occurrences of S3 raid transmog currencies in your history", count))
			end
		end
	},
	{
		name = "Clear cache",
		version = "3.17.6",
		func = function ()
			addon.db.global.cache = {}
			addon.db.global.playerCache = {}
		end
	}
}
