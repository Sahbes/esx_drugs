fx_version 'adamant'

game 'gta5'

author 'Sahbes'
description 'A resource written from esx_illigal but with lots of new functions'

server_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'server/*.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'client/main.lua'
}

dependencies {
	'es_extended'
}
