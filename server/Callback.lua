-- Callback controller for Spark.
-- Made and maintained by frackz

local Callback = {
    Callbacks = {},
    Ongoing = {},
    CurrentId = 0
}

--- Get the Callback module
function Spark:Callback()
    return Callback
end

--- Run a callback, and get a response. (hopefully)
--- @param name string
function Callback:Run(player, name, ...)
    assert(self:Exist(name), "Callback "..name.." tried to be run, but is invalid.")
    return self:Get(name)(player, ...)
end

--- Register a server callback
--- @param name string
--- @param callback function
function Callback:Register(name, callback)
    assert(type(callback) == "function" or type(callback) == "table", "Function in callback "..name.." is not actually a function")

    print("REGISTER")
    self.Callbacks[name] = callback
    print(json.encode(self:All()))
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
--- @return number
function Callback:Id()
    self.CurrentId = self.CurrentId + 1
    return self.CurrentId
end

Spark:Event():Register('Spark:Callback:Server:Run', function(player, name, id, ...)
    print(json.encode(Callback:All()))
    print(Callback:Exist(name))
    if (not Callback:Exist(name)) or not id then
        print("WOW")
        return
    end

    print("RUN")
    player:Client():Event(
        'Spark:Callback:Client:Return', -- Event
        id, -- Callback ID
        Callback:Run(player, name, ...) -- And the response of the callback
    )
end)

Spark:Event():Register('Spark:Callback:Server:Return', function(player, id, ...)
    local callback = Callback.Ongoing[id]
    if not callback then
        return
    end

    return callback(...)
end)