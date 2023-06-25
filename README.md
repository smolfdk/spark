# ✨ Spark
A FiveM-framework, currently in work-in-progress. That goes for a more simplified approach to easily create and develop FiveM scripts.

### Player object
Spark uses player objects, to very easily get access to all available users functions.
All functions which does not require the user's ped to be used, can be triggered when the user is offline.
```lua
local Spark = exports["Spark"]:Spark()

local User = 
Spark:Players():Get('id', 1 or '1') -- Get user from ID
Spark:Players():Get('steam', 'hex here')  -- Get user from Steam Hex
Spark:Players():Get('source', 1) -- Get user from source
```

### Easy data saving
Spark has a inbuilt database, and a very easy key-value player data system.
This data will save, so no need to worry. This can also be ran even if the user is offline.
```lua
User:Data():Set('Test', 1)
print(User:Data():Get('Test')) -- Will return 1.
```
