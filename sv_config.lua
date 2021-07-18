Config.Locations = {
    legion = {
        location = vector3(232.06, -791.88, 30.6), -- Location of the NPC.
        heading = 60.0, -- Direction of NPC.
        model = `a_m_m_hillbilly_01`, -- Model of the NPC for the qtarget use.
        blip = {label = 'Legion Shop', sprite = 540, colour = 2}, -- Blip info.
        sellableitems = { -- Items that you're able to sell.
            bar_gold = {icon = 'fas fa-microchip', label = 'Gold Bars', reqamount = 1, costeach = 50},
            bar_iron = {icon = 'fas fa-microchip', label = 'Iron Bars', reqamount = 1, costeach = 25},
        }
    }
}