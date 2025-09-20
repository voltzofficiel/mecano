local ESX = exports['es_extended']:getSharedObject()

local CurrentlyTowedVehicle

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

RegisterNetEvent('esx:setJob2', function(job2)
    ensurePlayerData()
    ESX.PlayerData.job2 = job2
end)

local function notify(description, type)
    lib.notify({
        title = "Benny's",
        description = description,
        type = type or 'inform'
    })
end

local function getAmountInput(title)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Montant', min = 1 }
    })

    if not input or not input[1] then
        return
    end

    local amount = tonumber(input[1])
    if not amount or amount <= 0 then
        return
    end

    return math.floor(amount)
end

local function getTextInput(title, label, maxLength)
    local input = lib.inputDialog(title, {
        {
            type = 'input',
            label = label,
            max = maxLength or 255
        }
    })

    if not input or not input[1] or input[1] == '' then
        return
    end

    return input[1]
end

local function getClosestVehicle(ped)
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end

    local coords = GetEntityCoords(ped)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        return vehicle
    end

    return nil
end

local function repairVehicle()
    local ped = PlayerPedId()
    local vehicle = getClosestVehicle(ped)

    if not vehicle then
        notify('Aucun véhicule à proximité.', 'error')
        return
    end

    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true)
    lib.progressCircle({
        duration = 10000,
        label = 'Réparation du véhicule...',
        useWhileDead = false,
        canCancel = true,
        position = 'bottom'
    })
    ClearPedTasksImmediately(ped)

    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true)
    notify('Véhicule réparé.', 'success')
end

local function cleanVehicle()
    local ped = PlayerPedId()
    local vehicle = getClosestVehicle(ped)

    if not vehicle then
        notify('Aucun véhicule à proximité.', 'error')
        return
    end

    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
    lib.progressCircle({
        duration = 10000,
        label = 'Nettoyage du véhicule...',
        useWhileDead = false,
        canCancel = true,
        position = 'bottom'
    })
    ClearPedTasksImmediately(ped)

    SetVehicleDirtLevel(vehicle, 0.0)
    notify('Véhicule nettoyé.', 'success')
end

local function unlockVehicle()
    local ped = PlayerPedId()
    local vehicle = getClosestVehicle(ped)

    if not vehicle then
        notify('Aucun véhicule à proximité.', 'error')
        return
    end

    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_WELDING', 0, true)
    lib.progressCircle({
        duration = 10000,
        label = 'Crochetage du véhicule...',
        useWhileDead = false,
        canCancel = true,
        position = 'bottom'
    })
    ClearPedTasksImmediately(ped)

    SetVehicleDoorsLocked(vehicle, 1)
    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
    notify('Véhicule déverrouillé.', 'success')
end

local function impoundVehicle()
    local ped = PlayerPedId()

    if not DoesEntityExist(ped) or IsEntityDead(ped) then
        return
    end

    if not IsPedSittingInAnyVehicle(ped) then
        notify('Installez-vous dans le véhicule à mettre en fourrière.', 'error')
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        notify('Vous devez être conducteur du véhicule.', 'error')
        return
    end

    TaskLeaveVehicle(ped, vehicle, 0)
    lib.progressCircle({
        duration = 10000,
        label = 'Mise en fourrière en cours...',
        useWhileDead = false,
        canCancel = true,
        position = 'bottom'
    })

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    notify('Le véhicule a été envoyé à la fourrière.', 'success')
end

local function attachTowTruck()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, true)

    if vehicle == 0 then
        notify('Vous devez être dans une dépanneuse.', 'error')
        return
    end

    local towModel = GetHashKey('flatbed')
    if not IsVehicleModel(vehicle, towModel) then
        notify('Vous devez utiliser une dépanneuse à plateau.', 'error')
        return
    end

    local targetVehicle = ESX.Game.GetVehicleInDirection()

    if not targetVehicle or targetVehicle == 0 then
        if CurrentlyTowedVehicle then
            AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
            DetachEntity(CurrentlyTowedVehicle, true, true)
            CurrentlyTowedVehicle = nil
            notify('Véhicule détaché.', 'inform')
        else
            notify('Aucun véhicule à attacher.', 'error')
        end
        return
    end

    if vehicle == targetVehicle then
        notify('Impossible d\'attacher votre propre dépanneuse.', 'error')
        return
    end

    TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
    lib.progressCircle({
        duration = 10000,
        label = 'Attache du véhicule...',
        useWhileDead = false,
        canCancel = true,
        position = 'bottom'
    })
    ClearPedTasksImmediately(playerPed)

    AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
    CurrentlyTowedVehicle = targetVehicle
    notify('Véhicule attaché.', 'success')
end

local function sendInvoice()
    local amount = getAmountInput('Facturation')

    if not amount then
        notify('Montant invalide.', 'error')
        return
    end

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 3.0 then
        notify('Aucun joueur à proximité.', 'error')
        return
    end

    TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_bennys', "Benny's", amount)
    notify('Facture envoyée.', 'success')
end

local function recruitPlayer()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 3.0 then
        notify('Aucun joueur à proximité.', 'error')
        return
    end

    TriggerServerEvent('Voltz:Recruter', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
end

local function manageClosest(eventName)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 3.0 then
        notify('Aucun joueur à proximité.', 'error')
        return
    end

    TriggerServerEvent(eventName, GetPlayerServerId(closestPlayer))
end

local function openManagementMenu()
    lib.registerContext({
        id = 'mecano_management',
        title = "Gestion d'entreprise",
        options = {
            {
                title = 'Recruter',
                onSelect = function()
                    recruitPlayer()
                end
            },
            {
                title = 'Promouvoir',
                onSelect = function()
                    manageClosest('Voltz:PromotionMecano')
                end
            },
            {
                title = 'Rétrograder',
                onSelect = function()
                    manageClosest('Voltz:Retrograder')
                end
            },
            {
                title = 'Virer',
                onSelect = function()
                    manageClosest('Voltz:Virer')
                end
            },
            {
                title = 'Gestion société',
                onSelect = function()
                    ExecuteCommand('society')
                end
            }
        }
    })

    lib.showContext('mecano_management')
end

local function openAnnouncementMenu()
    lib.registerContext({
        id = 'mecano_announces',
        title = 'Annonces',
        options = {
            {
                title = "Benny's ouvert",
                icon = 'bullhorn',
                onSelect = function()
                    TriggerServerEvent('Voltz:GarageOuvert')
                end
            },
            {
                title = "Benny's fermé",
                icon = 'bullhorn',
                onSelect = function()
                    TriggerServerEvent('Voltz:GarageFermer')
                end
            },
            {
                title = 'Annonce personnalisée',
                icon = 'pen',
                onSelect = function()
                    local message = getTextInput('Annonce personnalisée', 'Message', 105)
                    if not message then
                        notify('Message invalide.', 'error')
                        return
                    end

                    TriggerServerEvent('Voltz:MecanoMsgPerso', message)
                end
            }
        }
    })

    lib.showContext('mecano_announces')
end

local function openMechanicMenu()
    ensurePlayerData()

    if not ESX.PlayerData or not ESX.PlayerData.job or ESX.PlayerData.job.name ~= 'bennys' then
        return
    end

    local options = {
        { title = 'Annonces', icon = 'bullhorn', onSelect = openAnnouncementMenu },
        { title = 'Facturer un client', icon = 'file-invoice-dollar', onSelect = sendInvoice },
        { title = 'Réparer un véhicule', icon = 'screwdriver-wrench', onSelect = repairVehicle },
        { title = 'Nettoyer un véhicule', icon = 'broom', onSelect = cleanVehicle },
        { title = 'Crocheter un véhicule', icon = 'key', onSelect = unlockVehicle },
        { title = 'Mettre le véhicule sur le plateau', icon = 'truck-pickup', onSelect = attachTowTruck },
        { title = 'Envoyer en fourrière', icon = 'warehouse', onSelect = impoundVehicle }
    }

    if ESX.PlayerData.job.grade_name == 'boss' then
        options[#options + 1] = {
            title = "Gestion d'entreprise",
            icon = 'briefcase',
            onSelect = openManagementMenu
        }
    end

    lib.registerContext({
        id = 'mecano_main',
        title = 'Menu Mécano',
        options = options
    })

    lib.showContext('mecano_main')
end

lib.addKeybind({
    name = 'voltz_open_mecano',
    description = 'Ouvrir le menu Mécano',
    defaultKey = 'F6',
    onPressed = openMechanicMenu
})

CreateThread(function()
    local blip = AddBlipForCoord(Config.Pos.Blip)
    SetBlipSprite(blip, 446)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 47)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Benny's")
    EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('Voltz:alertmeca', function()
    ESX.ShowAdvancedNotification("Benny's", '~b~Secrétaire', "Un client vous attend à l'accueil.", 'CHAR_CARSITE3', 4)
end)

local function openReceptionMenu()
    lib.registerContext({
        id = 'mecano_reception',
        title = 'Accueil',
        options = {
            {
                title = 'Appeler un mécano',
                icon = 'phone',
                onSelect = function()
                    TriggerServerEvent('Voltz:AlertMecano')
                    notify('Demande envoyée.', 'success')
                end
            },
            {
                title = 'Fermer',
                icon = 'xmark',
                onSelect = function() end
            }
        }
    })

    lib.showContext('mecano_reception')
end

CreateThread(function()
    while true do
        ensurePlayerData()

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.Pos.Acceuil)

        if distance <= 2.0 then
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour parler à l'accueil")
            DrawMarker(6, Config.Pos.Acceuil.x, Config.Pos.Acceuil.y, Config.Pos.Acceuil.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, nil, nil, false)

            if IsControlJustPressed(1, 51) then
                openReceptionMenu()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
