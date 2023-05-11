local Database = {}
local Query = exports['Database']:Connection({}, function(query)
    Query = query
end)

function Spark:Database()
    return Database
end

function Database:Query(query, params, cb)
    Query(query, params, function(result)
        local message = result.sqlMessage

        if not message then
            return cb(result)
        end

        return error('A error occurred trying to execute query: '..tostring(message)), cb(false)
    end)
end

function Database:Await(query, params)
    local Promise = promise.new()

    self:Query(query, params, function(result)
        Promise:resolve(result)
    end)

    return Citizen.Await(Promise)
end