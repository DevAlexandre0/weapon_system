-- weapon_recoil.lua (clean + config-driven)

-- ===== Locals / natives =====
local PlayerId                    = PlayerId
local PlayerPedId                 = PlayerPedId
local GetSelectedPedWeapon        = GetSelectedPedWeapon
local IsPedShooting               = IsPedShooting
local IsPedArmed                  = IsPedArmed
local IsPedInAnyVehicle           = IsPedInAnyVehicle
local IsPlayerFreeAiming          = IsPlayerFreeAiming
local HasPedGotWeaponComponent    = HasPedGotWeaponComponent
local DisableControlAction        = DisableControlAction
local GetGameTimer                = GetGameTimer
local GetFollowPedCamViewMode     = GetFollowPedCamViewMode
local GetGameplayCamRelativePitch = GetGameplayCamRelativePitch
local SetGameplayCamRelativePitch = SetGameplayCamRelativePitch
local GetGameplayCamRelativeHeading = GetGameplayCamRelativeHeading
local SetGameplayCamRelativeHeading = SetGameplayCamRelativeHeading
local HideHudComponentThisFrame   = HideHudComponentThisFrame
local ShowHudComponentThisFrame   = ShowHudComponentThisFrame
local DisplayAmmoThisFrame        = DisplayAmmoThisFrame

-- ===== ox_inventory: track current weapon =====
local currentWeapon = nil
RegisterNetEvent('ox_inventory:currentWeapon', function(data)
    currentWeapon = data
end)

local Config = require 'shared.config'
if not (Config.Recoil and Config.Recoil.Enabled or (Config.Crosshair and Config.Crosshair.Enabled) or (Config.HUD and Config.HUD.ManageReticle)) then
    return
end

-- ===== Config shims (รองรับชื่อ key ใหม่/เก่า) =====
local HUD  = Config.HUD or {}
local CRS  = Config.Crosshair or {}
local RC   = Config.Recoil or {}
local CTL  = Config.Controls or { MoveKeys = {32,33,34,35}, CrouchKey = 36 } -- W S A D / CTRL

local legacyScopedWeapons  = Config.scopedWeapons or {}
local legacyHideComponents = Config.disableHudComponents or {}

local componentsToHide = HUD.DisableHudComponents or HUD.componentsToHide or legacyHideComponents
local hideAmmo = (HUD.HideAmmo ~= nil and HUD.HideAmmo) or (HUD.displayAmmo == false) or (Config.displayAmmo == false)

-- Reticle flags (case-insensitive fallback)
local CRS_manage  = (CRS.ManageReticle ~= nil and CRS.ManageReticle) or (CRS.manage == true)
local CRS_onlyADS = (CRS.ShowOnlyWhenAiming ~= nil and CRS.ShowOnlyWhenAiming) or (CRS.showOnlyWhenAiming ~= false) -- default true
local CRS_showFPS = (CRS.ShowInFirstPerson ~= nil and CRS.ShowInFirstPerson) or (CRS.showInFirstPerson ~= false)    -- default true
local CRS_useComp = (CRS.UseScopeComponentCheck == true) or (CRS.showWhenHasScopeComponent == true)
local CRS_whitelist = CRS.ScopedWeaponsWhitelist or CRS.scopedWeapons or legacyScopedWeapons or {}

local SCOPE_COMPONENTS = CRS.ScopeComponents or CRS.scopeComponents or {
    `COMPONENT_AT_SCOPE_SMALL`,
    `COMPONENT_AT_SCOPE_SMALL_MK2`,
    `COMPONENT_AT_SCOPE_MEDIUM`,
    `COMPONENT_AT_SCOPE_MEDIUM_MK2`,
    `COMPONENT_AT_SCOPE_LARGE`,
    `COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM`,
    `COMPONENT_AT_SIGHTS`,
    `COMPONENT_AT_SIGHTS_SMG`,
    `COMPONENT_AT_SIGHTS_MK2`,
}

-- ===== Helpers =====
local function isMoving()
    for _, key in ipairs(CTL.MoveKeys or {}) do
        if IsControlPressed(0, key) then return true end
    end
    return false
end

local function isCrouching()
    return CTL.CrouchKey and IsControlPressed(0, CTL.CrouchKey) or false
end

local function weaponHasScopeAttached(ped, weaponHash)
    if not CRS_useComp then return false end
    for _, comp in ipairs(SCOPE_COMPONENTS) do
        if HasPedGotWeaponComponent(ped, weaponHash, comp) then
            return true
        end
    end
    return false
end

local function shouldShowReticle(ped, weaponHash, weaponName)
    if not CRS_manage then return false end
    if CRS_onlyADS and not IsPlayerFreeAiming(PlayerId()) then return false end
    if GetFollowPedCamViewMode() == 4 and not CRS_showFPS then return false end  -- FPS gate
    if CRS_whitelist and CRS_whitelist[weaponName] then return true end
    if weaponHasScopeAttached(ped, weaponHash) then return true end
    return false
end

-- ===== Recoil helpers =====
local lastShotAt, rampFactor = 0, 1.0
local function getRecoilNumbers(ped, weaponName, weaponHash)
    -- base tables (with sensible defaults ifไม่ตั้ง)
    local baseV = (RC.Base and (RC.Base[weaponName] or RC.Base.Default)) or 0.8
    local baseH = (RC.Horizontal and (RC.Horizontal[weaponName] or RC.Horizontal.Default)) or 0.18

    -- multipliers
    local ADS   = RC.Mult and RC.Mult.ADS        or 0.85
    local Hip   = RC.Mult and RC.Mult.Hip        or 1.00
    local Crou  = RC.Mult and RC.Mult.Crouch     or 0.85
    local Move  = RC.Mult and RC.Mult.Moving     or 1.15
    local Veh   = RC.Mult and RC.Mult.Vehicle    or 1.35
    local WScope= RC.Mult and RC.Mult.WithScope  or 0.90

    local aiming  = IsPlayerFreeAiming(PlayerId())
    local moving  = isMoving()
    local crouch  = isCrouching()
    local inVeh   = IsPedInAnyVehicle(ped, false)
    local scoped  = CRS_whitelist[weaponName] or weaponHasScopeAttached(ped, weaponHash)

    local m = (aiming and ADS or Hip)
    if crouch then m = m * Crou end
    if moving then m = m * Move end
    if inVeh  then m = m * Veh  end
    if scoped then m = m * WScope end

    -- ramp up on sustained fire
    local R   = RC.Ramp or { step = 0.04, max = 1.6, resetMs = 500 }
    local now = GetGameTimer()
    if now - lastShotAt <= (R.resetMs or 500) then
        rampFactor = math.min((R.max or 1.6), rampFactor + (R.step or 0.04))
    else
        rampFactor = 1.0
    end
    lastShotAt = now

    return baseV * m * rampFactor, baseH * m * math.sqrt(rampFactor)
end

-- ===== HUD / Reticle / Recoil loop =====
CreateThread(function()
    local forcedFPS = false
    while true do
        local ped = PlayerPedId()

        if not IsPedArmed(ped, 6) then
            forcedFPS = false
            Wait(200)
        else
            Wait(0)

            -- ซ่อน HUD อื่น ๆ
            for _, comp in ipairs(componentsToHide) do
                HideHudComponentThisFrame(comp)
            end

            -- Ammo HUD
            if hideAmmo then
                HideHudComponentThisFrame(20)
                HideHudComponentThisFrame(2)
                DisplayAmmoThisFrame(false)
            end

            -- --- Reticle priority: ForceHide > ForceShow > Auto ---
            if Config.Crosshair and Config.Crosshair.ForceHide then
                HideHudComponentThisFrame(14)
            elseif Config.Crosshair and Config.Crosshair.ForceShow then
                ShowHudComponentThisFrame(14)
            elseif CRS_manage then
                local whash = GetSelectedPedWeapon(ped)
                local wname = (currentWeapon and currentWeapon.name) or "Default"
                if shouldShowReticle(ped, whash, wname) then
                    ShowHudComponentThisFrame(14)
                else
                    HideHudComponentThisFrame(14)
                end
            end

            -- block melee while aiming (QoL)
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)

            -- On free aim, force FPS once, allow manual camera toggle afterwards
            if IsPlayerFreeAiming(PlayerId()) then
                if not forcedFPS then
                    SetFollowPedCamViewMode(4)
                    forcedFPS = true
                end
            else
                forcedFPS = false
            end

            if IsPedShooting(ped) then
                local weaponHash = GetSelectedPedWeapon(ped)
                local weaponName = (currentWeapon and currentWeapon.name) or "Default"

                -- First-person handling
                local fps = (GetFollowPedCamViewMode() == 4)
                local fpApply = RC.FirstPerson and RC.FirstPerson.Apply == true
                if not (fps and not fpApply) then
                    local vertical, horizontal = getRecoilNumbers(ped, weaponName, weaponHash)

                    -- vertical: raise smoothly
                    local applied = 0.0
                    local maxStep = (RC.VerticalStepMaxPerFrame or 0.25)
                    while applied < vertical do
                        Wait(0)
                        local p = GetGameplayCamRelativePitch()
                        local step = math.min(maxStep, vertical - applied)
                        SetGameplayCamRelativePitch(p + step, 0.20)
                        applied = applied + step
                    end

                    -- horizontal jitter: small random sway
                    local jitter = (math.random() * 2.0 - 1.0) * horizontal
                    SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading() + jitter)
                end
            end
        end
    end
end)
