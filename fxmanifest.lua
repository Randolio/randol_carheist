fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Randolio'

shared_scripts {
    '@ox_lib/init.lua', 
}

client_scripts {
    'bridge/client/**.lua',
    'cl_carheist.lua', 
}

server_scripts {
    'bridge/server/**.lua',
    'sv_config.lua', 
    'sv_carheist.lua',
}