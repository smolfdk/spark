-- Notification controller for Spark.
-- Made and maintained by frackz

local Player = Spark:Player()

--- Send a notification
function Spark:Notify(text, color)
    return Player:NUI():Send({
        brow = text,
        colors = color,

        type = "notify"
    })
end