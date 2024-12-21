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

    local z = tonumber(args[2])
    local x = tonumber(args[3])
    local y = tonumber(args[4])

    local placedBlocks = {}

    local yIterator = 1
    local xIterator = 1

    local freeBlocksToRight = {}

    while true do
        local hasBlockInfront, data = turtle.inspect()
        print (hasBlockInfront)

        if xIterator <= x then
            turtle.turnRight()

            local hasBlockToRight, data = turtle.inspect()

            if hasBlockToRight == false then
                table.insert(freeBlocksToRight, xIterator)
            end

            if hasBlockInfront == false or xIterator == x then
                return
            end

            turtle.turnLeft()
            turtle.forward()

            turtle.turnRight()
            turtle.turnRight()

            if hasBlockToRight and #freeBlocksToRight == 0 then
                table.insert(placedBlocks, { xIterator, yIterator })

                turtle.place()
            end

            turtle.turnRight()
            turtle.turnRight()
        else
            break
        end

        xIterator = xIterator + 1
    end

    print('freeBlocksToRight')
    print(#freeBlocksToRight)
    print(textutils.serialize(freeBlocksToRight))
end

return floodfill
