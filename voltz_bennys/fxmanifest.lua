fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_script '@ox_lib/init.lua'

server_scripts {
    'server.lua',
    '@mysql-async/lib/MySQL.lua'
}

client_scripts {
    'client/client.lua',
    'client/boss.lua',
    'client/vestiaire.lua',
    'client/garage.lua',
    'client/coffre.lua',
    'config.lua'
}

dependency 'ox_lib'
