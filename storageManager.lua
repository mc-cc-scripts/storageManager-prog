local storageManager = {}

---@param peripherals table { alias: peripheralName }
function storageManager:init()
    -- Wrap all available peripherals
    local peripherals = peripheral.getNames()
    self.peripherals = {}
    for i=1, #peripherals do
        self.peripherals[peripherals[i]] = peripheral.wrap(peripherals[i])
    end

    -- Map of items
    -- self.items[name] = {
    --    [slot] = count
    --    ...
    -- }
    self.items = nil

    self:prepareCommands()
    self:fetchItems()
end

function storageManager:fetchItems(peripheral)
    for slot, item in pairs(self.peripherals[peripheral].list()) do
        self.items[item.name] = {
            [slot] = item.count,
        }
    end
end

---@param from string peripheral name
---@param to string peripheral name
---@param name string item name (with prefix e.g.: `minecraft:`)
---@param count number | nil optional
function storageManager:pullItem(from, to, name, count)
    count = count or 1
    local slot = self.items[name].slot
    self.peripherals[to].pullItems(self.peripherals[from].name, slot, count)
end

---@param from string peripheral name
---@param to string peripheral name
---@param slot number optional
---@param count number optional
function storageManager:pushItem(from, to, slot, count)
    if not slot then
        for _slot, item in pairs(self.transfer_chest.list()) do
            self.peripherals[from].pushItems(self.peripherals[to].name, _slot, item.count)
        end
    else
        self.peripherals[from].pushItems(self.peripherals[to].name, slot, count)
    end
end

-- define command names for API
function storageManager:prepareCommands()
    self.commands = {
        ["extract"] = self.pullItem,
        ["list"] = self.fetchItems,
        ["search"] = self.search,
        ["put"] = self.pushItem,
    }
end

---@param name string
---@return table | nil
function storageManager:search(name)
    for _name, item in pairs(self.items) do
        if _name.find(name) then
            return item
        end
    end
    return nil
end

function storageManager:addToStartup()
    --@TODO: add script to startup
end

storageManager:init()