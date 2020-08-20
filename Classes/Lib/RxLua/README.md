## RCLootCouncil RxLua
This is an implementation of [bjornbytes/RxLua](https://github.com/bjornbytes/RxLua) that's been modified for use with WoW and the RCLootCouncil environment.

Only the classes used in RCLootCouncil have been ported, but others can easily be included following the established schema.

### Other changes
* `take*` functions will now unsubscribe when done (as per rxjs implementation).
* Added `:next` alias for `Subject.onNext()`.
