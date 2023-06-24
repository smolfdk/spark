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

--- Get the amount of entries there is in a table
function Utility:Entries(list)
    local count = 0
    for _ in pairs(list) do
        count = count + 1
    end

    return count
end

--- Convert a table into string, this is mostly used for debugging
--- @param list table
--- @return string
function Utility:Table(list)
    local text, index, length = '', 0, self:Entries(list)
    assert(type(list) == "table", "Trying to print a table, but it's not a table?")

    for k, v in pairs(list) do
        if type(v) == "table" then
            v = '('..self:Table(v)..')'
        elseif type(v) == "function" then
            v = "<function>"
        end

        text = text .. ("%s %s"):format(
            k..":",
            v
        ) .. (index == length and '\n' or '')

        index = index + 1
    end

    return text
end

--- Get the resource name
--- @return string
function Utility:Resource()
    return GetCurrentResourceName()
end

--- Get the resource state
--- @return string
function Utility:State()
    return GetResourceState(self:Resource())
end