require "/wow_api/FrameAPI/Frames/Frame"

local function noop() end

local objectMethods = {
	SetOwner = function(self, frame, anchor, ...)
		self.owner = frame
		self.anchor = anchor
	end,
	GetOwner = function(self) return self.owner, self.anchor end,
	NumLines = function(self) return #self.lines end,
	AddLine = function(self, text, ...) tinsert(self.lines, text) end,
	AddDoubleLine = function(self, textL, textR, ...) tinsert(self.lines, textL .. textR) end,
	ClearLines = function(self) wipe(self.lines) end,
}

local noopMethods = {
	-- Too many functions, didn't bother
	"SetBagItem",
	"SetHyperlink",
}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

GameTooltipFrame = {
	New = function(name, parent)
		local super = _G.Frame.New(name, parent)
		local object = {lines = {}, owner = nil, anchor = nil}
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
