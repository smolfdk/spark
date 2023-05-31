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
    function module:Ped()
        return PlayerPedId()
    end

    --- Get the vehicle the player is currently in
    function module:Vehicle()
        return GetVehiclePedIsIn(self:Ped(), false)
    end

    --- Get the players's armor
    function module:Armor()
        return GetPedArmour(self:Ped())  
    end

    --- Get the player's health
    function module:Health()
        return GetEntityHealth(self:Ped())
    end

    --- Get the player's position
    function module:Position()
        local pos = GetEntityCoords(Player:Get():Ped())
        return pos.x, pos.y, pos.z
    end

    --- Get the player's heading
    function module:Heading()
        return GetEntityHeading(self:Ped())
    end

    return module
end

--- Get the set module
function Player:Set()
    local module = {}

    --- Set the player's armor
    function module:Armor(amount)
        return SetPedArmour(Player:Get():Ped(), amount)
    end

    --- Set the player's health
    function module:Health(amount)
        return SetEntityHealth(Player:Get():Ped(), amount)
    end

    --- Get the player's position
    function module:Position(x, y, z)
        return SetEntityCoords(Player:Get():Ped(), x, y, z, false, false, false, false)
    end

    --- Get the player's heading
    function module:Heading(heading)
        return SetEntityHeading(Player:Get():Ped(), heading)
    end

    return module
end

--- Get the server module
function Player:Server()
    local module = {}

    --- Trigger a server event
    function module:Event(name, ...)
        return TriggerServerEvent(name, ...)
    end

    --- Trigger a server callback
    function module:Callback()
        
    end
    
    return module
end