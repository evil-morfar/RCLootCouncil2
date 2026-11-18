---@diagnostic disable: duplicate-set-field, missing-fields
--- Only loaded when playing Forever
--- Adds a dropdown to select using Group Loot or a Master Loot candidate to the usage popup

---@class RCLootCouncil
local addon = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale("RCLootCouncil")

local LibDialog = LibStub "LibDialog-1.0"
local selected = "group_loot"

---@param data string
local function ButtonCallback(data, _, menu)
	selected = data
	addon.db.profile.lastUsagePopupSelection = data
	menu:OnUpdate()
end

---@param menu RootMenuDescriptionProxy|SharedMenuDescriptionProxy This is techincally root
local function DropdownGenerator(owner, menu)
	menu:CreateButton(L.GROUP_LOOT, ButtonCallback, "group_loot")
	menu:CreateTitle(_G.MASTER_LOOTER)
	local group = addon:UpdateCandidatesInGroup()

	local names = {}
	for name in pairs(group) do
		names[#names + 1] = name
	end
	table.sort(names)

	for _, name in ipairs(names) do
		menu:CreateButton(addon:GetClassIconAndColoredName(name), ButtonCallback, name)
	end
end

local dropdown
local function CreateOrGenerateMenu(parent)
	if dropdown then return dropdown:GenerateMenu() end
	dropdown = CreateFrame("DropdownButton", "RCLOOTCOUNCIL_USAGE_DROPDOWN_MENU", parent, "WowStyle1DropdownTemplate")
	dropdown:SetPoint("CENTER", 0, -15)
	dropdown:SetSelectionText(function()
		if selected == "group_loot" then return L.GROUP_LOOT end
		return addon:GetClassIconAndColoredName(selected)
	end)
	dropdown:SetWidth(200)
	dropdown:SetupMenu(DropdownGenerator)
end

LibDialog:Register("RCLOOTCOUNCIL_CONFIRM_USAGE", {
	text = L["confirm_usage_text"],
	on_show = function(self)
		self:SetFrameStrata("FULLSCREEN")
		selected = addon:Getdb().lastUsagePopupSelection or "group_loot"
		if UnitIsGroupLeader("player") then
			CreateOrGenerateMenu(self)
			self.delegate.height = 150
		else
			self.delegate.height = 120
		end
	end,
	buttons = {
		{
			text = _G.YES,
			on_click = function()
				addon.Log("Player confirmed usage")
				local lootMethod = Enum.LootMethod.Group
				if selected ~= "group_loot" then
					lootMethod = Enum.LootMethod.Masterlooter
				end
				if lootMethod ~= (addon:GetLootMethod()) then
					addon.Log:D("Setting lootmethod to", lootMethod, selected)
					C_PartyInfo.SetLootMethod(lootMethod, selected)
				end
				local db = addon:Getdb()
				if db.autoAward and GetLootThreshold() ~= 2 and GetLootThreshold() > db.autoAwardLowerThreshold then
					addon:Print(L["Changing loot threshold to enable Auto Awarding"])
					SetLootThreshold(db.autoAwardLowerThreshold >= 2 and db.autoAwardLowerThreshold or 2)
				end

				addon:StartHandleLoot()
			end,
		},
		{
			text = _G.NO,
			on_click = function()
				addon.Log("Player declined usage")
				addon:Print(L[" is not active in this raid."])
				-- Call it just in case
				addon:StopHandleLoot()
			end,
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
	width = 320,
	height = 150,
	static_size = true,
})
