-- Source controller for Spark.
-- This is used for source-based functions, normally not used outside Spark
-- Made and maintained by frackz

local Source = {
    Dummy = 'tewstOMG' -- The default steam hex, used for debugging and whatnot
}

--- Get the source module
function Spark:Source()
    return Source
end

--- Get the steam identifier from source
--- @param source number
function Source:Steam(source)
    if not source or source == 0 then -- Check if its a debugging account
        return self.Dummy
    end

    for _, v in pairs(GetPlayerIdentifiers(source) or {}) do -- Loops through all their identifiers
        if string.find(v, 'steam:') then -- Checks if it contains the text 'steam:'
            return v:gsub('steam:', "") -- If it does, returns a cut version where is only the hex
        end
    end
end