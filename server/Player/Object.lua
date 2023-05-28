-- Player object controller for Spark.
-- Made and maintained by frackz

local Player = Spark:Player()
local Identifiers, Config = {
    steam = true,
    source = true,
    id = true
}, Spark:Config():Get('Server')

function Player:Get(identifier, value)
    assert(Identifiers[identifier], "Identifier "..value or 'Invalid'.." does not exist.")

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
                self:Extend({
                    key = value
                })
            end

            (self:Raw() or {})[key] = value
        end

        function data:Extend(data)
            if not player:Is():Online() then -- If the user is online, we use database.
                local user = Player:Data(steam)
                assert(user, "User does not exist?")
                assert(type(user) == "table", "Saved data is not a table?")

                for k,v in pairs(data) do
                    user[k] = v
                end

                return true, player:Dump(user)
            end

            for k,v in pairs(data) do
                self:Raw()[k] = v
            end
        end

        return data
    end

    --- Kick the player from the server
    function player:Kick(reason)
        reason = reason or 'No reason set.'

        -- Checks if the user is online, and the source has been set, and if the account is a debug
        assert(player:Is():Online(), "Trying to kick offline user!")
        assert(player:Get():Source(), "Source is not set, and therefor cannot kick player")
        assert(player:Is():Debug(), "Cannot kick a debug account")

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

    --- Get the is module
    function player:Is()
        local module = {}

        --- Check if the user is online
        function module:Online() return player:Data():Raw() ~= nil end

        --- Check if the user is banned
        function module:Banned() return player:Data():Get('Banned') ~= nil end

        --- Check if the user is whitelisted
        function module:Whitelisted() return player:Data():Get('Whitelisted') or false end

        --- Check if the user is a debug account
        function module:Debug() return player:Get():Source() == 0 or player:Get():Source() == "" end

        --- Check if the user is currently loaded in (has a source)
        function module:Loaded() return player:Get():Source() ~= nil end

        return module
    end

    --- Get the "get" module. This is for things like ban-reason, id, steam, etc.
    function player:Get()
        local module = {}

        --- Get the user's ban reason, will return false if not banned.
        function module:Ban() return player:Data():Get('Banned') or false end

        --- Get the user's id, this can be accessed immediately
        function module:ID() return id end

        --- Get the user's steam, this can be accessed immediately
        function module:Steam() return steam end

        --- Get the user's source, this can only be accessed after the player has spawned for the first time.
        function module:Source() return (Player:Raw(steam) or {}).source end

        --- Get the user's ped, this can only be accessed after the player has spawned for the first time.
        function module:Ped() return GetPlayerPed(self:Source() or 0) end

        return module
    end

    --- This will dump user data to the database, only do this if you need to.
    function player:Dump(data)
        return Player:Dump(steam, self:Data():Raw() or data)
    end

    --- Get the position module
    function player:Position()
        local module = {}

        --- Set the position of the player
        function module:Set(x, y, z)
            SetEntityCoords(player:Get():Ped(), x, y, z, false, false, false, false)
        end

        --- Get the position of the player
        function module:Get()
            local pos = GetEntityCoords(player:Get():Ped())
            return pos.x, pos.y, pos.z
        end

        return module
    end

    --- Remove the user from the players list
    function player:Exile()
        Player.Players[self:Get():Steam()] = nil
    end

    --- Get the client module
    function player:Client()
        local module = {}

        --- Call a client event
        function module:Event(name, ...)
            assert(player:Is():Loaded() or player:Is():Debug(), "Cannot call a event on a non-loaded or debugged user")            

            return TriggerClientEvent(name, player:Get():Source(), ...)
        end

        --- todo
        function module:Callback(name, ...)
            assert(player:Is():Loaded() or player:Is():Debug(), "Cannot call a callback on a non-loaded or debugged user")
        end

        return module
    end

    return player
end

--- Connect event, this is after the user has been authenticated, so checks needs to be done
--- TODO (Make so if you are rejected you will be removed from lists, etc)
RegisterNetEvent('Spark:Connect', function(steam, def)
    assert(source == "", "A user tried using the connect event from the client.")

    local player = Player:Get('steam', steam)
    if player:Is():Banned() then -- Check if the user is banned
        return def.done("You are banned for: ".. (player:Get():Ban() or 'No reason set')), player:Exile()
    end

    if Config.Whitelist and not player:Is():Whitelisted() then
        return def.done("You are not currently whitelisted"), player:Exile()
    end

    def.done() -- And after all th(ose/e) checks, we can finally move on.
end)

--- When the player has spawned, this is important for getting their source.
RegisterNetEvent('Spark:Spawned', function(_)
    local source = (type(_) == "number" and source == "") and _ or source
    local player = Player:Get('source', source)

    -- Check if the player is unreachable
    assert(player, "The user that spawned is currently unreachable")

    -- Makes sure that the user is online, and does not alread have a source. (needs changing)
    assert(player:Is():Online(), "Player what spawned is not online?")
    assert(player:Get():Source() == nil, "User spawned but is dead or already spawned")

    print("Player spawned, now updating source")
    Player.Players[player:Get():Steam()].source = source -- Sets the source (needs changing prob)

    -- Inform all that the user is ready to be edited ;)
    TriggerEvent('Spark:Ready', player:Get():Steam())

    -- Check if it is a debug account, and therefor has no ped to update.
    if player:Is():Debug() then
        return print("Debug account spawned")
    end

    -- Set to last position
    local position = player:Data():Get('Coords')
    if position then
        player:Position():Set(position.x, position.y, position.z)
    end
end)

--- When the user drop, it will dump their "meta" data, like coords, weapons, etc.
RegisterNetEvent('Spark:Dropped', function(steam)
    assert(source == "", "A user tried using the dropped event from the client.")

    local player = Player:Get('steam', steam)

    -- Check if it is a debug account, and therefor has no ped data to extract.
    if player:Is():Debug() or not player:Is():Loaded() then
        return print("Dropped player is a debugging account - or is not loaded.")
    end

    local x, y, z = player:Position():Get() -- Get the coordinates

    player:Data():Extend({ -- Edit the data table
        Coords = { x = x, y = y, z = z }
    })
end)

CreateThread(function()
    Wait(1000)
    local player = Player:Get('source', 0)
end)