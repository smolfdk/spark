-- Manifest for Spark.
-- Made and maintained by frackz

fx_version 'cerulean'
game 'gta5'

author 'frackz <https://github.com/frackz>'
description 'A FiveM framework'
version '1.0.0'

ui_page 'gui/Index.html'

files {
    'gui/Index.html',
    'gui/Menu/Index.css',
    'gui/Menu/Index.js'
}

shared_scripts {
    'cfg/Player.lua'
}

client_scripts {
    'client/Spark.lua',
    'client/Events.lua',
    'client/Player.lua',

    'client/GUI/Menu.lua'
}

server_scripts {
    'server/Spark.lua',
    'server/Utility.lua',
    'server/Config.lua',
    'server/HTTP.lua',
    'server/Version.lua',

    'server/Socket/Socket.js',
    'server/Socket/Socket.lua',

    'server/Database/Database.js',
    'server/Database/Database.lua',

    'server/Player/Source.lua',
    'server/Player/Player.lua',

    'server/Player/Object.lua',
}

lua54 'yes'