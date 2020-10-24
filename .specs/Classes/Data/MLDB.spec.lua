require "busted.runner"()
local addon = {
    realmName = "Realm1",
    db = {global = {log = {}, cache = {}}, profile = {}},
    defaults = {global = {logMaxEntries = 2000}}
}
loadfile(".specs/AddonLoader.lua")(nil, nil, addon).LoadArray {
    [[Libs\LibStub\LibStub.lua]],
    [[Libs\CallbackHandler-1.0\CallbackHandler-1.0.xml]],
    [[Libs\AceComm-3.0\AceComm-3.0.xml]],
    [[Libs\AceLocale-3.0\AceLocale-3.0.xml]],
    [[Libs\AceSerializer-3.0\AceSerializer-3.0.xml]],
    [[Libs\AceEvent-3.0\AceEvent-3.0.xml]],
    [[Locale\enUS.lua]],
    [[Core\Constants.lua]],
    [[Core\Defaults.lua]],
    [[Classes\Core.lua]],
    [[Classes\Lib\RxLua\embeds.xml]],
    [[Libs\LibDeflate\LibDeflate.lua]],
    [[Classes\Utils\Log.lua]],
    [[Classes\Utils\TempTable.lua]],
    [[Classes\Services\ErrorHandler.lua]],
    [[Locale\enUS.lua]],
    [[Utils\Utils.lua]],
    [[Classes\Data\Player.lua]],
    [[Classes\Services\Comms.lua]],
    [[Classes\Data\MLDB.lua]]
}

function addon:Getdb()
    return self.db.profile
end

setmetatable(
    addon.db.profile,
    {
        __index = addon.defaults.profile
    }
)

describe(
    "#Data #MLDB",
    function()
        ---@type Data.MLDB
        local MLDB = addon.Require "Data.MLDB"
        local AceSer = LibStub("AceSerializer-3.0")
        describe(
            "init",
            function()
                it(
                    "should contain basic functions",
                    function()
                        assert.is.Function(MLDB.GetForTransmit)
                        assert.is.Function(MLDB.RestoreFromTransmit)
                        assert.is.Function(MLDB.Send)
                        assert.is.Function(MLDB.Get)
                        assert.is.Function(MLDB.Update)
                    end
                )
            end
        )
        describe(
            "functions",
            function()
                before_each(
                    function()
                        -- Always use a fresh copy
                        loadfile([[Core\Defaults.lua]])(nil, addon)
                    end
                )

                it(
                    "should get MLDB",
                    function()
                        local mldb = MLDB:Get()
                        assert.are.equal(60, mldb.timeout)
                        assert.are.equal(true, mldb.selfVote)
                    end
                )

                it(
                    "should compress the MLDB",
                    function()
                        local mldb = MLDB:Get()
                        local forTransmit = MLDB:GetForTransmit()
                        assert.are.equal(60, forTransmit["|12"]) -- timeout
                        assert.True(#AceSer:Serialize(mldb) > #AceSer:Serialize(forTransmit))
                    end
                )

                it(
                    "should restore a transmitted MLDB",
                    function()
                        local mldb = MLDB:Get()
                        local restored = MLDB:RestoreFromTransmit(MLDB:GetForTransmit())
                        assert.are.same(mldb, restored)
                    end
                )

                it(
                    "should update mldb",
                    function()
                        local mldb1 = MLDB:Get()
                        addon.db.profile.buttons.NEW = {
                            numButtons = 1,
                            {text = "Test"}
						}
						addon.db.profile.responses.NEW = {
							{text = "Tester"}
						}
                        local mldb2 = MLDB:Update()
                        assert.are_not.same(mldb1, mldb2)
                        assert.are.equal(1, #mldb2.buttons.NEW)
                        assert.are.equal("Test", mldb2.buttons.NEW[1].text)
                    end
                )
                it(
                    "should handle random added values",
                    function()
                        assert.has_no.errors(
                            function()
                                local mldb = MLDB:Get()
                                mldb.newValue = true
                                MLDB:GetForTransmit(mldb)
                            end
                        )
                    end
                )
            end
        )
    end
)
