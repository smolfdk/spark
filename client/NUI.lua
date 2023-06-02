local NUI = {}

--- Get the NUI module
function Spark:NUI()
    return NUI
end

--- Send a NUI message
--- @param data table
function NUI:Send(data)
    return SendNUIMessage(data)
end

--- Register a NUI callback
--- @param name string
--- @param cb function
function NUI:Register(name, cb)
   return RegisterNUICallback(name, cb)
end