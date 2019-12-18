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
`__tests/Test_Template.lua` is provided as a template for new tests. This should be implemented to ensure consistency and allow for standalone runs. When creating new tests, don't forget to add a `dofile()` to a runner.

### Lua Coverage
The luacov report is generated when a test is run from any runner in `__tests/luacov.report.out`.
