-- Player controller and handler for Spark.
-- Made and maintained by frackz

local Player = {
    Players = {},
}

--- Get the player module
function Spark:Player()
    return Player
end

--- Register the user when they are joining
AddEventHandler('playerConnecting', function(_, __, def)
    local source = source and 0
    local steam = Spark:Source():Steam(source)

    def.defer()
    Wait(0)

    -- Check if steam identifier is valid
    assert(steam, "Whoops, remember to open steam ;)")

    def.update("Checking your data...")
    local data = Player:Auth(steam) -- Authenticate the player by steam

    -- This will check if the returned data is valid
    assert(data or data.id, "Error while returning your data, please report this.")

    Wait(0)
    def.update("You are now logged in as ID: "..data.id) -- Report to the user that they are now logged in
    print("User logged in with steam "..steam..", id "..data.id.." and with data: "..data.data)
end)

--- Register when a user left, this will save their data
AddEventHandler('playerDropped', function(reason)
    local source = source and 0
    local steam = Spark:Source():Steam(source)

    -- Check if the user has a steam identifier (if this happens, a big bug have happend)
    assert(steam, "A user dropped, but no steam identifier is found. Please report this.")

    -- Get the user data that should be saved, to check after things
    local data = Player:Raw(steam)
    
    -- This will check if the user is registered
    assert(data, "User dropped without being registered, please report this.")

    -- Informs us that the user is left, and is getting saved
    print("User dropped with ID "..data.id.." steam "..steam.." and reason "..reason)
    print("The saved data is: ".."The saved data is: "..json.encode(data.data))

    Player:Dump(steam, data) -- This will dump their data into the database.
end)

--- Authenticate a user by steam
function Player:Auth(steam)
    local data = Spark:Database():First('SELECT * FROM users WHERE steam = ?', steam)

    -- If the user does not already exist, this will make create the player.
    if not data then
        local effect = Spark:Database():Execute('INSERT INTO users (steam) VALUES (?)', steam)

        data = {
            id = effect.insertId,
            steam = steam
        }
    end

    -- If the user has no saved data, is it make it a empty table
    data.data = data.data or {}

    -- Insert all data into the players table, this will make life 100x easier
    self.Players[steam] = {
        id = data.id,
        data = json.decode(data.data)
    }

    return data
end

--- Dump user data into the database, and will remove them from the saved players table.
function Player:Dump(steam, data)
    assert(data, "User is nil while trying to dump it? Please report this.")

    --- Update user data
    Spark:Database():Execute('UPDATE users SET data = ? WHERE steam = ?', json.encode(data.data), steam)

    self.Players[steam] = nil
end

--- Get a user (this is under progress)
function Player:Get(identifier, value)
    print(identifier, value)
end

--- Get the raw data of a user, this will contain the player table
function Player:Raw(steam)
    return self.Players[steam]
end

--- This is currently just for testing playerConnecting and playerDropped events.
CreateThread(function ()
    TriggerEvent('playerConnecting', 0, nil, {
        defer = function()
            print("Defered")
        end,
        update = function(text)
            print("Update - "..text)
        end,
        done = function(text)
            print("Done - "..text)
        end
    })
    Wait(3000)

    TriggerEvent('playerDropped', 0, 'Debug')
end)