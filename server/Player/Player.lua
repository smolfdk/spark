-- Player controller and handler for Spark.
-- Made and maintained by frackz

local Players = Spark:Config():Get('Players')

--- Get the player module
function Spark:Players()
    return Players
end

--- Register the user when they are joining
AddEventHandler('playerConnecting', function(_, __, def)
    local source = (source == "") and _ or source
    local steam = Spark:Source():Steam(source)

    def.defer()
    Wait(0)

    -- Check if steam identifier is valid
    if not steam then
        return def.done('Whoops, remember to open steam ;)')
    end

    def.update("Checking your data...")
    local data = Players:Auth(steam) -- Authenticate the player by steam

    -- This will check if the returned data is valid
    if not (data or {}).id then
        return def.done("Error while returning your data, please report this."), error("Error while authenticating user")
    end

    Wait(0)
    def.update("You are now logged in as ID: "..data.id) -- Report to the user that they are now logged in
    Spark:Debug():Print('👨',
        "User joined! ID '"..data.id.."', Steam '"..steam.."'"
    )

    TriggerEvent('Spark:Connect', steam, def)
end)

--- Register when a user left, this will save their data
AddEventHandler('playerDropped', function(reason)
    local source = (source == "") and reason or source
    local steam = Spark:Source():Steam(source)

    -- Check if the user has a steam identifier (if this happens, a big bug have happend)
    assert(steam, "A user dropped, but no steam identifier is found. Please report this.")

    local data = Players:Raw(steam)

    -- This will check if the user is registered
    assert(data, "User dropped without being registered, please report this.")

    -- Get the user data that should be saved, to check after things
    TriggerEvent('Spark:Dropped', steam)

    -- Informs us that the user is left, and is getting saved
    Spark:Debug():Print('🚪',
        "User left! ID '"..data.id.."', Steam: '"..steam.."', Source '"..data.source.."'"
    )

    Players:Dump(steam, data.data) -- This will dump their data into the database.
    Players.Players[steam] = nil -- This will remove them for the players list
end)

--- Authenticate a user by steam
--- @param steam string
--- @return table
function Players:Auth(steam)
    local data = self:Pull('steam', steam)

    -- If the user does not already exist, this will make create the player.
    if not data then
        local effect = Spark:Database():Execute('INSERT INTO users (steam) VALUES (?)', steam)

        data = {
            id = effect.insertId,
            steam = steam
        }
    end

    -- If the user has no saved data, it will use the default data
    data.data = data.data or json.encode(self.Default)

    -- Insert all data into the players table, this will make life 100x easier
    self.Players[steam] = {
        id = tostring(data.id),
        data = json.decode(data.data)
    }

    return data
end

--- Dump user data into the database
--- @param steam string
--- @param data table
function Players:Dump(steam, data)
    assert(data, "User is nil while trying to dump it? Please report this.")

    -- Update user data to the database
    Spark:Database():Execute('UPDATE users SET data = ? WHERE steam = ?', json.encode(data), steam)
end

--- Get user data by steam from the database
--- @param steam string
--- @return table | boolean
function Players:Data(steam)
    local data = self:Pull('steam', steam)
    return not data and false or json.decode(data.data or "{}")
end

--- Get player data from database.
--- @param qoute string
--- @param steam string
--- @return table
function Players:Pull(qoute, steam)
    return Spark:Database():First('SELECT * FROM users WHERE '..qoute..' = ?', steam)
end

--- Check if a user is registered
--- @param steam string
--- @return boolean
function Players:Exist(steam)
    return self:Pull('steam', steam) ~= nil
end

--- Get the raw data of a user, this will contain the player table
--- @param steam string
--- @return table
function Players:Raw(steam)
    return self.Players[steam]
end

--- Convert ID to steam
--- @param id number | string
--- @return number | string
function Players:Convert(id)
    for k,v in pairs(self.Players) do
        if v.id == id or tonumber(v.id) == id then
            return k
        end
    end

    return 0
end

--- Dump your user data
RegisterCommand('dump', function(source)
    TriggerEvent('Spark:Dropped', Spark:Source():Steam(source))
    Spark:Players():Get('source', source):Dump()
end, false)

--- This will load all users again.
function Players:All()
    Players.Players = {}
    for _, source in pairs(GetPlayers()) do -- Loop all users
        Players:Auth(Spark:Source():Steam(source))
        Wait(500)
        return TriggerEvent('Spark:Spawned', source)
    end
end

--- This will load all online users, when Spark gets restarted. This is more for development
CreateThread(function()
    Players:All()
end)