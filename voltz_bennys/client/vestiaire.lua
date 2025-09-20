local ESX = exports['es_extended']:getSharedObject()

local function ensurePlayerData()
    if ESX.PlayerData and ESX.PlayerData.job then
        return
    end

    ESX.PlayerData = ESX.GetPlayerData()
end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
    ensurePlayerData()
    ESX.PlayerData.job = job
end)

local function applyMechanicOutfit()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local outfit = Config.Tenue.Homme
        if skin.sex ~= 0 then
            outfit = Config.Tenue.Femme
        end

        if outfit then
            TriggerEvent('skinchanger:loadClothes', skin, outfit)
        end
    end)
end

local function applyCivilianOutfit()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end

local function openLockerRoom()
    lib.registerContext({
        id = 'mecano_vestiaire',
        title = 'Vestiaire',
        options = {
            {
                title = 'Tenue mécano',
                icon = 'shirt',
                onSelect = applyMechanicOutfit
            },
            {
                title = 'Tenue civile',
                icon = 'user',
                onSelect = applyCivilianOutfit
            },
            {
                title = 'Fermer',
                icon = 'xmark',
                onSelect = function() end
            }
        }
    })

    lib.showContext('mecano_vestiaire')
end

CreateThread(function()
    while true do
        ensurePlayerData()

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.Pos.Vestiaire)

        if distance <= 2.0 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'bennys' then
            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le ~b~vestiaire')
            DrawMarker(6, Config.Pos.Vestiaire.x, Config.Pos.Vestiaire.y, Config.Pos.Vestiaire.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, nil, nil, false)

            if IsControlJustPressed(1, 51) then
                openLockerRoom()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
