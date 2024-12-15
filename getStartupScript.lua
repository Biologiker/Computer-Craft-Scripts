local relativePath = "Startupscripts/wgetGit.lua"
local baseUrl = "https://raw.githubusercontent.com/Biologiker/Computer-Craft-Scripts/refs/heads/main/ "
local finalFileName = "startup"

shell.run(string.format("mv %s_old", finalFileName))
shell.run(string.format("wget %s%s %s", baseUrl, relativePath, finalFileName))