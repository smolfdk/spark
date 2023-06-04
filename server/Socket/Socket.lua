-- Socket controller for Spark.
-- Made and maintained by frackz

local Socket = {}

--- Get the socket module
function Spark:Socket()
    return Socket
end

--- Connect to a socket by url
--- @param url string
function Socket:Connect(url)
    local module, events, send, close = {}, {
        open = {},
        message = {},
        error = {},
        close = {}
    }, nil, nil

    --- Get the events module, this is for listening
    function module:Events()
        local module = {}

        --- The open event is triggered after the socket is ready and opened
        --- @param def function
        function module:Open(def) table.insert(events.open, def) end

        --- The message event is triggered whenever a message is recieved
        --- @param def function
        function module:Message(def) table.insert(events.message, def) end

        --- The error event is triggered whenever a error occurs
        --- @param def function
        function module:Error(def) table.insert(events.error, def) end

        --- The close event is triggered if the socket closes.
        --- @param def function
        function module:Close(def) table.insert(events.close, def) end

        return module
    end

    --- Send a message to the socket
    --- @param message string
    function module:Message(message)
        assert(send or close, "Cannot send message if the socket is not open.")
        return send(message) -- This will send a message to the JS script telling it to send the message
    end

    --- Close the socket, the socket will be useless after this.
    function module:Close()
        assert(send or close, "Cannot close the socket if it is not open.")

        close() -- This will tell the JS script to close the connection.
        send, close = nil, nil
    end

    --- Run a event, this is usally only used for development
    --- @param event string
    function module:Run(event, ...)
        for _, v in pairs(events[event] or {}) do
            v(...)
        end
    end

    exports['Spark']:Socket(url,
        function(...) send, close = ... module:Run('open')
        end, function(msg) module:Run('message', msg)
        end, function(code) module:Run('error', code)
        end, function(reason) module:Run('close', reason)
    end)

    return module
end