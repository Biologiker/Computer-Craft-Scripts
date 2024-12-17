function GetMonitors()
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

function InitMonitors(monitors)
    for i, monitor in ipairs(monitors) do
        monitor.setTextScale(0.5)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.setCursorBlink(false)
    end
end

function PrintRowJustified(monitor, row, align, text, ...)
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