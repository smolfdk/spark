-- Notification controller for Spark.
-- Made and maintained by frackz

local NUI = Spark:NUI()

--- Send a notification
--- @param text string
--- @param color string
function Spark:Notify(text, color)
    return NUI:Send({
        brow = text,
        colors = color,

        type = "notify"
    })
end