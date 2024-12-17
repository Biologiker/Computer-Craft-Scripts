function GetWirelessModem()
    local modem = nil
    for i, side in ipairs(redstone.getSides()) do
        if peripheral.getType(side) == "modem" then
            -- double nesting, because lua sucks
            local device = peripheral.wrap(side)
            if device.isWireless() then
                modem = device
                break
            end
        end
    end
    return modem
end

function InitModem(modem, channel, hostname)
    rednet.open(peripheral.getName(modem))

    -- start hosting the channel
    rednet.host(channel, hostname)

    local detectedHosts = { rednet.lookup(channel, hostname) };
    if (#detectedHosts < 1) then error("Rednet self-check failed!") end
    print("Modem self-check successfull.")
end