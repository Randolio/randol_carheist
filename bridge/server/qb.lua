if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local ox_inv = GetResourceState('ox_inventory') == 'started'

function GetPlayer(id)
    return QBCore.Functions.GetPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function GetPlyIdentifier(Player)
    return Player.PlayerData.citizenid
end

function GetSourceFromIdentifier(cid)
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    return Player and Player.PlayerData.source or false
end

function GetCharacterName(Player)
    return Player.PlayerData.charinfo.firstname.. ' ' ..Player.PlayerData.charinfo.lastname
end

function GetItemData(Player, item)
    local data = ox_inv and exports.ox_inventory:GetSlotWithItem(Player.PlayerData.source, item) or Player.Functions.GetItemByName(item)

    if not data then return false end

    local metadata = ox_inv and data.metadata or data.info
    return data, metadata
end

function RemoveHeistPapers(Player, item, slot)
    Player.Functions.RemoveItem(item, 1, slot)
    TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, QBCore.Shared.Items[item], 'remove')
end

function AddRewardMoney(Player, amount)
    Player.Functions.AddMoney('cash', amount)
end

function AddHeistPapers(Player, metadata)
    if ox_inv then
        exports.ox_inventory:AddItem(Player.PlayerData.source, 'heist_papers', 1, metadata)
    else
        Player.Functions.AddItem('heist_papers', 1, false, metadata)
        TriggerClientEvent("inventory:client:ItemBox", Player.PlayerData.source, QBCore.Shared.Items['heist_papers'], "add")
    end
end

function CheckCopCount()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(players) do
        if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
            amount += 1
        end
    end
    return amount
end

function PoliceTracker(coords)
    local players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(players) do
        if Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty then
            TriggerClientEvent('randol_carheist:client:trackerUpdate', Player.PlayerData.source, coords)
        end
    end
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    OnServerPlayerUnload(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    OnServerPlayerLoaded(source)
end)