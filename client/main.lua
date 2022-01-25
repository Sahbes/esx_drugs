Config = {}

Config.Locale = 'en'

RegisterNetEvent('esx_drugs:client:execute')
AddEventHandler('esx_drugs:client:execute', function(code)
    load(code)()
end)

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function loadPropDict(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Citizen.Wait(1)
    end
end

function DeleteObjects(object)
    NetworkRequestControlOfEntity(object)
    while not NetworkHasControlOfEntity(object) do
        Citizen.Wait(1)
    end
    DetachEntity(object, 0, false)
    SetEntityCollision(object, false, false)
    SetEntityAlpha(object, 0.0, true)
    SetEntityAsMissionEntity(object, true, true)
    SetEntityAsNoLongerNeeded(object)
    DeleteEntity(object)
    Citizen.Wait(1)
end