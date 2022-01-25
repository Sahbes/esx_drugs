ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_drugs:openPoochMenu')
AddEventHandler('esx_drugs:openPoochMenu', function()
    OpenPoochMenu()
end)

local currentAction = false

function OpenPoochMenu()

    local elements = {}

    for k, v in pairs(ESX.GetPlayerData().inventory) do
        if v.name == 'cannabis' then
            if v.count > 0 then
			    table.insert(elements, {label = v.label, value = v.name})
            end
        elseif v.name == 'chemicals' then
            if v.count > 0 then
                table.insert(elements, {label = v.label, value = v.name})
            end
        elseif v.name == 'coca_leaf' then
            if v.count > 0 then
                table.insert(elements, {label = v.label, value = v.name})
            end
		end
	end
  
    ESX.UI.Menu.CloseAll()
  
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'poochMenu',
    {
        title    = 'Drugs Verwerken',
        align    = 'center',
        elements = elements
    },
    function(data, menu)

        if currentAction == false then
            currentAction = true
            TriggerEvent('esx_illigal:usePooch', data.current.value)
            TriggerServerEvent('esx_drugs:removePooch')
        else
            ESX.ShowNotification('Wacht tot je klaar bent met verpakken')
        end

    end,function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('esx_drugs:clearAction')
AddEventHandler('esx_drugs:clearAction', function()
    currentAction = false
end)