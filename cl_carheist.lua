local spawnBlip, zoneDrop, blip2, HEIST_CAR, START_PED, pedZone, policeBlip, garageZone
local robberyactive, trackerActive, dropoffVehicle = false
local Config = {}
local myData = {}

local function targetLocalEntity(entity, options, distance)
    if GetResourceState('ox_target') == 'started' then
        for _, option in ipairs(options) do
            option.distance = distance
            option.onSelect = option.action
            option.action = nil
        end
        exports.ox_target:addLocalEntity(entity, options)
    else
        exports['qb-target']:AddTargetEntity(entity, { options = options, distance = distance })
    end
end

local function yeetPed()
    if not DoesEntityExist(START_PED) then return end
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeLocalEntity(START_PED, {'Start Job', 'Return Papers'})
    else
        exports['qb-target']:RemoveTargetEntity(START_PED, {'Start Job', 'Return Papers'})
    end
    DeleteEntity(START_PED)
    START_PED = nil
end

local function spawnPed()
    if DoesEntityExist(START_PED) then return end
    
    lib.requestModel(Config.PedModel)
    START_PED = CreatePed(0, Config.PedModel, Config.PedCoords, false, false)
    SetEntityAsMissionEntity(START_PED)
    SetPedFleeAttributes(START_PED, 0, 0)
    SetBlockingOfNonTemporaryEvents(START_PED, true)
    SetEntityInvincible(START_PED, true)
    FreezeEntityPosition(START_PED, true)
    TaskStartScenarioInPlace(START_PED, 'WORLD_HUMAN_SMOKING_POT', 0, true)
    SetModelAsNoLongerNeeded(Config.PedModel)

    targetLocalEntity(START_PED, {
        {
            icon = 'fa-solid fa-square-check',
            label = 'Start Job',
            action = function()
                local data = lib.callback.await('randol_carheist:attemptjob', false)
                if type(data) == 'table' then
                    myData = data
                    stealPoint()
                end
            end,
        },
        {
            icon = 'fa-solid fa-square-check',
            label = 'Return Papers',
            item = 'heist_papers',
            action = function()
                lib.callback.await('randol_carheist:server:returnPapers', false)
            end,
        },
    }, 1.3)
end

local function createPedPoint()
    pedZone = lib.points.new({ coords = Config.PedCoords.xyz, distance = 50, onEnter = spawnPed, onExit = yeetPed, })
end

local function CreateBlip(x, y)
    local offsetSign = math.random(-100, 100)/100
    local blip = AddBlipForRadius(x, y, 0.0, 100.0)
    SetBlipSprite(blip, 9)
    SetBlipColour(blip, 27)
    SetBlipAlpha(blip, 80)
    return blip
end

local function CreateBlip2(dropoff)
    RemoveBlip(spawnBlip)
    blip2 = AddBlipForCoord(dropoff.x, dropoff.y, dropoff.z)
    SetBlipSprite(blip2, 315)
    SetBlipColour(blip2, 1)
    SetBlipAlpha(blip2, 200)
    SetBlipDisplay(blip2, 4)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Drop Off')
    EndTextCommandSetBlipName(blip2)
    createDropZone(dropoff)
end

local function DeleteBlip()
    if DoesBlipExist(spawnBlip) then RemoveBlip(spawnBlip) end
    if DoesBlipExist(blip2) then RemoveBlip(blip2) end
end

local function dropoffVehicle()
    local vehicle = cache.vehicle

    if not vehicle or not robberyactive or vehicle ~= HEIST_CAR then return end

    FreezeEntityPosition(vehicle, true)
    droppingOff = true

    if lib.progressCircle({
        duration = 3000,
        position = 'bottom',
        label = 'Delivering vehicle..',
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, mouse = false, combat = true, },
    }) then
        DeleteBlip()
        TaskLeaveVehicle(cache.ped, vehicle, 1)
        Wait(2000)
        local success = lib.callback.await('randol_carheist:server:finishHeist', false, NetworkGetNetworkIdFromEntity(vehicle))
        if success then 
            droppingOff = false
            lib.hideTextUI()
            zoneDrop:remove()
            HEIST_CAR, dropoff, zoneDrop, spawnBlip, blip2, coords, vehicle = nil
            table.wipe(myData)
        end
    end
end

function createDropZone(coords)
    zoneDrop = lib.zones.box({ 
        coords = coords, 
        size = vector3(6, 6, 6), 
        rotation = 0, 
        debug = Config.Debug, 
        inside = function()
            if IsControlJustReleased(0, 38) and not droppingOff then
                if not trackerActive then
                    dropoffVehicle()
                else
                    DoNotification('You can\'t deliver while the tracker is still active.', 'error')
                end
            end
        end, 
        onEnter = function()
            lib.showTextUI('[E] - Drop Off Vehicle', { icon = 'fa-solid fa-car', position = 'left-center', })
        end, 
        onExit = function()
            lib.hideTextUI()
        end,
    })
end

RegisterNetEvent('randol_carheist:client:resetHeist', function()
    if GetInvokingResource() then return end

    if policeBlip then RemoveBlip(policeBlip) policeBlip = nil end
    if zoneDrop then zoneDrop:remove() zoneDrop  = nil end

    DeleteBlip()

    if robberyactive then
        DoNotification('You ran out of time, ditch the car.', 'error', 10000)
        PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', 1)
        robberyactive = false
    end

    trackerActive = false
    HEIST_CAR, spawnBlip, blip2 = nil
    table.wipe(myData)
    if garageZone then
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:removeZone(garageZone)
        else
            exports['qb-target']:RemoveZone(garageZone)
        end
        garageZone = nil
    end
end)

RegisterNetEvent('randol_carheist:client:trackerOff', function()
    if GetInvokingResource() then return end

    if policeBlip then RemoveBlip(policeBlip) policeBlip = nil end

    if robberyactive then
        DoNotification('The tracker has expired.', 'success', 10000)
        PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', 1)
        trackerActive = false
    end
end)

RegisterNetEvent('randol_carheist:client:trackerUpdate', function(coords)
    if GetInvokingResource() then return end

    if policeBlip then RemoveBlip(policeBlip) policeBlip = nil end
    policeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(policeBlip, 161)
    SetBlipDisplay(policeBlip, 4)
    SetBlipScale(policeBlip, 1.0)
    SetBlipColour(policeBlip, 1)
    PulseBlip(policeBlip)
    SetBlipAsShortRange(policeBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('CAR HEIST')
    EndTextCommandSetBlipName(policeBlip)
end)

RegisterNetEvent('randol_carheist:client:endRobbery', function()
    if GetInvokingResource() then return end

    robberyactive, trackerActive = false
    if policeBlip then RemoveBlip(policeBlip) policeBlip = nil end
    HEIST_CAR, spawnBlip, blip2 = nil

    table.wipe(myData)
    if garageZone then
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:removeZone(garageZone)
        else
            exports['qb-target']:RemoveZone(garageZone)
        end
        garageZone = nil
    end
end)

local function initVehicle(netid)
    HEIST_CAR = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netid) then
            return NetToVeh(netid)
        end
    end, 'Could not load entity in time.', 2000)

    SetVehicleNumberPlateText(HEIST_CAR, 'CARH'..tostring(math.random(1000, 9999)))
    SetEntityAsMissionEntity(HEIST_CAR, true, true)
    SetVehicleColours(HEIST_CAR, math.random(160), math.random(160))
    SetVehicleDoorsLocked(HEIST_CAR, 1)
    handleVehicleKeys(HEIST_CAR)

    if Config.FuelScript.enable then
        exports[Config.FuelScript.name]:SetFuel(HEIST_CAR, 100.0)
    else
        Entity(HEIST_CAR).state.fuel = 100
    end

    if AlertPolice then
        AlertPolice(HEIST_CAR)
    end
    
    robberyactive = true
    trackerActive = true
    DoNotification('You found the correct vehicle. Outdrive the tracker!', 'success')
    RemoveBlip(spawnBlip)
    spawnBlip = nil
    SetNewWaypoint(myData.delivery.x, myData.delivery.y)
    CreateBlip2(myData.delivery)
end

local function enterGarage(coords)
    if garageZone then
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:removeZone(garageZone)
        else
            exports['qb-target']:RemoveZone(garageZone)
        end
        garageZone = nil
    end
    SetEntityHeading(cache.ped, coords.w)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z-1.0)
    Wait(100)
    local offset = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, -1.1, -0.95)
    SetEntityCoords(cache.ped, offset)
    lib.requestAnimDict('anim@apt_trans@garage')
    TaskPlayAnim(cache.ped, 'anim@apt_trans@garage', 'gar_open_1_left', 8.0, -8.0, -1, 02, 0, 0, 0, 0)
    RemoveAnimDict('anim@apt_trans@garage')
    Wait(2000)
    DoScreenFadeOut(500)
    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, 'GARAGE_DOOR_SCRIPTED_OPEN', 0, true)
    ReleaseSoundId(soundId)
    Wait(1000)
    ClearPedTasksImmediately(cache.ped)
    Wait(100)
    local netid = lib.callback.await('randol_carheist:server:createVehicle', false)
    initVehicle(netid)
    Wait(1000)
    DoScreenFadeIn(1000)
end

function stealPoint()
    local vehicle = myData.model
    local label = GetLabelText(GetDisplayNameFromVehicleModel(vehicle))
    local coords = myData.location.enter

    spawnBlip = CreateBlip(coords.x, coords.y)
    if Config.Debug then SetNewWaypoint(coords.x, coords.y) end

    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', 1)
    DoNotification(('You need to retrieve a %s. It has been marked on your gps.'):format(label), 'success')

    if GetResourceState('ox_target') == 'started' then
        garageZone = exports.ox_target:addSphereZone({
            name = 'garage_enter',
            coords = vec3(coords.x, coords.y, coords.z),
            radius = 1.0,
            debug = false,
            options = {
                {
                    icon = 'fa-solid fa-circle',
                    label = 'Enter Garage',
                    onSelect = function()
                        enterGarage(coords)
                    end,
                    distance = 2.5,
                },
                
            }
        })
    else
        exports['qb-target']:AddCircleZone('garage_enter', vec3(coords.x, coords.y, coords.z), 1.0, {
            name ='garage_enter',
            useZ =true,
        }, {options = {
            {
                icon = 'fa-solid fa-circle',
                label = 'Enter Garage',
                action = function()
                    enterGarage(coords)
                end,
            },
        },
        distance = 2.5})
        garageZone = 'garage_enter'
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if pedZone then pedZone:remove() pedZone = nil end
        yeetPed()
        if garageZone then
            if GetResourceState('ox_target') == 'started' then
                exports.ox_target:removeZone(garageZone)
            else
                exports['qb-target']:RemoveZone(garageZone)
            end
            garageZone = nil
        end
        table.wipe(myData)
    end
end)

function OnPlayerLogout()
    if pedZone then pedZone:remove() pedZone = nil end
    if zoneDrop then zoneDrop:remove() zoneDrop = nil end
    if policeBlip then RemoveBlip(policeBlip) policeBlip = nil end

    DeleteBlip()
    robberyactive, trackerActive = false
    HEIST_CAR, spawnBlip, blip2 = nil
    yeetPed()

    if garageZone then
        if GetResourceState('ox_target') == 'started' then
            exports.ox_target:removeZone(garageZone)
        else
            exports['qb-target']:RemoveZone(garageZone)
        end
        garageZone = nil
    end
    table.wipe(myData)
end

RegisterNetEvent('randol_carheist:cacheConfig', function(data)
    if GetInvokingResource() or not hasPlyLoaded() then return end
    Config = data
    Wait(1000)
    createPedPoint()
end)