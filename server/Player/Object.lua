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

    if not Player:Raw(steam) then -- Check if the user is not offline
        if identifier == "source" then -- If the user is not offline, and its using source we know that the user is not saved.
            return false, "user_does_not_exist"
        end

        local data = Player:Pull(identifier, value)
        if not data then -- Check if the user cannot be found in the database.
            return false, "user_cannot_be_found"
        end

        id, steam = data.id, data.steam -- Update the id and steam to the database information.
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
            if not player:Is():Online() then -- If the user is online, we use database.
                local user = Player:Data(steam)
                assert(user, "User does not exist?")

                return user[key]
            end

            return (self:Raw() or {})[key]
        end

        --- Set a key inside the data table, this is used for storing data easily.
        function data:Set(key, value)
            if not player:Is():Online() then -- If the user is online, we use database.
                local user = Player:Data(steam)
                assert(user, "User does not exist?")
                assert(type(user) == "table", "Saved data is not a table?")

                user[key] = value
                return true, player:Dump(user)
            end

            (self:Raw() or {})[key] = value
        end

        return data
    end

    --- Kick the player from the server
    function player:Kick(reason)
        reason = reason or 'No reason set.'

        -- Checks if the user is online, and the source has been set.
        assert(player:Is():Online(), "Trying to kick offline user!")
        assert(player:Get():Source(), "Source is not set, and therefor cannot kick player")

        DropPlayer(player:Get():Source(), reason)
    end

    --- Ban the user from the server
    function player:Ban(reason)
        reason = reason or 'No reason set.' -- If no reason is it set, use default one.

        if self:Is():Banned() then -- If user is already banned, unban them (this will be changed)
            return false, self:Data():Set('Banned', nil)
        end

        self:Data():Set('Banned', reason) -- Set the banned key to the reason
        
        if self:Is():Online() then -- If they are online, kick them.
            self:Kick('[Banned] '..reason)
        end

        return true
    end

    --- Get the is module, this is for checking statements.
    function player:Is()
        local data = {}

        --- Check if the user is online
        function data:Online() return player:Data():Raw() ~= nil end

        --- Check if the user is banned
        function data:Banned() return player:Data():Get('Banned') ~= nil end

        --- Check if the user is whitelisted
        function data:Whitelisted() return player:Data():Get('Whitelisted') or false end

        return data
    end

    --- Get the "get" module. This is for things like ban-reason, id, steam, etc.
    function player:Get()
        local data = {}

        --- Get the user's ban reason, will return false if not banned.
        function data:Ban() return player:Data():Get('Banned') or false end

        --- Get the user's id, this can be accessed immediately
        function data:ID() return id end

        --- Get the user's steam, this can be accessed immediately
        function data:Steam() return steam end

        --- Get the user's source, this can only be accessed after the player has spawned for the first time.
        function data:Source() return (Player:Raw(steam) or {}).source end

        return data
    end

    --- This will dump user data to the database, only do this if you need to.
    function player:Dump(data)
        return Player:Dump(steam, self:Data():Raw() or data)
    end

    return player
end

--- Connect event, this is after the user has been authenticated, so checks needs to be done
--- TODO (Make so if you are rejected you will be removed from lists, etc)
RegisterNetEvent('Spark:Connect', function(steam, def)
    assert(source == "", "A user tried using the connect event from the client.")

    local player = Player:Get('steam', steam)
    if player:Is():Banned() then -- Check if the user is banned
        return def.done("You are banned for: ".. (player:Get():Ban() or 'No reason set'))
    end

    def.done() -- And after all th(ose/e) checks, we can finally move on.
end)

--- When the player has spawned, this is important for getting their source.
RegisterNetEvent('Spark:Spawned', function(_)
    local source = source
    if _ and source == "" then -- Check if the source is "artificially" put in. 
        source = _
    end

    local player = Player:Get('source', source)

    -- Makes sure that the user is online, and does not alread have a source. (needs changing)
    assert(player:Is():Online(), "Player what spawned is not online?")
    assert(player:Get():Source() == nil, "User spawned but is dead or already spawned")

    print("Player spawned, now updating source")
    Player.Players[player:Get():Steam()].source = source -- Sets the source (needs changing prob)
end)

-- A debug command for banning
RegisterCommand('ban', function(_, args)
    local player = Player:Get('id', args[1])
    player:Ban(args[2] or 'No reason')
    print("BAN")
end)