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

        function data:Extend(data)
            if not player:Is():Online() then -- If the user is online, we use database.
                local user = Player:Data(steam)
                assert(user, "User does not exist?")
                assert(type(user) == "table", "Saved data is not a table?")

                for k,v in pairs(data) do user[k] = v end
                return true, player:Dump(user)
            end

            for k,v in pairs(data) do self:Raw()[k] = v end
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
        local module = {}

        --- Check if the user is online
        function module:Online() return player:Data():Raw() ~= nil end

        --- Check if the user is banned
        function module:Banned() return player:Data():Get('Banned') ~= nil end

        --- Check if the user is whitelisted
        function module:Whitelisted() return player:Data():Get('Whitelisted') or false end

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

    --- Get the cash module
    function player:Cash()
        local module = {}

        --- Set the cash for the player
        function module:Set(amount)
            return player:Data():Set('Cash', amount)
        end

        --- Get the cash of the player
        function module:Get()
            return player:Data():Get('Cash')
        end

        --- Check if the player has a amount of cash
        function module:Has(amount)
            return self:Get() >= amount
        end

        --- Add a amount of cash to the player
        function module:Add(amount)
            if amount < 0 then
                return false, "amount_is_under_0"
            end

            return true, self:Set(self:Get() + amount)
        end

        --- Remove a amount of cash from the player
        function module:Remove(amount)
            if amount < 0 then
                return false, "amount_is_under_0"
            end

            if not self:Has(amount) then
                return false, "does_not_have_enough_cash"
            end

            return true, self:Set(self:Get() - amount)
        end

        return module
    end

    --- Get the health module
    function player:Health()
        local module = {}

        --- Set the health of the player
        function module:Set(health)
            SetEntityHealth(player:Get():Ped(), health)
        end

        --- Get the health of the player
        function module:Get()
            return GetEntityHealth(player:Get():Ped())
        end

        --- Add a amount of health to the user
        function module:Add(amount)
            if amount < 0 then
                return false, "amount_is_under_0"
            end

            return true, self:Set(self:Get() + amount)
        end

        --- Remove a amount of health from the user
        function module:Remove(amount)
            if amount < 0 then
                return false, "amount_is_under_0"
            end

            if self:Get() - amount < 0 then
                return false, "invalid_health"
            end

            return self:Set(self:Get() - amount)
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

    TriggerEvent('Spark:Ready', player:Get():Steam())

    -- Set to last position
    local position = player:Data():Get('Coords')
    if position then
        player:Position():Set(position.x, position.y, position.z)
    end
end)

RegisterNetEvent('Spark:Dropped', function(steam)
    assert(source == "", "A user tried using the dropped event from the client.")

    local player = Player:Get('steam', steam)
    local x, y, z = player:Position():Get()

    player:Data():Extend({
        Coords = { x = x, y = y, z = z }
    })
end)

-- A debug command for banning
RegisterCommand('ban', function(_, args)
    local player = Player:Get('id', args[1])
end)

-- Run the dropped command, this is for debugging
RegisterCommand('drop', function(source)
    TriggerEvent('playerDropped', source)
end)