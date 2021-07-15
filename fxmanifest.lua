--[[----------------------------------
Creation Date:	25/06/2021
]]------------------------------------
fx_version 'adamant'
game 'gta5'
author 'Leah#0001'
version '1.0'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

client_scripts {
	'client/client.lua'
}

server_scripts {
	'server/server.lua',
	'sv_config.lua'
}

dependencies {
    'es_extended',
	'bixbi_core'
}