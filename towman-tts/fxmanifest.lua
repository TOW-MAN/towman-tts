fx_version 'cerulean'
game 'gta5'

author 'TOW_MAN'
description 'No-API Proximity Text-To-Speech Interface with Config for QBCore'
version '1.2.0'

dependencies {
    'qb-core',
    'ox_lib',
    'xsound'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    -- Include your UI styles, scripts, or audio assets here
}
