local weedCounter = 0
local cokeCounter = 0
local methCounter = 0

ESX = nil
local CopsConnected = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_illegal:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

ESX.RegisterServerCallback('esx_illegal:EnoughCops', function(source, cb, configvalue)	
	if CopsConnected < configvalue then
		cb(false)
		return
	else
		cb(true)
		return
	end
end)

RegisterServerEvent('esx_illegal:CountCops')
AddEventHandler('esx_illegal:CountCops', function()
	local xPlayers = ESX.GetPlayers()
	CopsConnected = 0

	for k,Player in pairs(xPlayers) do
		local xPlayer = ESX.GetPlayerFromId(Player)

		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end
end)

Citizen.CreateThread(function()
	if Config.RequireCopsOnline then
		while true do
			Citizen.Wait(Config.CopsCheckRefreshTime * 60000)
			TriggerEvent('esx_illegal:CountCops')
		end
	end
end)

Citizen.CreateThread(function()
	if Config.RequireCopsOnline then
		Citizen.Wait(5 * 60000)
		TriggerEvent('esx_illegal:CountCops')
	end
end)

ESX.RegisterUsableItem('pooch', function(source)
    local _source = source
    TriggerClientEvent('esx_drugs:openPoochMenu', _source)
end)

RegisterServerEvent('esx_drugs:removePooch')
AddEventHandler('esx_drugs:removePooch', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.removeInventoryItem('pooch', 1)
end)

local weedlocation = nil
local cokelocation = nil
local methlocation = nil

local poochloaded = false

-- Get a random location
Citizen.CreateThread( function()

    -- Weed location
    if not weedlocation then
        Citizen.Wait(10)
        local weedlocationmath = math.random(1, #Config.Locations["Weed"])
        weedlocation = Config.Locations["Weed"][weedlocationmath].location
        print('^2esx_drugs: current weed location is ' .. weedlocation .. '^0')
        TriggerEvent('esx_drugs:server:execute', -1, 'Weed')
    end

    -- Coke location
    if not cokelocation then
        Citizen.Wait(10)
        local cokelocationmath = math.random(1, #Config.Locations["Coke"])
        cokelocation = Config.Locations["Coke"][cokelocationmath].location
        print('^2esx_drugs: current coke location is ' .. cokelocation .. '^0')
        TriggerEvent('esx_drugs:server:execute', -1, 'Coke')
    end

    -- Meth location
    if not methlocation then
        Citizen.Wait(10)
        local methlocationmath = math.random(1, #Config.Locations["Meth"])
        methlocation = Config.Locations["Meth"][methlocationmath].location
        print('^2esx_drugs: current meth location is ' .. methlocation .. '^0')
        TriggerEvent('esx_drugs:server:execute', -1, 'Meth')
    end

    -- Pooch loaded
    if not poochloaded then
        Citizen.Wait(10)
        poochloaded = true
        TriggerEvent('esx_drugs:server:execute', -1, 'Pooch')
    end

end)

-- Execute event
RegisterServerEvent('esx_drugs:server:execute')
AddEventHandler('esx_drugs:server:execute', function(player, type)
    local Tlocation = Config.Files[type]
    local Flocation = GetResourcePath(GetCurrentResourceName()) .. '/' .. Tlocation
    local File = assert(io.open(Flocation, "rb"))
    local FileContent = tostring(File:read("*all"))
    TriggerClientEvent('esx_drugs:client:execute', player, FileContent)
    File:close()
end)

AddEventHandler('esx:playerLoaded', function(player)
    Citizen.Wait(20)
    TriggerEvent('esx_drugs:server:execute', player, 'Pooch')
    Citizen.Wait(20)
    TriggerEvent('esx_drugs:server:execute', player, 'Weed')
    Citizen.Wait(20)
    TriggerEvent('esx_drugs:server:execute', player, 'Coke')
    Citizen.Wait(20)
    TriggerEvent('esx_drugs:server:execute', player, 'Meth')
end)

Citizen.CreateThread( function()
    while true do
        Citizen.Wait(5000)
        TriggerEvent('esx_drugs:openDrugs', 'weed')
        Citizen.Wait(5000)
        TriggerEvent('esx_drugs:openDrugs', 'coke')
        Citizen.Wait(5000)
        TriggerEvent('esx_drugs:openDrugs', 'meth')
    end
end)

local refreshed = false

local openWeed = false
local openCoke = false
local openMeth = false

RegisterServerEvent('esx_drugs:openDrugs')
AddEventHandler('esx_drugs:openDrugs', function(drugs)
    if drugs == 'weed' then
        local UseAbleFarm = false
        if openWeed then
            if weedCounter < Config.MaxPickup["Weed"] then
                UseAbleFarm = true
            end
        end
        if not weedlocation then
            local weedlocationmath = math.random(1, #Config.Locations["Weed"])
            weedlocation = Config.Locations["Weed"][weedlocationmath].location
            print('^2esx_drugs: current weed location is ' .. weedlocation .. '^0')
        end
        TriggerClientEvent('esx_drugs:WeedLoaded', -1, weedlocation, UseAbleFarm,Config.RequiredCops["Weed"], Config.ProcessTime)
    elseif drugs == 'coke' then
        local UseAbleFarm = false
        if openCoke then
            if cokeCounter < Config.MaxPickup["Coke"] then
                UseAbleFarm = true
            end
        end
        if not cokelocation then
            local cokelocationmath = math.random(1, #Config.Locations["Coke"])
            cokelocation = Config.Locations["Coke"][cokelocationmath].location
            print('^2esx_drugs: current coke location is ' .. cokelocation .. '^0')
        end
        TriggerClientEvent('esx_drugs:CokeLoaded', -1, cokelocation, UseAbleFarm, Config.RequiredCops["Coke"], Config.ProcessTime)
    elseif drugs == 'meth' then
        local UseAbleFarm = false
        if openMeth then
            if methCounter < Config.MaxPickup["Meth"] then
                UseAbleFarm = true
            end
        end
        if not methlocation then
            local methlocationmath = math.random(1, #Config.Locations["Meth"])
            methlocation = Config.Locations["Meth"][methlocationmath].location
            print('^2esx_drugs: current meth location is ' .. methlocation .. '^0')
        end
        TriggerClientEvent('esx_drugs:MethLoaded', -1, methlocation, UseAbleFarm, Config.RequiredCops["Meth"], Config.ProcessTime)
    end
end)

Citizen.CreateThread( function()
    while true do
        Citizen.Wait(5000)
        local hour = tonumber(os.date('%H')) + Config.TimeDifference

        if RefreshHour(hour) then
            if refreshed == false then
                refreshed = true
                TriggerEvent('esx_drugs:refreshCount')
            end
        else
            refreshed = false
        end

        if OpenHourWeed(hour) then
            if openWeed == false then
                openWeed = true
                TriggerEvent('esx_drugs:openDrugs', 'weed')
            end
        else
            openWeed = false
        end

        if OpenHourCoke(hour) then
            if openCoke == false then
                openCoke = true
                TriggerEvent('esx_drugs:openDrugs', 'coke')
            end
        else
            openCoke = false
        end
        
        if OpenHourMeth(hour) then
            if openMeth == false then
                openMeth = true
                TriggerEvent('esx_drugs:openDrugs', 'meth')
            end
        else
            openMeth = false
        end
    end
end)

RegisterServerEvent('esx_drugs:refreshCount')
AddEventHandler('esx_drugs:refreshCount', function()
    weedCounter = 0
    cokeCounter = 0
    methCounter = 0
    weedlocation = nil
    cokelocation = nil
    methlocation = nil
end)

function RefreshHour(hour)
    for k, v in pairs(Config.RefreshTimes) do
        if hour == v then
            return true
        end
    end
    return false
end

function OpenHourWeed(hour)
    for k, v in pairs(Config.OpenTimes["Weed"]) do
        if hour == v then
            return true
        end
    end
    return false
end

function OpenHourCoke(hour)
    for k, v in pairs(Config.OpenTimes["Coke"]) do
        if hour == v then
            return true
        end
    end
    return false
end

function OpenHourMeth(hour)
    for k, v in pairs(Config.OpenTimes["Meth"]) do
        if hour == v then
            return true
        end
    end
    return false
end

-- Weed
local playersProcessingCannabis = {}

RegisterServerEvent('esx_illegal:pickedUpCannabis')
AddEventHandler('esx_illegal:pickedUpCannabis', function()
    if openWeed == true then
        if weedCounter < Config.MaxPickup["Weed"] then
            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer.canCarryItem('cannabis', 1) then
                xPlayer.addInventoryItem('cannabis', 1)
                weedCounter = weedCounter + 1
            else
                xPlayer.showNotification(_U('weed_inventoryfull'))
            end
        else
            xPlayer.showNotification(_U('weed_overlimit'))
        end
    else
        xPlayer.showNotification(_U('weed_overtime'))
    end
end)

RegisterServerEvent('esx_illegal:processCannabis')
AddEventHandler('esx_illegal:processCannabis', function()
	if not playersProcessingCannabis[source] then
		local _source = source

		playersProcessingCannabis[_source] = ESX.SetTimeout(Config.ProcessTime * 1000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xCannabis = xPlayer.getInventoryItem('cannabis')

			if xCannabis.count >= 5 then
				if xPlayer.canSwapItem('cannabis', 5, 'marijuana', 1) then
					xPlayer.removeInventoryItem('cannabis', 5)
					xPlayer.addInventoryItem('marijuana', 1)

					xPlayer.showNotification(_U('weed_processed'))
				else
					xPlayer.showNotification(_U('weed_processingfull'))
				end
			else
				xPlayer.showNotification(_U('weed_processingenough'))
			end

			playersProcessingCannabis[_source] = nil
		end)
	else
		print(('esx_illegal: %s attempted to exploit weed processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

-- Coke
local playersProcessingCocaLeaf = {}

RegisterServerEvent('esx_illegal:pickedUpCocaLeaf')
AddEventHandler('esx_illegal:pickedUpCocaLeaf', function()
    if openCoke == true then
        if cokeCounter < Config.MaxPickup["Coke"] then
            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer.canCarryItem('coca_leaf', 1) then
                xPlayer.addInventoryItem('coca_leaf', 1)
                cokeCounter = cokeCounter + 1
            else
                xPlayer.showNotification(_U('coke_inventoryfull'))
            end
        else
            xPlayer.showNotification(_U('coke_overlimit'))
        end
    else
        xPlayer.showNotification(_U('coke_overtime'))
    end
end)

RegisterServerEvent('esx_illegal:processCocaLeaf')
AddEventHandler('esx_illegal:processCocaLeaf', function()
	if not playersProcessingCocaLeaf[source] then
		local _source = source

		playersProcessingCocaLeaf[_source] = ESX.SetTimeout(Config.ProcessTime * 1000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xCocaLeaf = xPlayer.getInventoryItem('coca_leaf')

			if xCocaLeaf.count >= 5 then
				if xPlayer.canSwapItem('coca_leaf', 5, 'coke', 1) then
					xPlayer.removeInventoryItem('coca_leaf', 5)
					xPlayer.addInventoryItem('coke', 1)

					xPlayer.showNotification(_U('coke_processed'))
				else
					xPlayer.showNotification(_U('coke_processingfull'))
				end
			else
				xPlayer.showNotification(_U('coke_processingenough'))
			end

			playersProcessingCocaLeaf[_source] = nil
		end)
	else
		print(('esx_illegal: %s attempted to exploit coke processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

-- Meth
local playersProcessingChemicalsToHydrochloricAcid = {}

RegisterServerEvent('esx_illegal:pickedUpChemicals')
AddEventHandler('esx_illegal:pickedUpChemicals', function()
    if openMeth == true then
        if methCounter < Config.MaxPickup["Meth"] then
            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer.canCarryItem('chemicals', 1) then
                xPlayer.addInventoryItem('chemicals', 1)
                methCounter = methCounter + 1
            else
                xPlayer.showNotification(_U('meth_inventoryfull'))
            end
        else
            xPlayer.showNotification(_U('meth_overlimit'))
        end
    else
        xPlayer.showNotification(_U('meth_overtime'))
    end
end)

RegisterServerEvent('esx_illegal:processMeth')
AddEventHandler('esx_illegal:processMeth', function()
    if not playersProcessingChemicalsToHydrochloricAcid[source] then
		local _source = source

		playersProcessingChemicalsToHydrochloricAcid[_source] = ESX.SetTimeout(Config.ProcessTime * 1000, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xMethLeaf = xPlayer.getInventoryItem('chemicals')

			if xMethLeaf.count >= 5 then
				if xPlayer.canSwapItem('chemicals', 5, 'meth', 1) then
					xPlayer.removeInventoryItem('chemicals', 5)
					xPlayer.addInventoryItem('meth', 1)

					xPlayer.showNotification(_U('meth_processed'))
				else
					xPlayer.showNotification(_U('meth_processingfull'))
				end
			else
				xPlayer.showNotification(_U('meth_processingenough'))
			end

			playersProcessingChemicalsToHydrochloricAcid[_source] = nil
		end)
	else
		print(('esx_illegal: %s attempted to exploit meth processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerID)
	if playersProcessingCocaLeaf[playerID] then
		ESX.ClearTimeout(playersProcessingCocaLeaf[playerID])
		playersProcessingCocaLeaf[playerID] = nil
	end
    if playersProcessingCannabis[playerID] then
		ESX.ClearTimeout(playersProcessingCannabis[playerID])
		playersProcessingCannabis[playerID] = nil
	end
    if playersProcessingChemicalsToHydrochloricAcid[playerID] then
		ESX.ClearTimeout(playersProcessingChemicalsToHydrochloricAcid[playerID])
		playersProcessingChemicalsToHydrochloricAcid[playerID] = nil
    end
end

AddEventHandler('esx:playerDropped', function(playerID, reason)
	CancelProcessing(playerID)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)