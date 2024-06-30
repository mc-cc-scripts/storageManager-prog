local storageManager = {}
local scm = require("./scm")
local Config = scm:load("config")
local args = {...}

local defaultConfig = {
    ["protocol"] = {
        ["description"] = "Protocol used for rednet.",
        ["default"] = "00",
        ["type"] = "string"
    },
    ["protocolPrefix"] = {
        ["description"] = "Prefix used for the rednet protocol.",
        ["default"] = "storageManager#",
        ["type"] = "string"
    },
    ["serverName"] = {
        ["description"] = "Name of the server used in rednet communication.",
        ["default"] = "storageManager",
        ["type"] = "string"
    },
}

function storageManager:init()
    Config:init(defaultConfig)

    if args[1] == "startup" then
        self:addToStartup()
    elseif args[1] == "config" then
        Config:command(args)
    else
        -- Wrap all available peripherals
        local peripherals = peripheral.getNames()
        self.peripherals = {}
        for i=1, #peripherals do
            self.peripherals[peripherals[i]] = peripheral.wrap(peripherals[i])
        end

        self:run()
    end
end

---@param peripheral string
---@return table
function storageManager:fetchItems(peripheral)
    local items = {}
    for slot, item in pairs(self.peripherals[peripheral].list()) do
        items[item.name] = {
            [slot] = item.count,
        }
    end

    return items
end

---@param from string peripheral name
---@param to string peripheral name
---@param fromSlot number slot to take item from
---@param count number | nil optional
---@param toSlot number slot to put item to
function storageManager:pullItem(from, to, fromSlot, count, toSlot)
    count = count or 1
    self.peripherals[to].pullItems(self.peripherals[from].name, fromSlot, count, toSlot)
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

function storageManager:addToStartup()
    local startupPath = "./startup.lua"
    if not fs.exists(startupPath) then
        local file = fs.open(startupPath, "w")
        file.write("shell.run(\"storageManager.lua\")")
        file.close()
    else
        print("startup.lua already exists.")
    end
end

function storageManager:run()
    local protocol = Config:get('protocolPrefix') .. Config:get('protocol')
    local name = Config:get('serverName')
    rednet.host(protocol, name)
    print("Server `" .. name .. "` running on protocol `" .. protocol .. "`")
    
    while true do
        local deviceID
        local message
        deviceID, message, _ = rednet.receive(protocol)
        local messageObj = textutils.unserialiseJSON(message)
        local command = messageObj["command"]
        local response = ""
        local success = false
        
        if command == "list" then
            local peripheral = messageObj["peripheral"]
            local items = nil
            if peripheral then
                items = self:fetchItems(peripheral)
            end
            if items then success = true end

            response = textutils.serialiseJSON({
                ["success"] = success,
                ["items"] = items
            })
        elseif command == "put" then
            local from = messageObj["from"]
            local to = messageObj["to"]
            local slot = messageObj["slot"]
            local count = messageObj["count"]
            
            if from and to and slot then
                self:pushItem(from, to, slot, count)
                success = true
            end

            response = textutils.serialiseJSON({
                ["success"] = success
            })
        elseif command == "extract" then
            local from = messageObj["from"]
            local to = messageObj["to"]
            local fromSlot = messageObj["fromSlot"]
            local count = messageObj["count"]
            local toSlot = messageObj["toSlot"]

            if from and to and fromSlot and count then
                self:pullItem(from, to, fromSlot, count, toSlot)
                success = true
            end
            
            response = textutils.serialiseJSON({
                ["success"] = success
            })
        end

        rednet.send(deviceID, response, protocol)
    end

    rednet.unhost(protocol)
end

storageManager:init()