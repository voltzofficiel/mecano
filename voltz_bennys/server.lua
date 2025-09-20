ESX = exports["es_extended"]:getSharedObject()
TriggerEvent('esx_society:registerSociety', 'bennys', 'bennys', 'society_bennys', 'society_bennys', 'society_bennys', {type = 'public'})


TriggerEvent('esx_addonaccount:getSharedAccount', 'society_bennys', function(account)
	societyAccount = account
end)

RegisterServerEvent('Voltz:GarageOuvert')
AddEventHandler('Voltz:GarageOuvert', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Benny's", '~b~Annonce', 'Nous sommes ~g~ouvert~s~ !', 'CHAR_CARSITE3', 8)
	end
end)

RegisterServerEvent('Voltz:GarageFermer')
AddEventHandler('Voltz:GarageFermer', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Benny's", '~b~Annonce', 'Nous sommes ~r~fermé~s~ !', 'CHAR_CARSITE3', 8)
	end
end)

RegisterServerEvent('Voltz:MecanoMsgPerso')
AddEventHandler('Voltz:MecanoMsgPerso', function(msgpersomecano)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Benny's", '~b~Annonce', msgpersomecano, 'CHAR_CARSITE3', 8)
	end
end)

RegisterServerEvent('Voltz:Recruter')
AddEventHandler('Voltz:Recruter', function(target, job, grade)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	targetXPlayer.setJob(job, grade)
	TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~recruté " .. targetXPlayer.name .. "~w~.")
	TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~embauché par " .. sourceXPlayer.name .. "~w~.")
end)

RegisterServerEvent('Voltz:PromotionMecano')
AddEventHandler('Voltz:PromotionMecano', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 3) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~b~promouvoir~w~ d'avantage.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) + 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~b~promu " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~b~promu~s~ par " .. sourceXPlayer.name .. "~w~.")
		end
	end
end)


RegisterServerEvent('Voltz:Retrograder')
AddEventHandler('Voltz:Retrograder', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~r~rétrograder~w~ d'avantage.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) - 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~rétrogradé " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~r~rétrogradé par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('Voltz:Virer')
AddEventHandler('Voltz:Virer', function(target)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local job = "unemployed"
	local grade = "0"
	if (sourceXPlayer.job.name == targetXPlayer.job.name) then
		targetXPlayer.setJob(job, grade)
		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~viré " .. targetXPlayer.name .. "~w~.")
		TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~viré par " .. sourceXPlayer.name .. "~w~.")
	else
		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
	end
end)



ESX.RegisterServerCallback('Voltz:Inventairemecano', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterServerEvent("Voltz:CoffreDeposemecano")
AddEventHandler("Voltz:CoffreDeposemecano", function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_bennys', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, "Vous avez déposé ~y~x"..count.." ~b~"..inventoryItem.label)
		else
			TriggerClientEvent('esx:showNotification', _source, "quantité invalide")
		end
	end)
end)

ESX.RegisterServerCallback('Voltz:CoffreSocietymecano', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_bennys', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('Voltz:RetireCoffremecano')
AddEventHandler('Voltz:RetireCoffremecano', function(itemName, count, itemLabel)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_bennys', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if count > 0 and inventoryItem.count >= count then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, "Vous avez retiré ~y~x"..count.." ~b~"..itemLabel)
		else
			TriggerClientEvent('esx:showNotification', _source, "Quantité invalide")
		end
	end)
end)

RegisterServerEvent('Voltz:AlertMecano')
AddEventHandler('Voltz:AlertMecano', function() 
	local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'bennys' then
			TriggerClientEvent('Voltz:alertmeca', xPlayer.source)
		end
	end
end)

ESX.RegisterServerCallback('Voltz:mechanicSalaire', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local salairemechanic = {}

    MySQL.Async.fetchAll('SELECT * FROM job_grades', {

    }, function(result)

        for i=1, #result, 1 do

            table.insert(salairemechanic, {
				id = result[i].id,
                job_name = result[i].job_name,
                label = result[i].label,
                salary = result[i].salary,
            })
        end
        cb(salairemechanic)
    end)
end)

RegisterServerEvent("Voltz:mechanicNouveauSalaire")
AddEventHandler("Voltz:mechanicNouveauSalaire", function(id, label, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    MySQL.Async.fetchAll("UPDATE job_grades SET salary = "..amount.." WHERE id = "..id,
	{
		['@id'] = id,
		['@salary'] = amount
	}, function (rowsChanged)
	end)
end)


ESX.RegisterServerCallback('Voltz:getSocietyMoney', function(source, cb, societyName)
	if societyName ~= nil then
	  local society = "society_bennys"
	  TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
		cb(account.money)
	  end)
	else
	  cb(0)
	end
end)

ESX.RegisterServerCallback('Voltz:mecanoArgentEntreprise', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local compteentreprise = {}


    MySQL.Async.fetchAll('SELECT * FROM addon_account_data WHERE account_name = "society_bennys"', {

    }, function(result)

        for i=1, #result, 1 do
            table.insert(compteentreprise, {
                account_name = result[i].account_name,
                money = result[i].money,
            })
        end
        cb(compteentreprise)
    end)
end)

RegisterServerEvent("Voltz:mecanodepotentreprise")
AddEventHandler("Voltz:mecanodepotentreprise", function(money)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local total = money
    local xMoney = xPlayer.getAccount("bank").money
    
    TriggerEvent('esx_addonaccount:getSharedAccount', "society_bennys", function (account)
        if xMoney >= total then
            account.addMoney(total)
            xPlayer.removeAccountMoney('bank', total)
            TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~mecano", "Vous avez déposé ~g~"..total.." $~s~ dans votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
        else
            TriggerClientEvent('esx:showNotification', source, "<C>~r~Vous n'avez pas assez d'argent !")
        end
    end)   
end)

RegisterServerEvent("Voltz:mecanoRetraitEntreprise")
AddEventHandler("Voltz:mecanoRetraitEntreprise", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	local xMoney = xPlayer.getAccount("bank").money
	
	TriggerEvent('esx_addonaccount:getSharedAccount', "society_bennys", function (account)
		if account.money >= total then
			account.removeMoney(total)
			xPlayer.addAccountMoney('bank', total)
			TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~mecano", "Vous avez retiré ~g~"..total.." $~s~ de votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
		else
			TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~mecano", "Vous avez pas assez d'argent dans votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
		end
	end)
end) 
