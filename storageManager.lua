local storageManager = {}

function storageManager:init()
    -- Designated chest for in- and output.
    -- The name has to be predefined.
    self.transfer_chest = peripheral.wrap("minecraft:chest_2")
    -- The controller is part of the storage drawers mod and handles a lot of the storing logic for us.
    self.controller = nil
    -- Map of items with name as key and count and slot as value
    self.items = nil

    if not self:findDrawerController() then
        print "No drawer controller found!"
        return
    end

    self:prepareCommands()
    self:fetchItems()

    -- provide cli
    self:cli()
end

function storageManager:findDrawerController()
    local peripherals = peripheral.getNames()
    for i=1, #peripherals do
        if string.find(peripherals[i], "controller")  then
            self.controller = peripheral.wrap(peripherals[i])
            return true
        end
    end

    return false
end

function storageManager:fetchItems()
    for slot, item in pairs(self.controller.list()) do
        self.items[item.name] = {
            ["count"] = item.count,
            ["slot"] = slot
        }
    end
end

function storageManager:pullItem(name, count)
    local slot = self.items[name].slot
    self.transfer_chest.pullItems(self.controller.name, slot, count)
end

function storageManager:pushItem(slot, count)
    self.transfer_chest.pushItems(self.controller.name, slot, count)
end

-- commands
function storageManager:prepareCommands()
    self.commands = {
        -- extracts an item by name with an optional item count
        ["x"] = self.extract,
        ["extract"] = self.extract,
        -- fetch all items in systen (refresh self.items)
        ["f"] = self.fetchItems,
        ["fetch"] = self.fetchItems,
        -- search for a specific item by name
        ["s"] = self.search,
        ["search"] = self.search,
        -- puts all items from transfer_chest into the system
        ["p"] = self.putItems,
        ["put"] = self.putItems,
        -- help; lists all commands
        ["h"] = self.help,
        ["help"] = self.help
    }
end

---@param name string
---@param count number | nil optional
function storageManager:extract(name, count)
    count = count or 1
    self:pullItem(name, count)
end

---@param name string
---@return number
function storageManager:search(name)
    return self.items[name].count or 0
end

---@param slot number optional
---@param count number optional
function storageManager:putItems(slot, count)
    if not slot then
        for _slot, item in pairs(self.transfer_chest.list()) do
            self:pushItem(_slot, item.count)
        end
    elseif count then
        self:pushItem(slot, count)
    else
        self:pushItem(slot)
    end
end

function storageManager:help()
    --@TODO: add description to commands and loop over them?
    print("commands: extract [x], fetch [f], search [s], put [p], help [h]")
end

function storageManager:cli()
    -- shell.setCompletionFunction("storageManager.lua", completionFunction)
    -- shell.run(read(nil, nil, shell.complete, "storageManager "))
end

function storageManager:addToStartup()
    --@TODO: add script to startup
end

storageManager:init()