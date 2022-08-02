fx_version 'bodacious'
game 'gta5'

author 'GMD'
version '1.0.0'

client_scripts {
    'client/raid.lua',
    'client/weapon.lua',
    'client/sharedclients.lua'

    --'client/ui.lua'
} 
server_scripts {
    'server/raid.lua',
    'server/weapon.lua',
    'server/sharedserver.lua',
    'server/query.lua',
    'server/discord.lua',
    'sv_config.lua',
    '@oxmysql/lib/MySQL.lua'
} 
shared_script 'config.lua'

lua54 'yes'

escrow_ignore {
    'config.lua',
    'sv_config.lua'
}

dependencies {
    'es_extended',
    'oxmysql',
    'esx_addonaccount',
    'esx_datastore', -- if you use an esx job as an Armyjob
    'utk_fingerprint',
    'utk_hackdependency'
}