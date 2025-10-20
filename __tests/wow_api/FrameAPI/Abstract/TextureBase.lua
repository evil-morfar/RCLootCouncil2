require "/FrameAPI/Abstract/Region"

local function noop() end

local objectMethods = {}

local noopMethods = {
	"GetAtlas",
	"GetBlendMode",
	"GetDesaturation",
	"GetHorizTile",
	"GetRotation",
	"GetTexCoord",
	"GetTexelSnappingBias",
	"GetTexture",
	"GetTextureFileID",
	"GetTextureFilePath",
	"GetVertTile",
	"GetVertexOffset",
	"IsBlockingLoadRequested",
	"IsDesaturated",
	"IsSnappingToPixelGrid",
	"SetAtlas",
	"SetBlendMode",
	"SetBlockingLoadsRequested",
	"SetColorTexture",
	"SetDesaturated",
	"SetDesaturation",
	"SetGradient",
	"SetHorizTile",
	"SetMask",
	"SetRotation",
	"SetSnapToPixelGrid",
	"SetTexCoord",
	"SetTexelSnappingBias",
	"SetTexture",
	"SetVertTile",
	"SetVertexOffset",
}

for _, v in ipairs(noopMethods) do objectMethods[v] = noop end

TextureBase = {
	New = function(name)
		local super = _G.Region.New(name)
		return setmetatable({}, {
			__index = function(self, v)
				local k = objectMethods[v] or super[v]
				self[v] = k -- Store for easy future lookup
				return k
			end,
		})
	end,
}
