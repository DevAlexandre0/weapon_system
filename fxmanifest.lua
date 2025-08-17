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
    'config.lua'
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

files {
    'data/*.lua',
    'utils.lua',
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