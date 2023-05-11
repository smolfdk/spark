-- Version controller for Spark.
-- Made and maintained by frackz

local Version = {
    Version = 1.0,
    Request = 'https://pastebin.com/raw/sh5zZrmy'
}

--- Get the Version module
function Spark:Version()
    return Version
end

--- Get the current version
function Version:Get()
   return self.Version
end

--- Get the newest version
function Version:Newest()
    local success, request = Spark:HTTP():Perform(self.Request, 'GET')

    if not success or not request then
        return self:Get()
    end

    return tonumber(request)
end

--- Check if the the version is outdated
CreateThread(function()
    local Query = Spark:Database():First('SELECT * FROM users WHERE id = ?', 1)
    print(Query.steam)

    if Version:Newest() ~= Version:Get() then -- Outdated version
        return error("This version is outdated! Please download the new version")
    end

    print("You are up-to-date!")
end)