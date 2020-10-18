# RCLootCouncil Tests

Tests are made using [busted](https://github.com/Olivine-Labs/busted).
Each test can be run individually from it's file (assuming path is pointing at the project root), or globally.

## Structure
I hate the standard busted `*_spec.lua` convention and have opted for `*.spec.lua` instead. Busted should pick up spec files no matter where they are, but for structure I try to keep them in `/.specs` (which also automatically avoids having them packaged).

## Running tests
When using the tools below, running the tests is as easy as running the `atom-build` target `Busted`.
Alternatively one can invoke `busted` in the root folder, assuming `busted.bat` is in the current PATH.

## Tools
Below is my collection of useful tools for the testing environment and development.

### Atom
* [linter](https://github.com/steelbrain/linter) - general linting.
* [linter-lua](https://github.com/AtomLinter/linter-lua) - lua linting.
* [atom-build](https://github.com/noseglid/atom-build) - used for building the project (configured with `.scrips/deploy.sh`).
* [atom-build-busted](https://github.com/xpol/atom-build-busted) - parses `.busted` config for `atom-build`.
* [atom-script](https://github.com/rgbkrk/atom-script) - for running lua scripts within atom.
* [language-lua](https://github.com/FireZenk/language-lua) - lua language support and snippets.

### VS Code
* [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) - general lua IDE.
* [Lua Debug](https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug) - lua debugger.
* [vscode-lua](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua) - lua linting.
* [emmylua](https://marketplace.visualstudio.com/items?itemName=tangzx.emmylua)