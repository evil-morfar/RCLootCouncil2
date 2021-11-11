# RCLootCouncil Tests

Tests are made using [busted](https://github.com/Olivine-Labs/busted).
Each test can be run individually from it's file (assuming path is pointing at the project root), or globally.

## Structure

I hate the standard busted `*_spec.lua` convention and have opted for `*.spec.lua` instead. Busted should pick up spec files no matter where they are, but for structure I try to keep them in `/.specs` (which also automatically avoids having them packaged).

## Running tests

When using the tools below, running the tests is as easy as running the `atom-build` target `Busted`.
Alternatively one can invoke `busted` in the root folder, assuming `busted.bat` is in the current PATH.

For VS Code I've setup a debugger for running a single file with busted ("Run Busted") as well as several tasks for running both single and all files.

## Tools

Below is my collection of useful tools for the testing environment and development.

### Atom

*Not up-to-date as I switched to VS Code awhile back.*

- [linter](https://github.com/steelbrain/linter) - general linting.
- [linter-lua](https://github.com/AtomLinter/linter-lua) - lua linting.
- [atom-build](https://github.com/noseglid/atom-build) - used for building the project (configured with `.scrips/deploy.sh`).
- [atom-build-busted](https://github.com/xpol/atom-build-busted) - parses `.busted` config for `atom-build`.
- [atom-script](https://github.com/rgbkrk/atom-script) - for running lua scripts within atom.
- [language-lua](https://github.com/FireZenk/language-lua) - lua language support and snippets.

### VS Code

See [extensions.json](../.vscode/extensions.json)
