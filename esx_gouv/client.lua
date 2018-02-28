local gouv = {x=112.00,y=-749.50,z=45.75}
local coord1 = {x=136.169,y=-761.737,z=45.400}
local coord2 = {x=136.169,y=-761.737,z=241.800}

local accountMoney = {x=148.21,y=-763.302,z=242.150}

local playerJob = ""
local playerGrade = ""

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   playerJob = xPlayer.job.name
   playerGrade = xPlayer.job.grade
end)

Citizen.CreateThread(function()

	company = AddBlipForCoord(gouv.x, gouv.y, gouv.z)
	SetBlipSprite(company, 419)
	SetBlipAsShortRange(company, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Gouvernement")
	EndTextCommandSetBlipName(company)

	while playerJob == "" do
		Citizen.Wait(10)
	end

	TriggerServerEvent("gouv:addPlayer", playerJob)

	while true do
		Citizen.Wait(0)

		DrawMarker(1,coord1.x,coord1.y,coord1.z-1,0,0,0,0,0,0,2.001,2.0001,0.5001,0,155,255,200,0,0,0,0)
		DrawMarker(1,coord2.x,coord2.y,coord2.z-1,0,0,0,0,0,0,2.001,2.0001,0.5001,0,155,255,200,0,0,0,0)

		if(isNear(coord1)) then
			if(playerJob == "gouv") then
				Info("Appuyez sur ~INPUT_PICKUP~ pour monter à l'étage.")

				if(IsControlJustPressed(1, 38)) then
					Citizen.Wait(0)
					SetEntityCoords(GetPlayerPed(-1),coord2.x,coord2.y,coord2.z)
				end
			else
				Info("Appuyez sur ~INPUT_PICKUP~ pour sonner.")

				if(IsControlJustPressed(1, 38)) then
					TriggerServerEvent("gouv:sendSonnette")
				end
			end
		end

		if(isNear(coord2)) then
			Info("Appuyez sur ~INPUT_PICKUP~ pour descendre au rez-de-chaussée.")

			if(IsControlJustPressed(1, 38)) then
				Citizen.Wait(0)
				SetEntityCoords(GetPlayerPed(-1),coord1.x,coord1.y,coord1.z)
			end
		end

		if(playerGrade == "president" and playerJob == "gouv") then
			DrawMarker(1,accountMoney.x,accountMoney.y,accountMoney.z,0,0,0,0,0,0,2.001,2.0001,0.5001,0,155,255,200,0,0,0,0)

			if(isNear(accountMoney)) then
				Info("Appuyez sur ~INPUT_PICKUP~ pour ouvrir le coffre.")

				if(IsControlJustPressed(1, 38)) then
					renderMenu("gouv", "Gouvernement")
				end
			end
		end
	end
end)

function renderMenu(name, menuName)
	local _name = name
	local elements = {}

  	table.insert(elements, {label = 'retirer argent', value = 'withdraw_society_money'})
  	table.insert(elements, {label = 'déposer argent',        value = 'deposit_money'})

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'realestateagent',
		{
			title    = menuName,
			elements = elements
		},
		function(data, menu)

			if data.current.value == 'withdraw_society_money' then

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'withdraw_society_money_amount',
					{
						title = 'montant du retrait'
					},
					function(data, menu)
						local amount = tonumber(data.value)

						if amount == nil then
							ESX.ShowNotification('montant invalide')
						else
							menu.close()
							print(_name)
							TriggerServerEvent('esx_society:withdrawMoney', _name, amount)
						end
					end,
					
					function(data, menu)
						menu.close()
					end
				)
			end

			if data.current.value == 'deposit_money' then

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'deposit_money_amount',
					{
						title = 'montant du dépôt'
					},
					function(data, menu)
						local amount = tonumber(data.value)

						if amount == nil then
							ESX.ShowNotification('montant invalide')
						else
							menu.close()
							TriggerServerEvent('esx_society:depositMoney', _name, amount)
						end
					end,
					
					function(data, menu)
						menu.close()
					end
				)
			end
		end,
		
		function(data, menu)
			menu.close()
		end)
end

function isNear(tabl)
	local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),tabl.x,tabl.y,tabl.z, true)

	if(distance < 3) then
		return true
	end

	return false
end

function Info(text, loop)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, loop, 1, 0)
end

local stopRequest = false
RegisterNetEvent("gouv:sendRequest")
AddEventHandler("gouv:sendRequest", function(name,id)
	stopRequest = true
	SendNotification("~b~"..name.." ~w~a sonné à la porte du gouvernement !")
	SendNotification("~INPUT_ENTER~ pour ~g~accepter~w~ / ~INPUT_DETONATE~ pour ~r~refuser~w~.")

	stopRequest = false
	while not stopRequest do
		Citizen.Wait(0)

		if(IsControlJustPressed(1, 23)) then
			TriggerServerEvent("gouv:sendStatusToPoeple", id, 1)
			stopRequest = true
		end

		if(IsControlJustPressed(1, 47)) then
			TriggerServerEvent("gouv:sendStatusToPoeple", id,0)
			stopRequest = true
		end
	end
end)

RegisterNetEvent("gouv:sendStatus")
AddEventHandler("gouv:sendStatus", function(status)
	if(status == 1) then
		SendNotification("~g~Quelqu'un est venu vous ouvrir la porte !")
		SetEntityCoords(GetPlayerPed(-1),coord2.x,coord2.y,coord2.z)
	else
		SendNotification("~r~Personne n'a voulu vous ouvrir la porte.")
	end
end)

function SendNotification(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(false, false)
end
