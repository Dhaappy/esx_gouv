local players = {}

RegisterServerEvent("gouv:addPlayer")
AddEventHandler("gouv:addPlayer", function(jobName)
	local _source = source
	players[_source] = jobName
end)

AddEventHandler("playerDropped", function(reason)
	--players[_source] = nil
end)

RegisterServerEvent("gouv:sendSonnette")
AddEventHandler("gouv:sendSonnette", function()
	local _source = source
	for i,k in pairs(players) do
		if(k~=nil) then
			if(k == "gouv") then
				TriggerClientEvent("gouv:sendRequest", i, GetPlayerName(_source), _source)
			end
		end
	end

end)

RegisterServerEvent("gouv:sendStatusToPoeple")
AddEventHandler("gouv:sendStatusToPoeple", function(id, status)
	TriggerClientEvent("gouv:sendStatus", id, status)
end)