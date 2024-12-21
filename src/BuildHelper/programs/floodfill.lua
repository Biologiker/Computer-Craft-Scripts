local floodfill = {}
local helpPages = require('helpPages')

function floodfill.Start(args)
    if #args < 2 then
        print('Please specify a Z coordinate relative to the turtle as a starting height!')

        return;
    end

    if string.lower(args[2]) == 'help' or string.lower(args[2]) == 'info' then
        helpPages.FloodFillHelp()

        return;
    end

    if #args < 4 then
        print('Please specify X and Y coordinates as a work region (0 would be "infinite")')
    end

    local z = args[2]
    local x = args[3]
    local y = args[4]

    local placedBlocks = {}

    local yIterator = 1 --for y...

    local freeBlocks = {}

    for xIterator = 1, x - 1 do
        turtle.turnRight()

        local hasBlock, data = turtle.inspect()

        if hasBlock == false then
            table.insert(freeBlocks, {xIterator, yIterator})
        end

        turtle.turnLeft()
        turtle.forward()

        turtle.turnRight()
        turtle.turnRight()

        if hasBlock and #freeBlocks == 0 then
            table.insert(placedBlocks, {xIterator, yIterator})

           turtle.place()
        end

        turtle.turnRight()
        turtle.turnRight()
    end

    print ('freeBlocks')
    print (#freeBlocks)
    print (textutils.serialize(freeBlocks))
    print ('placedBlocks')
    print (#placedBlocks)
    print (textutils.serialize(placedBlocks))
end

return floodfill