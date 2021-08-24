ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

RegisterServerEvent('bixbi_npcsales:Server')
AddEventHandler('bixbi_npcsales:Server', function(item, npcLoc)
    local xPlayer = ESX.GetPlayerFromId(source)

    local locationItem = Config.Locations[npcLoc].sellableitems[item]
    if (xPlayer.getInventoryItem(item).count < locationItem.reqamount) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You do not have enough ' .. locationItem.label .. ' in your inventory.')
    else
        TriggerClientEvent('bixbi_npcsales:Process', source, item, npcLoc)
    end
end)

RegisterServerEvent('bixbi_npcsales:Complete')
AddEventHandler('bixbi_npcsales:Complete', function(item, npcLoc, quantity)
    local xPlayer = ESX.GetPlayerFromId(source)
    local locationItem = Config.Locations[npcLoc].sellableitems[item]
    local inventoryCount = xPlayer.getInventoryItem(item).count
    if (inventoryCount < locationItem.reqamount or inventoryCount < quantity) then
        TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You do not have enough ' .. locationItem.label .. ' in your inventory.')
    else
        xPlayer.removeInventoryItem(item, quantity)
        xPlayer.addAccountMoney('money', locationItem.costeach * quantity)
        TriggerClientEvent('bixbi_core:Notify', source, 'success', 'You have sold ' .. quantity .. 'x ' .. locationItem.label .. ' for £' .. locationItem.costeach * quantity)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetResourceState('bixbi_core') ~= 'started' ) then
        print('Bixbi_NPCSales - ERROR: Bixbi_Core hasn\'t been found! This could cause errors!')
    end
end)