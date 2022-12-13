dofile("__tests/wow_api.lua")

dofile("Libs/LibStub/LibStub.lua")
dofile("Libs/AceSerializer-3.0/AceSerializer-3.0.lua")
dofile("Libs/LibDeflate/LibDeflate.lua")

local AceSer = LibStub("AceSerializer-3.0")
local ld = LibStub("LibDeflate")


local function Encode(command, data)
    command = command or "test"
    local serialized = AceSer:Serialize(command, { data })
    local compressed = ld:CompressDeflate(serialized, { level = 3 })
    local encoded = ld:EncodeForWoWAddonChannel(compressed)

    return encoded;
end

local function Serialize(command, data)
    command = command or "test"
    return AceSer:Serialize(command, { data })
end

local function Deserialize(input)
    local test, command, data = AceSer:Deserialize(input)
    assert(test, "Error deserializing")
    return unpack(data)
end

local function GetItemStringFromLink(link)
    return strmatch(strmatch(link or "", "item:[%d:-]+") or "", "(item:.-):*$")
end

local function StripRedundantItemString(item)
    if not item or item == "" then return end
    item = gsub(GetItemStringFromLink(item), "item:", "")
    local pattern = "(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):%d*:%d*:%d*"
    local replacement = "%1:%2:%3:%4:%5:%6:%7:::" -- Compare link with uniqueId, linkLevel and SpecID removed
    return item:gsub(pattern, replacement)
end

local function OptimizeItemLinks(data)
    local ret = CopyTable(data)
    for session, d in ipairs(ret) do
        d.link = StripRedundantItemString(d.link)
        for name, candData in pairs(d.candidates) do
            candData.gear1 = StripRedundantItemString(candData.gear1)

            candData.gear2 = StripRedundantItemString(candData.gear2)
        end
    end
    return ret
end

local function LookUp(data)
    local ret = CopyTable(data)
    ret.lookup = {}
    local function processLookup(link)
        if not link or link == "" then return link end
        local i = tIndexOf(ret.lookup, link)
        if not i then
            return tinsert(ret.lookup, link)
        end
        return i
    end

    for session, d in ipairs(ret) do
        d.link = processLookup(d.link)
        for name, candData in pairs(d.candidates) do
            candData.gear1 = processLookup(candData.gear1)
            candData.gear2 = processLookup(candData.gear2)
        end
    end
    return ret
end

local function RemoveUnneededCanidateData(data)
    local ret = CopyTable(data)
    local function processField(field)
        if not field or field == "" then return nil end
        return field
    end

    for session, d in ipairs(ret) do
        for name, candData in pairs(d.candidates) do
            candData.haveVoted = nil
            candData.class = nil
            candData.role = nil
            candData.diff = nil
            candData.votes = nil
            candData.specID = nil
            candData.isRelic = nil
            candData.rank = nil
            candData.gear1 = processField(candData.gear1)
            candData.gear2 = processField(candData.gear2)
        end
    end
    return ret
end

local function RestructureData(data)
    local convertResponse = function(response)
        -- return response
        if response == "AUTOPASS" then
            return true
        elseif response == "PASS" then
            return false
        else
            return response
        end
    end
    local ret = {}
    for session, d in ipairs(data) do
        for name, candData in pairs(d.candidates) do
            if not ret[name] then
                ret[name] = {
                    ilvl = candData.ilvl,
                    gear1 = {
                    },
                    gear2 = {
                    },
                    voters = {
                    },
                    response = {
                    }
                }
            end
            ret[name].gear1[session] = candData.gear1
            ret[name].gear2[session] = candData.gear2
            ret[name].voters[session] = #candData.voters > 0 and candData.voters or nil
            ret[name].response[session] = convertResponse(candData.response)

        end
    end
    if data.lookup then ret.lookup = data.lookup end
    return ret
end

local function ReplaceKeyWords(data)
    local key = "|"
    -- Yes this is more efficient than an array
    local replacements = {
        [key .. "1"] = "ilvl",
        [key .. "2"] = "gear1",
        [key .. "3"] = "gear2",
        [key .. "4"] = "voters",
        [key .. "5"] = "haveVoted",
        [key .. "6"] = "response",
    }
    local replacements_inv = tInvert(replacements)
    local ret = {}
    for name, d in pairs(data) do
        if name == "lookup" then
            ret[replacements_inv[name]] = d
        else
            ret[name] = {}
            for k, v in pairs(d) do
                ret[name][replacements_inv[k]] = v
            end
        end
    end
    -- Remove empty tables
    for _, d in pairs(ret) do
        for k, v in pairs(d) do
            if type(v) == "table" and #v == 0 then
                d[k] = nil
            end
        end
    end
    return ret
end

local function ReplacePlayerNames(data)
    local ret = {}
    local function GenerateRandomID()
        local str = ""
        for i = 1, 8 do
            local r = math.random(0, 15)
            if r < 10 then
                str = str .. string.char(r + 48)
            else
                str = str .. string.char(r + 65 - 10)
            end
        end
        return str
    end

    -- TODO Only remove realm part on people from our realm
    for name, d in pairs(data) do
        ret[GenerateRandomID()] = d
    end
    return ret
end

local function ReplaceSemiColons(data)
    local empty = {}
    for name, d in pairs(data) do
        for i, item in ipairs(d["|3"] or empty) do
            d["|3"][i] = item:gsub(":::::::::::", "ø")
        end
    end
    return data
end

local function RunTests(name, data)
    print("Test: " .. name)
    print "Size of reconnect"
    print("Current:\t\t", #Encode("reconnect", data) / 1000 .. " kb")

    local unneededCandidateData = RemoveUnneededCanidateData(data)
    print("Remove Unneeded data:\t", #Encode("reconnect", unneededCandidateData) / 1000 .. " kb")

    local optimizedItemLinksData = OptimizeItemLinks(unneededCandidateData)
    print("Optimize itemLinks:\t", #Encode("reconnect", optimizedItemLinksData) / 1000 .. " kb")


    -- Lookup is apparently worse.
    -- 2.603 kb vs 2.637 kb
    -- 4.072 kb vs 4.261 kb
    -- local lookupData = LookUp(optimizedItemLinksData)
    -- print("Lookup:\t\t\t", #Encode("reconnect", lookupData) / 1000 .. " kb")


    -- local restructured1 = RestructureData(lookupData)
    -- print("Restructured1:\t\t", #Encode("reconnect", restructured1) / 1000 .. " kb")

    local restructured2 = RestructureData(optimizedItemLinksData)
    print("Restructured:\t\t", #Encode("reconnect", restructured2) / 1000 .. " kb")

    -- local replaced1 = ReplaceKeyWords(restructured1)
    -- print("Replaced1:\t\t", #Encode("reconnect", replaced1) / 1000 .. " kb")

    local replaced2 = ReplaceKeyWords(restructured2)
    local encoded = Encode("reconnect", replaced2)
    print("Replaced:\t\t", #encoded / 1000 .. " kb")

    -- print(Serialize("reconnect", replaced2))

    -- local nameReplaced1 = ReplacePlayerNames(replaced1)
    -- print("NameReplaced1:\t\t", #Encode("reconnect", nameReplaced1) / 1000 .. " kb")

    local nameReplaced2 = ReplacePlayerNames(replaced2)
    print("NameReplaced:\t\t", #Encode("reconnect", nameReplaced2) / 1000 .. " kb")

    local colonsRemoved = ReplaceSemiColons(nameReplaced2)
    print("ColonsRemoved:\t\t", #Encode("reconnect", colonsRemoved) / 1000 .. " kb")

    print "---------------------------------------------------------------------\n"
    -- printtable(colonsRemoved)
    -- print (Serialize("reconnect", colonsRemoved))
end

local data1 = dofile "__tests/Reconnect/data1.lua"
RunTests("Data 1", data1)

local data2 = dofile "__tests/Reconnect/data2.lua"
RunTests("Data 2", data2)

local data3 = Deserialize(dofile "__tests/Reconnect/data3.lua")
RunTests("Data 3", data3)



-------------------------------------------------------------
-- Results
-------------------------------------------------------------
--[[
Test: Data 1
Size of reconnect
Current:			    9.651 kb
Remove Unneeded data:	7.839 kb
Optimize itemLinks:		4.072 kb
Restructured:			3.191 kb
Replaced:			    2.374 kb
NameReplaced:			2.162 kb
ColonsRemoved:			2.164 kb
---------------------------------------------------------------------

Test: Data 2
Size of reconnect
Current:			    5.127 kb
Remove Unneeded data:	3.936 kb
Optimize itemLinks:		2.603 kb
Restructured:			1.816 kb
Replaced:			    1.728 kb
NameReplaced:			1.619 kb
ColonsRemoved:			1.581 kb
---------------------------------------------------------------------

Test: Data 3
Size of reconnect
Current:			    27.049 kb
Remove Unneeded data:	18.979 kb
Optimize itemLinks:		17.56 kb
Restructured:			12.023 kb
Replaced:			    10.782 kb
NameReplaced:			10.721 kb
ColonsRemoved:			10.721 kb
---------------------------------------------------------------------

]]
