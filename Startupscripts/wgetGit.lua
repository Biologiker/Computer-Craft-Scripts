local relativePath = "Startupscripts/warehouseV3.lua"
local baseUrl = "https://raw.githubusercontent.com/Biologiker/Computer-Craft-Scripts/refs/heads/main/ "
local finalFileName = "warehouse"

shell.run(string.format("mv %s_old", finalFileName))
shell.run(string.format("wget %s%s %s", baseUrl, relativePath, finalFileName))