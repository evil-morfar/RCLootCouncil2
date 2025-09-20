# RCLootCouncil Tests

Tests are made using [busted](https://github.com/Olivine-Labs/busted).
Each test can be run individually from it's file (assuming path is pointing at the project root), or globally.
Tests are run automatically on the repo, and should be run before commits aswell (see [below](#git-pre-commit) for instructions).

The goal is to cover as much of the addon's code as practically possible, as to avoid run-time errors when making changes, and be confident that a new feature won't break existing stuff. Some of the older codebase wasn't created with testing in mind, as naturally is harder to test. Newer code is more modularized, and I strive to always make appropriate tests whenever adding or refactoring.

I much prefer full integration tests, as stuff usually don't break in isolation - however unit tests can be useful - especially in Classes that are used everywhere.

## Structure

I hate the standard busted `*_spec.lua` convention and have opted for `*.spec.lua` instead. Busted should pick up spec files no matter where they are, but for structure I try to keep them in `/.specs` (which also automatically avoids having them packaged).

### Paths

`AddonLoader.lua` (which basically all test script uses to load files) relies on `__tests/wow_api/wow_api.lua` and `__tests/wow_api/wow_item_api.lua` being in the execution path.

There's several ways to do this depending on your OS, but in VS Code using yhe `sumneko.lua` extension, the required settings are already included in VS Code settings, tasks and launch configurations, and in the `.busted` file.

## Running tests

When using the tools below, running the tests is as easy as running any of the  `Busted` tasks.
Alternatively one can invoke `busted` in the root folder, assuming `busted.bat` is in the current PATH.

## Tools

Below is my collection of useful tools for the testing environment and development.

### VS Code

See [extensions.json](../.vscode/extensions.json)

## Git pre-commit

To automatically run the tests before committing, simply add this following to `.git/hooks/pre-commit`:

``` sh
#!/bin/sh

branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "$branch" = "master" ]; then
  echo "You can't commit directly to master branch"
  exit 1
else
  echo "Running tests"
  # Add wow_api's to path to complete tests
  LUA_PATH=".\\__tests\\?.lua;$LUA_PATH"
  exec busted.bat -o=TAP --no-coverage
fi
```

That's a file named `pre-commit`.
