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
      if v.version == "always"
      or (addon:VersionCompare(addon.db.global.version, v.version) or not addon.db.global.version)
      and not v.executed then
         addon:Debug("<Compat>", "Executing:", k, v.name or "no_name")
         local check, err = pcall(v.func, addon, addon.version, addon.db.global.version, addon.db.global.oldVersion)
         v.executed = true
         if not check then
            addon:Debug("<Compat>", "<ERROR>", err)
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
--    func:    The function to execute if the version predicate is met. Called with the following parameters:
--             (addon, addon.version, addon.db.global.version, addon.db.global.oldVersion)
Compat.list = {
   {
      name = "verTestCandidates upgrade",
      version = "2.10.0",
      func = function(self)
         self.db.global.verTestCandidates = {} -- Reset due to new structure
      end,
   },
   {
      name = "History fixes v1",
      version = "2.12.1",
      func = function(self, version)
         self:ScheduleTimer(function()
            -- Log fixes:
            self.db.global[version] = {}
            -- Fix for texts in whisperKeys:
            local c = 0
            for _, b in pairs(self.db.profile.buttons) do
               for i, btn in pairs(b) do
                  if i ~= "numButtons" and btn.whisperKey and btn.whisperKey.text then
                     btn.whisperKey = nil
                     c = c + 1
                  end
               end
            end
            self.db.global[version].buttons = c
            self:Debug("Fixed", c, "buttons")

            -- Fix for response object in response color:
            c = 0
            for _, r in pairs(self.db.profile.responses.default)do
               if r.color and r.color.color then
                  r.color.color = nil;
                  r.color.text = nil;
                  c = c + 1;
               end;
            end;
            self.db.global[version].responses = c
            self:Debug("Fixed", c, "responses")

            c = 0
            for _, factionrealm in pairs(self.lootDB.sv.factionrealm) do
               for _, items in pairs(factionrealm) do
                  for _, item in pairs(items) do
                     if item.color and item.color.color then
                        item.color.color = nil
                        item.color.text = nil
                        c = c + 1
                     end
                  end
               end
            end
            self.db.global[version].entries = c
            self:Debug("Fixed", c, "loot history entries")

            -- Fix missing indicies in lootDB color arrays:
            c = 0
            local colors = {}
            local needFix = false
            -- fetch all colors first, and check if we need fixes
            for _, factionrealm in pairs(self.lootDB.sv.factionrealm) do
               for _, items in pairs(factionrealm) do
                  for _, item in pairs(items) do
                     colors[item.response] = item.color
                     if not needFix then -- Make it permanent
                        needFix = item.color and #item.color == 0
                     end
                  end
               end
            end
            if needFix then
               local found
               for _, factionrealm in pairs(self.lootDB.sv.factionrealm) do
                  for _, items in pairs(factionrealm) do
                     for _, item in pairs(items) do
                        found = item.color and #item.color == 0
                        if found then
                           item.color = colors[item.response]
                           c = c + 1
                        end
                     end
                  end
               end
            end
            self.db.global[version].colors = c
            self:Debug("Color indicies needs fix?", needFix, "Fixed", c, "entries")
         end, 10) -- Wait like 10 seconds after login
      end,
   },
   {
      name = "Breath of Bronsamdi in history from v2.11.0-alpha",
      version = "2.12.2", -- Run for 2 patches
      func = function (addon)
         addon:ScheduleTimer(function()
            local count = 0
            local link
            for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
               for _, items in pairs(factionrealm) do
                  if items and #items > 0 then
                     for i = #items, 1, - 1 do
                        --165703 == Breath of Bwonsamdi
                        if (GetItemInfoInstant(items[i].lootWon)) == 165703 then
                           link = items[i].lootWon
                           table.remove(items, i)
                           count = count + 1
                        end
                     end
                  end
               end
            end
            return count > 0 and addon:Debug("Removed", count, link)
         end, 10)
      end
   },
   {
      name = "Add iClass and iSubClass to loot history",
      version = "2.15.0",
      func = function (addon)
         addon:ScheduleTimer( -- Wait 20 secs
            function ()
               local count = 0
               for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
                  for _, items in pairs(factionrealm) do
                     for _, data in ipairs(items) do
                        local _, _, _, _, _, itemClassID, itemSubClassID = GetItemInfoInstant(data.lootWon)
                        data.iClass = itemClassID
                        data.iSubClass = itemSubClassID
                        count = count + 1
                     end
                  end
               end
               addon:DebugLog("Added classID and subClassID to", count, "items")
            end,
         20)
      end
   },

   {
      name = "Fix for wrong responseID for awardReasons",
      version = "2.16.0",
      func = function (addon, version)
         addon:ScheduleTimer(
            function ()
               -- Build lookup table of the awardReasons text
               local lookup = {}
               for k, v in ipairs(addon.db.profile.awardReasons) do
                  lookup[v.text] = k
               end
               -- Search for bad awardReasons
               local count = 0
               for _, factionrealm in pairs(addon.lootDB.sv.factionrealm) do
                  for _, items in pairs(factionrealm) do
                     for _, data in ipairs(items) do
                        if lookup[data.response] then
                           if type(data.responseID ~= "number") then
                              data.responseID = lookup[data.response]
                              count = count + 1
                           end
                        end
                     end
                  end
               end
               if count > 0 then
                  addon:DebugLog("Fixed", count, "broken award reasons")
                  addon.db.global[version] = count
               end
            end,
         2)
      end
   }
}
