-- HTTP controller for Spark.
-- Made and maintained by frackz

local HTTP = {}

--- Get the HTTP module
function Spark:HTTP()
    return HTTP
end

--- Perform a HTTP request with Promises
--- @param url string
--- @param method string
--- @param data string | nil
--- @param headers table | nil
--- @return boolean, table | number
function HTTP:Perform(url, method, data, headers)
    local Promise = Spark:Promise()

    PerformHttpRequest(url, function (err, data, _)
        Promise:Resolve(err == 200 and data or err)
    end, method, data or '', headers or {})

    local Result = Promise:Await() -- Awaits until done
    return type(Result) ~= "number", Result
end