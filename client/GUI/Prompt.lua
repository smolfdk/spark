-- Prompt controller for Spark.
-- Made and maintained by frackz

local Status, Prompt = false, {}

--- Get the prompt module
function Spark:Prompt()
    return Prompt
end

--- Show the prompt
--- @param text string
--- @param size number
function Prompt:Show(text, size)
    assert(not Status, "Prompt is already open")
    return SetNuiFocus(true, true), NUI:Send({
        show = true,
        text = text,
        size = size,

        type = "prompt"
    })
end

--- When the key / button cancel has been pressed
NUI:Register('Prompt:Cancel', function()
    SetNuiFocus(false, false)

    return true
end)

--- When the key / button submit has been pressed
NUI:Register('Prompt:Submit', function(data)
    SetNuiFocus(false, false)
    print(data.text)
    return true
end)