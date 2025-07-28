---@type RCLootCouncil
local addon = {}
loadfile(".specs/AddonLoader.lua")(nil, nil, addon).LoadArray {
	"Classes/Core.lua",
	[[Classes\Lib\RxLua\embeds.xml]],
}

describe("#RxLua", function()
	local Subject = addon.Require("rx.Subject")
	local Observable = addon.Require("rx.Observable")
	describe("#Subject", function()
		pending("should handle basic Subject functions", function()

			local test = Subject.create()

			local sub = test:take(1):subscribe(print)
			print(sub.unsubscribed)
			test(1)
			test(2)
			test(3)

			print(sub.unsubscribed)

			local sub2 = test:subscribe(print)
			test(1)
			test(2)
			sub2:unsubscribe()
			test(3)
		end)
	end)
	describe("#Observable", function()
		
		it("should handle basic Observable functions", function()
			local s = Subject.create()
			local o = Observable.create(function(observer)
				return s:subscribe(observer)
			end)
			local sp = spy.new()
			o:subscribe(sp)
			s("Test")
			assert.spy(sp).was_called(1)
			assert.spy(sp).was_called_with("Test")
		end)

		it("can create from Subjects", function()
			local s = Subject.create()
			local o = Observable.fromSubject(s)
			local sp = spy.new()
			o:subscribe(sp)
			s("Test")
			assert.spy(sp).was_called(1)
			assert.spy(sp).was_called_with("Test")
		end)
	end)
end)
