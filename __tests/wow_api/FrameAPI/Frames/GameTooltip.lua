require "/wow_api/FrameAPI/Frames/Frame"

local function noop() end

local objectMethods = {
	SetOwner = function(self, frame, anchor, ...)
		self.owner = frame
		self.anchor = anchor
	end,
	GetOwner = function(self) return self.owner, self.anchor end,
	NumLines = function(self) return #self.lines end,
	AddLine = function(self, text, ...)
		local index = #self.lines + 1
		local lineName = self:GetName() .. "TextLeft" .. index

		if _G[lineName] then
			_G[lineName]:SetText(text)
			tinsert(self.lines, _G[lineName])
		else
			local frame = self:CreateFontString(lineName, "OVERLAY", "GameFontNormal")
			frame:SetText(text)
			_G[lineName] = frame
			tinsert(self.lines, frame)
		end
	end,
	AddDoubleLine = function(self, textL, textR, ...) self:AddLine(self.lines, textL .. textR) end,
	ClearLines = function(self)
		for i = 1, #self.lines do _G[self:GetName() .. "TextLeft" .. i] = nil end
		wipe(self.lines)
	end,
}

local noopMethods = {
	-- Too many functions, didn't bother
	"SetBagItem",
	"SetHyperlink",
	"IsOwned"
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

GameTooltipFrame = {
	New = function(name, parent)
		local super = _G.Frame.New(name, parent)
		local object = {parent = super, lines = {}, owner = nil, anchor = nil, _type = "GameTooltip", }
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
