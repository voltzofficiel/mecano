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
        title = 'Coffre',
        description = description,
        type = type or 'inform'
    })
end

local function getNumberInput(title, max)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Quantité', min = 1, max = max }
    })

    if not input or not input[1] then
        return
    end

    local value = tonumber(input[1])
    if not value or value <= 0 then
        return
    end

    return math.floor(value)
end

local function fetchInventory()
    local p = promise.new()
    ESX.TriggerServerCallback('Voltz:Inventairemecano', function(inventory)
        p:resolve(inventory)
    end)
    return Citizen.Await(p)
end

local function fetchStock()
    local p = promise.new()
    ESX.TriggerServerCallback('Voltz:CoffreSocietymecano', function(items)
        p:resolve(items)
    end)
    return Citizen.Await(p)
end

local function openDepositMenu()
    local inventory = fetchInventory()
    local options = {}

    if inventory and inventory.items then
        for _, item in ipairs(inventory.items) do
            if item.count and item.count > 0 then
                local itemName = item.name
                local itemLabel = item.label or item.name
                local itemCount = item.count

                options[#options + 1] = {
                    title = itemLabel,
                    description = ('x%s'):format(itemCount),
                    onSelect = function()
                        local quantity = getNumberInput(('Déposer %s'):format(itemLabel), itemCount)
                        if not quantity then
                            notify('Quantité invalide.', 'error')
                            return
                        end

                        TriggerServerEvent('Voltz:CoffreDeposemecano', itemName, quantity)
                        notify(('Vous avez déposé x%s %s'):format(quantity, itemLabel), 'success')
                    end
                }
            end
        end
    end

    if #options == 0 then
        options[1] = {
            title = 'Inventaire vide',
            disabled = true
        }
    end

    lib.registerContext({
        id = 'mecano_coffre_depot',
        title = 'Déposer au coffre',
        options = options
    })

    lib.showContext('mecano_coffre_depot')
end

local function openWithdrawMenu()
    local items = fetchStock()
    local options = {}

    if items then
        for _, item in ipairs(items) do
            if item.count and item.count > 0 then
                local itemName = item.name
                local itemLabel = item.label or item.name
                local itemCount = item.count

                options[#options + 1] = {
                    title = itemLabel,
                    description = ('x%s'):format(itemCount),
                    onSelect = function()
                        local quantity = getNumberInput(('Retirer %s'):format(itemLabel), itemCount)
                        if not quantity then
                            notify('Quantité invalide.', 'error')
                            return
                        end

                        TriggerServerEvent('Voltz:RetireCoffremecano', itemName, quantity, itemLabel)
                        notify(('Vous avez retiré x%s %s'):format(quantity, itemLabel), 'success')
                    end
                }
            end
        end
    end

    if #options == 0 then
        options[1] = {
            title = 'Coffre vide',
            disabled = true
        }
    end

    lib.registerContext({
        id = 'mecano_coffre_retrait',
        title = 'Retirer du coffre',
        options = options
    })

    lib.showContext('mecano_coffre_retrait')
end

local function openCoffreMenu()
    lib.registerContext({
        id = 'mecano_coffre',
        title = 'Coffre',
        options = {
            {
                title = 'Déposer',
                icon = 'arrow-down',
                onSelect = openDepositMenu
            },
            {
                title = 'Retirer',
                icon = 'arrow-up',
                onSelect = openWithdrawMenu
            },
            {
                title = 'Fermer',
                icon = 'xmark',
                onSelect = function() end
            }
        }
    })

    lib.showContext('mecano_coffre')
end

CreateThread(function()
    while true do
        ensurePlayerData()

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.Pos.Coffre)

        if distance <= 2.0 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'bennys' then
            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour accéder au ~b~coffre')
            DrawMarker(6, Config.Pos.Coffre.x, Config.Pos.Coffre.y, Config.Pos.Coffre.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, nil, nil, false)

            if IsControlJustPressed(1, 51) then
                openCoffreMenu()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
