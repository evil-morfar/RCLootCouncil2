---@type RCLootCouncil
local addon = select(2, ...)
---@class RCLootHistory
local LootHistory = addon:GetModule("RCLootHistory")
--- @type RCLootCouncilLocale
local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")
---@class RCLootHistory.SessionData
local SessionData = {}
LootHistory.SessionData = SessionData

local ROW_HEIGHT = 20;
local FRAME_AUTO_HIDE_TIME = 2

function SessionData:GetSessionResponsesFrame()
	if self.frame then return self.frame end
	local f = CreateFrame("Frame", "RCLootHistorySessionResponsesFrame", LootHistory.frame, "TooltipBackdropTemplate")
	f:SetFrameStrata("TOOLTIP")
	f:SetToplevel(true)
	addon.UI:RegisterForCombatMinimize(f)
	f:SetScript("OnLeave", function()
		C_Timer.After(FRAME_AUTO_HIDE_TIME, function()
			if not f:IsMouseOver() then
				f:Hide()
			end
		end)
	end)
	local st = LibStub("ScrollingTable"):CreateST({
		{ name = "",                 width = ROW_HEIGHT, }, -- Class icon
		{ name = "",                 width = ROW_HEIGHT, }, -- Winner indicator
		{ name = _G.NAME,            width = 100,        sort = 1, },
		{ name = L["Reason"],        width = 190, },
		{ name = _G.ITEM_LEVEL_ABBR, width = 55, },
		{ name = L["Votes"],         width = 45, },
		{ name = _G.ROLL,            width = 40, },
		{ name = L["Notes"],         width = 40, },
	}, 10, ROW_HEIGHT, nil, f)
	st.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -25)
	f:SetWidth(st.frame:GetWidth() + 20)
	f:SetHeight(st.frame:GetHeight() + 35)
	f.st = st
	self.frame = f
	return f
end

local shownEntry = nil
--- Toggles the display of the session responses for a specific history entry.
---@param name string Name of the history entry's owner.
---@param entry table The history entry containing sessionResponses.
---@param triggerFrame Frame to anchor the frame to.
function SessionData:SessionDetailButtonOnClick(name, entry, triggerFrame)
	if self.frame and self.frame:IsShown() then
		if shownEntry == entry then -- Only hide if called with the same entry
			shownEntry = nil
			self.frame:Hide()
			return
		end
	end
	shownEntry = entry
	self:Show(name, entry, triggerFrame)
end

function SessionData:Hide()
	if self.frame and self.frame:IsShown() then
		self.frame:Hide()
	end
end

--- Displays everyone's response to a specific history entry, as collected on award.
---@param winner string Name of the history entry's owner.
---@param entry table The history entry containing sessionResponses.
---@---@param triggerFrame Frame to anchor the frame to.
function SessionData:Show(winner, entry, triggerFrame)
	local f = self:GetSessionResponsesFrame()
	f:SetPoint("TOPRIGHT", triggerFrame, "BOTTOMLEFT", 0, 0)
	local rows = {}
	for name, v in pairs(entry.sessionResponses) do
		local isWinner = addon:UnitIsUnit(name, winner)
		local class, response, color, responseID, note, votes
		if isWinner then
			-- The winner's data lives on the history entry itself
			class, response, color, responseID, note, votes =
				entry.class, entry.response, entry.color, entry.responseID, entry.note, entry.votes
		else
			local r = addon:GetResponse(entry.typeCode or "default", v.response)
			class, response, color, responseID, note, votes = v.class, r.text, r.color, v.response, v.note, v.votes
		end
		tinsert(rows, {
			cols = {
				{ DoCellUpdate = addon.SetCellClassIcon,      args = { class, },                                                                                                              value = class or "", },
				{ DoCellUpdate = self.SetCellWinnerIndicator, args = { isWinner = isWinner, },                                                                                                value = isWinner and 1 or 0, },
				{ value = addon.Ambiguate(name),              color = addon:GetClassColor(class), },
				{ DoCellUpdate = LootHistory.SetCellResponse, args = { color = color, response = response, responseID = responseID or 0, isAwardReason = isWinner and entry.isAwardReason, }, },
				{ value = v.ilvl or "", },
				{ value = votes or 0, },
				{ value = v.roll or "", },
				{ DoCellUpdate = self.SetCellNote,            args = { note = note, },                                                                                                        value = note and 1 or 0, },
			},
		})
	end
	-- Winner on top, then by votes
	table.sort(rows, function(a, b)
		if a.cols[2].value ~= b.cols[2].value then return a.cols[2].value > b.cols[2].value end
		return (a.cols[8].value or 0) > (b.cols[8].value or 0)
	end)
	f.st:SetData(rows)
	f:Show()
end

function SessionData.SetCellWinnerIndicator(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	if not frame.winnerTex then
		frame.winnerTex = frame:CreateTexture(nil, "OVERLAY")
		frame.winnerTex:SetPoint("CENTER", frame, "CENTER")
		frame.winnerTex:SetSize(ROW_HEIGHT - 6, ROW_HEIGHT - 6)
		frame.winnerTex:SetTexture("Interface/RaidFrame/ReadyCheck-Ready")
	end
	frame.winnerTex:SetShown(data[realrow].cols[column].args.isWinner or false)
end

-- Same as History.SetCellNote, except the note is delivered in args instead of being fetched from the lootDB.
function SessionData.SetCellNote(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local note = data[realrow].cols[column].args.note
	local f = frame.noteBtn or CreateFrame("Button", nil, frame)
	f:SetSize(ROW_HEIGHT, ROW_HEIGHT)
	f:SetPoint("CENTER", frame, "CENTER")
	if note then
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Up.png")
		f:SetScript("OnEnter", function() addon:CreateTooltip(_G.LABEL_NOTE, note) end)
		f:SetScript("OnLeave", function() addon:HideTooltip() end)
	else
		f:SetScript("OnEnter", nil)
		f:SetNormalTexture("Interface/BUTTONS/UI-GuildButton-PublicNote-Disabled.png")
	end
	frame.noteBtn = f
end
