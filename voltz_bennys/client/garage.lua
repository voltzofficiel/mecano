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

local function notify(description, type)
    lib.notify({
        title = 'Garage',
        description = description,
        type = type or 'inform'
    })
end

local function storeVehicle(vehicle)
    DeleteVehicle(vehicle)
    notify('Véhicule rangé.', 'success')
end

local function monitorVehicleStorage(vehicle, label)
    CreateThread(function()
        while DoesEntityExist(vehicle) do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local distance = #(pos - Config.Pos.DeleteVehicle)

            if distance <= 2.0 then
                ESX.ShowHelpNotification(('Appuyez sur ~INPUT_CONTEXT~ pour ranger le ~b~%s'):format(label))
                if IsControlJustPressed(1, 51) then
                    storeVehicle(vehicle)
                    return
                end
            else
                Wait(500)
            end

            Wait(0)
        end
    end)
end

local function spawnGarageVehicle(vehicleData)
    local model = GetHashKey(vehicleData.label)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local vehicle = CreateVehicle(model, Config.Pos.SpawnVehicule.x, Config.Pos.SpawnVehicule.y, Config.Pos.SpawnVehicule.z, Config.Pos.SpawnVehicule.w, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehRadioStation(vehicle, 'OFF')

    notify(('Vous avez sorti le véhicule ~b~%s'):format(vehicleData.name), 'success')
    monitorVehicleStorage(vehicle, vehicleData.name)
end

local function openGarageMenu()
    ensurePlayerData()

    if not ESX.PlayerData or not ESX.PlayerData.job or ESX.PlayerData.job.name ~= 'bennys' then
        notify("Vous n'avez pas accès au garage.", 'error')
        return
    end

    local options = {}
    for _, vehicle in ipairs(GarageList) do
        options[#options + 1] = {
            title = vehicle.name,
            description = vehicle.label,
            onSelect = function()
                spawnGarageVehicle(vehicle)
            end
        }
    end

    if #options == 0 then
        options[1] = {
            title = 'Aucun véhicule disponible',
            disabled = true
        }
    end

    lib.registerContext({
        id = 'mecano_garage',
        title = 'Garage',
        options = options
    })

    lib.showContext('mecano_garage')
end

CreateThread(function()
    while true do
        ensurePlayerData()

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.Pos.Garage)

        if distance <= 2.0 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'bennys' then
            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le ~b~garage')
            DrawMarker(6, Config.Pos.Garage.x, Config.Pos.Garage.y, Config.Pos.Garage.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 0, 215, 255, 200, false, true, 2, false, nil, nil, false)

            if IsControlJustPressed(1, 51) then
                openGarageMenu()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
