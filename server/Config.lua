-- Config controller for Spark.
-- Made and maintained by frackz

local Config = {
    Configs = {}
}

--- Get the Config module
function Spark:Config()
    return Config
end

--- Get a config by path, this is just the name of the file
--- @param path string
--- @return table
function Config:Get(path)
    if self.Configs[path] then
        return self.Configs[path]
    end

    local resource, key = Spark:Utility():Resource(), 'cfg/'..path..'.lua'
    local content = LoadResourceFile(resource, key)
    
    assert(content, "Config cannot be found with path "..path)

    local f, err = load(content, resource..'/'..key)
    assert(f, "Error while parsing config "..path.." error "..tostring(err))

    local response = table.pack(xpcall(f, debug.traceback))
    local config, content = response[1], response[2]
    assert(config, "Error loading config "..path)

    self.Configs[path] = content
    return content
end