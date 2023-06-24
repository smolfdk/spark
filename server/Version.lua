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