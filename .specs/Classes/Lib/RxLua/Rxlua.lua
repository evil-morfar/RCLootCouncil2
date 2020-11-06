local addon = {}
loadfile("Classes/Core.lua")("", addon)
loadfile(".specs/AddonLoader.lua")(nil,nil, addon).LoadXML([[Classes\Lib\RxLua\embeds.xml]])


local Subject = addon.Require("rx.Subject")

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