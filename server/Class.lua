-- Class controller for Spark.
-- Made and maintained by frackz

local Class = {}

--- Get the class module
function Spark:Class()
    return Class
end

function Class:Extend(object)
    object = object or {}

    Spark:Utility():Copy(self, object)
    object._ = object._ or {}

    setmetatable(object, {
        __call = function(self, ...)
            return self:Init(...)
        end
    })

    return object
end

function Class:Init(...)
    local object = self:Extend()
    if object.__init then
        object.__init(...)
    end

    return object
end

function Class:New(object)
    object = object or {}
    return self:Extend(object)
end