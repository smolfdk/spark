-- Player controller and handler for Spark.
-- Made and maintained by frackz

local Player = {
    Players = {},
}

--- Get the player module
function Spark:Player()
    return Player
end

AddEventHandler('playerConnecting', function(_, __, def)
    local source = source
    if _ == 0 then source = 0 end -- This is just used for debugging

    local steam = Spark:Source():Steam(source)

    def.defer()
    Wait(0)

    if not steam then -- Check if steam identifier is valid
        return def.done("Whoops, remember to open steam ;)")
    end

    local data = Player:Auth(steam) -- Authenticate the player by steam

    Wait(0)
    def.update("Checking your data...")

    if not data or not data then -- This will check if the returned data is valid
        Wait(0)
        return def.done("Error while returning your data, please report this.")
    end

    Wait(0)
    def.update("You are now logged in as ID: "..data.id) -- Report to the user that they are now logged in
end)

function Player:Auth(steam)
    local data = Spark:Database():First('SELECT * FROM users WHERE steam = ?', steam)

    if not data then
        local effect = Spark:Database():Execute('INSERT INTO users (steam) VALUES (?)', steam)

        data = {
            id = effect.insertId,
            steam = steam
        }
    end

    data['data'] = data['data'] or {}

    return data
end

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
