dofile("__tests/wow_api.lua")
require "bit"

local SpecFlag = {} -- This class


local flagsToDecode = {
   -- "365002107467",
   -- "241000100044",
   -- "124002607703",
   -- "367002707767",
   -- "324001607743",
   -- "324002007700",
   -- "092775070310",
   -- "092075070010",
   -- "010773050000",
   -- "4294967295",

   "092776070010",
   -- tostring(0xffffffffff)
}

function Main ()
   for i, flag in ipairs(flagsToDecode) do
      SpecFlag:DecodeFlag(flag)
   end
end


local seperator = ("-"):rep(80)
local function printheader (flag)
   print("Decoding: ", flag)
   print(string.format("ID\t%-13s Bin \t Hex \t%-15s Specs", "Class", "Roles"))
   print(seperator)
end

function SpecFlag:DecodeFlag (flag)
   printheader(flag)
   for i=GetNumClasses(), 1, -1 do
      local name = GetClassInfo(i)
      local hex = tonumber(flag:sub(-i, -i), 16)
      local bin = self:Int2Bin(hex)
      if bin ~= "0000" then
         print(string.format("[%d]\t%s %s \t 0x%x \t%-15s %s", i,string.format("%-13s",name), bin, hex,
            table.concat(self:GetRolesForClassSpecs(i, bin), ","),
            table.concat(self:GetNamesForClassSpecs(i, bin), "/")))
      end
   end
   print(seperator)
end

-- @param binSpecs String representaion of the binary spec identifier, i.e. 0001
function SpecFlag:GetRolesForClassSpecs (classID, binSpecs)
   local result = {}
   for specNum=1,GetNumSpecializationsForClassID(classID) do
      if binSpecs:sub(-specNum, -specNum) == "1" then
         local role = self:GetSpecRole(classID, specNum):gsub("DAMAGER", "DPS")
         if not tContains(result, role) then tinsert(result, role) end
      end
   end
   return result
end

function SpecFlag:GetNamesForClassSpecs (classID, binSpecs)
   local result = {}
   for specNum=1,GetNumSpecializationsForClassID(classID) do
      if binSpecs:sub(-specNum, -specNum) == "1" then
         local name = self:GetSpecName(classID, specNum)
         if not tContains(result, name) then tinsert(result, name) end
      end
   end
   return result
end

function SpecFlag:GetSpecRole (classID, specNum)
   return select(5, GetSpecializationInfoForClassID(classID, specNum))
end

function SpecFlag:GetSpecName (classID, specNum)
   return select(2, GetSpecializationInfoForClassID(classID, specNum))
end

function SpecFlag:Int2Bin (n)
   local result = ""
   while n ~= 0 and n do
      if n % 2 == 0 then
         result = "0"..result
      else
         result = "1"..result
      end
      n = math.floor(n / 2)
   end
   return string.format("%04s", result)
end

function SpecFlag:SetClassSpecFlag (flag, classID, specIndex)
   flag = flag or ("0"):rep(GetNumClasses())
   local digit = tonumber(flag:sub(-classID,-classID), 16)
   digit = digit + 2^(specIndex-1)
   return flag:sub(1, GetNumClasses() - classID)..string.format("%X", digit)..flag:sub(GetNumClasses() - classID + 2, GetNumClasses())
end

Main()

-- Set WARRIOR (1) to spec 2
local flag = SpecFlag:SetClassSpecFlag(nil, 1, 2)
print(flag)
-- Add spec 3 as well
flag = SpecFlag:SetClassSpecFlag(flag, 1, 3)
print(flag)
-- and spec 1
flag = SpecFlag:SetClassSpecFlag(flag, 1, 1)
print(flag)
-- Now add priest spec 3
flag = SpecFlag:SetClassSpecFlag(flag, 5, 3)
print(flag)
