-- Author      : nnp_home
-- Create Date : 8/14/2012 9:16:20 AM
-- RCVersionFrame.lua - Displays version checks

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
RCLootCouncil_VersionFrame = addon:NewModule("RCLootCouncil_VersionFrame", "AceTimer-3.0")

local contentTable = {} -- versionFrame content {classTexture, name, rank, version}
local version = addon:GetVersion()
local newestVersion = version
local currSortIndex, sortMethod;

function RCLootCouncil_VersionFrame:OnEnable()
	local entry = CreateFrame("Button", "$parentEntry1", RCVersionFrameContentFrame, "RCVersionFrameEntry"); -- Creates the first row
	entry:SetID(1); -- Set the ID
	entry:SetPoint("TOPLEFT", 4, -4) -- Set anchor
	for i = 2, 10 do -- Create the rest of the rows
		local entry = CreateFrame("Button", "$parentEntry"..i, RCVersionFrameContentFrame, "RCVersionFrameEntry");
		entry:SetID(i);
		entry:SetPoint("TOP", "$parentEntry"..(i-1), "BOTTOM") -- Set the anchor to the row above
	end
	RCLootCouncil_VersionFrame:AddSelf()
	RCLootCouncil_VersionFrame:Update()
	RCVersionFrame:Show()
end

function RCLootCouncil_VersionFrame:OnDisable()
	wipe(contentTable)
	RCVersionFrame:Hide()
end

function RCLootCouncil_VersionFrame:CloseButtonClick()
	RCLootCouncil:DisableModule("RCLootCouncil_VersionFrame")
end

function RCLootCouncil_VersionFrame:SendVerTest(media)
	wipe(contentTable)
	RCLootCouncil_VersionFrame:AddSelf()
	if IsInRaid() and media == "PARTY" then
		RCLootCouncil:SendCommMessage("RCLootCouncil", "verTest "..version, "RAID")
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, class = GetRaidRosterInfo(i)
			local _, rank = RCLootCouncil_Mainframe.getGuildRankNum(name)
			if name ~= GetUnitName("player",true) then tinsert(contentTable, {class, name, rank, ""}); end
		end
	else
		RCLootCouncil:SendCommMessage("RCLootCouncil", "verTest "..version, media)
	end
	self:ScheduleTimer("Timeout", 5)
	RCLootCouncil_VersionFrame:Update()
end

function RCLootCouncil_VersionFrame:AddSelf()
	local _, class = UnitClass("player")
	contentTable[1] = {class, GetUnitName("player",true), RCLootCouncil:GetGuildRank(), version}
end

function RCLootCouncil_VersionFrame:AddPlayer(data) --class, name, rank, version
	if RCLootCouncil_VersionFrame:IsEnabled() then -- don't do anything if the module isn't enabled
		local test = true;
		for k, v in pairs(contentTable) do
			if v[2] == data[2] then
				contentTable[k] = data
				test = false;
				break;
			end
		end
		if test then tinsert(contentTable, data); end
		RCLootCouncil_VersionFrame:Update()
	end
end

function RCLootCouncil_VersionFrame:Timeout()
	for k,v in pairs(contentTable) do
		if v[4] == "" then
			contentTable[k][4] = "Not installed";
		end
	end
	RCLootCouncil_VersionFrame:Update()
end

function RCLootCouncil_VersionFrame:Update()
	FauxScrollFrame_Update(RCVersionFrameContentFrame, #contentTable, 10, 20, nil, nil, nil, nil, nil, nil, true);
	local offset = FauxScrollFrame_GetOffset(RCVersionFrameContentFrame)
	for i = 1, 10 do 
		local line = offset + i;
		if contentTable[line] then -- if there's something at a given entry
			local entry = contentTable[line]
			RCLootCouncil_Mainframe.setCharName(getglobal("RCVersionFrameContentFrameEntry"..i.."Name"), entry[1], entry[2])
			RCLootCouncil_Mainframe.setClassIcon(getglobal("RCVersionFrameContentFrameEntry"..i.."ClassTexture"), entry[1]);
			getglobal("RCVersionFrameContentFrameEntry"..i.."Rank"):SetText(entry[3])
			getglobal("RCVersionFrameContentFrameEntry"..i.."Version"):SetText("v"..entry[4])
			
			if entry[4] == "Not installed" then
				getglobal("RCVersionFrameContentFrameEntry"..i.."Version"):SetTextColor(0.75,0.75,0.75,1) -- grey
				getglobal("RCVersionFrameContentFrameEntry"..i.."Version"):SetText(entry[4])

			elseif entry[3] == "Unknown" then
				getglobal("RCVersionFrameContentFrameEntry"..i.."Version"):SetTextColor(0.75,0.75,0.75,1) -- grey
				getglobal("RCVersionFrameContentFrameEntry"..i.."Version"):SetText("Old - "..entry[4])

			elseif newestVersion <= entry[4] then
				newestVersion = entry[4]
				getglobal("RCVersionFrameContentFrameEntry"..i.."Version"):SetTextColor(0,1,0,1) -- green
			else
				getglobal("RCVersionFrameContentFrameEntry"..i.."Version"):SetTextColor(1,0,0,1) -- red
			end
			getglobal("RCVersionFrameContentFrameEntry"..i):Show()
		else
			getglobal("RCVersionFrameContentFrameEntry"..i):Hide()
		end
	end
end

function RCLootCouncil_VersionFrame:Sort(id)
--class, name, rank, version
		if currSortIndex == id then -- if we're already sorting this one
		if sortMethod == "asc" then -- then switch the order
			sortMethod = "desc"
		else
			sortMethod = "asc"
		end
	elseif id then -- if we got a valid id
		currSortIndex = id -- then initialize our sort index
		sortMethod = "asc" -- and the order we're sorting in
	end
	if (id == 0) then -- Name sorting (alphabetically)
		table.sort(contentTable, function(v1, v2)
			if sortMethod == "desc" then
				return v1 and v1[2] > v2[2]
			else
				return v1 and v1[2] < v2[2]
			end
		end)
		
	elseif (id == 1) then -- Guild Rank sorting (numerically)
		table.sort(contentTable, function(v1, v2)
			if sortMethod == "desc" then
				return (v1 and RCLootCouncil_Mainframe.getGuildRankNum(v1[2]) > RCLootCouncil_Mainframe.getGuildRankNum(v2[2]))
			else
				return (v1 and RCLootCouncil_Mainframe.getGuildRankNum(v1[2]) < RCLootCouncil_Mainframe.getGuildRankNum(v2[2]))
			end
		end)
	elseif (id == 2) then -- version sorting
		table.sort(contentTable, function(v1, v2)
			if sortMethod == "desc" then
				return v1[4] > v2[4]
			else 
				return v1[4] < v2[4]
			end
		end)
	end
	RCLootCouncil_VersionFrame:Update()
end

