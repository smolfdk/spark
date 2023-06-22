-- Player controller for Spark.
-- Made and maintained by frackz

local Player = {}

--- Get the HTTP module
function Spark:Player()
    return Player
end

--- Get the get module
function Player:Get()
    local module = {}

    --- Get the player ped
    --- @return number
    function module:Ped()
        return PlayerPedId()
    end

    --- Get the vehicle the player is currently in
    --- @return number | nil
    function module:Vehicle()
        return GetVehiclePedIsIn(self:Ped(), false)
    end

    --- Get the players's armor
    --- @return number
    function module:Armor()
        return GetPedArmour(self:Ped())
    end

    --- Get the player's health
    --- @return number
    function module:Health()
        return GetEntityHealth(self:Ped())
    end

    --- Get the player's position
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

--- Get the set module
function Player:Set()
    local module = {}

    --- Set the player's armor
    --- @param amount number
    function module:Armor(amount)
        assert(health,
            "Trying to set player's armor to nil"
        )
        return SetPedArmour(Player:Get():Ped(), amount)
    end

    --- Set the player's health
    --- @param amount number
    function module:Health(amount)
        assert(health,
            "Trying to set player's health to nil"
        )
        return SetEntityHealth(Player:Get():Ped(), amount)
    end

    --- Get the player's position
    --- @param x number
    --- @param y number
    --- @param z number
    function module:Position(x, y, z)
        assert(x or y or z,
            "Cannot edit position of player with invalid coordinates."
        )

        return SetEntityCoords(Player:Get():Ped(), x, y, z, false, false, false, false)
    end

    --- Get the player's heading
    --- @param heading number
    function module:Heading(heading)
        assert(heading,
            "Trying to change player's heading with nil"
        )
        return SetEntityHeading(Player:Get():Ped(), heading)
    end

    return module
end

--- Get the server module
function Player:Server()
    local module = {}

    --- Trigger a server event
    --- @param name string
    function module:Event(name, ...)
        assert(name, "Cannot call a event with no name :/")
        return TriggerServerEvent(name, ...)
    end

    --- Trigger a server callback, and hopefully get a response.
    --- @param name string
    function module:Callback(name, ...)
        assert(name, "Cannot call a callback with no name :/")
    end
    
    return module
end