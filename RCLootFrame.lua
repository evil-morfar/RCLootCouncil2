-- Author      : Potdisc
-- Create Date : 3/23/2012 4:37:15 PM
-- LootFrame.lua
-- Gets info from MainFrame.lua and displays looting options for the player

local MAX_VISIBLE_FRAMES = 5;
local db, buttonsDB;
local itemsLooting = {}
local lootFrames = {}
local buttonsWidth = 0
local _;

function RCLootCouncil_LootFrame:CreateFrame(id)
	RCLootCouncil:debugS("LootFrame:CreateFrame("..tostring(id)..")")
	local frame = CreateFrame("Frame", "$parentEntry"..id, RCLootFrame, "RCLootFrameEntry")
	frame:SetPoint("TOPLEFT", RCLootFrame)
	frame:SetID(id)

	-- Note button
	StaticPopupDialogs["LOOTFRAME_NOTE"] = {
		text = "Enter your note:",
		button1 = "Done",
		button2 = "Cancel",
		OnAccept = function(self)
			self.frame.note = self.editBox:GetText()
		end,
		enterClicksFirstButton = true,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, 	
	}

	local noteButton = CreateFrame("Button", nil, frame)
	noteButton:SetWidth(25)
    noteButton:SetHeight(25)
    noteButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    noteButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)

    local noteButtonIcon = noteButton:CreateTexture(nil, "BACKGROUND")
    noteButtonIcon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
    noteButtonIcon:SetPoint("CENTER", noteButton, "CENTER", 0, 1)
    noteButtonIcon:SetHeight(14)
    noteButtonIcon:SetWidth(12)

    local noteButtonOverlay = noteButton:CreateTexture(nil, "OVERLAY")
    noteButtonOverlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    noteButtonOverlay:SetWidth(42)
    noteButtonOverlay:SetHeight(42)
    noteButtonOverlay:SetPoint("TOPLEFT")

    noteButton:RegisterForClicks("AnyUp")

    noteButton:SetScript("OnClick", function()
        local dialog = StaticPopup_Show("LOOTFRAME_NOTE");
		if dialog then
			dialog.frame = frame
		end
    end)

    noteButton:SetScript("OnMouseDown", function(self)
        noteButtonIcon:SetTexCoord(.1,.9,.1,.9)
    end)
    noteButton:SetScript("OnMouseUp", function(self)
        noteButtonIcon:SetTexCoord(0,1,0,1)
    end)

    noteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "BOTTOMRIGHT")
        GameTooltip:AddLine("Add note")
        GameTooltip:AddLine("Click this to add a note to send to the master looter.",.8,.8,.8,1, true)
        GameTooltip:Show()
    end)
    noteButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    noteButton:EnableMouse(true)

	frame.noteButton = noteButton;
	frame.note = nil
	frame.buttons = {}

	return frame;
end

function RCLootCouncil_LootFrame:Update(lootTable, newRollRequest)
	-- only edit the lootTable when we recieve it from the ML
	-- and actually create a new table, not just reference
	if lootTable then
		wipe(itemsLooting)
		for k, v in ipairs(lootTable) do
			itemsLooting[k] = { item = v, position = k}
		end
	end 
	if newRollRequest then
		local test = true
		for _,v in pairs(itemsLooting) do
			if v.item == newRollRequest.item then test = false; end
		end
		if test then tinsert(itemsLooting, newRollRequest); end
	end
	local numFrames = 0
	db = RCLootCouncil:GetVariable("mlDB")
	buttonsDB = db.buttons
	
	for i,_ in ipairs(itemsLooting) do
		if not itemsLooting[i] then break; end 		
		numFrames = numFrames + 1

		if numFrames > MAX_VISIBLE_FRAMES then break end -- only show the max number of frames

		local name, link, _, ilvl, _, _, _, _, _, texture = GetItemInfo(itemsLooting[i].item)

		local frame = lootFrames[i]
		if not frame then
			frame = RCLootCouncil_LootFrame:CreateFrame(i)
			lootFrames[i] = frame
		end
		frame.item = itemsLooting[i].item
		frame.id = itemsLooting[i].position
		if not db.allowNotes then
			frame.noteButton:Hide()
		else
			frame.noteButton:Show()
		end

		-- Create/show the buttons
		for j = 1, db.numButtons do
			local button = frame.buttons[j]
			if not button then -- create it
				button = CreateFrame("button", "$parentButton"..j, frame, "RCLootFrame_Button")
				button:SetID(j)				
				if j == 1 then -- first needs specific anchor
					button:SetPoint("BOTTOMLEFT", 65, 10)				
				else
					button:SetPoint("TOPLEFT", "$parentButton"..(j-1), "TOPRIGHT", 5, 0)				
				end	
				button:Show()
				frame.buttons[j] = button				
			end
			-- Always update the text in case of changes
			local length = #(buttonsDB[j]["text"]) * 10 - 20; -- calculate length
			if length < 66 then length = 66 end -- minimun is 66px
			button:SetText(buttonsDB[j]["text"])
			button:SetWidth(length)

			-- Frame and mouseover width
			local count = 18
			if strlen(name) > count then
				count = strlen(name)
			end
			local lootFrameWidth = 155
			local hoverWidth = count * 10 - 40

			-- Get the width of each button
			for k, but in pairs(frame.buttons) do
				if k > db.numButtons then break; end -- don't get it too wide
				lootFrameWidth = lootFrameWidth + but:GetWidth()
			end

			-- make sure the width doesn't get less than the length of the item
			if lootFrameWidth - 50 < hoverWidth then lootFrameWidth = hoverWidth + 50; end 
			RCLootFrame:SetWidth(lootFrameWidth)

			frame:SetWidth(lootFrameWidth)
			getglobal("RCLootFrameEntry"..i.."Hover2"):SetWidth(hoverWidth)
			getglobal("RCLootFrameEntry"..i.."ItemLabel"):SetText(link);
			getglobal("RCLootFrameEntry"..i.."ItemLabel"):SetFont("Fonts\\FRIZQT__.TTF", 16);
			getglobal("RCLootFrameEntry"..i.."Texture"):SetTexture(texture);
			getglobal("RCLootFrameEntry"..i.."Ilvl"):SetText("ilvl: "..ilvl);
			getglobal("RCLootFrameEntry"..i.."Ilvl"):SetPoint("TOPRIGHT", "$parent", "TOPRIGHT", -2, -5)
			RCLootFrame:SetHeight(i * 75)
			RCLootFrame:SetWidth(lootFrameWidth)
			frame:Show();
			lootFrames[i] = frame
		end
		for j = db.numButtons+1, #frame.buttons do -- throw away not used buttons
			if frame.buttons[j] then
				frame.buttons[j]:Hide()
				frame.buttons[j]:SetParent(nil)
			end
		end
		-- Anchor the frames correctly
		if i > 1 then
			lootFrames[i]:SetPoint("TOPLEFT", lootFrames[i-1], "BOTTOMLEFT")
		end
	end  
	
	-- Hide unused frames
	for i = MAX_VISIBLE_FRAMES, numFrames+1, -1 do
		if lootFrames[i] then
			lootFrames[i]:Hide()
			-- and clear the note since we need a blank next time
			lootFrames[i].note = nil;
		end
	end		
	if #itemsLooting == 0 then -- they're all hidden, so hide the frame
		RCLootCouncil:debugS("LootFrame hidden")
		RCLootCouncil_LootFrame.hide()
		return;
	end
	RCLootFrame:Show()
end

---------- ShowTooltip -------------
-- Shows the loot item's tooltip
------------------------------------
function RCLootCouncil_LootFrame.ShowTooltip(frame)
	GameTooltip:SetOwner(RCLootFrame, "ANCHOR_CURSOR")
	GameTooltip:SetHyperlink(frame.item)
	GameTooltip:Show()
end

------------- toolMouseLeave ------------------------
-- Removes the tooltip when mouse leaves the area
-----------------------------------------------------
function RCLootCouncil_LootFrame.toolMouseLeave()
	GameTooltip:Hide()
end

---------- onClick ------------------
-- Sends user response to MasterLooter
-------------------------------------
function RCLootCouncil_LootFrame:onClick(response, frame, button)
	RCLootCouncil:debugS("LootFrame:onClick("..tostring(response)..", frame, button)")
	RCLootCouncil.handleResponse(response, frame);	
	tremove(itemsLooting, frame:GetID())
	RCLootCouncil_LootFrame:Update()
end

----------- hide -------------------
-- Hides the loot frame 
------------------------------------
function RCLootCouncil_LootFrame.hide()
	if RCLootFrame:IsShown() then
		wipe(itemsLooting)
		RCLootFrame:Hide()
	end
end
