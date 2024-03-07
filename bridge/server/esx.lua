if GetResourceState('es_extended') ~= 'started' then return end

if GetResourceState('ox_inventory') ~= 'started' then
    return lib.print.error('ox inventory is required for ESX bridge unless you make the changes yourself.')
end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function GetPlyIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetByIdentifier(cid)
    return ESX.GetPlayerFromIdentifier(cid)
end

function GetSourceFromIdentifier(cid)
    local xPlayer = ESX.GetPlayerFromIdentifier(cid)
    return xPlayer and xPlayer.source or false
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end

function GetItemData(xPlayer, item)
    local data = exports.ox_inventory:GetSlotWithItem(xPlayer.source, item)
    return data, data.metadata
end

function RemoveHeistPapers(xPlayer, item, slot)
    exports.ox_inventory:RemoveItem(xPlayer.source, item, 1, nil, slot)
end

function AddRewardMoney(xPlayer, amount)
    exports.ox_inventory:AddItem(xPlayer.source, 'money', amount)
end

function AddHeistPapers(xPlayer, metadata)
    exports.ox_inventory:AddItem(xPlayer.source, 'heist_papers', 1, metadata)
end

function CheckCopCount()
    local amount = 0
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do 
        local xPlayer = players[i]
        if xPlayer.job.name == 'police' then -- ESX don't have a playerdata for duty?
            amount += 1
        end
    end
    return amount
end

function PoliceTracker(coords)
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do 
        local xPlayer = players[i]
        if xPlayer.job.name == 'police' then -- ESX don't have a playerdata for duty?
            TriggerClientEvent('randol_carheist:client:trackerUpdate', xPlayer.source, coords)
        end
    end
end

AddEventHandler('esx:playerLogout', function(source)
    OnServerPlayerUnload(source)
end)

AddEventHandler('esx:playerLoaded', function(source)
    OnServerPlayerLoaded(source)
end)