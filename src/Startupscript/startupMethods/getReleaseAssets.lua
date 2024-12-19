local getReleaseAssets = {}

function getReleaseAssets.Start(config)
    local githubAuthorization = config["authorization"]
    local repo = config["repo"]

    local request = http.get {
        url = "https://api.github.com/repos/" .. repo .. "/releases",
        headers = {
            ["authorization"] = "Bearer " .. githubAuthorization
        }
    }

    local data = request.readAll()
    request.close()

    local dataTable = textutils.unserializeJSON(data);
    local newestRelease = dataTable[1]
    local htmlUrl = newestRelease["html_url"]
    local assets = newestRelease["assets"]

    print("Got release: " .. htmlUrl .. '\n')
    print("Containing " .. #assets .. " assets\n")

    for i = 1, #assets do
        local assetId = assets[i]["id"]
        local fileName = assets[i]["name"]

        print("Starting download of: " .. fileName .. '... ')

        request = http.get {
            url = "https://api.github.com/repos/" .. repo .. "/releases/assets/" .. assetId,
            headers = {
                ["authorization"] = "Bearer " .. githubAuthorization,
                ["accept"] = "application/octet-stream"
            }
        }

        local fileContent = request.readAll()
        request.close()

        local file = fs.open("./" .. fileName, "w")

        file.write(fileContent)

        print("Completed.\n")
    end
end

return getReleaseAssets