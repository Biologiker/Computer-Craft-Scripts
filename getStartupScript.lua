local relativePath = "Startupscripts/wgetGit.lua"
local finalFileName = "startup"

shell.run("rm startup")
shell.run(string.format("wget -O %s https://raw.githubusercontent.com/Biologiker/Computer-Craft-Scripts/refs/heads/main/%s", finalFileName, relativePath))