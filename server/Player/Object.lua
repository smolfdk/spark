-- Player object controller for Spark.
-- Made and maintained by frackz

local Players = Spark:Players()
local Identifiers, Config = {
    steam = true,
    source = true,
    id = true
}, Spark:Config():Get('Server')

--- Get a player by source, id or steam
function Players:Get(identifier, value)
    assert(Identifiers[identifier], "Identifier "..(value or 'Invalid').." does not exist.")

    local steam, id = value, nil
    if identifier == "id" then
        steam, id = self:Convert(value), value
    elseif identifier == "source" then
        steam = Spark:Source():Steam(value)
    end

    id = id or Players:Raw(steam).id
    if not Players:Raw(steam) then -- Check if the user is not offline
        if identifier == "source" then -- If the user is not offline, and its using source we know that the user is not saved.
            return false, "user_does_not_exist"
        end

        local data = Players:Pull(identifier, value)
        if not data then -- Check if the user cannot be found in the database.
            return false, "user_cannot_be_found"
        end

        id, steam = data.id, data.steam -- Update the id and steam to the database information.
    end

    local player = {
        Nil = {}
    }

    --- Get the player data module.
    function player:Data()
        local module = {}

        --- Get the whole data table
        --- @return table | nil
        function module:Raw()
            return (Players:Raw(steam) or {})['data']
        end

        --- Get a key from the data table
        --- @param key string
        function module:Get(key)
            if not player:Is():Online() then -- If the user is online, we use database.
                local user = Players:Data(steam)
                assert(user, "User does not exist?")

                return user[key]
            end

            return (self:Raw() or {})[key]
        end

        --- Set a key inside the data table, this is used for storing data easily.
        --- @param key string
        --- @param value any
        function module:Set(key, value)
            if value == nil then
                value = player:Null()
            end

            return self:Extend({
                [key] = value
            })
        end

        --- Extend the data set
        --- @param data table
        function module:Extend(data)
            if not player:Is():Online() then -- If the user is online, we use database.
                local user = Players:Data(steam) -- Pull data from database
                assert(user, "User does not exist?")
                assert(type(user) == "table", "Saved data is not a table?")

                for k,v in pairs(data) do
                    v = (v ~= player:Null()) and v or nil
                    user[k] = v
                end

                return true, player:Dump(user) -- Dump data to database
            end

            for k,v in pairs(data) do
                v = (v ~= player:Null()) and v or nil
                self:Raw()[k] = v
            end
        end

        return module
    end

    --- Kick the player from the server
    --- @param reason string
    function player:Kick(reason)
        reason = reason or 'No reason set.'

        -- Checks if the user is online, and the source has been set, and if the account is a debug
        assert(player:Is():Online(), "Trying to kick offline user!")
        assert(player:Get():Source(), "Source is not set, and therefor cannot kick player")
        assert(not player:Is():Debug(), "Cannot kick a debug account")

        DropPlayer(player:Get():Source(), reason)
    end

    --- Get the set module
    function player:Set()
        local module = {}

        --- Set the position of the player
        --- @param x number
        --- @param y number
        --- @param z number
        function module:Position(x, y, z)
            assert(x and y and z,
                "Position arguments not set"
            )
            return SetEntityCoords(player:Get():Ped(), x, y, z, false, false, false, false)
        end

        --- Set the health of the player
        --- @param amount number
        function module:Health(amount)
            assert(amount,
                "Cannot set health to nil"
            )
            return player:Client():Event('Spark:Client:SetHealth', amount)
        end

        --- Set if the user is banned
        --- @param value boolean
        --- @param reason string | nil
        function module:Banned(value, reason)
            if not value then
                return false, player:Data():Set('Banned', nil)
            end

            player:Data():Set('Banned', reason)
            if player:Is():Online() then
                player:Kick('[Banned] '..reason)
            end

            return true
        end

        --- Set if the user is whitelisted
        --- @param value boolean
        function module:Whitelisted(value)
            return player:Data():Set('Whitelisted', value)
        end

        return module
    end

    --- Get the is module
    function player:Is()
        local module = {}

        --- Check if the user is online
        --- @return boolean
        function module:Online() return player:Data():Raw() ~= nil end

        --- Check if the user is banned
        --- @return boolean
        function module:Banned() return player:Data():Get('Banned') ~= nil end

        --- Check if the user is whitelisted
        --- @return boolean
        function module:Whitelisted() return player:Data():Get('Whitelisted') or false end

        --- Check if the user is a debug account
        --- @return boolean
        function module:Debug() return player:Get():Source() == 0 or player:Get():Source() == "" end

        --- Check if the user is currently loaded in (has a source)
        --- @return boolean
        function module:Loaded() return player:Get():Source() ~= nil end

        return module
    end

    --- Get the "get" module. This is for things like ban-reason, id, steam, etc.
    function player:Get()
        local module = {}

        --- Get the user's ban reason, will return false if not banned.
        --- @return string | boolean
        function module:Ban() return player:Data():Get('Banned') or false end

        --- Get the user's id, this can be accessed immediately
        function module:ID() return id end

        --- Get the user's steam, this can be accessed immediately
        function module:Steam() return steam end

        --- Get the user's source, this can only be accessed after the player has spawned
        --- @return string
        function module:Source() return (Players:Raw(steam) or {}).source end

        --- Get the user's ped, this can only be accessed after the player has spawned
        --- @return number
        function module:Ped() return GetPlayerPed(self:Source() or 0) end

        --- Get the user's health, this can only be accessed after the player has spawned
        --- @return number
        function module:Health() return GetEntityHealth(self:Ped()) end

        --- Get the position of the player - only after ped is set
        --- @return vector3
        function module:Position() return GetEntityCoords(self:Ped()) end

        --- Get the distance between the player and a set of coords
        --- @param coords vector3
        --- @return number
        function module:Distance(coords) return #(self:Position() - coords) end

        --- Get the player's heading
        --- @return number
        function module:Heading() return GetEntityHeading(self:Ped()) end

        return module
    end

    --- Get the cash module
    function player:Cash()
        local module = {}

        --- Get the amount of cash the user has
        --- @return number
        function Cash:Get()
            return player:Data():Get('Cash') or 0
        end

        --- Set the amount of cash the user has
        --- @param amount number
        --- @return boolean
        function Cash:Set(amount)
            assert(type(amount) == "number", "Cannot set cash to a non-number")
            return player:Data():Set('Cash', amount)
        end

        --- Add a amount to the user's cash
        --- @param amount number
        --- @return boolean
        function Cash:Add(amount)
            assert(type(amount) == "number", "Cannot add cash to a non-number")
            return self:Set(self:Get() + amount)
        end

        --- Remove a amount of cash from the user
        --- @param amount number
        --- @return boolean
        function Cash:Remove(amount)
            assert(type(amount) == "number", "Cannot remove cash from a non-number")
            return self:Set(self:Get() - amount)
        end
        
        --- Check if the user has a amount of cash
        --- @param amount number
        --- @return boolean
        function Cash:Has(amount)
            assert(type(amount) == "number", "Cannot check if user has a non-number of cash")
            return self:Get() >= amount
        end

        --- Make a payment, will return true if it went trought, and falso not.
        --- @param amount number
        --- @return boolean
        function Cash:Payment(amount)
            return self:Has(amount) and self:Remove(amount) or false
        end

        return module
    end

    --- This will dump user data to the database, only do this if you need to.
    --- @param data table | nil
    function player:Dump(data)
        return Players:Dump(steam, (data or self:Data():Raw()) or {})
    end

    --- Remove the user from the players list
    function player:Exile()
        Players.Players[self:Get():Steam()] = nil
    end

    --- Use this instead of "nil" in your tables, if you use :Data():Extend()
    --- @return table
    function player:Null()
        return self.Nil
    end

    --- Get the client module
    function player:Client()
        local module = {}

        --- Call a client event
        --- @param name string
        function module:Event(name, ...)
            assert(player:Is():Loaded() or player:Is():Debug(), "Cannot call a event on a non-loaded or debugged user")            
            return TriggerClientEvent(name, player:Get():Source(), ...)
        end

        --- Call a callback, and hopefully get a response...
        --- @param name string
        function module:Callback(name, cb, ...)
            assert(player:Is():Loaded() or player:Is():Debug(), "Cannot call a callback on a non-loaded or debugged user")
            
        end

        return module
    end

    return player
end

--- Connect event, this is after the user has been authenticated, so checks needs to be done
RegisterNetEvent('Spark:Connect', function(steam, def)
    assert(source == "", "A user tried using the connect event from the client.")

    local player = Players:Get('steam', steam)
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
    local source = (source == "") and _ or source
    local player = Players:Get('source', source)

    -- Check if the player is unreachable
    assert(player, "The user that spawned is currently unreachable")

    -- Makes sure that the user is online, and does not alread have a source. (needs changing)
    assert(player:Is():Online(), "Player what spawned is not online?")
    assert(player:Get():Source() == nil, "User spawned but is dead or already spawned")

    Spark:Debug():Print('📝',
        "User spawned! ID '"..player:Get():ID().."', Steam '"..player:Get():Steam().."', Source '"..source.."'"
    )
    Players.Players[player:Get():Steam()].source = source -- Sets the source (needs changing prob)

    -- Inform all that the user is ready to be edited ;)
    TriggerEvent('Spark:Ready', player:Get():Steam())

    -- Check if it is a debug account, and therefor has no ped to update.
    if player:Is():Debug() then
        return
    end

    -- Update player information / like position, and health.
    local position = player:Data():Get('Coords')
    local health = player:Data():Get('Health')
    if position then
        player:Set():Position(position.x, position.y, position.z)
    end

    if health then
        player:Set():Health(health)
    end
end)

--- When the user drop, it will dump their "meta" data, like coords, weapons, etc.
RegisterNetEvent('Spark:Dropped', function(steam)
    assert(source == "", "A user tried using the dropped event from the client.")

    local player = Players:Get('steam', steam)

    -- Check if it is a debug account, and therefor has no ped data to extract.
    if player:Is():Debug() or not player:Is():Loaded() then
        return
    end

    player:Data():Extend({ -- Edit the data table
        Coords = player:Get():Position() or player:Null(),
        Health = player:Get():Health() or player:Null()
    })
end)