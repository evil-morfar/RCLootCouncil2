require "busted.runner"()
local addon = {
    realmName = "Realm1",
    db = {global = {log = {}, cache = {}}},
    defaults = {global = {logMaxEntries = 2000}}
}

loadfile(".specs/AddonLoader.lua")(nil, nil, addon).LoadArray()
