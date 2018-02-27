local gouv = {x=-429.525,y=1109.5,z=327.682}
local office = {x=3069.9,y=-4632.4,z=16.2}
local sortie = {x=-80.489,y=-832.529,z=243.386}

local accountMoney = {x=-81.883,y=-808.073,z=243.39}

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

		DrawMarker(1,gouv.x,gouv.y,gouv.z-1,0,0,0,0,0,0,2.001,2.0001,0.5001,0,155,255,200,0,0,0,0)
		DrawMarker(1,sortie.x,sortie.y,sortie.z-1,0,0,0,0,0,0,2.001,2.0001,0.5001,0,155,255,200,0,0,0,0)

		if(isNear(gouv)) then
			if(playerJob == "gouv") then
				Info("Appuyez sur ~g~E~w~ pour entrer.")

				if(IsControlJustPressed(1, 38)) then
					SetEntityCoords(GetPlayerPed(-1),-75.8466, -826.9893, 243.3859)
				end
			else
				Info("Appuyez sur ~g~E~w~ pour sonner.")

				if(IsControlJustPressed(1, 38)) then
					TriggerServerEvent("gouv:sendSonnette")
				end
			end
		end

		if(isNear(sortie)) then
			Info("Appuyez sur ~g~E~w~ pour sortir.")

			if(IsControlJustPressed(1, 38)) then
				SetEntityCoords(GetPlayerPed(-1),gouv.x,gouv.y,gouv.z+1)
			end
		end

		if(playerGrade == "president" and playerJob == "gouv") then
			DrawMarker(1,accountMoney.x,accountMoney.y,accountMoney.z-1,0,0,0,0,0,0,2.001,2.0001,0.5001,0,155,255,200,0,0,0,0)

			if(isNear(accountMoney)) then
				Info("Appuyez sur ~g~E~w~ pour ouvrir le coffre.")

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
	SendNotification("~b~"..name.." ~w~a sonné à la porte du gouvernement.")
	SendNotification("~b~F~w~ pour ~g~accepter~w~ / ~b~G~w~ pour ~r~refuser~w~.")

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
		SetEntityCoords(GetPlayerPed(-1),-75.8466, -826.9893, 243.3859)
	else
		SendNotification("~r~Personne n'a voulu vous ouvrir la porte.")
	end
end)

function SendNotification(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(false, false)
end
