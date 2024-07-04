local protocol = "storageManager#00"
local hostname = "storageManager"

peripheral.find("modem", rednet.open)
if rednet.isOpen() then
    local host = rednet.lookup(protocol, hostname)
    -- print(host)

    -- get peripherals
    local message = {
        ["command"] = "peripherals"
    }

    rednet.send(host, message, protocol)

    local msg
    while true do
        local id, prot
        id, msg, prot = rednet.receive(protocol)
        print(id, msg, prot)
        break
    end

    local controller
    local chest
    local peripherals = msg['peripherals']
    print(msg['peripherals'])
    for i=1, #peripherals do
        print(peripherals[i])
        -- Note: In my test world I've used a drawer controller and a chest connected to the server via wired modems.
        if string.find(peripherals[i], "controller") then
            controller = peripherals[i]
        elseif string.find(peripherals[i], "chest") then
            chest = peripherals[i]
        end
    end

    print(controller, chest)

    -- list all items in controller
    message = {
        ["command"] = "list",
        ["peripheral"] = controller
    }

    rednet.send(host, message, protocol)

    -- move items from controller to chest (extract test)
    msg = nil
    while true do
        local id, prot
        id, msg, prot = rednet.receive(protocol)
        print(id, msg, prot)
        for item, slots in pairs(msg["items"]) do
            for slot, count in pairs(slots) do
                message = {
                    ["command"] = "extract",
                    ["from"] = controller,
                    ["to"] = chest,
                    ["fromSlot"] = tonumber(slot),
                    ["count"] = tonumber(count),
                    ["toSlot"] = nil
                }
                rednet.send(host, message, protocol)
                sleep(1)
            end
        end
        break
    end

    -- put test
    message = {
        ["command"] = "put",
        ["from"] = chest,
        ["to"] = controller,
        ["fromSlot"] = 1,
        ["count"] = 1,
        ["toSlot"] = nil,
    }

    rednet.send(host, message, protocol)

    msg = nil
    while true do
        local id, prot
        id, msg, prot = rednet.receive(protocol)
        print(id, textutils.serialiseJSON(msg), prot)
        break
    end


else
    print("No open modem")
end
