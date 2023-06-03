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
    'gui/Index.js',

    'gui/Menu/Index.css',
    'gui/Menu/Index.js',

    'gui/Prompt/Index.css',
    'gui/Prompt/Index.js',

    'gui/Notify/Index.css',
    'gui/Notify/Index.js'
}

shared_scripts {
    'cfg/Player.lua'
}

client_scripts {
    'client/Spark.lua',
    'client/Events.lua',
    'client/Player.lua',

    'client/NUI.lua',
    'client/Keys.lua',

    'client/GUI/Menu.lua',
    'client/GUI/Notify.lua',
    'client/GUI/Prompt.lua'
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

    'server/Callback.lua',

    'server/Player/Source.lua',
    'server/Player/Player.lua',

    'server/Player/Object.lua',

    'server/Event.lua'
}

lua54 'yes'