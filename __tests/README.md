## RCLootCouncil Tests

### Requirements
These tests are made with the use of `luaunit` and `luacov`.

### Environment
All test scripts needs to be called with the project root (`/.`) as the current working directory. All imports are relative to it.

### "Runners"
`__tests/RunAllTests.lua` will run all the tests listed in
* `__tests/FullTests/RunFullTests.lua`,
* `__tests/UnitTests/RunUnitTests.lua`

Each individual test is also created to be run standalone.

### Template
`__tests/Test_Template.lua` is provided as a template for new tests. This should be implemented to ensure consistency and allow for standalone runs. When creating new tests, don't forget to add a `require()` to a runner.

### Lua Coverage
The luacov report is generated when a test is run from any runner in `__tests/luacov.report.out`.

## WoW API's
Some of the WoW FrameXML functions have been implemented in order to allow fully fletched addon code to be tested.

Currently provided are `wow_api.lua` and `wow_item_api.lua`.

### wow_api
This file attempts to implement the most commonly used functions from FrameXML. This includes several of [wow lua additions](https://wow.gamepedia.com/Lua_functions) along with an assortment of FrameXML function (such as `CreateFrame`).

Some variables are exposed globally (mainly those related to groups and raids) to allow for alterations of the returned values.

Functions that normally returns any sort of values instead return either a mock value (e.g. `GetRealmName() == "Realm Name"`) or best effort of the orignal function (e.g. `GetServerTime() == os.time()`) .

I'm adding functions as needed when I encounter them in my tests.

### wow_item_api
This file attempts to recreate the `GetItemInfo` and `GetItemInfoInstant` functions with meaningful return values. To accomplish this I've exported the results of `GetItemInfo` for some 2.400 items from my RCLootCouncil History, and created a lookup table.

This allows one to call both item functions with either the `itemString`, `itemLink`,`itemID` or `itemName` of any of these items.

All the item data is exposed through the `_G.Items` table. Additionally a `_G.Items_Array` table is created, which is an array of all `itemString`s. This allows you to fetch a random item with `local itemString = Items_Array[math.random(#Items_Array)]`, which is then guaranteed to be a valid input for `GetItemInfo/Instant`.
