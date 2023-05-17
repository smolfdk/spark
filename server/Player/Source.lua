-- Source controller for Spark.
-- This is used for source-based functions, normally not used outside Spark
-- Made and maintained by frackz

local Source = {
    Default = 'tewstOMG' -- The default steam hex, used for debugging and whatnot
}

--- Get the player module
function Spark:Source()
    return Source
end

--- Get the steam identifier from source
function Source:Steam(source)
    if source == 0 then -- If the source is 0 (which means its server), it will return a default steam (for debugging)
        return self.Default
    end
    print(type(source), source)
    for _, v in pairs(GetPlayerIdentifiers(source) or {}) do -- Loops through all their identifiers
        if string.find(v, 'steam:') then -- Checks if it contains the text 'steam:'
            return v:gsub('steam:', "") -- If it does, returns a cut version where is only the hex
        end
    end
end