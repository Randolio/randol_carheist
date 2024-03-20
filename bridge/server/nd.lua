if GetResourceState('ND_Core') ~= 'started' then return end

if GetResourceState('ox_inventory') ~= 'started' then
    return lib.print.error('ox inventory is required for ND bridge unless you make the changes yourself.')
end

local NDCore = exports["ND_Core"]

function GetPlayer(id)
    local player = NDCore:getPlayer(id)
    return player?.id
end

function DoNotification(src, text, nType)
    local player = NDCore:getPlayer(src)
    if not player then return end
    player.notify({ title = text, type = nType })
end

function GetPlyIdentifier(player)
    return player?.identifier
end

function GetByIdentifier(cid)
    local players = NDCore:getPlayers("identifier", cid, true)
    return players[1]
end

function GetSourceFromIdentifier(cid)
    local players = NDCore:getPlayers("identifier", cid, true)
    return players[1]?.source or false
end

function GetCharacterName(player)
    return player.fullname
end

function GetItemData(player, item)
    local data = exports.ox_inventory:GetSlotWithItem(player.source, item)
    return data, data.metadata
end

function RemoveHeistPapers(player, item, slot)
    exports.ox_inventory:RemoveItem(player.source, item, 1, nil, slot)
end

function AddRewardMoney(player, amount)
    exports.ox_inventory:AddItem(player.source, 'money', amount)
end

function AddHeistPapers(player, metadata)
    exports.ox_inventory:AddItem(player.source, 'heist_papers', 1, metadata)
end

function CheckCopCount()
    local cops = 0
    local players = NDCore:getPlayers()
    local policeDepartments = {"sahp", "lspd", "bcso"}

    for _, player in pairs(players) do
        for i=1, #policeDepartments do
            if player.groups[policeDepartments[i]] then
                cops += 1
            end
        end
    end
    
    return cops
end

function PoliceTracker(coords)
    local players = NDCore:getPlayers()
    local policeDepartments = {"sahp", "lspd", "bcso"}
    
    for _, player in pairs(players) do
        for i=1, #policeDepartments do
            if player.groups[policeDepartments[i]] then
                TriggerClientEvent('randol_carheist:client:trackerUpdate', player.source, coords)
            end
        end
    end
end

function AlertPolice(src, vehicle)
    if GetResourceState("ND_MDT") ~= "started" then return end
    
    local coords = GetEntityCoords(vehicle)
    local location = lib.callback.await("randol_carheist:getLocationText", src, coords)

    exports["ND_MDT"]:createDispatch({
        callDescription = "High value car theft",
        location = location,
        coords = coords
    })
end

AddEventHandler("ND:characterLoaded", function(player)
    OnServerPlayerLoaded(player.source)
end)

AddEventHandler("ND:characterUnloaded", function(source)
    OnServerPlayerUnload(source)
end)
