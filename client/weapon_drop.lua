local CurrentWeapon = {}

local Config = require 'shared.config'
local utils = require 'utils'
local state = require 'client.state'
local equippedWeapon = state.equippedWeapon

AddEventHandler('ox_inventory:currentWeapon', function(currentWeapon) CurrentWeapon = currentWeapon end)
if Config.DropWeaponOnDeath then

    AddEventHandler('gameEventTriggered', function(event, data)
        if event == 'CEventNetworkEntityDamage' then
            if data[1] == cache.ped and IsEntityDead(cache.ped) then
                if CurrentWeapon then
                    DeleteEntity(GetWeaponObjectFromPed(cache.ped))
                    TriggerServerEvent('mbt_malisling:dropWeapon', {
                        slot = CurrentWeapon.slot,
                        hash = GetWeapontypeModel(CurrentWeapon.hash)
                    })
                end
            end
        end
    end)
end

local function dropCurrentWeapon()
    local playerPed = cache.ped
    local boneIndex = GetPedBoneIndex(playerPed, 57005)
    local bonePos = GetWorldPositionOfEntityBone(playerPed, boneIndex)
    local weaponModel = GetWeapontypeModel(CurrentWeapon.hash)
    local currentWeapon = utils.tableDeepCopy(CurrentWeapon)
    lib.requestModel(weaponModel)
    equippedWeapon.dropped = true
    local weaponObj = CreateObject(weaponModel, bonePos.x, bonePos.y, bonePos.z, true, true, true)
    ActivatePhysics(weaponObj)
    TriggerEvent("ox_inventory:disarm", true)
    while IsEntityInAir(weaponObj) do Wait(250); end
    Wait(700)
    local weaponCoords = GetEntityCoords(weaponObj)
    Wait(10)
    DeleteObject(weaponObj)
    TriggerServerEvent("mbt_malisling:createWeaponDrop", {
        WeaponInfo = currentWeapon,
        Coords = weaponCoords
    })
end

exports('dropCurrentWeapon', dropCurrentWeapon)
