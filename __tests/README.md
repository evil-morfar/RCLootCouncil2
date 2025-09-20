# __tests

This is the place where tests were once located (moved to [.specs](../.specs/README.md)), and now only contains experiments/helper scripts along with the WoW API mock used for testing.

## WoW API's

Some of the WoW FrameXML functions have been implemented in order to allow fully fletched addon code to be tested.

Everything is relative to `./__tests/wow_api/`, so to use the (thus running any tests) make sure this is in your path - which it should be with the provided configurations.


### `wow_api`

This file attempts to implement the most commonly used functions from FrameXML. This includes several of [wow lua additions](https://wow.gamepedia.com/Lua_functions) along with an assortment of FrameXML function (such as `CreateFrame`).

Some variables are exposed globally (mainly those related to groups and raids) to allow for alterations of the returned values.

Functions that normally returns any sort of values instead return either a mock value (e.g. `GetRealmName() == "Realm Name"`) or best effort of the orignal function (e.g. `GetServerTime() == os.time()`) .

It also serves as the loader for other API scripts.

I'm adding functions as needed when I encounter them in my tests.

### `wow_item_api`

This file attempts to recreate the `GetItemInfo` and `GetItemInfoInstant` functions with meaningful return values. To accomplish this I've exported the results of `GetItemInfo` for some 2.400 items from my RCLootCouncil History, and created a lookup table.

This allows one to call both item functions with either the `itemString`, `itemLink`,`itemID` or `itemName` of any of these items.

All the item data is exposed through the `_G.Items` table. Additionally a `_G.Items_Array` table is created, which is an array of all `itemString`s. This allows you to fetch a random item with `local itemString = _G.Items_Array[math.random(#_G.Items_Array)]`, which is then guaranteed to be a valid input for `GetItemInfo/Instant`.

### See also

- [wow_api/API](./wow_api/API/readme.md)
- [wow_api/FrameAPI](./wow_api/FrameAPI/Readme.md)
- [RCLootCouncil Testing](./../.specs/README.md)