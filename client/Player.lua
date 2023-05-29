-- Player controller for Spark.
-- Made and maintained by frackz

local Player = {}
local Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173, ['ARROWUP'] = 188, ['ARROWDOWN'] = 187
}

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

--- Get the NUI module
function Player:NUI()
    local module = {}

    --- Send a NUI Message
    function module:Send(data)
        return SendNUIMessage(data)
    end

    function module:Register(name, callback)
        return RegisterNUICallback(name, callback)
    end

    return module
end

--- Get the key module
function Player:Keys()
    local module = {}

    --- Check if a key is pressed
    function module:Pressed(key)
        assert(self:Get(key), "Key "..tostring(key).." does not exist.") -- Check if the key exists.
        
        return IsControlJustPressed(1, self:Get(key))
    end

    --- Get the key's "id"
    function module:Get(key)
        return Keys[key]
    end

    return module
end