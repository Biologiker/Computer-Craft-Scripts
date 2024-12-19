local executeFiles = {}

function executeFiles.Start(config)
    local filesToExecute = config["filesToExecute"]

    for i = 1, #filesToExecute do
        print('Executing: ' .. filesToExecute[i])

        shell.run(filesToExecute[i])
    end
end

return executeFiles