-- Utility controller for Spark.
-- Made and maintained by frackz

local Utility = {}

function Spark:Utility()
    return Utility
end

function Utility:Copy(object, destination)
    object, destination = object or {}, destination or {}

    for k,v in pairs(object) do
        if not destination[k] then
            if type(v) == "table" then
                destination[k] = self:Copy(v)
            else
                destination[k] = v
            end
        end
    end

    return destination
end