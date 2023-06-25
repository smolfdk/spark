-- The main file for handling exports, and the initial table
-- Made and maintained by frackz

--- Exports the Spark table
exports('Server', function()
    return Spark
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= Spark:Utility():Resource() then
        return
    end

    repeat Wait(5)
    until Spark:Utility():State() == "started"
    Spark:Debug():Spark("Spark has loaded!")

    if Spark:Version():Get() ~= Spark:Version():Newest() then
        return Spark:Debug():Error(
            'You are not up to date. Please update to the newest version!'
        )
    end

    Spark:Debug():Print('📚',
        "You are up to date!"
    )

    local err = Spark:Database():Error()
    if err then
        return Spark:Debug():Error(
            "Database connection failed! "..err
        )
    end

    Spark:Debug():Print('💻',
        "Database connection established!"
    )
end)