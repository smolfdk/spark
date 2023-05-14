-- Player object controller for Spark.
-- Made and maintained by frackz

local Player = Spark:Player()
local Identifiers = {
    steam = true,
    source = true,
    id = true
}

function Player:Get(identifier, value)
    assert(Identifiers[identifier], "Identifier "..value.." does not exist.")

    -- This currently just works for online users, this should be avaible to offline also.
    local steam = value
    if identifier == "id" then
        steam = self:Convert(value)
    elseif identifier == "source" then
        steam = Spark:Source():Steam(value)
    end

    local player = {}

    if self:Exist(steam) == false then
        return false, "user_does_not_exist", error("User does not exist.")
    end

    --- Get the player data module.
    function player:Data()
        local data = {}

        --- Get the whole data table
        function data:Raw()
            return Player:Raw(steam)['data']
        end

        --- Get a key from the data table
        function data:Get(key)
            return (self:Raw() or {})[key]
        end

        --- Set a key inside the data table, this is used for storing data easily.
        function data:Set(key, value)
            (self:Raw() or {})[key] = value
        end

        return data
    end

    --- Check if the user is currently online
    function player:Online()
        return self:Data() ~= nil
    end

    --- This will dump user data to the database, only do this if you need to.
    function player:Dump()
        return Player:Dump(steam, self:Data():Raw())
    end

    return player
end

CreateThread(function()
    Wait(1000)
    local player = Player:Get('id', 21 or '21')

    player:Data()
end)