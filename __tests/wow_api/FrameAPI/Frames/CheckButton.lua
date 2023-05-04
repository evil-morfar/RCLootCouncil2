require "/wow_api/FrameAPI/Frames/Button"
require "/wow_api/FrameAPI/Fonts/FontString"

local function noop()
end

local objectMethods = {
    SetChecked = function(self, checked) self.checked = checked end,
    GetChecked = function(self) return self.checked end,
    -- TODO Not complete
}

CheckButton = {
    New = function(name, parent)
        local super = _G.Button.New(name, parent)
        local object = { text = _G.FontString.New(name .. "Text", parent), checked = false, }
        _G[name .. "Text"] = object.text
        return setmetatable(object, {
            __index = function(self, v)
                local k = objectMethods[v] or super[v]
                self[v] = k -- Store for easy future lookup
                return k
            end,
        })
    end,
}
