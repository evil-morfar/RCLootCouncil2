local addon = {
    realmName = "Realm1",
    db = {global = {log = {}, cache = {}}},
    defaults = {global = {logMaxEntries = 2000}}
}
loadfile(".specs/AddonLoader.lua")(nil, nil, addon).LoadArray {
    [[Libs\LibStub\LibStub.lua]],
    [[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
    [[Libs\AceComm-3.0\AceComm-3.0.xml]],
    [[Libs\AceSerializer-3.0\AceSerializer-3.0.xml]],
    [[Libs\LibDeflate\LibDeflate.lua]]
}
local ld = LibStub("LibDeflate")
local AS = LibStub("AceSerializer-3.0")

local magicKey = "|"

local replacements = {
    [magicKey .. "1"] = "selfVote",
    [magicKey .. "2"] = "multiVote",
    [magicKey .. "3"] = "anonymousVoting",
    [magicKey .. "4"] = "allowNotes",
    [magicKey .. "5"] = "numButtons",
    [magicKey .. "6"] = "hideVotes",
    [magicKey .. "7"] = "observe",
    [magicKey .. "8"] = "buttons",

    [magicKey .. "9"] = "rejectTrade",
    [magicKey .. "10"] = "requireNotes",

    [magicKey .. "11"] = "responses",
    [magicKey .. "12"] = "timeout",
    [magicKey .. "13"] = "outOfRaid",

    [magicKey .. "14"] = "default",
    [magicKey .. "15"] = "text",
    [magicKey .. "16"] = "color"

}

local replacements_inv = tInvert(replacements)

_G.printtable = function( data, level )
	if not data then return end
	level = level or 0
	local ident=strrep('     ', level)
	if level>6 then return end
	if type(data)~='table' then print(tostring(data)) end;
	for index,value in pairs(data) do repeat
		if type(value)~='table' then
			print( ident .. '['..tostring(index)..'] = ' .. tostring(value) .. ' (' .. type(value) .. ')' );
			break;
		end
		print( ident .. '['..tostring(index)..'] = {')
        _G.printtable(value, level+1)
        print( ident .. '}' );
	until true end
end

function ReplaceMLDB(mldb)
    local ret = {}
    for k, v in pairs(mldb) do
        if (type(v) == "table") then 
         v = ReplaceMLDB(v) end
        if replacements_inv[k] then
            ret[replacements_inv[k]] = v
        else
            ret[k] = v
        end
    end
    return ret
end

local mldb_normal =
    "^1^SMLdb^T^N1^T^SallowNotes^B^Stimeout^N90^SselfVote^B^Sresponses^T^Sdefault^T^N1^T^Scolor^T^N1^N1^N2^N0.1^N3^N0^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SBest~`in~`Slot^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.54^N3^N0.09^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SStat~`upgrade^Ssort^N2^t^N3^T^Scolor^T^N1^N0.99^N2^N0.9^N3^N0.27^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SIlvl~`upgrade^Ssort^N3^t^N4^T^Scolor^T^N1^N0.16^N2^N0.98^N3^N0.17^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N0^N2^N0.52^N3^N0.98^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^STransmogrification^Ssort^N5^t^t^SAZERITE^T^N1^T^Scolor^T^N1^N1^N2^N0^N3^N0.07^N4^N1^t^Stext^SBest~`in~`Slot^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.51^N3^N0^N4^N1^t^Stext^SMajor~`trait~`upgrade^Ssort^N2^t^N3^T^Scolor^T^N1^N0.92^N2^N1^N3^N0^N4^N1^t^Stext^SMinor~`trait~`upgrade^Ssort^N3^t^N4^T^Scolor^T^N1^N0^N2^N1^N3^N0.02^N4^N1^t^Stext^SIlvl~`upgrade^Ssort^N4^t^N5^T^Scolor^T^N1^N0.09^N2^N0.25^N3^N1^N4^N1^t^Stext^SOffspec^Ssort^N5^t^N6^T^Scolor^T^N1^N0.85^N2^N0.12^N3^N1^N4^N1^t^Stext^STransmogrification^Ssort^N6^t^t^t^ShideVotes^B^SmultiVote^B^Sbuttons^T^Sdefault^T^N1^T^Stext^SBiS^t^N2^T^Stext^SStat~`upgrade^t^N3^T^Stext^SIlvl~`upgrade^t^N4^T^Stext^SOffspec^t^N5^T^Stext^STransmog^t^SnumButtons^N5^t^SAZERITE^T^N1^T^Stext^SBiS^t^N2^T^Stext^SMajor~`trait~`upgrade^t^N3^T^Stext^SMinor~`trait~`upgrade^t^N4^T^Stext^SIlvl~`upgrade~`(no~`trait)^t^N5^T^Stext^SOffspec^t^N6^T^Stext^STransmog^t^t^t^SnumButtons^N5^t^t^^"

local _, _, mldb = AS:Deserialize(mldb_normal)
local mldb_ser = AS:Serialize(mldb)

print("Normal lenght:", #mldb_ser)

local encoded_normal = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(mldb_ser))
print("Encoded lenght:", #encoded_normal)
local mldb_replaced = AS:Serialize(ReplaceMLDB(mldb[1]))
print(mldb_replaced)

print("Replaced lenght:", #mldb_replaced)
local encoded_replaced = ld:EncodeForWoWAddonChannel(
                             ld:CompressDeflate(mldb_replaced))
print("Encoded lenght:", #encoded_replaced)

local decomp = ld:DecompressDeflate(
                   ld:DecodeForWoWAddonChannel(encoded_replaced))
local mldb_received = decomp
for k, v in pairs(replacements) do mldb_received = string.gsub(mldb_received, k, v) end

local _, mldbR = AS:Deserialize(mldb_received)
-- printtable(mldb)
printtable(mldbR)
print(mldbR == mldb)
local mldb_replaced2 = AS:Serialize(ReplaceMLDB(mldbR))
print(mldb_replaced == mldb_replaced2)
print("1:", decomp)
print("2:", mldb_replaced2)
