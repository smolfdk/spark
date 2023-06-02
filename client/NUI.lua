local NUI = {}

--- Get the NUI module
function Spark:NUI()
    return NUI
end

--- Send a NUI message
--- @param data table
function NUI:Send(data)
    assert(data or type(data) == "table",
        "Cannot send NUI message with invalid data :/"
    )

    return SendNUIMessage(data)
end

--- Register a NUI callback
--- @param name string
--- @param cb function
function NUI:Register(name, cb)
    assert(name or cb,
        "Cannot register a NUI callback with invalid a invalid name or callback"
    )

    return RegisterNUICallback(name, cb)
end