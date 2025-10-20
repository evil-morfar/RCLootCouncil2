require "/FrameAPI/Abstract/TextureBase"

local function noop() end

local objectMethods = {}

local noopMethods = {"AddMaskTexture", "GetMaskTexture", "GetNumMaskTextures", "RemoveMaskTexture"}

for _, v in ipairs(noopMethods) do if not objectMethods[v] then objectMethods[v] = noop end end

Texture = {
	New = function(name, parent, drawLayer, templateName, subLevel)
		local super = _G.TextureBase.New(name)
		local object = {parent = parent, values = {drawLayer = drawLayer, templateName = templateName, subLevel = subLevel}}
		return setmetatable(object, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
