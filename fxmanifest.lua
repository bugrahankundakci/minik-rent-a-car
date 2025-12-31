fx_version 'cerulean'
game 'gta5'

author 'minik-rentacar'
description 'Araç kiralama sistemi - QBCore'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qb-core',
    'qb-target'
}

