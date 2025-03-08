--- Loads all Ace3 files with "AddonLoader.lua" and returns the result
return dofile(".specs/AddonLoader.lua").LoadArray {
	[[Libs\LibStub\LibStub.lua]],
	[[Libs\AceAddon-3.0\AceAddon-3.0.xml]],
	[[Libs\AceConsole-3.0\AceConsole-3.0.xml]],
	[[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
	[[Libs\AceComm-3.0\AceComm-3.0.xml]],
	[[Libs\AceLocale-3.0\AceLocale-3.0.xml]],
	[[Libs\AceSerializer-3.0\AceSerializer-3.0.xml]],
	[[Libs\AceEvent-3.0\AceEvent-3.0.xml]],
	[[Libs\AceHook-3.0\AceHook-3.0.xml]],
	[[Libs\AceTimer-3.0\AceTimer-3.0.xml]],
	[[Libs\AceBucket-3.0\AceBucket-3.0.xml]],
	[[Libs\AceDB-3.0\AceDB-3.0.xml]],
	[[Libs\AceGUI-3.0\AceGUI-3.0.xml]],
}
