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
    local steam, id = value, nil
    if identifier == "id" then
        steam, id = self:Convert(value), value
    elseif identifier == "source" then
        steam = Spark:Source():Steam(value)
    end

    if not Player:Raw(steam) then
        if identifier == "source" then
            return false, "user_does_not_exist"
        end

        local data = Player:Pull(identifier, value)
        if not data then
            return false, "user_cannot_be_found"
        end

        id, steam = data.id, data.steam
    end

    local player = {}

    --- Get the player data module.
    function player:Data()
        local data = {}

        --- Get the whole data table
        function data:Raw()
            return (Player:Raw(steam) or {})['data'] or {}
        end

        --- Get a key from the data table
        function data:Get(key)
            if not player:Online() then
                local user = Player:Data(steam)
                assert(user, "User does not exist?")

                return user[key]
            end

            return self:Raw()[key]
        end

        --- Set a key inside the data table, this is used for storing data easily.
        function data:Set(key, value)
            if not player:Online() then
                local user = Player:Data(steam)
                assert(user, "User does not exist?")
                assert(type(user) == "table", "Saved data is not a table?")

                user[key] = value
                return true, Player:Dump(steam, user)
            end

            self:Raw()[key] = value
        end

        return data
    end

    function player:Kick(reason)
        assert(player:Online(), "Trying to kick offline user!")
        
    end

    --- Check if the user is currently online
    function player:Online()
        return self:Data() == nil
    end

    --- This will dump user data to the database, only do this if you need to.
    function player:Dump()
        return Player:Dump(steam, self:Data():Raw())
    end

    --- Get the user id
    function player:ID()
        return id
    end

    --- Get the user steam
    function player:Steam()
        return steam
    end

    return player
end

CreateThread(function()
    Wait(1000)
    local player = Player:Get('id', 2)
    print(player:Data():Get('bob'))
end)