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

-- ===== Config shims (รองรับชื่อ key ใหม่/เก่า) =====
local HUD  = Config.HUD or {}
local RET  = Config.Reticle or {}
local RC   = Config.Recoil or {}
local CTL  = Config.Controls or { MoveKeys = {32,33,34,35}, CrouchKey = 36 } -- W S A D / CTRL

local legacyScopedWeapons  = Config.scopedWeapons or {}
local legacyHideComponents = Config.disableHudComponents or {}

local componentsToHide = HUD.DisableHudComponents or HUD.componentsToHide or legacyHideComponents
local hideAmmo = (HUD.HideAmmo ~= nil and HUD.HideAmmo) or (HUD.displayAmmo == false) or (Config.displayAmmo == false)

-- Reticle flags (case-insensitive fallback)
local RET_manage  = (RET.ManageReticle ~= nil and RET.ManageReticle) or (RET.manage == true)
local RET_onlyADS = (RET.ShowOnlyWhenAiming ~= nil and RET.ShowOnlyWhenAiming) or (RET.showOnlyWhenAiming ~= false) -- default true
local RET_showFPS = (RET.ShowInFirstPerson ~= nil and RET.ShowInFirstPerson) or (RET.showInFirstPerson ~= false)    -- default true
local RET_useComp = (RET.UseScopeComponentCheck == true) or (RET.showWhenHasScopeComponent == true)
local RET_whitelist = RET.ScopedWeaponsWhitelist or RET.scopedWeapons or legacyScopedWeapons or {}

local SCOPE_COMPONENTS = RET.ScopeComponents or RET.scopeComponents or {
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
    if not RET_useComp then return false end
    for _, comp in ipairs(SCOPE_COMPONENTS) do
        if HasPedGotWeaponComponent(ped, weaponHash, comp) then
            return true
        end
    end
    return false
end

local function shouldShowReticle(ped, weaponHash, weaponName)
    if not RET_manage then return false end
    if RET_onlyADS and not IsPlayerFreeAiming(PlayerId()) then return false end
    if GetFollowPedCamViewMode() == 4 and not RET_showFPS then return false end  -- FPS gate
    if RET_whitelist and RET_whitelist[weaponName] then return true end
    if weaponHasScopeAttached(ped, weaponHash) then return true end
    return false
end

-- ===== HUD / Reticle =====
CreateThread(function()
    while true do
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
        local ped = PlayerPedId()
        if Config.Reticle and Config.Reticle.ForceHide then
            HideHudComponentThisFrame(14)
        elseif Config.Reticle and Config.Reticle.ForceShow then
            ShowHudComponentThisFrame(14)
        elseif RET_manage then
            if IsPedArmed(ped, 6) then
                local whash = GetSelectedPedWeapon(ped)
                local wname = (currentWeapon and currentWeapon.name) or "Default"
                if shouldShowReticle(ped, whash, wname) then
                    ShowHudComponentThisFrame(14)
                else
                    HideHudComponentThisFrame(14)
                end
            else
                HideHudComponentThisFrame(14)
            end
        end
    end
end)


-- ===== Recoil (vertical + horizontal + ramp; config-driven) =====
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
    local scoped  = RET_whitelist[weaponName] or weaponHasScopeAttached(ped, weaponHash)

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

-- single recoil loop
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()

        -- block melee while aiming (QoL)
        if IsPedArmed(ped, 6) then
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
        end

        if IsPedShooting(ped) then
            local weaponHash = GetSelectedPedWeapon(ped)
            local weaponName = (currentWeapon and currentWeapon.name) or "Default"

            -- First-person handling
            local fps = (GetFollowPedCamViewMode() == 4)
            local fpApply = RC.FirstPerson and RC.FirstPerson.Apply == true
            if fps and not fpApply then
                goto continue
            end

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
        ::continue::
    end
end)
