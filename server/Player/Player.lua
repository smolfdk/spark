-- Player controller and handler for Spark.
-- Made and maintained by frackz

local Player = Spark:Config():Get('Player')

--- Get the player module
function Spark:Player()
    return Player
end

--- Register the user when they are joining
AddEventHandler('playerConnecting', function(_, __, def)
    local source = (type(_) == "number" and source == "") and _ or source
    local steam = Spark:Source():Steam(source)

    def.defer()
    Wait(0)

    -- Check if steam identifier is valid
    if not steam then
        return def.done('Whoops, remember to open steam ;)')
    end

    def.update("Checking your data...")
    local data = Player:Auth(steam) -- Authenticate the player by steam

    -- This will check if the returned data is valid
    if not (data or {}).id then
        return def.done("Error while returning your data, please report this."), error("Error while authenticating user")
    end

    Wait(0)
    def.update("You are now logged in as ID: "..data.id) -- Report to the user that they are now logged in
    print("User logged in with steam "..steam..", id "..data.id.." and with data: "..data.data)

    TriggerEvent('Spark:Connect', steam, def)
end)

--- Register when a user left, this will save their data
AddEventHandler('playerDropped', function(reason)
    local source = (type(reason) == "number" and source == "") and reason or source
    local steam = Spark:Source():Steam(source)

    -- Check if the user has a steam identifier (if this happens, a big bug have happend)
    assert(steam, "A user dropped, but no steam identifier is found. Please report this.")

    local data = Player:Raw(steam)

    -- This will check if the user is registered
    assert(data, "User dropped without being registered, please report this.")

    -- Get the user data that should be saved, to check after things
    TriggerEvent('Spark:Dropped', steam)

    -- Informs us that the user is left, and is getting saved
    print("User dropped with ID "..data.id.." steam "..steam.." and reason "..reason)
    print("The saved data is: "..json.encode(data.data))

    Player:Dump(steam, data.data) -- This will dump their data into the database.
    Player.Players[steam] = nil -- This will remove them for the players list
end)

--- Authenticate a user by steam
function Player:Auth(steam)
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

--- Dump user data into the database, and will remove them from the saved players table.
function Player:Dump(steam, data)
    assert(data, "User is nil while trying to dump it? Please report this.")

    -- Update user data to the database
    Spark:Database():Execute('UPDATE users SET data = ? WHERE steam = ?', json.encode(data), steam)
end

--- Get user data by steam
function Player:Data(steam)
    local data = self:Pull('steam', steam)
    if not data then
        return false
    end

    return json.decode(data.data or {})
end

--- Get player data from database.
function Player:Pull(qoute, steam)
    return Spark:Database():First('SELECT * FROM users WHERE '..qoute..' = ?', steam)
end

--- Check if a user is registered
function Player:Exist(steam)
    return self:Pull('steam', steam) ~= nil
end

--- Get the raw data of a user, this will contain the player table
function Player:Raw(steam)
    return self.Players[steam]
end

--- Convert ID to steam
function Player:Convert(id)
    for k,v in pairs(self.Players) do
        if v.id == id or tonumber(v.id) == id then
            return k
        end
    end
end

--- This will load all users again. Only use this if player table is empty
function Player:All()
    for _, source in pairs(GetPlayers()) do -- Loop all users
        local data = Player:Auth(Spark:Source():Steam(source)) -- Authenticate them
        Wait(500)
        TriggerEvent('Spark:Spawned', source) -- Run the spawned event, so it will "load" the user

        print("Reloaded user "..(data or {}).id)
    end
end

--- This will load all online users, when Spark gets restarted. This is more for development
CreateThread(function()
    Player:All()
end)

--- This is currently just for testing playerConnecting and playerDropped events.
CreateThread(function ()
    TriggerEvent('playerConnecting', 0, nil, {
        defer = function() end,
        update = function() end,
        done = function(text)
            print("[Done] "..(text or ''))
        end
    })

    Wait(100)
    TriggerEvent('Spark:Spawned', 0)
end)

RegisterCommand('drop', function()
    TriggerEvent('playerDropped', 0)
end)