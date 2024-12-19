local floodfill = {}
local helpPages = require('helpPages')

function floodfill.Start(args)
    if #args <= 2 then
        print('Please specify a Z coordinate relative to the turtle as a starting height!')

        return;
    end

    if string.lower(args[2]) == 'help' or string.lower(args[2]) == 'info' then
        helpPages.FloodFillHelp()

        return;
    end

    if #args <= 4 then
        print('Please specify X and Y coordinates as a work region (0 would be "infinite")')
    end

    local z = args[2]
    local x = args[3]
    local y = args[4]

    for i = 1, x do
        local has_block, data = turtle.inspect()
        
        if has_block then
            print('Has block')

            print(textutils.serialise(data))
        else
            print('Doesnt have Block')

            print(textutils.serialise(data))
        end

        -- turtle.placeDown()
    end
end

return floodfill