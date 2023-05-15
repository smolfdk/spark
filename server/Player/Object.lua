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
            return (Player:Raw(steam) or {})['data']
        end

        --- Get a key from the data table
        function data:Get(key)
            if not player:Is():Online() then
                local user = Player:Data(steam)
                assert(user, "User does not exist?")

                return user[key]
            end

            return (self:Raw() or {})[key]
        end

        --- Set a key inside the data table, this is used for storing data easily.
        function data:Set(key, value)
            if not player:Is():Online() then
                local user = Player:Data(steam)
                assert(user, "User does not exist?")
                assert(type(user) == "table", "Saved data is not a table?")

                user[key] = value
                return true, player:Dump()
            end

            (self:Raw() or {})[key] = value
        end

        return data
    end

    function player:Kick(reason)
        assert(player:Is():Online(), "Trying to kick offline user!")
        assert(player:Get():Source(), "Source is not set, and therefor cannot kick player")

        DropPlayer(player:Get():Source(), reason)
    end

    --- Ban the user from the server
    function player:Ban(reason)
        reason = reason or ''

        if self:Is():Banned() then
            return false, self:Data():Set('Banned', nil)
        end

        self:Data():Set('Banned', reason)
        if self:Is():Online() then
            self:Kick('[Banned] '..reason)
        end

        return true
    end


    function player:Is()
        local data = {}

        function data:Online()
            return player:Data():Raw()
        end

        function data:Banned()
            return player:Data():Get('Banned') ~= nil
        end

        function data:Whitelisted()
            return player:Data():Get('Whitelisted') or false
        end

        return data
    end

    function player:Get()
        local data = {}

        --- Get ban reason
        function data:Ban()
            return player:Data():Get('Banned') or false
        end

        --- Get the user id
        function data:ID()
            return id
        end

        --- Get the user steam
        function data:Steam()
            return steam
        end

        function data:Source()
            return (Player:Raw(steam) or {}).source
        end

        return data
    end

    --- This will dump user data to the database, only do this if you need to.
    function player:Dump()
        return Player:Dump(steam, self:Data():Raw())
    end

    return player
end

--- TODO (Make so if you are rejected you will be removed from lists, etc)
AddEventHandler('Spark:Connect', function(steam, def)
    assert(source == "", "A user tried using the connect event from the client.")

    local player = Player:Get('steam', steam)
    if player:Is():Banned() then
        return def.done("You are banned for: ".. (player:Get():Ban() or 'No reason set'))
    end

    Wait(0)
    def.done()
end)

AddEventHandler('Spark:Spawned', function(_)
    local source = source
    if _ and source == "" then
        source = _
    end

    local player = Player:Get('source', source)

    assert(player:Is():Online(), "Player what spawned is not online?")
    assert(player:Get():Source() == nil, "User spawned but is dead or already spawned")

    print("Player spawned, now updating source")
    Player.Players[player:Get():Steam()].source = source
end)

RegisterCommand('banme', function(source, args)
    local player = Player:Get('source', source)
    player:Ban(args[1] or 'No reason')
end)

CreateThread(function()
    Wait(2000)
    local player = Player:Get('id', 1)
    print(player:Get():Source())
end)