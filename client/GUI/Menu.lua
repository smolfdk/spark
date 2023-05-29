local Player = Spark:Player()
local Open, Index, Data, Color = false, 1, {}, '#EF5064'

local Menu = {}

function Spark:Menu()
    return Menu
end

function Menu:Show(text, data, color)
    Player:NUI():Send({
        show = true,
        text = text,
        list = data,
        color = color,
        
        type = 'menu'
    })

    Index, Data, Open, Color = #data, data, true, color
end

function Menu:Close()
    Player:NUI():Send({
        show = false,
        text = text,
        
        type = 'menu'
    })

    Open, Data = false, {}
end

function Menu:Move(method, old)
    Player:NUI():Send({
        oldIndex = old,
        index = Index,
        method = method,
        color = Color,

        type = 'menu'
    })
end

CreateThread(function()
    while true do
        if Open then
            if Player:Keys():Pressed('BACKSPACE') then
                print("CLOSE")
                Menu:Close()
            elseif Player:Keys():Pressed('ARROWDOWN') then
                local index = Index
                if Index ~= 1 then
                    Index = Index - 1
                    Menu:Move('down', 0)
                else
                    Index = #Data
                    Menu:Move('teleport', index)
                end
            elseif Player:Keys():Pressed('ARROWUP') then
                print("UP")
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

        Wait(0)
    end
end)

RegisterCommand('menu', function()
    Menu:Show('Hello', {
        "Hello",
        "Ok",
        "123"
    }, '#EF5064')
end)