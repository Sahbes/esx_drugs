local methCoords = nil
local methLoaded = false
local methCanFarm = false

local requiredCops = 0
local processTime = 0

RegisterNetEvent('esx_drugs:MethLoaded')
AddEventHandler('esx_drugs:MethLoaded', function(location, canFarm, cops, process)
    methCoords = location
    methCanFarm = canFarm
    requiredCops = cops
    processTime = process
    methLoaded = true
end)

Citizen.CreateThread( function()
    while methLoaded == false do
        Citizen.Wait(10)
    end

    local SpawnedChemicals = 0
    local Chemicals = {}
    local isPickingUp, isProcessing = false, false

    Citizen.CreateThread( function()
        while true do
            Citizen.Wait(0)
            if methCanFarm == false then
                if #Chemicals > 0 then
                    for k, v in pairs(Chemicals) do
                        ESX.Game.DeleteObject(v)
                    end
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10)
            if methCanFarm == true then
                local coords = GetEntityCoords(PlayerPedId())

                if GetDistanceBetweenCoords(coords, methCoords, true) < 100 then
                    SpawnChemicals()
                    Citizen.Wait(500)
                else
                    Citizen.Wait(500)
                end
            end
        end
    end)

    RegisterNetEvent('esx_illigal:usePooch')
    AddEventHandler('esx_illigal:usePooch', function(type)
        if type == 'chemicals' then
            if requiredCops > 0 then
                ESX.TriggerServerCallback('esx_illegal:EnoughCops', function(cb)
                    if cb then
                        ProcessMeth()
                    else
                        ESX.ShowNotification(_U('cops_notenough'))
                    end
                end, requiredCops)
            else
                ProcessMeth()
            end
        end
    end)

    function ProcessMeth()
        isProcessing = true

        ESX.ShowNotification(_U('meth_processingstarted'))
        TriggerServerEvent('esx_illegal:processMeth')
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

            for i=1, #Chemicals, 1 do
                if GetDistanceBetweenCoords(coords, GetEntityCoords(Chemicals[i]), false) < 3.5 then
                    nearbyObject, nearbyID = Chemicals[i], i
                end
            end

            if nearbyObject and IsPedOnFoot(playerPed) then

                if not isPickingUp then
                    ESX.ShowHelpNotification(_U('chemicals_pickupprompt'))
                end

                if IsControlJustReleased(0, 38) and not isPickingUp then
                    if not IsPedInAnyVehicle(playerPed, true) then
                        if requiredCops > 0 then
                            ESX.TriggerServerCallback('esx_illegal:EnoughCops', function(cb)
                                if cb then
                                    PickUpChemicals(playerPed, coords, nearbyObject, nearbyID)
                                else
                                    ESX.ShowNotification(_U('cops_notenough'))
                                end
                            end, requiredCops)
                        else
                            PickUpChemicals(playerPed, coords, nearbyObject, nearbyID)
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

    function PickUpChemicals(playerPed, coords, nearbyObject, nearbyID)
        if methCanFarm == true then

            isPickingUp = true

            ESX.TriggerServerCallback('esx_illegal:canPickUp', function(canPickUp)

                if canPickUp then
                    TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_KNEEL', 0, false)
        
                    Citizen.Wait(2000)
                    ClearPedTasks(playerPed)
                    Citizen.Wait(1500)
        
                    ESX.Game.DeleteObject(nearbyObject)
        
                    table.remove(Chemicals, nearbyID)
        
                    TriggerServerEvent('esx_illegal:pickedUpChemicals')
                    Citizen.Wait(5000)
                    SpawnedChemicals = SpawnedChemicals - 1
                else
                    ESX.ShowNotification(_U('chemicals_inventoryfull'))
                end

                isPickingUp = false

            end, 'chemicals')
        else
            ESX.ShowNotification(_U('meth_overlimit'))
        end
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then
            for k, v in pairs(Chemicals) do
                ESX.Game.DeleteObject(v)
            end
        end
    end)

    function SpawnChemicals()
        while SpawnedChemicals < 4 do
            Citizen.Wait(0)
            local chemicalsCoords = GenerateMethCoords()
    
            ESX.Game.SpawnLocalObject('prop_barrel_02a', chemicalsCoords, function(obj)
                PlaceObjectOnGroundProperly(obj)
                FreezeEntityPosition(obj, true)
    
                table.insert(Chemicals, obj)
                SpawnedChemicals = SpawnedChemicals + 1
            end)
        end
    end

    function ValidateMethCoord(plantCoord)
        if SpawnedChemicals > 0 then
            local validate = true
    
            for k, v in pairs(Chemicals) do
                if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
                    validate = false
                end
            end
    
            if GetDistanceBetweenCoords(plantCoord, methCoords, false) > 30 then
                validate = false
            end

            return validate
        else
            return true
        end
    end

    function GenerateMethCoords()
        while true do
            Citizen.Wait(1)

            local methCoordX, methCoordY

            math.randomseed(GetGameTimer())
            local modX = math.random(-5, 5)

            Citizen.Wait(100)

            math.randomseed(GetGameTimer())
            local modY = math.random(-5, 5)

            methCoordX = methCoords.x + modX
            methCoordY = methCoords.y + modY

            local coordZ = GetCoordZMeth(methCoordX, methCoordY)
            local coord = vector3(methCoordX, methCoordY, coordZ)

            if ValidateMethCoord(coord) then
                return coord
            end
        end
    end

    function GetCoordZMeth(x, y)
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