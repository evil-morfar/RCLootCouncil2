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
        if
            v.version == "always" or
                ((v.tVersion and
                    addon.Utils:CheckOutdatedVersion(
                        addon.db.global.version,
                        v.version,
                        addon.db.global.tVersion,
                        v.tVersion
                    ) == addon.VER_CHECK_CODES[3]) or
                    (addon.Utils:CheckOutdatedVersion(addon.db.global.version, v.version) == addon.VER_CHECK_CODES[2] or
                        not addon.db.global.version)) and
                    not v.executed
         then
            addon.Log("<Compat>", "Executing:", k, v.name or "no_name")
            local check, err = pcall(v.func, addon, addon.version, addon.db.global.version, addon.db.global.oldVersion)
            v.executed = true
            if not check then
                addon.Log:E("<Compat>", err)
            end
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
        tVersion = "Beta.2",
        func = function()
            local db = addon:Getdb()
            db.itemStorage = {} -- Just in case
            db.council = {} -- Needs reset
            -- All enabled by default, just removed for cleanup
            db.altClickLooting = nil
            db.autolootEverything = nil
            db.autoLootOthersBoE = nil
            db.saveBonusRolls = nil
            db.allowNotes = nil

            db.enabledButtons.CORRUPTED = nil
            db.buttons.CORRUPTED = nil
            db.responses.CORRUPTED = nil

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

            addon:ScheduleTimer("Print", 5, "Your Council has been reset as part of upgrading to v3.0")
        end
    },
    {
        name = "v3.0 Beta.3 Clear cache",
        version = "3.0.0",
        tVersion = "Beta.3",
        func = function()
            addon.db.global.cache.players = {}
        end
    },
    -- {
    --     name = "Clear player cache",
    --     version = "always",
    --     func = function()
    --         addon.db.global.cache.players = {}
    --     end
    -- }
}
