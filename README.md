# storageManager

WORK IN PROGRESS

A script to push and pull items from storage. This is based on storage drawers and for now will only support one drawer controller connected to multiple storage drawers.

# Setup
![Setup](setup/storageManager.jpg)
- [1] Computer
- [2] Wired Modem (Right-click to make sure everything is connected!)
- [3] Transfer Chest (In- and Output)
- [4] Drawer Controller
- [5] Drawers

**Note:** You may leave space between Computer, Chest and Drawer Controller but you will need an modem next to each of those and have those modems connected via cables.
You may also omit the modems entirely and have the Computer in between the Chest and the Drawer Controller.

# API
_Note: Currently errors are not handled properly and the `success` field in the response may not always be accurate._

Below you can find the available commands and an example for their requests and responses.

## List
Request example:
```lua
local message = {
    ["command"] = "list",
    ["peripheral"] = <string> -- peripheral name (e.g.: `minecraft:chest_2`)
}
```

Respond example:
```lua
local message = {
    ["success"] = true, -- returns if the call was successful or not
    ["items"] = {
        [itemName <string>] = {
            [slot <number>] = itemCount <number>
        },
        -- ...
    }
}
```

## Put
Request example:
```lua
local message = {
    ["command"] = "put",
    ["from"] = <string>, -- peripheral name (e.g.: `minecraft:chest_2`)
    ["to"] = <string>, -- peripheral name (e.g.: `minecraft:chest_2`)
    ["slot"] = <number>, -- target slot, will use any slot if not specified
    ["count"] = <number>, -- defaults to 1
}
```

Respond example:
```lua
local message = {
    ["success"] = true -- returns if the call was successful or not
}
```

## Extract
Request example:
```lua
local message = {
    ["command"] = "extract",
    ["from"] = <string>, -- peripheral name (e.g.: `minecraft:chest_2`)
    ["to"] = <string>, -- peripheral name (e.g.: `minecraft:chest_2`)
    ["fromSlot"] = <number>, -- fromSlot
    ["count"] = <number>, -- defaults to 1
    ["toSlot"] = <number>, -- toSlot, will use any slot if not specified
}
```

Respond example:
```lua
local message = {
    ["success"] = true -- returns if the call was successful or not
}
```