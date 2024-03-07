local Server = lib.require('sv_config')
local thief
local onCooldown = false
local tracker = 0
local carHeist = {}

local function initCooldown(src)
    onCooldown = true
    SetTimeout(Server.Cooldown * 60000, function()
        if carHeist[src] then 
            carHeist[src] = nil
        end
        if thief then thief = nil end
        TriggerClientEvent('randol_carheist:client:resetHeist', -1)
        onCooldown = false
    end)
end

local function updateTracker(source, vehicle)
    CreateThread(function()
        while tracker < 60 do

            if not DoesEntityExist(vehicle) then
                if carHeist[source] then carHeist[source] = nil end
                thief = nil
                break 
            end

            local coords = GetEntityCoords(vehicle)
            PoliceTracker(coords)

            tracker += 1
            Wait(5000)
        end
        tracker = 0
        TriggerClientEvent('randol_carheist:client:trackerOff', -1)
    end)
end

local function createHeistVehicle(source, model, coords)
    -- Not gonna bother using server setter for a temporary vehicle, cry about it.
    local veh = CreateVehicle(joaat(model), coords.x, coords.y, coords.z, coords.w, true, true)
    local ped = GetPlayerPed(source)

    while not DoesEntityExist(veh) do Wait(0) end 

    while GetVehiclePedIsIn(ped, false) ~= veh do TaskWarpPedIntoVehicle(ped, veh, -1) Wait(0) end

    return veh
end

lib.callback.register('randol_carheist:server:finishHeist', function(source, heistcar)
    local src = source
    local Player = GetPlayer(src)
    local cid = GetPlyIdentifier(Player)

    if not carHeist[src] or not thief or thief ~= cid then return false end 

    local vehicle = NetworkGetEntityFromNetworkId(heistcar)

    if not DoesEntityExist(vehicle) or vehicle ~= carHeist[src].entity then return false end
    
    local pos = GetEntityCoords(GetPlayerPed(src))
    local coords = carHeist[src].delivery
    
    if #(pos - coords) > 10.0 then return false end

    DeleteEntity(vehicle)

    local amt = math.random(Server.Min, Server.Max)
    local metadata = {amount = amt, cid = cid, description = ('$%s'):format(amt)}
    AddHeistPapers(Player, metadata)

    carHeist[src], thief = nil
    TriggerClientEvent('randol_carheist:client:endRobbery', -1)
    return true
end)

lib.callback.register('randol_carheist:attemptjob', function(source)
    local src = source

    if carHeist[src] then return false end 

    local amount = CheckCopCount()

    if amount < Server.RequiredCops then 
        DoNotification(src, ('Not Enough Cops (%s)'):format(Server.RequiredCops), 'error')
        return false 
    end

    if onCooldown then
        DoNotification(src, 'Heist is on cooldown.', 'error')
        return false
    end

    local Player = GetPlayer(src)
    thief = GetPlyIdentifier(Player)

    carHeist[src] = {
        model = Server.VehicleList[math.random(#Server.VehicleList)],
        location = Server.SpawnLocations[math.random(#Server.SpawnLocations)],
        delivery = Server.DeliveryCoords[math.random(#Server.DeliveryCoords)],
        entity = 0,
    }

    initCooldown(src)
    return carHeist[src]
end)

lib.callback.register('randol_carheist:server:createVehicle', function(source)
    if not carHeist[source] then return false end

    local data = carHeist[source]
    local entity = createHeistVehicle(source, data.model, data.location.spawn)

    updateTracker(source, entity)
    carHeist[source].entity = entity

    return NetworkGetNetworkIdFromEntity(entity)
end)

lib.callback.register('randol_carheist:server:returnPapers', function(source)
    local src = source
    local Player = GetPlayer(src)
    local item, metadata = GetItemData(Player, 'heist_papers')

    if not item or not next(metadata) then return false end

    if GetPlyIdentifier(Player) ~= metadata.cid then
        DoNotification(src, 'These papers do not have your name on them.', 'error')
        return false
    end

    RemoveHeistPapers(Player, item.name, item.slot)
    AddRewardMoney(Player, metadata.amount)

    DoNotification(src, ('You received $%s for delivering the vehicle.'):format(metadata.amount), 'success')
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        SetTimeout(2000, function()
            TriggerClientEvent('randol_carheist:cacheConfig', -1, Server)
        end)
    end
end)

function OnServerPlayerLoaded(source)
    local src = source
    SetTimeout(2000, function()
        TriggerClientEvent('randol_carheist:cacheConfig', src, Server)
    end)
end

function OnServerPlayerUnload(source)
    if carHeist[source] then
        if DoesEntityExist(carHeist[source].entity) then DeleteEntity(carHeist[source].entity) end
        carHeist[source] = nil
    end
end

AddEventHandler('playerDropped', function()
    if carHeist[source] then
        if DoesEntityExist(carHeist[source].entity) then DeleteEntity(carHeist[source].entity) end
        carHeist[source] = nil
    end
end)