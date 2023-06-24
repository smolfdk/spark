-- Debug controller for Spark.
-- Made and maintained by frackz

local Debug = {}

--- Get the Debug module
function Spark:Debug()
    return Debug
end

function Debug:Print(emoji, ...)
    for _, v in pairs((type(...) == "string" and {...} or ...) or {}) do
        print(emoji.." "..v)
    end
end

function Debug:Spark(...)
    self:Print('✨', ...)
end

function Debug:Success(...)
    self:Print('✅', ...)
end

function Debug:Warning(...)
    self:Print('⚠️', ...)
end

function Debug:Error(...)
    self:Print('🚫', ...)
end

function Debug:Table(table)
    
end