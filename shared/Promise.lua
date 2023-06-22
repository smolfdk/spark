-- Promise controller for Spark.
-- Made and maintained by frackz

--- Make a promise
function Spark:Promise()
    local promise, module = promise.new(), {}

    --- Resolve the promise
    function module:Resolve(...)
        return promise:resolve(...)
    end

    --- Reject the promise
    function module:Reject(...)
        return promise:reject(...)
    end

    --- Get function called when promise is resolved / rejected
    function module:Next(...)
        return promise:next(...)
    end

    --- Wait for the promise to get resolved / rejected, and get the response.
    function module:Await()
        return Citizen.Await(promise)
    end

    return module
end