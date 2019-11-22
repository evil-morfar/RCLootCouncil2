local _, addon = ...
local His = addon:GetModule("RCLootHistory")
local private = {
   errorList = {
      -- [i] = {line, cause}
   },
   idCount = 0
}

function His:DetermineImportType (import)
   if type(import) ~= "string" then
      addon:Print("The import was malformed (not a string)")
      return
   end

   -- Check csv
   if import:sub(1, 6) == "player" then
      -- Check for Sheet Copy
      if import:sub(7,7) == "\t" then
         if import:find("\tboss\tgear1") then -- Standard tsv export - not supported
            return "tsv"
         end
         import = import:gsub("\t", ",")
         if import:find("boss,difficultyID,mapID,") then
            return "tsv-csv" -- Copied from Google Sheet
         end
         return "Unknown"
      end
      return "csv"
   elseif import:sub(1, 2) == "^1" then
      return "playerexport"
   else
      return
   end
end

function His:ImportCSV (import)
   return self:ImportNew(import, ",")
end

function His:ImportTSV_CSV (import)
   return self:ImportNew(import, "\t")
end

function His:ImportNew (import, delimiter)
   wipe(private.errorList)
   local data = {strsplit("\n", import)}
   -- Validate the input
   if not private:ValidateHeader(data[1], delimiter) then
      private.errors.malformed_header()
      print(data[1])
      return
   end
   local line, lines = {}, {}
   for i = 2, #data do
      line = self:ExtractLine(data[i], delimiter)
      if #line ~= 24 then  print("Error:", i, #line, data[i]) end
      private:ValidateLine(i, line)
      tinsert(lines, line)
   end

   if self:DoErrorCheck() then return end

   -- Time to rebuild
   -- Clear errors and make it ready to be used again
   wipe(private.errorList)
   local rebuilt = self:RebuildData(lines)
   if self:DoErrorCheck() then return end
   data = self:ConvertRebuiltDataToLootDBFormat(rebuilt)

   printtable(data)
end

function His:ConvertRebuiltDataToLootDBFormat (rebuilt)
   local data = {}
   for _,v in ipairs(rebuilt) do
      if not data[v.winner] then data[v.winner] = {} end
      local lenght = #data[v.winner] + 1
      data[v.winner][lenght] = v
      data[v.winner][lenght].winner = nil
   end
   return data
end

function His:RebuildData (lines)
   local rebuilt = {}
   for i = 1, #lines do
      rebuilt[i] = {
         winner = "",
         lootWon = "",
         date = "",
         time = "",
         instance = "",
         boss = "",
         votes = 0,
         itemReplaced1 = nil,
         itemReplaced2 = nil,
         response = "",
         responseID = "",
         color = {},
         class = "",
         isAwardReason = false,
         difficultyID = 0,
         mapID = 0,
         groupSize = 0,
         note = nil,
         id = "",
         owner = "Unknown",
         -- typeCode = "", -- Probably not
         iClass = 0,
         iSubClass = 0
      }
      -- Each function has the responsibility to set each field themselves.
      private:RebuildPlayerName(lines[i], rebuilt[i], i)
      private:RebuildTime(lines[i], rebuilt[i], i)
      private:RebuildLootWon(lines[i], rebuilt[i], i)
      -- we don't care too much about response
      rebuilt[i].response = lines[i][8]
      rebuilt[i].votes = lines[i][9] and tonumber(lines[i][9]) -- nor votes
      rebuilt[i].class = lines[i][10] -- Class is validated and can be used as is
      private:RebuildInstance(lines[i], rebuilt[i], i)
      rebuilt[i].boss = lines[i][12] -- Don't care
      private:RebuildReplacedGear(lines[i], rebuilt[i], i)
      private:RebuildResponseID(lines[i], rebuilt[i], i)
      rebuilt[i].isAwardReason = lines[i][19] and lines[i][19]:lower() == "true"
      rebuilt[i].groupSize = lines[i][15] and tonumber(lines[i][15])
      rebuilt[i].note = lines[i][23] ~= "" and lines[i][23] or nil
   end
   return rebuilt
end

function His:DoErrorCheck ()
   -- Check for errors
   if #private.errorList > 0 then
      -- Print errors, but limit it to the first 10
      local num = #private.errorList > 10 and 10 or #private.errorList
      for i = 1, num do
         local err = private.errorList[i]
         addon:Print(string.format("Import error in line: %d: %s - value: '%s'", err[1],err[3],err[2]))
      end
      return true
   end
   return false
end

function His:ExtractLine (input, delimiter)
   -- print("ExtractLine", input)
   local ret = {}
   -- Check for any escaped commas:
   if input:find("\"") then
      local first, last = input:find("\".-\"")
      -- print(first,last)
      if not first then print(input) end
      -- do the first and second half, and put this in the middle.
      ret = self:ExtractLine(strsub(input, 1, first - 2), delimiter)
      tinsert(ret, strsub(input, first + 1, last - 1))
      local t2 = self:ExtractLine(strsub(input, last + 2), delimiter)
      local len = #ret
      for k, v in ipairs(t2) do
         ret[len + k] = v
      end
   else
      ret = {strsplit(delimiter, input)}
   end
   return ret
end

function His:CommaEscapeTSV (data)
   return data:gsub("\t(([^,\t\"]*,[^,\t\"]+)+)\t", "\t\"%1\"\t")
end

function private:RebuildResponseID(data,t, line)
   local responseID = data[18]
   if responseID:match("%d") then responseID = tonumber(responseID) end
   -- Must be valid, i.e. check every single type of responses
   for type in pairs(addon.responses) do
      if addon.responses[type][responseID] then
         -- also override response
         t.response = addon.responses[type][responseID].text
         t.color = addon.responses[type][responseID].color
         t.responseID = responseID
         return
      end
   end
   -- Invalid
   self:AddError(line, responseID, "Not a valid response of your current settings.")
end

function private:RebuildReplacedGear(data, t,line)
   local gear1, gear2 = data[16], data[17]
   if gear1 and gear1 ~= "" then
      t.itemReplaced1 = select(2, self:GetItemInfo(gear1,nil,nil, line))
   end
   if gear2 and gear2 ~= "" then
      t.itemReplaced2 = select(2, self:GetItemInfo(gear2, nil,nil, line))
   end
end

function private:RebuildPlayerName (data, t, line)
   t.winner = addon:UnitName(data[1] or "")
   t.owner = data[24] and data[24] ~= "Unknown" and addon:UnitName(data[24] or "") or t.owner
   if not t.winner or t.winner == "" then
      self:AddError(line, t.winner, "Could not restore playername for ".. data[1])
   end
end

function private:RebuildTime (data, t, line)
   local dato, time, id = data[2], data[3], data[4]
   if not dato and not time and not id then
      -- Not provided, just use current time
      t.date = date("%d/%m/%y")
   	t.time = date("%H:%M:%S")
      t.id = GetServerTime() .."-"..private.idCount
      private.idCount = private.idCount + 1
   elseif id then
      -- Rebuild time from id
      -- Check if it's our id, or just a time string
      local secs = 0
      if id:find("-") then
         secs = strsplit("-", id)
         t.id = id
      else
         secs = id
         t.id = id .. "-"..private.idCount
         private.idCount = private.idCount + 1
      end
      t.date = date("%d/%m/%y", secs)
   	t.time = date("%H:%M:%S", secs)
   elseif dato then
      local d, m, y = strsplit("/", dato or "", 3)
      local secs = His:DateTimeToSeconds(d,m,y) -- Will provide 0:0:0
      t.date = date("%d/%m/%y", secs)
   	t.time = date("%H:%M:%S", secs)
      t.id = id .. "-"..private.idCount
      private.idCount = private.idCount + 1
   elseif time then
      local d, m, y = strsplit("/", date("%d/%m/%y"), 3) -- Use today
      local h, min, s = strsplit(":", time, 3) -- but keep the time
      local secs = His:DateTimeToSeconds(d,m,y)
      t.date = date("%d/%m/%y", secs)
   	t.time = date("%H:%M:%S", secs)
      t.id = id .. "-"..private.idCount
      private.idCount = private.idCount + 1
   else
      -- Should never happen
      return self:AddError(line, string.format("%s|%s|%s", dato, time, id), "Could not recreate time.")
   end
end

function private:GetItemInfo (name, id, itemString, line)
   local useForInfo = ""
   -- Pick the first we get, in most informative order:
   if itemString then
      useForInfo = itemString
   elseif name then
      if string.find(name, "%[") then -- We can't use brackets
         useForInfo = string.sub(name, 2, -2)
      else
         useForInfo = name
      end
   elseif id then
      useForInfo = id
   end
   if not useForInfo or useForInfo == "" then
      return self:AddError(line, string.format("%s|%s|%s", tostring(name), tostring(id), tostring(itemString)), "Could not extract the winning item from this info.")
   end

   local iname, ilink, _, _, _, _, _, _,_, _, _, itemClassID, itemSubClassID = GetItemInfo(useForInfo)
   if not iname then
      return self:AddError(line, useForInfo, "GetItemInfo() returned nil. Check inputs.")
   end
   return iname, ilink, itemClassID, itemSubClassID
end

function private:RebuildLootWon(data ,t, line)
   local itemName, itemID, itemString = data[5],data[6],data[7]
   local iname, ilink, itemClassID, itemSubClassID = self:GetItemInfo(itemName, itemID, itemString, line)
   if not iname then return self:AddError(line, string.format("%s|%s|%s", tostring(itemName), tostring(itemID), tostring(itemString)), "Error rebuilding lootWon") end
   t.lootWon = ilink
   t.iClass = itemClassID
   t.iSubClass = itemSubClassID
end

local mapIDsToText = {
   [469] = "Blackwing Lair",
   [409] = "Molten Core",
   [509] = "Ruins of Ahn'Qiraj",
   [531] = "Temple of Ahn'Qiraj",
   [564] = "Black Temple",
   [565] = "Gruul's Lair",
   [534] = "Hyjal Summit",
   [532] = "Karazhan",
   [544] = "Magtheridon's Lair",
   [548] = "Serpentshrine Cavern",
   [580] = "Sunwell Plateau",
   [550] = "Tempest Keep",
   [631] = "Icecrown Citadel",
   [533] = "Naxxramas",
   [249] = "Onyxia's Lair",
   [616] = "The Eye of Eternity",
   [615] = "The Obsidian Sanctum",
   [724] = "The Ruby Sanctum",
   [649] = "Trial of the Crusader",
   [603] = "Ulduar",
   [624] = "Vault of Archavon",
   [757] = "Baradin Hold",
   [669] = "Blackwing Descent",
   [967] = "Dragon Soul",
   [720] = "Firelands",
   [671] = "The Bastion of Twilight",
   [754] = "Throne of the Four Winds",
   [1009] = "Heart of Fear",
   [1008] = "Mogu'shan Vaults",
   [1136] = "Siege of Orgrimmar",
   [996] = "Terrace of Endless Spring",
   [1098] = "Throne of Thunder",
   [1228] = "Highmaul",
   [1205] = "Blackrock Foundry",
   [1448] = "Hellfire Citadel",
   [1520] = "The Emerald Nightmare",
   [1648] = "Trial of Valor",
   [1530] = "The Nighthold",
   [1676] = "Tomb of Sargeras",
   [1712] = "Antorus, the Burning Throne",
   [1861] = "Uldir",
   [2070] = "Battle of Dazar'alor",
   [2096] = "Crucible of Storms",
   [2164] = "The Eternal Palace",
}

local diffIDToText = {
   [1] = "Normal",
   [2] = "Heroic",
   [3] = "10 Player",
   [4] = "25 Player",
   [5] = "10 Player (Heroic)",
   [6] = "25 Player (Heroic)",
   [7] = "Looking For Raid",
   [8] = "Mythic Keystone",
   [9] = "40 Player",
   [11] = "Heroic Scenario",
   [12] = "Normal Scenario",
   [14] = "Normal",
   [15] = "Heroic",
   [16] = "Mythic",
   [17] = "Looking For Raid",
   [18] = "Event",
   [19] = "Event",
   [20] = "Event Scenario",
   [23] = "Mythic",
   [24] = "Timewalking",
   [25] = "World PvP Scenario",
   [29] = "PvEvP Scenario",
   [30] = "Event",
   [32] = "World PvP Scenario",
   [33] = "Timewalking",
   [34] = "PvP",
   [38] = "Normal",
   [39] = "Heroic",
   [40] = "Mythic",
   [45] = "PvP",
   [147] = "Normal",
   [149] = "Heroic",
}

function private:RebuildInstance(data, t, line)
   local instance, diffID, mapID = data[11], data[13], data[14]
   if mapID and diffID then
      mapID = tonumber(mapID)
      diffID = tonumber(diffID)
      if mapIDsToText[mapID] and diffIDToText[diffID] then
         t.instance = mapIDsToText[mapID] .."-".. diffIDToText[diffID]
         t.mapID = mapID
         t.difficultyID = diffID
      end
   elseif mapID and not diffID and not instance then
      mapID = tonumber(mapID)
      t.instance = mapIDsToText[mapID]
      t.mapID = mapID
      t.difficultyID = nil
   elseif instance then
      if string.find(instance, "-") then
         mapID = mapID or tInvert(mapIDsToText)[(string.split(instance, "-"))]
         diffID = diffID or tInvert(diffIDToText[select(2,string.split(instance, "-"))])
      else
         mapID = mapID or tInvert(mapIDsToText)[instance]
      end
      t.instance = instance
      t.mapID = mapID
      t.difficultyID = diffID
   else
      self:AddError(line, string.format("%s|%s|%s", tostring(instance), tostring(diffID), tostring(mapID)), "Could not recreate instance info.")
   end

end

private.errors = {
   malformed_header = function ()
      addon:Print("Malformed header")
   end,
}

function private:AddError (lineNum, value, desc)
   tinsert(private.errorList, {lineNum, value, desc})
   return nil
end

function private:ValidateHeader (header, delimiter)
   local target = {"player", "date", "time", "id", "item", "itemID", "itemString", "response", "votes", "class", "instance", "boss", "difficultyID", "mapID", "groupSize", "gear1", "gear2", "responseID", "isAwardReason", "rollType", "subType", "equipLoc", "note", "owner"}
   return header == table.concat(target,delimiter)
end

function private:ValidateLine (num, line)
   for i, data in ipairs(line) do
      private.validators[i](num, data)
   end
end


private.validators = {
   function (num, input) -- name
      return type(input) == "string" and input ~= "" and #input > 1 or private:AddError(num, input,"Malformed Name")
   end,

   function (num, input) -- date
      -- can be empty
      return #input == 0 or input:match("%d%d?/%d%d?/%d%d?") or private:AddError(num, input,"Malformed date (nothing or 'dd/mm/yy')")
   end,
   function (num, input) -- time
      -- can be empty
      return #input == 0 or input:match("%d%d?:%d%d?:%d%d?") or private:AddError(num, input,"Malformed time (nothing or 'hh:mm:ss')")
   end,
   function (num, input) -- id
      -- can be empty, a time string (seconds) or our id
      return #input == 0 or input:match("%d+") or input:match("%d+%-%d+") or private:AddError(num, input,"Malformed id (nothing, seconds or 'seconds-id'")
   end,

   function (num, input) -- item
      -- accept anything
      return true
   end,
   function (num, input) -- itemID
      -- not present or numbers only
      return not input or #input == 0 or input:match("%d+") or private:AddError(num,input, "Malformed ItemID (nothing or number)")
   end,
   function (num, input) -- itemString
      -- not present or valid itemString
      return not input or #input == 0 or input:match("item:[%d:]+") or private:AddError(num, input,"Malformed itemString")
   end,
   function (num, input) -- response
      -- not present or string
      return not input or #input > 0 or private:AddError(num, input,"Malformed response (nothing or string)")
   end,
   function (num, input) -- votes
      -- not present, 'nil', or number
      return not input or input == "nil" or input:match("%d+") or private:AddError(num, input,"Malformed votes (nothing or numbers)")
   end,
   function (num, input) -- class
      -- must be valid
      return input and tContains(CLASS_SORT_ORDER, input) or private:AddError(num, input,"Malformed class (must be valid, uppercase class)")
   end,
   function (num, input) -- instance
      -- optional
      return true
   end,
   function (num, input) -- boss
      -- optional
      return true
   end,
   function (num, input) -- difficultyID
      -- empty or number
      return not input or input:match("[%d]+") or private:AddError(num, input, "Malformed difficultyID (must be a number or empty)")
   end,
   function (num, input) -- mapID
      -- empty or number
      return not input or input:match("[%d]+") or private:AddError(num, input, "Malformed mapID (must be a number or empty)")
   end,
   function (num, input) -- groupSize
      -- empty or number
      return not input or input:match("[%d]+") or private:AddError(num, input, "Malformed groupSize (must be a number or empty)")
   end,
   function (num, input) -- gear1
      -- optional
      return true
   end,
   function (num, input) -- gear2
      -- optional
      return true
   end,
   function (num, input) -- responseID
      -- required string or number
      return input:match("[%w%d]+") or private:AddError(num, input,"Malformed responseID (string or numbers only)")
   end,
   function (num, input) -- isAwardReason
      -- optional, but TRUE/FALSE if not empty
      return not input or (input and (input:lower() == "true" or input:lower() == "false")) or private:AddError(num,input, "Malformed isAwardReason - ('true' or 'false' or nothing)")
   end,
   function (num, input) -- rollType
      -- optional
      return true
   end,
   function (num, input) -- subType
      -- optional
      return true
   end,
   function (num, input) -- equipLoc
      -- optional
      return true
   end,
   function (num, input) -- note
      -- optional
      return true
   end,
   function (num, input) -- owner
      -- either nothing or a string
      return not input or #input > 1 or private:AddError(num, input,"Malformed owner - (nothing or name)")
   end,

}
