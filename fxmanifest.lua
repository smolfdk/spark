-- Manifest for Spark.
-- Made and maintained by frackz

fx_version 'cerulean'
game 'gta5'

author 'frackz <https://github.com/frackz>'
description 'A FiveM framework'
version '1.0.0'

-- What to run
shared_scripts {

}

server_scripts {
    'server/Spark.lua',
    'server/HTTP.lua',
    'server/Version.lua'
}

client_scripts {
    
}

lua54 'yes'