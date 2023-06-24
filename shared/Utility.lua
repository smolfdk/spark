-- Utility controller for Spark.
-- Made and maintained by frackz

local Utility = {}

--- Get the Utility module
function Spark:Utility()
    return Utility
end

--- Copy a table, make a replica without refrences.
--- @param object table | nil
--- @param destination table | nil
function Utility:Copy(object, destination)
    object, destination = object or {}, destination or {}

    for k,v in pairs(object) do
        if not destination[k] then
            destination[k] = type(v) == "table" and self:Copy(v) or v
        end
    end

    return destination
end

--- Get the resource name
--- @return string
function Utility:Resource()
    return GetCurrentResourceName()
end

function Utility:State()
    return GetResourceState(self:Resource())
end