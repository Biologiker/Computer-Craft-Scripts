----------------------------------------------------------------------------
-- SETTING
----------------------------------------------------------------------------

local wHostname = "New Myndelslöh"
local wChannel = "RSWarehouse-Myndelslöh"
local wPassword = "adminJesus"

local skipNBT = true
local ignoreFile = "ignore.conf"

local scanInterval = 1
local use24HourFormat = true

----------------------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------------------

-- Returns all connected monitors.
function getMonitors()
    local monitors = {}
    local peripheralNames = peripheral.getNames()
    for i, name in ipairs(peripheralNames) do
        if name:find("monitor_", 1, true) == 1 then
            table.insert(monitors, peripheral.wrap(name))
        end
    end
    for i, side in ipairs(redstone.getSides()) do
        if peripheral.getType(side) == "monitor" then
            table.insert(monitors, peripheral.wrap(side))
        end
    end
    return monitors
end

-- Updates monitor text scale and does some init stuff.
function initMonitors(monitors)
    for i, monitor in ipairs(monitors) do
        monitor.setTextScale(0.5)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.setCursorBlink(false)
    end
end

-- Prepare the modem
function initModem(modem, channel, hostname)
    rednet.open(peripheral.getName(modem))

    -- start hosting the channel
    rednet.host(channel, hostname)

    local detectedHosts = { rednet.lookup(channel, hostname) };
    if (#detectedHosts < 1) then error("Rednet self-check failed!") end
    print("Modem self-check successfull.")
end

-- tries to find a wireless modem
function getWirelessModem()
    local modem = nil
    for i, side in ipairs(redstone.getSides()) do
        if peripheral.getType(side) == "modem" then
            -- double nesting, because lua sucks
            device = peripheral.wrap(side)
            if device.isWireless() then
                modem = device
                break
            end
        end
    end
    return modem
end

-- checks if a character is a digit
function isDigit(char)
    local num = tonumber(char)
    return num ~= nil
end

-- automatically determins the side where the inventory container is located
function getInventorySide()
    local side = nil
    for i, _side in ipairs(redstone.getSides()) do
        block, type = peripheral.getType(_side)
        if type == "inventory" then
            side = _side
            break
        end
    end
    return side
end

-- tries to get the tool level from its metadata description
function getLevelFromDescription(description)
    local level = "Any"
    if string.find(description, "with maximal level: Leather") then level = "Leather" end
    if string.find(description, "with maximal level: Gold") then level = "Gold" end
    if string.find(description, "with maximal level: Chain") then level = "Chain" end
    if string.find(description, "with maximal level: Wood or Gold") then level = "Wood or Gold" end
    if string.find(description, "with maximal level: Stone") then level = "Stone" end
    if string.find(description, "with maximal level: Iron") then level = "Iron" end
    if string.find(description, "with maximal level: Diamond") then level = "Diamond" end
    return level
end

-- draws a row with a alignment on the monitor
function printRowJustified(monitor, row, align, text, ...)
    local width, height = monitor.getSize()
    local foreground = monitor.getTextColor()
    local background = monitor.getBackgroundColor()

    -- align
    if align == "left" then x = 1 end
    if align == "center" then x = math.floor((width - #text) / 2) end
    if align == "right" then x = width - #text end

    -- color
    if #arg > 0 then monitor.setTextColor(arg[1]) end
    if #arg > 1 then monitor.setBackgroundColor(arg[2]) end

    -- draw
    monitor.setCursorPos(x, row)
    monitor.write(text)
    monitor.setTextColor(foreground)
    monitor.setBackgroundColor(background)
end

-- prints the request lists on the given monitor
function printRequestLists(monitor, builder_requests, equipment_requests, other_requests)
    local row = 3
    monitor.clear()

    -- Builder List
    if #builder_requests > 0 then
        printRowJustified(monitor, row, "center", "Builder Requests")
        row = row + 1
        for i, request in ipairs(builder_requests) do
            local amountString = string.format("%d/%s", request.provided, request.name)
            printRowJustified(monitor, row, "left", amountString, request.color)
            printRowJustified(monitor, row, "right", " " .. request.target, request.color)
            row = row + 1
        end
    end
    
    -- Equipment list
    if #equipment_requests > 0 then
        printRowJustified(monitor, row, "center", "Equipment")
        row = row + 1
        for i, equipment in ipairs(equipment_requests) do
            local amountString = string.format("%d/%d %s", equipment.provided, equipment.needed, equipment.name)
            printRowJustified(monitor, row, "left", amountString, equipment.color)
            printRowJustified(monitor, row, "right", " " .. equipment.target, equipment.color)
            row = row + 1
        end
    end

    -- Other List
    if #other_requests > 0 then
        printRowJustified(monitor, row, "center", "Other Requests")
        row = row + 1
        for i, request in ipairs(other_requests) do
            local amountString = string.format("%d %s", request.needed, request.name)
            if isDigit(request.name:sub(1,1)) then
                amountString = string.format("%d/%s", request.provided, request.name)
            end
            printRowJustified(monitor, row, "left", amountString, request.color)
            printRowJustified(monitor, row, "right", " " .. request.target, request.color)
            row = row + 1
        end
    end

    -- No current requests
    if row == 3 then printRowJustified(monitor, row, "center", "No Open Requests") end
end

function displayTimer(monitors, time, twentyFourHour)
    local now = os.time()

    local cycle = "day"
    local cycleColor = colors.orange
    if now >= 4 and now < 6 then
        cycle = "sunrise"
        cycleColor = colors.orange
    elseif now >= 6 and now < 18 then
        cycle = "day"
        cycleColor = colors.yellow
    elseif now >= 18 and now < 19.5 then
        cycle = "sunset"
        cycleColor = colors.orange
    elseif now >= 19.5 or now < 5 then
        cycle = "night"
        cycleColor = colors.red
    end

    local timerColor = colors.orange
    if time < 15 then timerColor = colors.yellow end
    if time < 5 then timerColor = colors.red end

    -- draw
    local timeString = string.format("Time: %s [%s]", textutils.formatTime(now, twentyFourHour), cycle)
    local timerString = string.format("Remaining: %ss", time)
    for i, monitor in ipairs(monitors) do
        printRowJustified(monitor, 1, "left", timeString .. "    ", cycleColor)

        if cycle ~= "night" then
            printRowJustified(monitor, 1, "right", "    " .. timerString, timerColor)
        else
            printRowJustified(monitor, 1, "right", "    Remaining: PAUSED", colors.red)
        end
    end
end

function checkStringInTextFile(filename, searchString)
    local file = fs.open(filename, "r")
    if not file then
        fs.open(filename, "a").write("")
    end

    for line in io.lines(filename) do
        if string.find(line, searchString) then
            file:close()
            return true
        end
    end

    file:close()
    return false
end

-- the brain behind everything
-- scan the warehouse for request and pulls items from the rs system
function scanWorkRequests(monitors, rs, colony, storageSide, ignoreNBT, modem, channel, blacklistFile)
    local builder_requests = {}
    local equipment_requests = {}
    local other_requests = {}

    -- scan rs for all items. only ignore nbt items if defined above
    local items = rs.listItems()
    local rsitems = {}
    for i, item in ipairs(items) do
        if not ignoreNBT or not item.nbt then
            rsitems[item.name] = item.amount
            --print("Current item: " .. item.name)
        end
    end

    -- scan for open requests. try providing as much as possible from rs,
    -- then autocraft is possible.
    -- Green = Item was provided
    -- Yellow = Item is being crafted
    -- Red = Failed to provide item
    -- Blue = Skipped
    local workRequests = colony.getRequests()
    for i, request in ipairs(workRequests) do
        local provided = 0
        local item = request.items[1].name
        local needed = request.count
        print (item, needed)

        -- split target name into pars. we only need the first and surname
        local targetNameParts = {}
        for part in request.target:gmatch("%S+") do
            table.insert(targetNameParts, part)
        end

        -- construct shorted name
        local targetName = request.target
        if #targetNameParts >= 3 then targetName = targetNameParts[1] .. " " .. targetNameParts[#targetNameParts] end

        -- determin when to skip rs todo:
        local skipRS = checkStringInTextFile(blacklistFile, item)

        -- process items
        local requestedItem = request.items[1].name
        local color = colors.white
        if not skipRS then
            -- rs has item
            if rsitems[item] then
                provided = rs.exportItemToPeripheral({ name=item, count=needed }, storageSide)
                print("Exported " .. item .. " => provided: " .. provided)
            end
            print (item, needed)

            color = colors.green
            if provided < needed then
                if rs.isItemCrafting({name=item, count=needed}) then
                    color = colors.yellow
                    print("[Crafting]", {name=item, count=needed})
                else
                    if rs.craftItem({name=item, count=needed}) then
                        color = colors.yellow
                        print("[Scheduled]", needed, "x", item)
                    else
                        color = colors.red
                        print("[Failed]", item)
                    end
                end
            end
            print (item, needed)
        else
            color = colors.blue
            print("[Skipped]", request.name .. " [" .. targetName .. "]")
            provided = 0
        end


        -- sort into groups
        if string.find(request.desc, "level") then
            local level = getLevelFromDescription(request.desc)
            local fancyName = level .. " " .. request.name

            for i=1, table.getn(equipment_requests) do
                local request = equipment_requests[i]

                if(request.name == fancyName) then
                    request.needed = request.needed + 1
                    needed = request.needed

                    break
                end
            end

            if(needed == 1) then
                table.insert(equipment_requests, { name=fancyName, item=requestedItem, target=targetName, needed=needed, provided=provided, color=color })
            end
        elseif string.find(request.target, "Builder") then
            table.insert(builder_requests, { name=request.name, item=item, target=targetName, needed=needed, provided=provided, color=color })
        else
            table.insert(other_requests, { name=request.name, item=item, target=targetName, needed=needed, provided=provided, color=color })
        end

    end

    -- show lists
    for i, monitor in ipairs(monitors) do
        printRequestLists(monitor, builder_requests, equipment_requests, other_requests)
    end

    -- send to wireless stuff
    if modem then
        local message = textutils.serialize({ type="requests", builder_requests=builder_requests, equipment_requests=equipment_requests, other_requests=other_requests })
        rednet.broadcast(message, channel)
    end

    print("Scan completed at", textutils.formatTime(os.time(), false) .. " (" .. os.time() ..").")
end



----------------------------------------------------------------------------
-- CRYPTOGRAPHY
----------------------------------------------------------------------------

function calculateChecksum(password, channel, message)
    local combined = password .. channel .. message
    local checksum = 0

    for i = 1, #combined do
        local byteValue = string.byte(combined, i)
        checksum = checksum + byteValue
    end

    return string.format("%05d", checksum % 100000)
end

-- Basic encryption for text. Not highly secure bot enough
function encrypt(text, password)
    local encrypted = ""
    local passwordIndex = 1

    for i = 1, #text do
        local charCode = text:byte(i)
        local passwordChar = password:byte(passwordIndex)
        local encryptedCharCode = (charCode + passwordChar) % 256
        encrypted = encrypted .. string.char(encryptedCharCode)

        passwordIndex = passwordIndex % #password + 1
    end

    return encrypted
end

-- opposite of above
function decrypt(encryptedText, password)
    local decrypted = ""
    local passwordIndex = 1

    for i = 1, #encryptedText do
        local encryptedCharCode = encryptedText:byte(i)
        local passwordChar = password:byte(passwordIndex)
        local charCode = (encryptedCharCode - passwordChar) % 256
        decrypted = decrypted .. string.char(charCode)

        passwordIndex = passwordIndex % #password + 1
    end

    return decrypted
end

----------------------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------------------

-- Initialize Monitor(s)
local monitors = getMonitors()
if #monitors == 0 then error("No monitors found!") end
initMonitors(monitors)

-- Initialize RS Bridge
local bridge = peripheral.find("rsBridge")
if not bridge then error("RS Bridge not found.") end
print("RS Bridge initialized.")

-- Initialize Colony Integrator
local colony = peripheral.find("colonyIntegrator")
if not colony then error("Colony Integrator not found.") end
if not colony.isInColony then error("Colony Integrator is not in a colony.") end
print("Colony Integrator initialized.")

-- Initialize Storage
local storage = getInventorySide()
if not storage then error("Storage container not found.") end
print("Storage initialized.")

-- Initialize Wireless Modem
local modem = getWirelessModem()
if not modem then print("No Wireless Modem found. Remote capabilities disabled.") end
if modem then initModem(modem, wChannel, wHostname) end
print("Wireless Network initialized.")

----------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------

local currentTime = scanInterval

-- initial scan on startup
scanWorkRequests(monitors, bridge, colony, storage, skipNBT, modem, wChannel, ignoreFile)
displayTimer(monitors, currentTime, use24HourFormat, modem)

local timer = os.startTimer(1)
parallel.waitForAll(
    function()
        while true do
            local event, eTimer = os.pullEvent("timer")
            if eTimer == timer then
                local now = os.time()
                if now >= 5 and now < 19.5 then
                    currentTime = currentTime - 1
                    if currentTime <= 0 then
                        scanWorkRequests(monitors, bridge, colony, storage, skipNBT, modem, wChannel, ignoreFile)
                        currentTime = scanInterval
                    end
                end

                displayTimer(monitors, currentTime, use24HourFormat)

                -- send modem
                if modem then
                    local message = textutils.serialize({ type="time", time=currentTime })
                    rednet.broadcast(message, wChannel)
                end

                timer = os.startTimer(1)
            end
        end
    end,
    function()
        while true do
            os.pullEvent("monitor_touch")
            os.cancelTimer(timer)
            currentTime = scanInterval
            scanWorkRequests(monitors, bridge, colony, storage, skipNBT, modem, wChannel, ignoreFile)
            displayTimer(monitors, currentTime, use24HourFormat)
            timer = os.startTimer(1)
        end
    end,
    function()
        if not modem then return end
        while true do
            local event, sender, messageRaw, channel = os.pullEvent("rednet_message")

            -- verify protocoll
            if channel == wChannel then
                -- todo: encryption
                print(messageRaw)
                local message = textutils.unserialise(messageRaw)

                if message.type == "refresh" then
                    os.cancelTimer(timer)
                    scanWorkRequests(monitors, bridge, colony, storage, skipNBT, modem, wChannel, ignoreFile)
                    currentTime = scanInterval
                    timer = os.startTimer(1)
                end
            end
        end
    end
)
