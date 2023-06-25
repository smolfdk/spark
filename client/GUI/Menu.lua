-- Menu controller for Spark.
-- Made and maintained by frackz

local Menu, NUI = {}, Spark:NUI()
local Open, Index, Data, Callback, Color = false, 1, {}, nil, nil

--- Get the menu module
function Spark:Menu()
    return Menu
end

--- Get the current button that is being hovered
function Menu:Current()
    return Data[Index]
end

function Menu:Show(title, color, data, callback)
    assert(not Open, "Cannot open a menu if its already open")
    assert(type(callback) == "function" or type(callback) == "table", "Callback is not a function")

    Open, Callback, Index, Data, Color = true, callback, 1, data, color
    return NUI:Send({
        type = "menu",
        action = "open",
        data = {
            title = title,
            data = data,
            color = color
        }
    })
end

function Menu:Close()
    assert(Open, "Cannot close the menu if its closed")

    Open, Callback = false, nil
    return NUI:Send({
        type = "menu",
        action = "close",
        data = {}
    })
end

function Menu:Update()
    assert(Open, "Cannot update the hovered button if the menu it closed")

    return NUI:Send({
        type = "menu",
        action = "update",
        data = {
            index = Index,
            color = Color
        }
    })
end

CreateThread(function()
    while true do
        if Open then
            if Spark:Keys():Pressed('BACKSPACE') then
                Menu:Close()
            elseif Spark:Keys():Pressed('ENTER') then
                Callback(Menu:Current())
            elseif Spark:Keys():Pressed('ARROWUP') then
                if Index == 1 then
                    Index = #Data
                else
                    Index = Index - 1
                end
                Menu:Update()
            elseif Spark:Keys():Pressed('ARROWDOWN') then
                if Index == #Data then
                    Index = 1
                else
                    Index = Index + 1
                end
                Menu:Update()
            end
        end
        Wait(0)
    end
end) 