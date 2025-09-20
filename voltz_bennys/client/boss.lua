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

    local value = tonumber(input[1])
    if not value or value <= 0 then
        return
    end

    return math.floor(value)
end

local function fetchCompanyMoney()
    local p = promise.new()
    ESX.TriggerServerCallback('Voltz:mecanoArgentEntreprise', function(result)
        p:resolve(result)
    end)
    return Citizen.Await(p)
end

local function fetchSalaries()
    local p = promise.new()
    ESX.TriggerServerCallback('Voltz:mechanicSalaire', function(result)
        p:resolve(result)
    end)
    return Citizen.Await(p)
end

local function depositMoney()
    local amount = getAmountInput('Déposer dans la société')
    if not amount then
        notify('Montant invalide.', 'error')
        return
    end

    TriggerServerEvent('Voltz:mecanodepotentreprise', amount)
end

local function withdrawMoney()
    local amount = getAmountInput('Retirer de la société')
    if not amount then
        notify('Montant invalide.', 'error')
        return
    end

    TriggerServerEvent('Voltz:mecanoRetraitEntreprise', amount)
end

local function openBankMenu()
    local data = fetchCompanyMoney()
    local balanceText = 'Inconnu'

    if data and data[1] and data[1].money then
        balanceText = ('%s $'):format(ESX.Math.GroupDigits(data[1].money))
    end

    lib.registerContext({
        id = 'mecano_boss_bank',
        title = 'Banque entreprise',
        options = {
            {
                title = 'Déposer de l\'argent',
                icon = 'circle-down',
                onSelect = depositMoney
            },
            {
                title = 'Retirer de l\'argent',
                icon = 'circle-up',
                onSelect = withdrawMoney
            },
            {
                title = 'Solde actuel',
                description = balanceText,
                disabled = true
            }
        }
    })

    lib.showContext('mecano_boss_bank')
end

local function openSalaryMenu()
    local salaries = fetchSalaries()
    local options = {}

    if salaries then
        for _, grade in ipairs(salaries) do
            if grade.job_name == 'bennys' then
                local gradeLabel = grade.label
                local gradeSalary = grade.salary
                local gradeId = grade.id

                options[#options + 1] = {
                    title = gradeLabel,
                    description = ('%s $'):format(gradeSalary),
                    onSelect = function()
                        local amount = getAmountInput(('Salaire pour %s'):format(gradeLabel))
                        if not amount then
                            notify('Montant invalide.', 'error')
                            return
                        end

                        TriggerServerEvent('Voltz:mechanicNouveauSalaire', gradeId, gradeLabel, amount)
                        notify(('Salaire de %s mis à %s $.'):format(gradeLabel, amount), 'success')
                    end
                }
            end
        end
    end

    if #options == 0 then
        options[1] = {
            title = 'Aucun grade disponible',
            disabled = true
        }
    end

    lib.registerContext({
        id = 'mecano_boss_salaries',
        title = 'Salaires',
        options = options
    })

    lib.showContext('mecano_boss_salaries')
end

local function openBossMenu()
    lib.registerContext({
        id = 'mecano_boss',
        title = "Gestion Benny's",
        options = {
            {
                title = 'Banque entreprise',
                icon = 'wallet',
                onSelect = openBankMenu
            },
            {
                title = 'Salaire employé',
                icon = 'money-bill',
                onSelect = openSalaryMenu
            },
            {
                title = 'Ouvrir la gestion société',
                icon = 'briefcase',
                onSelect = function()
                    ExecuteCommand('society')
                end
            },
            {
                title = 'Fermer',
                icon = 'xmark',
                onSelect = function() end
            }
        }
    })

    lib.showContext('mecano_boss')
end

CreateThread(function()
    while true do
        ensurePlayerData()

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - Config.Pos.Boss)

        if distance <= 2.0 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'bennys' and ESX.PlayerData.job.grade_name == 'boss' then
            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour gérer l\'entreprise')
            DrawMarker(6, Config.Pos.Boss.x, Config.Pos.Boss.y, Config.Pos.Boss.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, nil, nil, false)

            if IsControlJustPressed(1, 51) then
                openBossMenu()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
