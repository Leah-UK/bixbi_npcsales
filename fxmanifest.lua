--[[----------------------------------
Creation Date:	25/06/2021
]]------------------------------------
fx_version 'cerulean'
game 'gta5'
author 'Leah#0001'
version '1.1'
versioncheck 'https://raw.githubusercontent.com/Leah-UK/bixbi_npcsales/main/fxmanifest.lua'
lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

client_scripts {
	'client/client.lua'
}

server_scripts {
	'server/server.lua'
}

dependencies {
	'bixbi_core'
}