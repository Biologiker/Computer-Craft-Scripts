if #args < 1  then
    print('Please specify a program to run!')

    return;
end

local programType = args[1]

if programType.lower() == 'floodfill' then
    local floodfill = require('floodfill')

    floodfill.Start(args);
end