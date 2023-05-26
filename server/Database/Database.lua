-- Database controller for Spark.
-- Made and maintained by frackz

local Database = {}
local Query, Execute, Promise = nil, nil, promise.new()

--- Get the database module
function Spark:Database()
    return Database
end

--- Connect to the Database
exports['Spark']:Connect({ -- insert your data here
    host = "localhost",
    user = "root",
    password = "",
    database = "spark",
    port = 3306, -- dont touch if you dont know what you're doing
    connectionLimit = 10, -- ^^
    dateStrings = true -- ^^
}, function(query, execute)
    if type(query) == "string" or type(execute) == "string" then
        return error("Error when tried to connect to database! "..query)
    end
    
    Query, Execute = query, execute
    Promise:resolve() -- Resolve so all waiting queries can run
end)

--- Execute a query, and get a response from a callback
function Database:Query(query, cb, ...)
    Citizen.Await(Promise) -- Wait for connection to establish
    assert(Query, "Whoops, database not done loading! Cannot execute in the meanwhile")

    local Response = Query(query, ...)
    local Message = Response.sqlMessage

    if not Message then
        return cb(Response)
    end

    return cb(false), error("Error while executing query? "..Message)
end

--- Get the first element inside the response
function Database:First(query, ...)
    return (self:Await(query, ...) or {{}})[1]
end

--- Await for a query to execute, this will return all findings
function Database:Await(query, ...)
    local Promise = promise.new()

    self:Query(query, function(result)
        assert(result, "Result is nil, prob a internal error.")

        Promise:resolve(result)
    end, ...)

    return Citizen.Await(Promise)
end

function Database:Execute(query, ...)
    local args = type(...) == "table" and ... or {...}
    assert(Execute, "Whoops, database not done loading! Cannot execute in the meanwhile")

    local Response = Execute(query, args)
    local Message = Response.sqlMessage

    if not Message then
        return Response.result, Response.fields
    end

    return false, error("Error while executing? "..Message)
end