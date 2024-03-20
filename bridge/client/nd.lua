if GetResourceState("ND_Core") ~= "started" then return end

local NDCore = exports["ND_Core"]
local playerLoaded = false

AddEventHandler("ND:characterLoaded", function()
    playerLoaded = true
end)

AddEventHandler("ND:characterUnloaded", function()
    playerLoaded = false
    OnPlayerLogout()
end)

function handleVehicleKeys(veh)
    SetTimeout(1000, function()
        SetVehicleDoorsLocked(veh, 0)
    end)
end

function hasPlyLoaded()
    return playerLoaded
end

function DoNotification(text, nType)
    NDCore:notify({ title = text, type = nType })
end

lib.callback.register("randol_carheist:getLocationText", function(coords)
    local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    return ("%s %s"):format(street, zoneName)
end)
