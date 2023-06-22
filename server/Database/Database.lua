-- Database controller for Spark.
-- Made and maintained by frackz

local Database = {}
local Query, Execute, Promise = nil, nil, Spark:Promise()

--- Get the database module
function Spark:Database()
    return Database
end

--- Connect to the Database
exports['Spark']:Connect(Spark:Config():Get('Database'), function(query, execute)
    if type(query) == "string" or type(execute) == "string" then
        return error("Error when tried to connect to database! "..query)
    end

    Query, Execute = query, execute
    Promise:Resolve() -- Resolve so all waiting queries can run
end)

--- Execute a query, and get a response from a callback
--- @param query string
--- @param cb function
function Database:Query(query, cb, ...)
    Promise:Await() -- Wait for connection to establish
    assert(Query, "Whoops, database not done loading! Cannot execute in the meanwhile")

    local Response = Query(query, ...)
    local Message = Response.sqlMessage

    assert(not Message, "Error while 'quering', message: "..tostring(Message))
    return cb(Response)
end

--- Get the first element inside the response
--- @param query string
function Database:First(query, ...)
    return (self:Await(query, ...) or {{}})[1]
end

--- Await for a query to execute, this will return all findings
--- @param query string
--- @return table
function Database:Await(query, ...)
    local Promise = Spark:Promise()

    self:Query(query, function(result)
        assert(result, "Result is nil, prob a internal error.")
        Promise:Resolve(result)
    end, ...)

    return Promise:Await()
end

--- Execute a query directly
--- @param query string
function Database:Execute(query, ...)
    Promise:Await()
    local args = type(...) == "table" and ... or {...}

    local Response = Execute(query, args)
    local Message = Response.sqlMessage

    assert(not Message, "Error while executing query, message: "..tostring(Message))
    return Response.result, Response.fields
end