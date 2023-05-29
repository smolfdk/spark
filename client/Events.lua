-- Events controller for Spark.
-- Made and maintained by frackz

--- This event is for informing the server that we have spawned.
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('Spark:Spawned')
end)