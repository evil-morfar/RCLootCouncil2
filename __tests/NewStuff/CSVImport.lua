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
      return "csv"
   elseif import:sub(1, 2) == "^1" then
      return "playerexport"
   else
      return
   end
end

function His:ImportCSV (import)
   wipe(private.errorList)
   local data = {strsplit("\n", import)}
   -- Validate the input
   if not private:ValidateHeader(data[1]) then
      return private.errors.malformed_header()
   end
   local line, lines = {}, {}
   for i = 2, #data do
      line = self:ExtractLine(data[i], ",")
      if #line ~= 21 then  print("Error:", i, #line, data[i]) end
      private:ValidateLine(i, line)
      tinsert(lines, line)
   end

   if self:DoErrorCheck() then return end

   -- Time to rebuild
   -- Clear errors and make it ready to be used again
   wipe(private.errorList)
   local rebuilt = {}
   for i = 1, 2 do
      rebuilt[i] = {
         winner = "",
         lootWon = "",
         date = "",
         time = "",
         instance = "",
         boss = "",
         votes = 0,
         itemReplaced1 = "",
         itemReplaced2 = "",
         response = "",
         responseID = "",
         color = {},       -- no import, can be extracted from response
         class = "",
         isAwardReason = false,
         difficultyID = 0, -- needs extraction
         mapID = 0,        -- no import
         groupSize = 0,    -- no import
         note = "",
         id = "",
         owner = "Unknown",
         typeCode = "", -- Probably not
         iClass = 0,
         iSubClass = 0
      }
      -- Each function has the responsibility to set each field themselves.
      private:RebuildPlayerName(lines[i], rebuilt[i])
      private:RebuildTime(lines[i], rebuilt[i])
      private:RebuildLootWon(lines[i], rebuilt[i])
      -- we don't care too much about response
      t.response = data[8]
      t.votes = data[9] -- nor votes
      t.class = data[10] -- Class is validated and can be used as is
      private:RebuildInstance(lines[i], rebuilt[i])
      t.boss = data[12] -- Don't care
      private:RebuildReplacedGear(lines[i], rebuilt[i])
      private:RebuildResponseID(lines[i], rebuilt[i])
      t.isAwardReason = data[16]
      t.note = data[20]
      private:RebuildOwner(lines[i], rebuilt[i])

   end
   if self:DoErrorCheck() then return end
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

function private:RebuildPlayerName (data, t)
   t.winner = addon:UnitName(data[1] or "")
   t.owner = addon:UnitName(data[20] or "") or t.owner
   if not t.winner or t.winner == "" then
      self:AddError(0, t.winner, "Could not restore playername for ".. data[1])
   end
end

function private:RebuildTime (data, t)
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
      return self:AddError(0, string.format("%s|%s|%s", dato, time, id), "Could not recreate time.")
   end
end

function private:RebuildLootWon(data ,t)
   local itemName, itemID, itemString = data[5],data[6],data[7]
   local useForInfo = ""
   -- Pick the first we get, in most informative order:
   if itemString then
      useForInfo = itemString
   elseif itemName then
      useForInfo = itemName
   elseif itemID then
      useForInfo = itemID
   else
      return self:AddError(0, string.format("%s|%s|%s", itemName, itemID, itemString), "Could not extract the winning item from this info.")
   end

   local iname, ilink, _, _, _, _, _, _,_, _, _, itemClassID, itemSubClassID = GetItemInfo(useForInfo)
   if not iname then
      return self:AddError(0, useForInfo, "GetItemInfo() returned nil. Check inputs.")
   end
   t.lootWon = ilink
   t.iClass = itemClassID
   t.iSubClass = itemSubClassID
end

private.errors = {
   malformed_header = function ()
      addon:Print("Malformed header")
   end,
}

function private:AddError (lineNum, value, desc)
   tinsert(private.errorList, {lineNum, value, desc})
end

function private:ValidateHeader (header)
   return header == "player, date, time, id, item, itemID, itemString, response, votes, class, instance, boss, gear1, gear2, responseID, isAwardReason, rollType, subType, equipLoc, note, owner"
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
      return #input == 0 or input:match("%d+") or input:match("%d+%-%d+") or private:AddError(num, input,"Malformed time (nothing or 'hh:mm:ss')")
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
      return not input or (input and (input == "true" or input == "false")) or private:AddError(num,input, "Malformed isAwardReason - ('true' or 'false' or nothing)")
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
