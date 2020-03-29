local Rx = require "rx"

local subject = Rx.Subject.create()
local obs = subject
   :take(2)
local subscription = obs:subscribe(print, print, function()
   print("obs completed")
   self = nil
end)

subject:onNext(1)
subject:subscribe(print)
subject:onNext(2)
subject:onNext(3)
subject:onNext(4)
print(collectgarbage("count") )
collectgarbage()
print("is unsubbed?", subscription.unsubscribed)
subscription:unsubscribe()
print("is unsubbed?", subscription.unsubscribed)
print(collectgarbage("count") )
print("Subscription:", subscription, obs)
