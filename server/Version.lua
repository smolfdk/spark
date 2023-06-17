-- Version controller for Spark.
-- Made and maintained by frackz

local Version = Spark:Config():Get('Version')

--- Get the Version module
function Spark:Version()
    return Version
end

--- Get the current version
--- @return number
function Version:Get()
   return self.Version
end

--- Get the newest version
--- @return number?
function Version:Newest()
    local success, request = Spark:HTTP():Perform(self.Request, 'GET')
    return (not success or not request) and self:Get() or tonumber(request)
end

--- Check if the the version is outdated
CreateThread(function()
    -- Check if its a outdated version
    assert(Version:Newest() == Version:Get(),
        "This version is outdated! Please download the new version"
    )

    -- Prints that its the newest
    print("You are up-to-date!")
end)