# kLib-1.0

A small library of utility functions, primarily used for the `k-series` of addons by `Kulldam`.

## Installation

- Place the `kLib` directory in your addon `libs` directory, as with any library.
- Include the appropriate `kLib*.xml` files, based on which modules you wish to use, in your `embeds.xml` or directly in your `.toc` file, like so:

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.blizzard.com/wow/ui/
..\FrameXML\UI.xsd">
	<Include file="libs\kLib\kLib-1.0.xml"/>
	<Include file="libs\kLib\kLibColor-1.0\kLibColor-1.0.xml"/>
	<Include file="libs\kLib\kLibComm-1.0\kLibComm-1.0.xml"/>
	<Include file="libs\kLib\kLibItem-1.0\kLibItem-1.0.xml"/>
	<Include file="libs\kLib\kLibOptions-1.0\kLibOptions-1.0.xml"/>
</Ui>
```

- `kLib` is `AceAddon-3.0`-embeddable, so when specifying your `AceAddon-3.0`, embed the appropriate `kLib` modules, like so:
 
```lua
local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME,
    "kLib-1.0",
    "kLibColor-1.0",
    "kLibComm-1.0",
    "kLibItem-1.0",
    "kLibOptions-1.0")
```

## Usage

All `kLib` functions are embedded into your core addon, so referencing any function would use the colon-syntax.

For example, the `ID` of an item can be obtained using `kLibItem-1.0` by using the `Item_Id` method:
 
```lua
local id = addon:Item_Id(myItem)
```