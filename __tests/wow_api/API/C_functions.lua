--- Various C defined wow functions.

C_Container = {}

C_CreatureInfo = {
    GetClassInfo = function(classIndex) return end,
}

C_Timer = {
    After = function(delay, callback)
    end,
}

require "wow_api/API/Color"

local classColors = {
    DEATHKNIGHT = CreateColor(196, 30, 58, 1),
    DEMONHUNTER = CreateColor(163, 48, 201, 1),
    DRUID = CreateColor(255, 124, 10, 1),
    EVOKER = CreateColor(51, 147, 127, 1),
    HUNTER = CreateColor(170, 211, 114, 1),
    MAGE = CreateColor(63, 199, 235, 1),
    MONK = CreateColor(0, 255, 152, 1),
    PALADIN = CreateColor(244, 140, 186, 1),
    PRIEST = CreateColor(255, 255, 255, 1),
    ROGUE = CreateColor(255, 244, 104, 1),
    SHAMAN = CreateColor(0, 112, 221, 1),
    WARLOCK = CreateColor(135, 136, 238, 1),
    WARRIOR = CreateColor(198, 155, 109, 1),
}

C_ClassColor = {
    GetClassColor = function(className) return classColors[className] end,
}
