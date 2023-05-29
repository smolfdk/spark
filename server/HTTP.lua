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
    local Promise = promise.new()

    PerformHttpRequest(url, function (err, data, _)
        if err ~= 200 then
            data = err
        end

        Promise:resolve(data)
    end, method, data or '', headers or {})

    local Result = Citizen.Await(Promise) -- Awaits until done

    -- Check if its a error code, and not a response
    if type(Result) == "number" then
        return false, Result
    end

    return true, Result
end