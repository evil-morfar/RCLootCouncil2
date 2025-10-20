# FrameAPI

This folder contains emulations of certain WoW UI elements allowing me to run tests that relies on these being present.

The files are logically divided into classes as described in the [Widget API Wiki](https://wowpedia.fandom.com/wiki/Widget_API), and their inheritance created as described.

`CreateFrame()` is implemented in `__tests/wow_api/wow_api.lua`, and uses `Constructor.lua` with the definitions in these files to create the frames requested.
