-- Prompt controller for Spark.
-- Made and maintained by frackz

local NUI, Status, Prompt, Callback = Spark:NUI(), false, {}, nil

--- Get the prompt module
function Spark:Prompt()
    return Prompt
end

--- Show the prompt
--- @param text string
--- @param size number
function Prompt:Show(text, size, callback)
    assert(not Status, "Prompt is already open")
    assert(type(Callback) == "function", "Callback is not a function")

    Callback, Status = callback, true
    return NUI:Focus(true, true), NUI:Send({
        show = true,
        text = text,
        size = size,

        type = "prompt"
    })
end

--- When the key / button cancel has been pressed
NUI:Register('Prompt:Cancel', function()
    NUI:Focus(false, false)
    Callback(false)

    Status, Callback = false, nil
    return true
end)

--- When the key / button submit has been pressed
NUI:Register('Prompt:Submit', function(data)
    NUI:Focus(false, false)
    Callback(true, data.text)

    Status, Callback = false, nil
    return true
end)