local cokeCoords = nil
local cokeLoaded = false
local cokeCanFarm = false

local requiredCops = 0
local processTime = 0

RegisterNetEvent('esx_drugs:CokeLoaded')
AddEventHandler('esx_drugs:CokeLoaded', function(location, canFarm, cops, process)
    cokeCoords = location
    cokeCanFarm = canFarm
    requiredCops = cops
    processTime = process
    cokeLoaded = true
end)

Citizen.CreateThread( function()
    while cokeLoaded == false do
        Citizen.Wait(10)
    end

    local spawnedCocaLeaf = 0
    local CocaPlants = {}
    local isPickingUp, isProcessing = false, false

    Citizen.CreateThread( function()
        while true do
            Citizen.Wait(0)
            if cokeCanFarm == false then
                if #CocaPlants > 0 then
                    for k, v in pairs(CocaPlants) do
                        ESX.Game.DeleteObject(v)
                    end
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10)
            if cokeCanFarm == true then
                local coords = GetEntityCoords(PlayerPedId())

                if GetDistanceBetweenCoords(coords, cokeCoords, true) < 100 then
                    SpawnCocaPlants()
                    Citizen.Wait(500)
                else
                    Citizen.Wait(500)
                end
            end
        end
    end)

    RegisterNetEvent('esx_illigal:usePooch')
    AddEventHandler('esx_illigal:usePooch', function(type)
        if type == 'coca_leaf' then
            if requiredCops > 0 then
                ESX.TriggerServerCallback('esx_illegal:EnoughCops', function(cb)
                    if cb then
                        ProcessCoke()
                    else
                        ESX.ShowNotification(_U('cops_notenough'))
                    end
                end, requiredCops)
            else
                ProcessCoke()
            end
        end
    end)

    function ProcessCoke()
        isProcessing = true
    
        ESX.ShowNotification(_U('coke_processingstarted'))
        TriggerServerEvent('esx_illegal:processCocaLeaf')
        local timeLeft = processTime
        local playerPed = PlayerPedId()
    
        loadPropDict('bkr_prop_weed_bag_01a')
        local prop = CreateObject(GetHashKey('bkr_prop_weed_bag_01a'), 1.0, 1.0, 1.0, 1, 1, 0)
        local bone = GetPedBoneIndex(playerPed, 28422)
        AttachEntityToEntity(prop, playerPed, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
    
        if not IsPedInAnyVehicle(playerPed, false) then
            loadAnimDict('amb@code_human_wander_texting@male@idle_a')
            TaskPlayAnim(playerPed, 'amb@code_human_wander_texting@male@idle_a', 'idle_a', 5.0, -1, -1, 50, 0, false, false, false)
        end
    
        while timeLeft > 0 do
            Citizen.Wait(1000)
            timeLeft = timeLeft - 1
        end
    
        SetEntityAsNoLongerNeeded(prop)
        DeleteObjects(prop)
    
        if DoesEntityExist(prop) then
            DeleteObjects(prop)
        end
    
        if DoesEntityExist(prop) then
            DeleteObjects(prop)
        end
    
        StopAnimTask(playerPed, 'amb@code_human_wander_texting@male@idle_a', 'idle_a', 5.0)
    
        isProcessing = false
        TriggerEvent('esx_drugs:clearAction')
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local nearbyObject, nearbyID

            for i=1, #CocaPlants, 1 do
                if GetDistanceBetweenCoords(coords, GetEntityCoords(CocaPlants[i]), false) < 1 then
                    nearbyObject, nearbyID = CocaPlants[i], i
                end
            end

            if nearbyObject and IsPedOnFoot(playerPed) then

                if not isPickingUp then
                    ESX.ShowHelpNotification(_U('coke_pickupprompt'))
                end

                if IsControlJustReleased(0, 38) and not isPickingUp then
                    if not IsPedInAnyVehicle(playerPed, true) then
                        if requiredCops > 0 then
                            ESX.TriggerServerCallback('esx_illegal:EnoughCops', function(cb)
                                if cb then
                                    PickUpCocaLeaf(playerPed, coords, nearbyObject, nearbyID)
                                else
                                    ESX.ShowNotification(_U('cops_notenough'))
                                end
                            end, requiredCops)
                        else
                            PickUpCocaLeaf(playerPed, coords, nearbyObject, nearbyID)
                        end
                    else
                        ESX.ShowNotification(_U('need_on_foot'))
                    end
                end

            else
                Citizen.Wait(500)
            end

        end

    end)

    function PickUpCocaLeaf(playerPed, coords, nearbyObject, nearbyID)
        if cokeCanFarm == true then

            isPickingUp = true

	        ESX.TriggerServerCallback('esx_illegal:canPickUp', function(canPickUp)
		
                if canPickUp then
                    TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

                    Citizen.Wait(2000)
                    ClearPedTasks(playerPed)
                    Citizen.Wait(1500)

                    ESX.Game.DeleteObject(nearbyObject)

                    table.remove(CocaPlants, nearbyID)

                    TriggerServerEvent('esx_illegal:pickedUpCocaLeaf')
                    Citizen.Wait(5000)
                    spawnedCocaLeaf = spawnedCocaLeaf - 1
                else
                    ESX.ShowNotification(_U('coke_inventoryfull'))
                end

                isPickingUp = false

	        end, 'coca_leaf')
        else
            ESX.ShowNotification(_U('coke_overlimit'))
        end
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then
            for k, v in pairs(CocaPlants) do
                ESX.Game.DeleteObject(v)
            end
        end
    end)

    function SpawnCocaPlants()
        while spawnedCocaLeaf < 25 do
            Citizen.Wait(0)
            if cokeCanFarm == true then
                local cokeCoords2 = GenerateCocaLeafCoords()

                ESX.Game.SpawnLocalObject('prop_plant_01a', cokeCoords2, function(obj)
                    PlaceObjectOnGroundProperly(obj)
                    FreezeEntityPosition(obj, true)
        
                    table.insert(CocaPlants, obj)
                    spawnedCocaLeaf = spawnedCocaLeaf + 1
                end)
            else
                Citizen.Wait(200)
            end
        end
    end

    function ValidateCocaLeafCoord(plantCoord)
        if spawnedCocaLeaf > 0 then
            local validate = true

            for k, v in pairs(CocaPlants) do
                if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
                    validate = false
                end
            end

            if GetDistanceBetweenCoords(plantCoord, cokeCoords, false) > 50 then
                validate = false
            end

            return validate
        else
            return true
        end
    end

    function GenerateCocaLeafCoords()
        while true do
            Citizen.Wait(1)
    
            local cokeCoordX, cokeCoordY
    
            math.randomseed(GetGameTimer())
            local modX = math.random(-25, 25)
    
            Citizen.Wait(100)
    
            math.randomseed(GetGameTimer())
            local modY = math.random(-25, 25)
    
            cokeCoordX = cokeCoords.x + modX
            cokeCoordY = cokeCoords.y + modY
    
            local coordZ = GetCoordZCoke(cokeCoordX, cokeCoordY)
            local coord = vector3(cokeCoordX, cokeCoordY, coordZ)
    
            if ValidateCocaLeafCoord(coord) then
                return coord
            end
        end
    end

    function GetCoordZCoke(x, y)
        local groundCheckHeights = { 50, 51.0, 52.0, 53.0, 54.0, 55.0, 56.0, 57.0, 58.0, 59.0, 60.0, 61.0, 62.0, 63.0, 64.0, 65.0, 66.0, 67.0, 68.0, 69.0, 70.0, 71.0, 72.0, 73.0, 74.0, 75.0, 76.0, 77.0, 78.0, 79.0, 80.0, 81.0, 82.0, 83.0, 84.0, 85.0, 86.0, 87.0, 88.0, 89.0, 90.0, 91.0 }

        for i, height in ipairs(groundCheckHeights) do
            local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

            if foundGround then
                return z
            end
        end
        
        return 53.85
    end
end)