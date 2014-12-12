-- Author      : Potdisc
-- Create Date : 5/21/2012 11:06:02 AM
-- RCRankFrame.lua - Manages the rankframe

local rank;

function RCLootCouncil_RankFrame.show()
	RCRankFrame:Show()
end

function RCLootCouncil_RankFrame.DropDown_OnLoad()
	for ci = 1, GuildControlGetNumRanks() do 
		info = {};
		info.text = " "..ci.." - "..GuildControlGetRankName(ci);
		info.value = ci;
		info.func = function() RCLootCouncil_RankFrame.setMinRank(ci) end;
		UIDropDownMenu_AddButton(info);
	end
end

function RCLootCouncil_RankFrame.setMinRank(rankNum)
	rank = rankNum;
	UIDropDownMenu_SetText(RankDropDown,  " "..rankNum.." - "..GuildControlGetRankName(rankNum)) 
end

function RCLootCouncil_RankFrame.acceptOnClick()
	if rank > 0 then
		RCLootCouncil_Mainframe.setRank(rank)
		RCRankFrame:Hide()
	else
		print("RCLootCouncil: Couldn't find the rank")
	end
end

function RCLootCouncil_RankFrame.cancelOnClick()
	RCRankFrame:Hide()
end
