ESX = exports["es_extended"]:getSharedObject()

local PlayerData = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    ESX.PlayerData.job2 = job2
end)

menugarage = {
    Base = {Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 215, 255}, Title = "Garage"},
    Data = {currentMenu = "Menu :"},
    Events = {
        onSelected = function(self, _, btn, pMenu, menuData, result )

            for i=1, #GarageList, 1 do 
                if btn.name == GarageList[i].name then
                    local pi = GarageList[i].label
                    local po = GetHashKey(pi)
                    RequestModel(po)
                    while not HasModelLoaded(po) do Wait(0) end
                    local pipo = CreateVehicle(po, Config.Pos.SpawnVehicule, true, false)
                    TaskWarpPedIntoVehicle(PlayerPedId(), pipo, -1)
                    SetVehRadioStation(pipo, "OFF")
                    CloseMenu()

                    CreateThread(function()
                    
                        while true do 

                            local ped = PlayerPedId()
                            local pos = GetEntityCoords(ped)
                            local menu = Config.Pos.DeleteVehicle
                            local dist = #(pos - menu)
                            
                            if dist <= 2 then

                                ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour ranger le : ~b~"..pi)
                                if IsControlJustPressed(1, 51) then
                                    DeleteVehicle(pipo)
                                    return
                                end 
                            else
                                Wait(1000)
                            end
                            Wait(0)
                        end
                    end)
                end
            end
        end,
},
    Menu = {
        ["Menu :"] = {
            b = {
            }
        }
    }
}

CreateThread(function()

    for i=1, #GarageList, 1 do 
        table.insert(menugarage.Menu["Menu :"].b, { name = GarageList[i].name, ask = "", askX = true})
    end

    while true do 

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local menu = Config.Pos.Garage
        local dist = #(pos - menu)

        if dist <= 2 and ESX.PlayerData.job.name == "bennys" then

            ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour ouvrir le ~b~menu")
            DrawMarker(6, menu, nil, nil, nil, -90, nil, nil, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, false, false, false)

            if IsControlJustPressed(1,51) then
                CreateMenu(menugarage)
            end
        else
            Wait(1000)
        end
        Wait(0)
    end
end)