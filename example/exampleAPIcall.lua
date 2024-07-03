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

    rednet.send(host, textutils.serialiseJSON(message), protocol)

    local msgObject
    while true do
        local id, msg, prot = rednet.receive(protocol)
        print(id, msg, prot)
        msgObject = textutils.unserialiseJSON(msg)
        break
    end

    local controller
    local chest
    local peripherals = msgObject['peripherals']
    print (textutils.serialiseJSON(msgObject['peripherals']))
    for i=1, #peripherals do
        print(peripherals[i])
        if string.find(peripherals[i], "controller") then
            controller = peripherals[i]
        elseif string.find(peripherals[i], "chest") then
            chest = peripherals[i]
        end
    end

    -- list all items in controller
    message = {
        ["command"] = "list",
        ["peripheral"] = controller
    }

    rednet.send(host, textutils.serialiseJSON(message), protocol)

    msgObject = nil
    while true do
        local id, msg, prot = rednet.receive(protocol)
        print(id, msg, prot)
        msgObject = textutils.unserialiseJSON(msg)
        break
    end

else
    print("No open modem")
end
