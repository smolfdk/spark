-- Menu controller for Spark.
-- Made and maintained by frackz

local NUI = Spark:NUI()
local Open, Index, Data, Color = false, 1, {}, '#EF5064'

local Menu = {}

--- Get the menu module
function Spark:Menu()
    return Menu
end

--- Open the menu with title, buttons, and color
function Menu:Show(title, data, color)
    NUI:Send({
        show = true,
        text = title,
        list = data,
        color = color or Color,
        
        type = 'menu'
    })

    Index, Data, Open, Color = #data, data, true, color
end

--- Close the currently shown menu.
function Menu:Close()
    NUI:Send({
        show = false,
        text = text,

        type = 'menu'
    })

    Open, Data = false, {}
end

--- Move the currently selected button (for development mainly)
function Menu:Move(method, old)
    NUI:Send({
        oldIndex = old,
        index = Index,
        method = method,
        color = Color,

        type = 'menu'
    })
end

--- Check if the menu is open
function Menu:Open()
    return Open
end

--- Check for key presses (like close, enter, down, up)
--[[CreateThread(function()
    while true do
        if Open then
            if Player:Keys():Pressed('BACKSPACE') then
                Menu:Close()
            elseif Player:Keys():Pressed('ARROWDOWN') then
                local index = Index
                if Index ~= 0 then
                    Index = Index - 1
                    Menu:Move('down', 0)
                else
                    Index = #Data
                    Menu:Move('teleport', index)
                end
            elseif Player:Keys():Pressed('ARROWUP') then
                local index = Index
                if Index ~= #Data then
                    Index = Index + 1
                    Menu:Move('up', 0)
                else
                    Index = 1
                    Menu:Move('teleport', index)
                end
            elseif Player:Keys():Pressed('ENTER') then
                local button = Data[#Data-Index+1]
                print(button)
            end
        end

        Wait(1)
    end
end)--]]