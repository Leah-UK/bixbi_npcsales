Config = {}

Config.Debug = true
Config.Locations = {
    legion = {
        location = vector3(232.06, -791.88, 30.6), -- Location of the NPC.
        heading = 60.0, -- Direction of NPC.
        model = `a_m_m_hillbilly_01`, -- Model of the NPC for the qtarget use.
        zcoords = {29.5, 31.5},
        blip = {label = 'Legion Shop', sprite = 207, colour = 2}, -- Blip info.
        event = nil,
        sellableitems = { -- Items that you're able to sell.
            bar_gold = {icon = 'fas fa-money-bill', label = 'Gold Bars', reqamount = 1, costeach = 50},
            bar_iron = {icon = 'fas fa-money-bill', label = 'Iron Bars', reqamount = 1, costeach = 25},
        }
    },
    identification = {
        location = vector3(284.32, -581.23, 43.26),
        heading = 0.0,
        model = `a_m_m_hillbilly_01`,
        zcoords = {42, 44.2},
        blip = {label = 'Legion Shop', sprite = 207, colour = 2},
        event = 'qidentification:applyForLicense',
        sellableitems = {
            identification = {icon = 'fas fa-id-card', label = 'Identification', reqamount = 1, costeach = 500},
            drivers_license = {icon = 'fas fa-id-card', label = 'Drivers License', reqamount = 1, costeach = 1500},
            firearms_license = {icon = 'fas fa-id-card', label = 'Weapons License', reqamount = 1, costeach = 2500},
        }
    }
}