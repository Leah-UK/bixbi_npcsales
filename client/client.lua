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
        while (ESX == nil) do
            Citizen.Wait(100)
        end
        
        Citizen.Wait(10000)
        ESX.PlayerLoaded = true
        FirstLoadup()
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    while (ESX == nil) do
        Citizen.Wait(100)
    end
    
    Citizen.Wait(10000)
    ESX.PlayerData = xPlayer
 	ESX.PlayerLoaded = true
    FirstLoadup()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

function FirstLoadup()
    playerPed = PlayerPedId()
    CreateBlips()
    NPCLoop()
    CreateTargets() 
end

local pedCreated = false
function NPCLoop()
    Citizen.CreateThread(function()
		local npcLoopSleep = 1
        while ESX.PlayerLoaded do
            local closestDistance = 1000
    
            for k, v in pairs(Config.Locations) do
                local distance = #(GetEntityCoords(playerPed) - v.location)
                if (distance < closestDistance) then closestDistance = distance end
                if (closestDistance < 50.0 and not pedCreated) then
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

function CreateBlips()
    for k, v in pairs(Config.Locations) do
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

function CreateTargets()
    for k, v in pairs(Config.Locations) do
        local options = {}

        if (v.event == nil) then
            for l, z in pairs(v.sellableitems) do
                table.insert(options, 
                    {
                        event = "bixbi_npcsales:Client",
                        icon = z.icon,
                        label = 'Sell ' .. z.label,
                        location = k,
                        required_item = l,
                    }
                )
            end
        else
            for l, z in pairs(v.sellableitems) do
                table.insert(options, 
                    {
                        event = v.event,
                        icon = z.icon,
                        label = z.label,
                        item = l,
                    }
                )
            end
        end
        

        -- exports['qtarget']:AddTargetModel({ v.model }, {
        --     options = options,
        --     distance = 2.0
        -- })

        exports['qtarget']:AddBoxZone(k .. '-npcsales', v.location, 0.6, 0.6, {
            name=v.blip.label,
            heading=v.heading,
            -- debugPoly=true,
            minZ=v.zcoords[1],
            maxZ=v.zcoords[2],
            }, {
                options = options,
                distance = 2.0
            }
        )
    end
end

RegisterNetEvent('bixbi_npcsales:Client')
AddEventHandler('bixbi_npcsales:Client', function(data)
    TriggerServerEvent('bixbi_npcsales:Server', data.required_item, data.location)
end)

RegisterNetEvent('bixbi_npcsales:Process')
AddEventHandler('bixbi_npcsales:Process', function(item, npcLoc)
    if (spawnedPed == nil) then return end
    local playerCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(spawnedPed)
    local dist = #(playerCoords - pedCoords)
    if (dist < 3.0) then
        local keyboard = exports["nh-keyboard"]:KeyboardInput({
            header = "How many to sell?", 
            rows = {
                {
                    id = 0, 
                    txt = "Quantity"
                }
            }
        })
        if keyboard ~= nil then
            if keyboard[1].input == nil then return end
            local quantity = tonumber(keyboard[1].input)

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
    else
        exports['bixbi_core']:Notify('error', 'You need to be closer.')
    end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        NPCRemoval()
	end
end)
