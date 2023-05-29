-- Event controller for Spark.
-- Made and maintained by frackz

local Event = {}

--- Get the Event module
function Spark:Event()
    return Event
end

--- Register a event handled by Spark to make the user a object.
function Event:Register(name, callback)
    RegisterNetEvent(name)
    self:Handle(name, callback)
end

function Event:Handle(name, callback)
    AddEventHandler(name, function(...)
        local source = source
        local player
        if source ~= "" then
            player = Spark:Player():Get('source', source)
        end

        pcall(callback(player, ...))
    end)
end