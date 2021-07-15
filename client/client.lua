ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

local playerPed = PlayerPedId()
AddEventHandler('onResourceStart', function(resourceName)
	if (resourceName == GetCurrentResourceName() and Config.Debug) then
        FirstLoadup()
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    while (ESX == nil) do
        Citizen.Wait(100)
    end
    
    ESX.PlayerData = xPlayer
 	ESX.PlayerLoaded = true
    FirstLoadup()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

local locations = nil
RegisterNetEvent('bixbi_npcsales:LocUpdate')
AddEventHandler('bixbi_npcsales:LocUpdate', function(ConfigLocs)
    locations = ConfigLocs
end)

function FirstLoadup()
    TriggerServerEvent('bixbi_npcsales:GetLocations')
    while locations == nil do
        Citizen.Wait(100)
    end

    playerPed = PlayerPedId()
    TargetsAndBlips()
    NPCLoop()
end

local pedCreated = false
function NPCLoop()
    Citizen.CreateThread(function()
		local npcLoopSleep = 1
        while ESX.PlayerLoaded do
            local closestDistance = 1000
            local coords = GetEntityCoords(playerPed)
    
            for k, v in pairs(locations) do
                local distance = #(coords - v.location)
                if (distance < closestDistance) then closestDistance = distance end
                if (closestDistance < 100.0 and not pedCreated) then
                    NPCCreation(v)
                    Citizen.Wait(5000)
                end
            end

            if (closestDistance < 100) then
                npcLoopSleep = 1
            elseif (closestDistance > 200) then
                npcLoopSleep = 10
            elseif (closestDistance > 500) then
                npcLoopSleep = 30
            elseif (closestDistance > 1000) then
                npcLoopSleep = 60
            end

            if (closestDistance > 150) then
                NPCRemoval()
            end
            
            Citizen.Wait(npcLoopSleep * 1000)
        end
	end)
end

local spawnedPed = nil
function NPCCreation(ConfigItem)
    local model = ConfigItem.model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(50)
    end

    spawnedPed = CreatePed(4, model, ConfigItem.location.x, ConfigItem.location.y, ConfigItem.location.z - 1, ConfigItem.heading, false, true)
    NPCSettings()

    pedCreated = true
end

function NPCSettings()
    if (spawnedPed ~= nil) then
        FreezeEntityPosition(spawnedPed, true)
        SetEntityInvincible(spawnedPed, true)
        SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    end
end

function NPCRemoval()
    if (spawnedPed ~= nil) then
        DeletePed(spawnedPed)
        spawnedPed = nil
        pedCreated = false
    end
end

function TargetsAndBlips()
    for k, v in pairs(locations) do
        local options = {}
        for l, z in pairs(v.sellableitems) do
            table.insert(options, 
                {
                    event = "bixbi_npcsales:Client",
                    icon = z.icon,
                    label = 'Sell ' .. z.label,
                    item = l,
                    location = k,
                }
            )
        end

        exports['bt-target']:AddTargetModel({ v.model }, {
            options = options,
            job = {"all"},
            distance = 2.0
        })

        if (v.blip ~= nil) then
            local blip = AddBlipForCoord(v.location)
            SetBlipSprite (blip, v.blip.sprite)
            SetBlipDisplay(blip, 6)
            SetBlipScale  (blip, 1.0)
            SetBlipColour (blip, v.blip.colour)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

RegisterNetEvent('bixbi_npcsales:Client')
AddEventHandler('bixbi_npcsales:Client', function(data)
    TriggerServerEvent('bixbi_npcsales:Server', data.item, data.location)
end)

RegisterNetEvent('bixbi_npcsales:Process')
AddEventHandler('bixbi_npcsales:Process', function(item, npcLoc)
    if (spawnedPed == nil) then return end
    local playerCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(spawnedPed)
    local dist = #(playerCoords - pedCoords)
    if (dist < 3.0) then
        ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'quantity',
        {
            title = "Quantity to Sell"
        },
        function(data, menu)
            local quantity = tonumber(data.value)
            ESX.UI.Menu.CloseAll()
            print(quantity)
            if (quantity ~= nil) then
                TaskStartScenarioInPlace(spawnedPed, 'WORLD_HUMAN_DRUG_DEALER_HARD', 0, true)
                FreezeEntityPosition(spawnedPed, false)
                
                TaskTurnPedToFaceEntity(spawnedPed, playerPed, 4000)
                TaskTurnPedToFaceEntity(playerPed, spawnedPed, 4000)
                exports['bixbi_core']:playAnim(playerPed, 'missfbi1ig_1_alt_1', 'conversation1_peda', -1)
                exports['bixbi_core']:Loading(4000, 'Discussing Sale')
                Citizen.Wait(4000)

                TaskTurnPedToFaceEntity(spawnedPed, playerPed, 2000)
                TaskTurnPedToFaceEntity(playerPed, spawnedPed, 2000)
                exports['bixbi_core']:playAnim(spawnedPed, 'mp_common', 'givetake1_a', -1)
                exports['bixbi_core']:playAnim(playerPed, 'mp_common', 'givetake1_a', -1)
                Citizen.Wait(2000)

                ClearPedTasks(playerPed)
                ClearPedTasks(spawnedPed)
                NPCSettings()

                TriggerServerEvent('bixbi_npcsales:Complete', item, npcLoc, quantity)
            end
        end, function(data, menu)
            menu.close()
        end)
    else
        exports['bixbi_core']:Notify('error', 'You need to be closer.')
    end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        NPCRemoval()
	end
end)
