-- Debug controller for Spark.
-- Made and maintained by frackz

local Debug = {}

--- Get the Debug module
function Spark:Debug()
    return Debug
end

--- Print multiple prints, with a emoji
function Debug:Print(emoji, ...)
    assert(emoji, "No emoji set when trying to print a debug message.")
    for _, v in pairs((type(...) == "string" and {...} or ...) or {}) do
        print(emoji.." "..v)
    end
end

--- Print messages with the Spark emoji
function Debug:Spark(...)
    self:Print('✨', ...)
end

--- Print messages with the Success emoji
function Debug:Success(...)
    self:Print('✅', ...)
end

--- Print messages with the Warning emoji
function Debug:Warning(...)
    self:Print('⚠️', ...)
end

--- Print messages with the Error emoji
function Debug:Error(...)
    self:Print('🚫', ...)
end

--- Print a table to the console.
--- @param list table
function Debug:Table(list)
    assert(type(list) == "table", "Trying to print a table, but it's not a table?")
    print(Spark:Utility():Table(list))
end