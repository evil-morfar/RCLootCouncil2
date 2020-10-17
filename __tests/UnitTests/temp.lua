local strmatch = string.match
local UnitGUID = function() return "PlayerName" end
local function matcher(unit)
    local guid
    if unit and not strmatch(unit, "Player%-") and strmatch(unit, "%d?%d?%d?%d%-%x%x%x%x%x%x%x%x") then
        -- GUID without "Player-"
        guid = "Player-" .. unit
    elseif unit and strmatch(unit, "Player%-%d?%d?%d?%d%-%x%x%x%x%x%x%x%x") then
        -- GUID with player
        guid = unit
    elseif type(unit) == "string" then
        -- Assume UnitName
        guid = UnitGUID(unit)
    else
        guid = string.format("%s invalid player", tostring(unit))
    end
    return guid
end


print(matcher("Player-3-0CC80653"))
print(matcher("Player-73-0CC80653"))
print(matcher("Player-173-0CC80653"))
print(matcher("Player-1173-0CC80653"))
print(matcher("73-0CC80653"))
print(matcher("7355-0CC80653"))
print(matcher("7-0CC80653"))
print(matcher("0CC80653"))
print(matcher("73-"))
print(matcher("73"))
print(matcher(73))
print(matcher("player"))