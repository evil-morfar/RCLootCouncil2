--- autopass.lua	Contains everything related to autopassing
-- @author	Potdisc
-- Create Date : 23/9/2016

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

--- Checks if the player should autopass on a given item.
-- All params are supplied by the lootTable from the ML.
-- Checks for a specific class if 'class' arg is provided, otherwise the player's class.
-- @usage
-- -- Check if the item in session 1 should be auto passed:
-- local dat = lootTable[1] -- Shortening
-- local boolean = RCLootCouncil:AutoPassCheck(dat.link, dat.equipLoc, dat.typeID, dat.subTypeID, dat.classesFlag, dat.isToken, dat.isRelic)
--@return true if the player should autopass the given item.
function RCLootCouncil:AutoPassCheck(link, equipLoc, typeID, subTypeID, classesFlag, isToken, isRelic, class)
	local class = class or self.playerClass
	local classID = self.classTagNameToID[class]
	return not DoesItemContainSpec(link, classID)
end
