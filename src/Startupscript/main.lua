local getReleaseAssets = require('getReleaseAssets')
local executeFiles = require('executeFiles')

local configFile = fs.open('config.json', 'r')
local config = configFile.readAll()
config =  textutils.unserializeJSON(config)

local startupMethods = config['startupMethods']
local startupMethodsString = textutils.serialise(startupMethods)

if string.find(startupMethodsString, '"getReleaseAssets"') ~= nil then
    getReleaseAssets.Start(config)

end

if string.find(startupMethodsString, '"executeFiles"') ~= nil then
    executeFiles.Start(config)
end