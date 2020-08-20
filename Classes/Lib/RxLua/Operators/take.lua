local _, addon = ...
local Observable = addon.Require("rx.Observable")
local Subscription = addon.Require("rx.Subscription")

--- Returns a new Observable that only produces the first n results of the original.
-- @arg {number=1} n - The number of elements to produce before completing.
-- @returns {Observable}
function Observable:take(n)
   n = n or 1

   return Observable.create(function(observer)
         if n <= 0 then
         observer:onCompleted()
         return
      end

      local i = 1
      local subscription
      local function unsub ()
         return subscription and subscription:unsubscribe()
      end

      local function onError(e)
         unsub()
         return observer:onError(e)
      end

      local function onCompleted()
         observer:onCompleted()
         unsub()
      end

      local function onNext(...)
         observer:onNext(...)

         i = i + 1

         if i > n then
            onCompleted()
         end
      end

      subscription = self:subscribe(onNext, onError, onCompleted)

      return Subscription.create(unsub)
   end)
end
