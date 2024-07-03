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

    -- list all items in controller
    message = {
        ["command"] = "list",
        ["peripheral"] = controller
    }

    rednet.send(host, message, protocol)

    msg = nil
    while true do
        local id, prot
        id, msg, prot = rednet.receive(protocol)
        print(id, msg, prot)
        break
    end

else
    print("No open modem")
end
