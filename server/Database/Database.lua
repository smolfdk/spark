local Database = {}
local Promise = promise.new()
local Query

exports['Spark']:Connection({ -- insert your data here
    host = "localhost",
    user = "root",
    password = "",
    database = "spark",
    port = 3306, -- dont touch if you dont know what you're doing
    connectionLimit = 10, -- ^^
    dateStrings = true -- ^^
}, function(query)
    if type(query) == "string" then
        return error("Error when tried to connect to database! "..query.code)
    end
    
    Query = query

    Promise:resolve()
end)

function Spark:Database()
    return Database
end

function Database:Query(query, cb, ...)
    Citizen.Await(Promise)

    if not Query then
        return false, error("Connection is invalid")
    end

    local Response = Query(query, ...)
    local Message = Response.sqlMessage

    if not Message then
        return cb(Response)
    end

    return false, error("Error while executing query? "..Message)
end

function Database:First(query, ...)
    return (self:Await(query, ...) or {{}})[1]
end

function Database:Await(query, ...)
    local Promise = promise.new()

    self:Query(query, function(result)
        if not result then
            return
        end

        Promise:resolve(result)
    end, ...)

    return Citizen.Await(Promise)
end