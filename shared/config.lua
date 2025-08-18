-- ===== Shared configuration with feature flags =======================
local Config = {}
Config.Debug = false
Config.DropWeaponOnDeath = true
Config.EnableSling = true
Config.EnableFlashlight = true
Config.Relog = false -- Put this to true if you have a esx_multicharacter and relog enabled!

-- Durability / wear system
Config.Durability = {
    Enabled = true
}

Config.Jamming = {
    ["Enabled"] = true,
    ["Cooldown"] = 5,
    ["Animation"] = { ["Dict"] = "anim@weapons@first_person@aim_rng@generic@pistol@singleshot@str", ["Anim"] = "reload_aim" },
    ["Chance"] = {
        [50] = 10, [40] = 15, [30] = 20, [20] = 25, [10] = 30
    }
}

Config.Throw = {
    ["Enabled"] = true,
    ["Animation"] = { ["Dict"] = "melee@unarmed@streamed_variations", ["Anim"] = "plyr_takedown_front_slap" },
    ["Groups"] = {
        [`GROUP_MELEE`]   = { ["Allowed"] = true,  ["Multipliers"] = { ["X"] = 40.0, ["Y"] = 40.0, ["Z"] = 15.0 } },
        [`GROUP_PISTOL`]  = { ["Allowed"] = true,  ["Multipliers"] = { ["X"] = 20.0, ["Y"] = 20.0, ["Z"] = 15.0 } },
        [`GROUP_RIFLE`]   = { ["Allowed"] = true,  ["Multipliers"] = { ["X"] = 10.0, ["Y"] = 10.0, ["Z"] = 5.0 } },
        [`GROUP_MG`]      = { ["Allowed"] = false, ["Multipliers"] = { ["X"] = 20.0, ["Y"] = 20.0, ["Z"] = 10.0 } },
        [`GROUP_SMG`]     = { ["Allowed"] = true,  ["Multipliers"] = { ["X"] = 20.0, ["Y"] = 20.0, ["Z"] = 10.0 } },
        [`GROUP_SHOTGUN`] = { ["Allowed"] = true,  ["Multipliers"] = { ["X"] = 20.0, ["Y"] = 20.0, ["Z"] = 10.0 } },
        [`GROUP_STUNGUN`] = { ["Allowed"] = true,  ["Multipliers"] = { ["X"] = 20.0, ["Y"] = 20.0, ["Z"] = 10.0 } },
        [`GROUP_SNIPER`]  = { ["Allowed"] = false, ["Multipliers"] = { ["X"] = 20.0, ["Y"] = 20.0, ["Z"] = 10.0 } },
        [`GROUP_HEAVY`]   = { ["Allowed"] = false, ["Multipliers"] = { ["X"] = 20.0, ["Y"] = 20.0, ["Z"] = 10.0 } },
    },
    ["Key"] = "K",
    ["Command"] = "throwWeapon"
}

Config.Bones = { ["Back"] = 24816, ["LHand"] = 36029 }

Config.HolsterControls = {
    ["Confirm"] = { ["Label"] = "Confirm Holster", ["Input"] = "MOUSE_BUTTON", ["Key"] = "MOUSE_RIGHT" },
    ["Cancel"]  = { ["Label"] = "Cancel Holster",  ["Input"] = "keyboard",     ["Key"] = "BACK" }
}

Config.Notification = function (data)
    lib.notify(data)
end

Config.Labels = {
    ["has_jammed"]   = { ["title"] = "Jammed!",   ["description"] = "Your weapon has jammed! Check its state!", ["type"] = "error",   ["icon"] = "fa-solid fa-triangle-exclamation" },
    ["has_unjammed"] = { ["title"] = "Unjammed!", ["description"] = "You have unjammed your weapon!",          ["type"] = "success", ["icon"] = "fa-solid fa-person-rifle" },
    ["no_allowed_throw"] = { ["title"] = "Ops!", ["description"] = "You are not able to throw this weapon!", ["type"] = "error", ["icon"] = "fa-solid fa-hand-fist" },
    ["Holster_Help"] = "[RMOUSE] - Unholster [BACKSPACE] - Cancel",
}

Config.PropInfo = {
    ["side"] = {
        ["Bone"] = Config.Bones["Back"],
        ["Pos"] = { ["male"] = { x=-0.15, y=0.0, z=-0.23 }, ["female"] = { x=-0.15, y=0.0, z=-0.23 } },
        ["Rot"] = { ["male"] = { x=90.0,  y=20.0, z=180.0 }, ["female"] = { x=90.0,  y=20.0, z=180.0 } },
        ["isPed"] = false, ["RotOrder"] = 2, ["FixedRot"] = true,
        ["HolsterAnim"] = { ["dict"] = "reaction@intimidation@cop@unarmed", ["animIn"] = "intro", ["animOut"] = "outro", ["sleep"] = 400, ["sleepOut"] = 450 }
    },
    ["back"] = {
        ["Bone"] = Config.Bones["Back"],
        ["Pos"] = { ["male"] = { x=0.4, y=-0.18, z=0.1 }, ["female"] = { x=0.4, y=-0.18, z=0.1 } },
        ["Rot"] = { ["male"] = { x=0.0, y=155.0, z=0.0 }, ["female"] = { x=0.0, y=155.0, z=0.0 } },
        ["isPed"] = false, ["RotOrder"] = 2, ["FixedRot"] = true,
        ["HolsterAnim"] = { ["dict"] = "reaction@intimidation@1h", ["animIn"] = "intro", ["animOut"] = "outro", ["sleep"] = 1200, ["sleepOut"] = 1200 }
    },
    ["back2"] = {
        ["Bone"] = Config.Bones["Back"],
        ["Pos"] = { ["male"] = { x=0.4, y=-0.18, z=0.1 }, ["female"] = { x=0.4, y=-0.18, z=0.1 } },
        ["Rot"] = { ["male"] = { x=0.4, y=-0.18, z=0.1 }, ["female"] = { x=0.4, y=-0.18, z=0.1 } },
        ["isPed"] = false, ["RotOrder"] = 2, ["FixedRot"] = true,
        ["HolsterAnim"] = { ["dict"] = "reaction@intimidation@1h", ["animIn"] = "intro", ["animOut"] = "outro", ["sleep"] = 1200, ["sleepOut"] = 1200 }
    },
    ["melee"] = {
        ["Bone"] = Config.Bones["Back"],
        ["Pos"] = { ["male"] = { x=-0.4, y=-0.1, z=0.22 }, ["female"] = { x=-0.4, y=-0.1, z=0.22 } },
        ["Rot"] = { ["male"] = { x=90.0, y=-10.0, z=120.0 }, ["female"] = { x=90.0, y=-10.0, z=120.0 } },
        ["isPed"] = false, ["RotOrder"] = 2, ["FixedRot"] = true,
        ["HolsterAnim"] = { ["dict"] = "combat@combat_reactions@pistol_1h_gang", ["animIn"] = "0", ["animOut"] = "0", ["sleep"] = 500, ["sleepOut"] = 500 }
    },
    ["melee2"] = {
        ["Bone"] = Config.Bones["Back"],
        ["Pos"] = { ["male"] = { x=-0.05, y=0.1, z=0.22 }, ["female"] = { x=-0.05, y=0.1, z=0.22 } },
        ["Rot"] = { ["male"] = { x=-90.0, y=-10.0, z=120.0 }, ["female"] = { x=-90.0, y=-10.0, z=120.0 } },
        ["isPed"] = false, ["RotOrder"] = 2, ["FixedRot"] = true,
        ["HolsterAnim"] = { ["dict"] = "combat@combat_reactions@pistol_1h_hillbilly", ["animIn"] = "0", ["animOut"] = "0", ["sleep"] = 500, ["sleepOut"] = 500 }
    },
    ["melee3"] = {
        ["Bone"] = Config.Bones["Back"],
        ["Pos"] = { ["male"] = { x=-0.2, y=-0.18, z=0.18 }, ["female"] = { x=-0.2, y=-0.18, z=0.18 } },
        ["Rot"] = { ["male"] = { x=0.0, y=115.0, z=0.0 }, ["female"] = { x=0.0, y=115.0, z=0.0 } },
        ["isPed"] = false, ["RotOrder"] = 2, ["FixedRot"] = true,
        ["HolsterAnim"] = { ["dict"] = "reaction@intimidation@1h", ["animIn"] = "intro", ["animOut"] = "outro", ["sleep"] = 1200, ["sleepOut"] = 1200 }
    }
}

Config.CustomPropPosition = {
    -- ตัวอย่าง preset (เว้นว่างไว้เหมือนเดิม)
}

-- ===== CONFIG (ของเดิมบางส่วน + เพิ่มบล็อกใหม่สำหรับ Recoil/Crosshair/HUD) =====

-- Fire-mode / UI ตัวเลือกยิง (ของเดิม)
Config.SelectorKey = 29
Config.SelectorImages = true
Config.StartSafe = true

-- >>> ใหม่: HUD / Crosshair ย้ายมาคุมตรงนี้ <<<
Config.HUD = {
    ManageReticle = true,       -- ให้สคริปต์นี้คุมการแสดง/ซ่อนเป้า
    HideAmmo      = true,       -- ซ่อนตัวเลขกระสุน/weapon icon
    -- ซ่อน HUD อื่น ๆ ทุกเฟรม (ห้ามใส่ 14 ที่นี่ เพราะเราคุม reticle แยกแล้ว)
    DisableHudComponents = {1, 3, 4, 7, 9, 13, 19, 21, 22}
}

Config.Crosshair = {
    Enabled = true,              -- เปิด/ปิดระบบจัดการเป้าโดยรวม
    ForceHide = false,           -- << เปิดอันนี้ = ซ่อนเป้าทุกกรณี >>
    ForceShow = false,           -- ถ้าจะบังคับโชว์ทุกกรณีให้สลับเป็น true (อย่าเปิดคู่กัน)
    ShowOnlyWhenAiming = false,
    ShowInFirstPerson = false,
    UseScopeComponentCheck = true,

    ScopedWeaponsWhitelist = {
        ["WEAPON_SNIPERRIFLE"]       = true,
        ["WEAPON_HEAVYSNIPER"]       = true,
        ["WEAPON_HEAVYSNIPER_MK2"]   = true,
        ["WEAPON_MARKSMANRIFLE"]     = true,
        ["WEAPON_MARKSMANRIFLE_MK2"] = true,
        ["WEAPON_STUNGUN"]           = true
    },

    ScopeComponents = {
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
}

-- Controls ที่รีคอยล์ใช้ (เช็คการเคลื่อนที่/ย่อตัว)
Config.Controls = {
    MoveKeys  = {32, 33, 34, 35}, -- W,S,A,D
    CrouchKey = 36                -- CTRL (ปรับตามสคริปต์ crouch ของคุณ)
}

-- >>> ใหม่: Recoil tuning ทั้งหมดอยู่ที่นี่ <<<
Config.Recoil = {
    Enabled = true,
    FirstPerson = { Apply = false },     -- ปล่อย native จัดการใน FPS (true = บังคับเอง)
    VerticalStepMaxPerFrame = 0.25,      -- เพดานยกกล้องต่อเฟรม (ให้ลื่น)

    Base = {                      -- ค่าพื้นฐานต่อ “นัด”
        ["WEAPON_PISTOL"]        = 0.55,
        ["WEAPON_PISTOL_MK2"]    = 0.60,
        ["WEAPON_COMBATPISTOL"]  = 0.65,
        ["WEAPON_SMG"]           = 0.70,
        ["WEAPON_MINISMG"]       = 0.75,
        ["WEAPON_ASSAULTRIFLE"]  = 0.85,
        ["WEAPON_CARBINERIFLE"]  = 0.85,
        ["WEAPON_ADVANCEDRIFLE"] = 0.90,
        ["WEAPON_COMBATMG"]      = 1.25,
        ["WEAPON_COMBATMG_MK2"]  = 1.35,
        ["WEAPON_MARKSMANRIFLE"] = 1.10,
        ["WEAPON_HEAVYSNIPER"]   = 2.00,
        Default                  = 0.80
    },

    Horizontal = {                -- “แกว่งซ้าย-ขวา” แบบสุ่มเล็กน้อย
        ["WEAPON_PISTOL"]        = 0.12,
        ["WEAPON_SMG"]           = 0.20,
        ["WEAPON_ASSAULTRIFLE"]  = 0.22,
        ["WEAPON_COMBATMG"]      = 0.28,
        Default                  = 0.18
    },

    Mult = {                      -- ตัวคูณตามสภาพผู้เล่น
        ADS        = 0.85,        -- เล็งลงศูนย์
        Hip        = 1.00,        -- ยิงสะโพก
        Crouch     = 0.85,
        Moving     = 1.15,
        Vehicle    = 1.35,
        Suppressor = 0.95,
        WithScope  = 0.90         -- มีสโคปติดอยู่
    },

    Ramp = { step = 0.04, max = 1.6, resetMs = 500 }  -- ยิงรัว/ออโต้: ไต่แรงขึ้น แล้วรีเซ็ตถ้าหยุด
}

-- ====== ของเดิม (ยังคงไว้เพื่อความเข้ากันได้กับระบบอื่น ๆ ในสคริปต์) ======
-- หมายเหตุ: scopedWeapons เดิมจะไม่ถูกใช้โดยระบบ reticle ใหม่ แต่เก็บไว้เพื่อ backward-compat
Config.disableHudComponents = {1, 3, 4, 7, 9, 13, 19, 21, 22}  -- อย่าใส่ 14 ที่นี่
Config.displayAmmo = false
Config.scopedWeapons = {
    ['WEAPON_SNIPERRIFLE']       = true,
    ['WEAPON_HEAVYSNIPER']       = true,
    ['WEAPON_MARKSMANRIFLE']     = true,
    ['WEAPON_HEAVYSNIPER_MK2']   = true,
    ['WEAPON_MARKSMANRIFLE_MK2'] = true
}

Config.Weapons = {} -- Do not edit this line

-- Fire-mode: พกสั้น/ปั๊ม — Safety & Semi เท่านั้น
Config.Weapons.Single = {
    "WEAPON_REVOLVER","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_PUMPSHOTGUN",
    "WEAPON_SNSPISTOL_MK2","WEAPON_REVOLVER_MK2"
}

-- Fire-mode: อาวุธอัตโนมัติ — Safety/Semi/Burst/Full
Config.Weapons.Full = {
    "WEAPON_MINISMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_MG","WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2","WEAPON_COMBATPDW","WEAPON_APPISTOL","WEAPON_MACHINEPISTOL",
    "WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_BULLPUPRIFLE","WEAPON_COMPACTRIFLE",
    "WEAPON_SPECIALCARBINE_MK2","WEAPON_BULLPUPRIFLE_MK2","WEAPON_PUMPSHOTGUN_MK2"
}

-- (เดิม) อาวุธที่ "ให้เห็นเรติเคิล" — ตอนนี้ถูกแทนด้วย Config.Crosshair แล้ว แต่คงไว้
Config.Weapons.Reticle = {
    "WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE","WEAPON_MARKSMANRIFLE_MK2","WEAPON_STUNGUN"
}

-- Effects that are randomly selected when the player takes any damage.
-- Pick and choose which effects using the list below. Remember to add ","s where needed.
Config.BloodEffects = {
	"Skin_Melee_0",
	"Useful_Bits",
	"Explosion_Med",
	"BigHitByVehicle",
	"Car_Crash_Heavy",
	"HitByVehicle",
	"BigRunOverByVehicle",
}

return Config
