require "/FrameAPI/Frames/Frame"
local function noop() end
local objectMethods = {}
local noopMethods = {
	"GetHorizontalScroll",
	"GetHorizontalScrollRange",
	"GetScrollChild",
	"GetVerticalScroll",
	"GetVerticalScrollRange",
	"SetHorizontalScroll",
	"SetScrollChild",
	"SetVerticalScroll",
	"UpdateScrollChildRect",
}
for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

ScrollFrame = {
	New = function(name, parent)
		local super = parent or _G.Frame.New(name)
		local object = { parent = super, _type = "ScrollFrame" }
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
