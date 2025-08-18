local Config = require 'shared.config'
if not Config.Jamming["Enabled"] then return end

local utils = require 'utils'
local currentWeapon

local jamAnim = Config.Jamming["Animation"]
local isJammed = false
LocalPlayer.state:set('JammedState', false, false)

AddEventHandler('ox_inventory:currentWeapon', function(data)
    currentWeapon = data
end)

local function skillCheck()
    Wait(1000)
    local success

    repeat
        success = lib.skillCheck({ 'easy', 'easy', { areaSize = 50, speedMultiplier = 1 }, 'easy' }, { 'w', 'a', 'd' })
        Wait(success and 100 or 800)
    until success

    isJammed = false
    TriggerServerEvent('mbt_malisling:unjamWeapon')
end

local function disableFiring()
    while isJammed do
        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 25, true)
        Wait(5)
    end
end

local function jammedAnim()
    lib.requestAnimDict(jamAnim["Dict"])
    while isJammed do
        TaskPlayAnim(cache.ped, jamAnim["Dict"], jamAnim["Anim"], 2.0, 2.0, 750, 48, 0.0, false, false, false)
        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 25, true)
        Wait(800)
    end
    ClearPedTasks(cache.ped)
    RemoveAnimDict(jamAnim["Dict"])
end

AddStateBagChangeHandler('JammedState', nil, function(bagName, key, value)
    if value == nil or type(value) ~= "boolean" then return end
    isJammed = value
    utils.mbtDebugger("isJammed has been set to ", isJammed)

    if isJammed then
        Config.Notification(Config.Labels["has_jammed"])
        Citizen.CreateThread(function()
            disableFiring()
        end)
        Citizen.CreateThread(function()
            jammedAnim()
        end)
        Citizen.CreateThread(function()
            skillCheck()
        end)
    else
        Config.Notification(Config.Labels["has_unjammed"])
    end
end)

AddEventHandler("CEventGunShot", function(entities, eventEntity, args)
    if currentWeapon and not isJammed then
        TriggerServerEvent('mbt_malisling:shotFired', currentWeapon.slot)
    end
end)

RegisterNetEvent('mbt_malisling:useRepairKit', function(data)
    if type(data) ~= 'table' then return end
    TriggerServerEvent('mbt_malisling:repairWeapon', data)
end)
