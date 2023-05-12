-- Player controller and handler for Spark.
-- Made and maintained by frackz

local Player = {
    Players = {},
}

--- Get the player module
function Spark:Player()
    return Player
end

AddEventHandler('playerConnecting', function(_, _, def)
    local source = source
    local steam = GetPlayerIdentifier(source, 'steam')
    def.defer()

    Wait(0)

    if not steam then
        return def.done("Whoops, remember to open steam ;)")
    end

    def.update("You are currently getting checked, please wait...")

    -- Authenticate the player by steam
    local data = Player:Auth(steam)

    Wait(0)
    def.update("Checking your data...")


end)

function Player:Auth(steam)
    local data = Spark:Database():First('SELECT * FROM users WHERE steam = ?', steam)

    if not data then
        local effect = Spark:Database():Execute('INSERT INTO users (steam) VALUES (?)', steam)

        data = {
            id = effect.insertId,
            steam = steam,
            data = {}
        }
    end

    return data
end