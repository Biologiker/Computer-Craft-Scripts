local floodfill = {}
local helpPages = require('helpPages')

function floodfill.Start(args)
    if #args < 2 then
        print('Please specify a Z coordinate relative to the turtle as a starting height!')

        return
    end

    if string.lower(args[2]) == 'help' or string.lower(args[2]) == 'info' then
        helpPages.FloodFillHelp()

        return
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

    turtle.turnRight()

    local hasBlockToRight = turtle.inspect()

    turtle.turnLeft()

    while true do
        local hasBlockInfront = turtle.inspect()

        if xIterator <= x then

            if hasBlockToRight == false then
                table.insert(freeBlocksToRight, xIterator)
            end

            if hasBlockInfront == false and xIterator < x then
                turtle.forward()

                if hasBlockToRight and #freeBlocksToRight == 0 then
                    turtle.turnRight()
                    hasBlockToRight = turtle.inspect()
                    turtle.turnRight()

                    table.insert(placedBlocks, { xIterator, yIterator })

                    turtle.place()

                    turtle.turnRight()
                    turtle.turnRight()
                else
                    turtle.turnRight()

                    hasBlockToRight = turtle.inspect()

                    turtle.turnLeft()
                end
            else
                turtle.turnRight()

                xIterator = 0

                print('freeBlocksToRight')
                print(#freeBlocksToRight)
                print(textutils.serialize(freeBlocksToRight))
                
                goto continue
            end
        else
            break
        end

        xIterator = xIterator + 1
        ::continue::
    end
end

return floodfill
