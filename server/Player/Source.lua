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
    if source == 0 then
        return self.Default
    end

    for _, v in pairs(GetPlayerIdentifiers(source)) do
        if string.find(v, 'steam:') then
            return v:gsub('steam:', "")
        end
    end
end