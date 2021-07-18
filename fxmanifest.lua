--[[----------------------------------
Creation Date:	25/06/2021
]]------------------------------------
fx_version 'adamant'
game 'gta5'
author 'Leah#0001'
version '1.0'
versioncheck 'https://raw.githubusercontent.com/Leah-UK/bixbi_npcsales/main/fxmanifest.lua'

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
	'bixbi_core'
}