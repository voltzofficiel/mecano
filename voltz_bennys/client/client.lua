ESX = exports["es_extended"]:getSharedObject()

local Voltzaal = {}
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



function RefreshMoney()
    Citizen.CreateThread(function()
            ESX.Math.GroupDigits(ESX.PlayerData.money)
            ESX.Math.GroupDigits(ESX.PlayerData.accounts[1].money)
            ESX.Math.GroupDigits(ESX.PlayerData.accounts[2].money)
    end)
end

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


function facturemecano()
    local amount = Keyboardput("Entré le montant", "", 15)
    
    if not amount then
      ESX.ShowNotification('~r~Montant invalide')
    else
  
      local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  
        if closestPlayer == -1 or closestDistance > 3.0 then
            ESX.ShowNotification('Pas de joueurs à ~b~proximité')
        else
            local playerPed = PlayerPedId()
  
            Citizen.CreateThread(function()
                ClearPedTasks(playerPed)
                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_bennys', "~b~Benny's", amount)
                ESX.ShowNotification("Vous avez bien envoyer la ~b~facture")
            end)
        end
    end
end
  

    function Keyboardput(TextEntry, ExampleText, MaxStringLength) 
      AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
      DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
      blockinput = true
      while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
          Citizen.Wait(0)
      end
      if UpdateOnscreenKeyboard() ~= 2 then
          local result = GetOnscreenKeyboardResult()
          Citizen.Wait(500)
          blockinput = false
          return result
      else
          Citizen.Wait(500)
          blockinput = false
          return nil
      end
  end

menumecano = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 251, 255}, Title = "Mécano"},
    Data = { currentMenu = "Menu", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)

            if btn.name == "Annonce" then
                OpenMenu("Annonce")
            elseif btn.name == "~b~Benny's ~s~Ouvert" then
                TriggerServerEvent('Voltz:GarageOuvert')
            elseif btn.name == "~b~Benny's ~s~Fermé" then
                TriggerServerEvent('Voltz:GarageFermer')
            elseif btn.name == "~b~Benny's ~s~personnalisé" then
                msgpersomecano = Keyboardput("Message", "", 105)
                TriggerServerEvent('Voltz:MecanoMsgPerso', msgpersomecano)
            elseif btn.name == "Facture" then
                facturemecano()


            elseif btn.name == "Réparer" then 

                local ped = PlayerPedId()
				local coords    = GetEntityCoords(ped)
				
				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					
					local vehicle = nil

					if IsPedInAnyVehicle(ped, false) then
						vehicle = GetVehiclePedIsIn(ped, false)
					else
						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
					end
					
					if DoesEntityExist(vehicle) then
						TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
						Citizen.CreateThread(function()
							Citizen.Wait(10000)
							SetVehicleFixed(vehicle)
							SetVehicleDeformationFixed(vehicle)
							SetVehicleUndriveable(vehicle, false)
							SetVehicleEngineOn(vehicle,  true,  true)
							ClearPedTasksImmediately(ped)
							ESX.ShowNotification('Véhicule ~b~réparé')
						end)
					end
                end
        
            elseif btn.name == 'Nettoyer' then
                    local ped = PlayerPedId()
                    local coords    = GetEntityCoords(ped)
                    
                    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
                        
                        local vehicle = nil
    
                        if IsPedInAnyVehicle(ped, false) then
                            vehicle = GetVehiclePedIsIn(ped, false)
                        else
                            vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
                        end
                        
                        if DoesEntityExist(vehicle) then
                            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_MAID_CLEAN", 0, true)
                            Citizen.CreateThread(function()
                                Citizen.Wait(10000)
                                SetVehicleDirtLevel(vehicle, 0)
                                ClearPedTasksImmediately(ped)
                                ESX.ShowNotification('Véhicule ~b~néttoyé')
                            end)
                        end
                    end
                
            elseif btn.name == "Crocheter" then
                local ped = PlayerPedId()
				local coords    = GetEntityCoords(ped)

				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

					local vehicle = nil

					if IsPedInAnyVehicle(ped, false) then
						vehicle = GetVehiclePedIsIn(ped, false)
					else
						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
					end

					if DoesEntityExist(vehicle) then
						TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)
						Citizen.CreateThread(function()
							Citizen.Wait(10000)
							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							ClearPedTasksImmediately(ped)
							ESX.ShowNotification('Véhicule ~g~déverouillé')
						end)
					end

				end
            elseif btn.name == "Mettre le véhicule sur le plateau" then
                attachedepanneuse()
                CloseMenu()
            elseif btn.name == "Mettre le véhicule en fourrière" then
                
                local ped = PlayerPedId()

				if (DoesEntityExist(ped) and not IsEntityDead(ped)) then 
					local pos = GetEntityCoords( ped )

					if (IsPedSittingInAnyVehicle(ped)) then 
						local vehicle = GetVehiclePedIsIn(ped, false)

						if (GetPedInVehicleSeat(vehicle, -1) == ped) then 
                            ESX.ShowAdvancedNotification('Mecano', '~b~Notification', "Le véhicule à été envoyé à la ~b~fourrière~s~ !", 'CHAR_CARSITE3', 8)
							SetEntityAsMissionEntity( vehicle, true, true )
							DeleteVehicle(vehicle)
						else 
							ESX.ShowNotification('Vous devez être assis du ~r~côté conducteur!')
						end 
					else
						local playerPos = GetEntityCoords(ped, 1)
						local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords(ped, 0.0, distanceToCheck, 0.0)

						if (DoesEntityExist(vehicle)) then
							ESX.ShowNotification('Vehicule ~r~mis en fourrière')
							SetEntityAsMissionEntity(vehicle, true, true)
							DeleteVehicle(vehicle)
						else 
							ESX.ShowNotification('Vous devez être ~r~près d\'un véhicule~s~ pour le mettre en fourrière')
						end 
					end 
				end

            end

if ESX.PlayerData.job.grade_name == 'boss' and ESX.PlayerData.job.name == "bennys" then
    if btn.name == "Gestion d'entreprise" then
        menumecano.Menu["Gestion"].b = {}
        table.insert(menumecano.Menu["Gestion"].b, { name = "Recruter", ask = "", askX = true})   
        table.insert(menumecano.Menu["Gestion"].b, { name = "Promouvoir", ask = "", askX = true})
        table.insert(menumecano.Menu["Gestion"].b, { name = "Destituer" , ask = "", askX = true})
        table.insert(menumecano.Menu["Gestion"].b, { name = "Virer", ask = "", askX = true})
        Citizen.Wait(200)
        ExecuteCommand("society")
        CloseMenu() -- ✅ Appel correct d’une fonction
    end
end
            if btn.name == "Recruter" then 
                if ESX.PlayerData.job.grade_name == 'boss'  then
                    Voltzaal.closestPlayer, Voltzaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Voltzaal.closestPlayer == -1 or Voltzaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Voltz:Recruter', GetPlayerServerId(Voltzaal.closestPlayer), ESX.PlayerData.job.name, 0)
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Promouvoir" then
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Voltzaal.closestPlayer, Voltzaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Voltzaal.closestPlayer == -1 or Voltzaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Voltz:PromotionMecano', GetPlayerServerId(Voltzaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Virer" then 
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Voltzaal.closestPlayer, Voltzaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Voltzaal.closestPlayer == -1 or Voltzaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Voltz:Virer', GetPlayerServerId(Voltzaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Destituer" then 
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Voltzaal.closestPlayer, Voltzaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Voltzaal.closestPlayer == -1 or Voltzaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Voltz:Retrograder', GetPlayerServerId(Voltzaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            end

           
end,
},
    Menu = {
        ["Menu"] = {
            b = {
                {name = "Annonce", ask = "", askX = true},
                {name = "Facture", ask = "", askX = true},
                {name = "Réparer", ask = "", askX = true},
                {name = "Nettoyer", ask = "", askX = true},
                {name = "Crocheter", ask = "", askX = true},
                {name = "Mettre le véhicule sur le plateau", ask = "", askX = true},
                {name = "Mettre le véhicule en fourrière", ask = "", askX = true},
                {name = "Gestion d'entreprise", ask = "", askX = true},

            }
        },
        ["Annonce"] = {
            b = {
                {name = "~b~Benny's ~s~Ouvert", ask = "", askX = true},
                {name = "~b~Benny's ~s~Fermé", ask = "", askX = true},
                {name = "~b~Benny's ~s~personnalisé", ask = "", askX = true},
            }
        },
        ["Gestion"] = {
            b = {
            }
        },
    }
}


keyRegister("VoltzOpenMecano", "Menu F6", "F6", function()
    if ESX.PlayerData.job.name == "bennys" then
        CreateMenu(menumecano)
    end
end)

Citizen.CreateThread(function()

    local blip = AddBlipForCoord(Config.Pos.Blip)
	SetBlipSprite (blip, 446)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour (blip, 47)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Benny's")
	EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('Voltz:alertmeca')
AddEventHandler('Voltz:alertmeca', function()
	ESX.ShowAdvancedNotification("Benny's", "~b~Secretaire", "Un client demande un ~b~mécanicien~s~ à l'acceuil", "CHAR_CARSITE3", 4)
end)

local menudemande = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 251, 255}, Title = "Acceuil"},
    Data = { currentMenu = "Menu"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)

            if btn.name == "Appelé un mécano" then
                TriggerServerEvent('Voltz:AlertMecano')
                CloseMenu()
            elseif btn.name == "~r~Fermé" then
                CloseMenu()
            end
        end,
},
    Menu = {
        ["Menu"] = {
            b = {
                {name = "Appelé un mécano", ask = "", askX = true},
                {name = "~r~Fermé", ask = "", askX = true},
            }
        }
    }
}

Citizen.CreateThread(function()

    while true do 

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local menu = Config.Pos.Acceuil
        local dist = #(pos - menu)

        if dist <= 2 then

            ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour ouvrir le ~b~menu")
            DrawMarker(6, menu, nil, nil, nil, -90, nil, nil, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, false, false, false)

            if IsControlJustPressed(1, 51) then
                CreateMenu(menudemande)
            end
        else
            Citizen.Wait(1000)
        end
        Citizen.Wait(0)
    end
end)

function attachedepanneuse()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, true)

    local car = "flatbed"
    local carh = GetHashKey(car)
    local isVehicleTow = IsVehicleModel(vehicle, carh)

    if isVehicleTow then
        local targetVehicle = ESX.Game.GetVehicleInDirection()

        if CurrentlyTowedVehicle == nil then
            if targetVehicle ~= 0 then
                if not IsPedInAnyVehicle(playerPed, true) then
                    if vehicle ~= targetVehicle then
                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                        Citizen.Wait(10000)
                        ClearPedTasksImmediately(playerPed)
                        AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
                        CurrentlyTowedVehicle = targetVehicle

                        if NPCOnJob then
                            if NPCTargetTowable == targetVehicle then
                                ESX.ShowNotification(_U('please_drop_off'))
                                Config.Zones.VehicleDelivery.Type = 1

                                if Blips['NPCTargetTowableZone'] then
                                    RemoveBlip(Blips['NPCTargetTowableZone'])
                                    Blips['NPCTargetTowableZone'] = nil
                                end

                                Blips['NPCDelivery'] = AddBlipForCoord(Config.Zones.VehicleDelivery.Pos.x, Config.Zones.VehicleDelivery.Pos.y, Config.Zones.VehicleDelivery.Pos.z)
                                SetBlipRoute(Blips['NPCDelivery'], true)
                            end
                        end
                    else
                        ESX.ShowAdvancedNotification('Mecano', '~r~Notification', "Vous ne pouvez pas attacher votre ~h~~r~propre véhicule de dépannage !", 'CHAR_CARSITE3', 8)
                    end
                end
            else
                ESX.ShowAdvancedNotification('Mecano', '~r~Notification', "Il n'y a pas de véhicule ~h~~r~attacher !", 'CHAR_CARSITE3', 8)
            end
        else
            AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
            DetachEntity(CurrentlyTowedVehicle, true, true)
            
            if NPCOnJob then
                if NPCTargetDeleterZone then

                    if CurrentlyTowedVehicle == NPCTargetTowable then
                        ESX.Game.DeleteVehicle(NPCTargetTowable)
                        TriggerServerEvent('esx_mechanicjob:onNPCJobMissionCompleted')
                        StopNPCJob()
                        NPCTargetDeleterZone = false
                    else
                        ESX.ShowAdvancedNotification('Mecano', '~r~Notification', "Ce n'est pas le bon ~h~~r~véhicule !", 'CHAR_CARSITE3', 8)
                    end

                else
                    ESX.ShowAdvancedNotification('Mecano', '~r~Notification', "Vous n'etes pas au bon endroit ~h~~r~pour faire cela !", 'CHAR_CARSITE3', 8)
                end
            end

            CurrentlyTowedVehicle = nil
        end
    else
        ESX.ShowAdvancedNotification('Mecano', '~r~Notification', "Vous devez avoir une ~r~~h~dépanneuse à plateau~s~ pour faire cela !", 'CHAR_CARSITE3', 8)
    end

end
