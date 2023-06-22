-- Events controller for Spark.
-- Made and maintained by frackz
local Player = Spark:Player()

--- This event is for informing the server that we have spawned.
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('Spark:Spawned')
end)

RegisterNetEvent('Spark:Client:SetHealth', function(health)
    Player:Set():Health(health)
end)