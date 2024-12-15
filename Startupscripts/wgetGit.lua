local relativePath = "warehouseV3.lua"
local baseUrl = "https://raw.githubusercontent.com/Biologiker/Computer-Craft-Scripts/refs/heads/main/"
local finalFileName = "warehouse"

shell.run(string.format("rm %s_old", finalFileName))
shell.run(string.format("mv %s %s_old", finalFileName, finalFileName))
shell.run(string.format("wget run %s%s %s", baseUrl, relativePath, finalFileName))