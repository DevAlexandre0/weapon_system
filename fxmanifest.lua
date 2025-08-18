fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mbt_malisling'
author 'Malibù Tech Team'
version      '1.1.4'
repository 'https://github.com/MalibuTechTeam/mbt_malisling'
description 'Weapon on back with various features'

dependencies { 
    '/onesync',
    'ox_lib', 
    'ox_inventory' 
}

shared_scripts {
        '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts {
    'server/main.lua',
    'server/scopes.lua',
    'server/version.lua',
    'server/weapon_drop.lua',
    'server/weapon_throw.lua'
}

client_scripts {
    'client/main.lua',
    'client/weapon_drop.lua',
    'client/weapon_firemode.lua',
    'client/weapon_jamming.lua',
    'client/weapon_recoil.lua',
    'client/weapon_throw.lua'
}

files {
    'data/*.lua',
    'utils.lua',
    'client/state.lua',
    'server/state.lua',
    "nui.html",
    "images/*.png",
    'metas/vehicle_weapons/*.meta',
    'metas/weaponcomponents/*.meta', 
    'metas/weapons/*.meta',
}

ui_page "nui.html"

data_file 'WEAPONINFO_FILE_PATCH' 'metas/vehicle_weapons/*.meta'
data_file 'WEAPONCOMPONENTSINFO_FILE' 'metas/weaponcomponents/*.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/weapons/*.meta'