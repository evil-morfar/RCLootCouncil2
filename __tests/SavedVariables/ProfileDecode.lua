dofile ".specs/AddonLoader.lua".LoadArray {
	[[Libs\LibStub\LibStub.lua]],
	[[Libs\AceSerializer-3.0\AceSerializer-3.0.xml]],
	[[Libs\LibDeflate\LibDeflate.lua]],
}

local encoded = [[
9c5Yonmmqu0VOQA3MqYwskbXIgHWfXUr46mP1Oepb)qaB4Bh7asveXA2znN7m(OlWHdGWRhrk4HwEjdehdEpzCjqh2ldd(4Z25Gw81G2ITKhDqvCr8DpiQ0I17LVq2pF(XPtwzhcXBTz(YZb2RnlGBVaV1Iy3AQV3nHQel7c7GvACJ0P4yHjmw9JzXi(0i3z6nrCR7uKjPJIcgLE4BDf3pi)aTR45LfRy1f3u3W2L063GM86D51njLwa4xLXy80NT4uLBYA2KbT5l3yBDEfRizMm4PR76EGggMlkl6MIMJ)zR(p2IZ1MuPWj)tN1XSwhCmod(6p
]]

local ld = LibStub "LibDeflate"
local decoded = ld:DecodeForPrint(encoded)
local decompressed = ld:DecompressDeflate(decoded)
local _, profile = LibStub"AceSerializer-3.0":Deserialize(decompressed)
printtable(profile)
