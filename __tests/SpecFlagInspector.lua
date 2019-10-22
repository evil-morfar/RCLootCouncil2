dofile("./wow_api.lua")
require "bit"

local SpecFlag = {} -- This class


local flagsToDecode = {
   "CC08EC8C8C8C",
   "082004030010"
}

function Main ()
   for i, flag in ipairs(flagsToDecode) do
      SpecFlag:DecodeFlag(flag)
   end
end


local seperator = ("-"):rep(40)
local function printheader (flag)
   print("Decoding: ", flag)
   print(string.format("ID\t%-13s Bin \t Hex", "Class"))
   print(seperator)
end

function SpecFlag:DecodeFlag (flag)
   printheader(flag)
   for i=GetNumClasses(), 1, -1 do
      local name = GetClassInfo(i)
      local hex = tonumber(flag:sub(-i, -i), 16)
      local bin = self:Int2Bin(hex)
      if bin ~= "0000" then
         print(string.format("[%d]\t%s %s \t 0x%x", i,string.format("%-13s",name), bin, hex))
      end
   end
   print(seperator)
end

function SpecFlag:Int2Bin (n)
   local result = ""
   while n ~= 0 do
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
