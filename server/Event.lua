-- Event controller for Spark.
-- Made and maintained by frackz

local Event = {}

--- Get the Event module
function Spark:Event()
    return Event
end

--- Register a event handled by Spark to make the user a object.
--- @param name string
--- @param callback function
function Event:Register(name, callback)
    RegisterNetEvent(name)
    self:Handle(name, callback)
end

--- Handle a event, this will also has player as the first argument
--- @param name string
--- @param callback function
function Event:Handle(name, callback)
    AddEventHandler(name, function(...)
        local player, source = nil, source
        if source ~= "" then
            player = Spark:Player():Get('source', source)
        end

        pcall(callback(player, ...))
    end)
end