local NUI = {}

--- Get the NUI module
function Spark:NUI()
    return NUI
end

--- Send a NUI message
function NUI:Send(...)
    return SendNUIMessage(...)
end

function NUI:Register(...)
   return RegisterNUICallback(...)
end