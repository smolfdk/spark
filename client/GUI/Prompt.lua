-- Prompt controller for Spark.
-- Made and maintained by frackz

local Player = Spark:Player()
local Status = false

local Prompt = {}

--- Get the prompt module
function Spark:Prompt()
    return Prompt
end

--- Show the prompt
function Prompt:Show(text, size)
    assert(not Status, "Prompt is already open")
    return SetNuiFocus(true, true), Player:NUI():Send({
        show = true,
        text = text,
        size = size,

        type = "prompt"
    })
end

--- When the key / button cancel has been pressed
Player:NUI():Register('cancel', function(data, cb)
    SetNuiFocus(false, false)
    print("cancel", cb())
end)

--- When the key / button submit has been pressed
Player:NUI():Register('submit', function(data, cb)
    SetNuiFocus(false, false)
    print(data.text, cb())
end)