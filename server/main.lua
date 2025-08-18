local utils = require 'utils'
local state = require 'server.state'
local scopesModule = require 'server.scopes'
local isESX = GetResourceState("es_extended") ~= "missing"
local FrameworkObj = {}
local isReady = false
local ox_inventory = exports["ox_inventory"]
local playersToTrack = state.playersToTrack
local weaponDurability = state.weaponDurability
local lastJam = state.lastJam
local addPlayerToPlayerScope = scopesModule.addPlayerToPlayerScope
local removePlayerFromScopes = scopesModule.removePlayerFromScopes
local TriggerScopeEvent = scopesModule.TriggerScopeEvent

if not lib.checkDependency('ox_inventory', '2.30.0') then warn("The script has not been tested with this versions of ox_inventory!") end

AddStateBagChangeHandler('WeaponFlashlightState', nil, function(bagName, key, value)
    if not value then return end

    local netId = bagName:gsub('player:', '')
    local playerSource = tonumber(netId)
    
    for slot, payload in pairs(value) do
        local weaponData = ox_inventory:GetSlot(playerSource, slot)

        if not weaponData then return end
        utils.mbtDebugger("Receiving WeaponFlashlightState ", payload.FlashlightState)
        utils.dumpTable(weaponData)
        
        weaponData.metadata.flashlightState = payload.FlashlightState
        ox_inventory:SetMetadata(playerSource, weaponData.slot, weaponData.metadata)
        
        utils.mbtDebugger("State of flashlight for weapon "..weaponData.label.." with serial "..weaponData.metadata.serial.." in slot "..weaponData.slot.." changed to "..tostring(weaponData.metadata.flashlightState))
        utils.mbtDebugger("State of flashlight for weapon "..weaponData.label.." with serial "..weaponData.metadata.serial.." in slot "..weaponData.slot.." changed to "..tostring(weaponData.metadata.flashlightState))
    end
end)

lib.callback.register('mbt_malisling:getWeapoConf', function(source)
    utils.mbtDebugger("getWeapoConf ~  Source ", source, " requested callback!")
    -- utils.mbtDebugger(MBT.WeaponsInfo)
    while not isReady do Wait(250) end
    return MBT.WeaponsInfo
end)

local function loadWeaponsInfo()
    utils.mbtDebugger("Loading WeaponsInfo!")

    local weaponsFile = LoadResourceFile("ox_inventory", 'data/weapons.lua')
    local weaponsChunk = assert(load(weaponsFile, ('@@ox_inventory/data/weapons.lua')))
    local weaponsInfo = weaponsChunk()

    for k, v in pairs(utils.data('weapons')) do
        if not weaponsInfo["Weapons"][k] then
            warn("Weapon not found in weapons data file: " .. k)
        else
            weaponsInfo["Weapons"][k]["type"] = v.type
        end
    end

    MBT.WeaponsInfo = weaponsInfo
    local b = MBT.EnableSling and true or false
    SetConvarReplicated("malisling:enable_sling", tostring(b))
    TriggerClientEvent("mbt_malisling:sendWeaponsData", -1, MBT.WeaponsInfo)
    isReady = true
end

---@param s number
local function dropPlayer(s)
    TriggerClientEvent("mbt_malisling:syncDeletion", -1,
        { playerSource = s, weaponType = "all", calledBy = "dropPlayer" })
    TriggerClientEvent("mbt_malisling:syncPlayerRemoval", -1, { playerSource = s })
    playersToTrack[s] = nil
    weaponDurability[s] = nil
    lastJam[s] = nil
    removePlayerFromScopes(s)
end


-- Check if the weaponanims convar is disabled
if GetConvarInt('inventory:weaponanims', 1) == 0 then
    warn(
    "You have enabled the sling feature, but you have disabled the weapons animation convar in ox_inventory. This will cause issues with animations and the sling feature. Please set inventory:weaponanims to 1")
end

if isESX then
    FrameworkObj = exports["es_extended"]:getSharedObject()

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(playerId)
        playersToTrack[playerId] = {}
        weaponDurability[playerId] = {}
        lastJam[playerId] = 0
    end)

    getPlayerJob = function (s)
        s = tonumber(s)
        local xPlayer = FrameworkObj.GetPlayerFromId(s)
        if not xPlayer then return "" end
        return xPlayer.job.name
    end

    getPlayerSex = function (s)
        s = tonumber(s)
        local xPlayer = FrameworkObj.GetPlayerFromId(s)
        if not xPlayer then return "male" end
        return xPlayer.get("sex") == "m" and "male" or "female"
    end

else
    getPlayerJob = function () return "" end
    getPlayerSex = function () return "male" end
end


AddEventHandler('onServerResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    loadWeaponsInfo()
end)

AddEventHandler("playerDropped", function()
    if not source then return end
    dropPlayer(source)
end)

RegisterNetEvent("mbt_malisling:getPlayersInPlayerScope")
AddEventHandler("mbt_malisling:getPlayersInPlayerScope", function(data)
    if not state.scopes[tostring(source)] then state.scopes[tostring(source)] = {} end
    for i = 1, #data do
        addPlayerToPlayerScope(source, data[i])
    end
end)

RegisterNetEvent("mbt_malisling:checkInventory")
AddEventHandler("mbt_malisling:checkInventory", function()
    utils.mbtDebugger("checkInventory ~ Checking inventory for source ", source)
    local inv = exports.ox_inventory:GetInventoryItems(source)
    -- utils.mbtDebugger(inv)
    TriggerClientEvent("mbt_malisling:checkWeaponProps", source, inv)
end)

RegisterNetEvent('mbt_malisling:syncSling', function(data)
    if type(data) ~= 'table' or type(data.playerWeapons) ~= 'table' then return end

    local maxTypes = utils.getTableLength(MBT.PropInfo)
    if utils.getTableLength(data.playerWeapons) > maxTypes then
        warn(('syncSling: too many weapon types from %s'):format(source))
        return
    end

    local _source = source
    playersToTrack[_source] = playersToTrack[_source] or {}

    for wType, weaponData in pairs(data.playerWeapons) do
        local propCfg = MBT.PropInfo[wType]
        local weaponInfo = type(weaponData) == 'table' and weaponData.name and MBT.WeaponsInfo and MBT.WeaponsInfo["Weapons"][weaponData.name]

        if propCfg and weaponInfo and weaponInfo.type == wType then
            playersToTrack[_source][wType] = weaponData
        else
            warn(('syncSling: invalid weapon type %s from %s'):format(tostring(wType), _source))
        end
    end

    TriggerScopeEvent({
        event = 'mbt_malisling:syncSling',
        scopeOwner = _source,
        selfTrigger = true,
        payload = {
            type = 'add',
            playerSource = _source,
            playerJob = getPlayerJob(_source),
            pedSex = getPlayerSex(_source),
            playerWeapons = playersToTrack[_source]
        }
    })
end)

RegisterNetEvent("mbt_malisling:syncDeletion")
AddEventHandler("mbt_malisling:syncDeletion", function(weaponType)
    local _source = source
    if playersToTrack[_source] == nil then return end
    playersToTrack[_source][weaponType] = false

    TriggerScopeEvent({
        event = "mbt_malisling:syncDeletion",
        scopeOwner = _source,
        selfTrigger = true,
        payload = {
            playerSource = _source,
            calledBy = "mbt_malisling:syncDeletion",
            weaponType = weaponType
        }
    })
end)

RegisterNetEvent('mbt_malisling:shotFired', function(slot)
    local src = source
    if not slot then return end

    local weaponData = ox_inventory:GetSlot(src, slot)
    if not weaponData or not weaponData.metadata then return end

    local durability = weaponData.metadata.durability or 100
    durability = math.max(durability - 1, 0)
    weaponData.metadata.durability = durability
    ox_inventory:SetMetadata(src, slot, weaponData.metadata)

    weaponDurability[src] = weaponDurability[src] or {}
    local serial = weaponData.metadata.serial or slot
    weaponDurability[src][serial] = durability

    local now = GetGameTimer()
    local cooldown = (MBT.Jamming["Cooldown"] or 0) * 1000
    lastJam[src] = lastJam[src] or 0
    if now - lastJam[src] >= cooldown and utils.getJammingChance(durability) then
        lastJam[src] = now
        local player = Player(src)
        if player then
            player.state:set('JammedState', true, true)
        end
    end
end)

RegisterNetEvent('mbt_malisling:unjamWeapon', function()
    local src = source
    local player = Player(src)
    if player then
        player.state:set('JammedState', false, true)
    end
end)

RegisterNetEvent('mbt_malisling:repairWeapon', function(data)
    local src = source
    if type(data) ~= 'table' then return end

    local slot = data.slot
    local item = data.item
    if not slot or not item then return end

    local weaponData = ox_inventory:GetSlot(src, slot)
    if not weaponData or not weaponData.metadata then return end

    local repairItem = ox_inventory:GetItem(src, item, nil, true)
    if not repairItem or repairItem.count < 1 then return end

    local durability = weaponData.metadata.durability or 100
    if durability >= 100 then return end

    weaponData.metadata.durability = 100
    ox_inventory:SetMetadata(src, slot, weaponData.metadata)

    weaponDurability[src] = weaponDurability[src] or {}
    local serial = weaponData.metadata.serial or slot
    weaponDurability[src][serial] = 100

    local player = Player(src)
    if player then
        player.state:set('JammedState', false, true)
    end

    ox_inventory:RemoveItem(src, item, 1)
end)
