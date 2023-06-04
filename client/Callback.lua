-- Callback controller for Spark.
-- Made and maintained by frackz

local Callback, Player = Spark:Player(), {
    Callbacks = {},
    Ongoing = {},
    CurrentId = 0
}

--- Get the Callback module
function Spark:Callback()
    return Callback
end

--- Run a server-callback
function Callback:Trigger(name, cb, ...)
    local id = self:Id()
    self.Ongoing[id] = cb

    Player:Server():Event('Spark:Callback:Server:Run', name, id, ...)
end

--- Run a client-callback, and get a response (hopefully)
--- @param name string
function Callback:Run(name, ...)
    assert(self:Exist(name), "Callback "..name.." tried to be run, but is invalid.")
    return self:Get(name)(...)
end

--- Register a server callback
--- @param name string
--- @param callback function
function Callback:Register(name, callback)
    assert(not self:Exist(name), "Callback with name "..name.." does already exist")
    assert(type(callback) == "function", "Function in callback "..name.." is not actually a function")
    
    self:All()[name] = callback
end

--- Check if a callback exists
--- @param name string
--- @return boolean
function Callback:Exist(name)
    return self:All()[name] ~= nil
end

--- Get all registered callbacks
--- @return table
function Callback:All()
    return self.Callbacks
end

--- Get a specific callback
--- @param name string
--- @return function
function Callback:Get(name)
    return self:All()[name]
end

--- Add 1 to the current id, and get returned the new.
function Callback:Id()
    self.CurrentId = self.CurrentId + 1
    return self.CurrentId
end

RegisterNetEvent('Spark:Callback:Client:Run', function(name, id, ...)
    if not Callback:Exist(name) then
        return
    end

    Player:Server():Event(
        'Spark:Callback:Server:Return', -- Event
        id, -- Callback ID
        Callback:Run(name, ...) -- And the response of the callback
    )
end)

RegisterNetEvent('Spark:Callback:Client:Return', function(id, ...)
    local callback = Callback.Ongoing[id]
    if not callback then
        return
    end

    callback(...)
end)