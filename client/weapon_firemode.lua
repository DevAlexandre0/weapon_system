local FireMode = {}
FireMode.Weapons = {}
FireMode.LastWeapon = false
FireMode.LastWeaponActive = false
FireMode.ShootingDisable = false
FireMode.Reloading = false
FireMode.Limp = -1

-- When the player spawns (or respawns after death)
AddEventHandler("playerSpawned", function ()
	ClearPedBloodDamage(PlayerPedId())
	FireMode.Weapons = {}
	FireMode.ShootingDisable = false
	FireMode.Reloading = false
	FireMode.LastWeapon = false
	FireMode.LastWeaponActive = false
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local PlayerId = PlayerId()
		local PlayerPed = PlayerPedId()

		-- Is the player armed with any gun
		if IsPedArmed(PlayerPed, 4) and not IsPedInAnyVehicle(PlayerPed, true) then
			local Active = false
			local PedWeapon = GetSelectedPedWeapon(PlayerPed)

			-- If last weapon used is not still in use
			if FireMode.LastWeapon ~= PedWeapon then
				-- Loop though all the semi-automatic weapons
				for _, Weapon in ipairs(Config.Weapons.Single) do
					-- If weapon is in list
					if GetHashKey(Weapon) == PedWeapon then
						-- Set weapon type to semi-automatic
						Active = "single"
						goto WeaponIdLoop
					end
				end

				-- If weapon was not found in semi-automatic loop
				if not Active then
					-- Loop though all full weapons
					for _, Weapon in ipairs(Config.Weapons.Full) do
						-- If weapon is in list
						if GetHashKey(Weapon) == PedWeapon then
							-- Set weapon type to full
							Active = "full"
							goto WeaponIdLoop
						end
					end
				end

				-- If weapon was not found in full auto loop
				if not Active then
					-- Loop though all the weapons that require a reticle
					for _, Weapon in ipairs(Config.Weapons.Reticle) do
						-- If weapon is in list
						if GetHashKey(Weapon) == PedWeapon then
							-- Set weapon type to full
							Active = "reticle"
							goto WeaponIdLoop
						end
					end
				end

				::WeaponIdLoop::

				-- If weapon not in any list
				if not Active then
					-- Remove last weapon type
					FireMode.LastWeaponActive = false
				-- If weapon was in a list
				else
					-- Save weapon
					FireMode.LastWeapon = PedWeapon
					-- Save weapon type
					FireMode.LastWeaponActive = Active
				end
			-- If last weapon is still current weapon
			else
				-- Set current type to saved type
				Active = FireMode.LastWeaponActive
			end



			-- If weapon needs to be affected
			if Active and Active ~= "reticle" then
				-- If weapon is not yet logged
				if FireMode.Weapons[PedWeapon] == nil then
					-- Log to array
					if Config.StartSafe then
						FireMode.Weapons[PedWeapon] = 0
					else
						FireMode.Weapons[PedWeapon] = 1
					end
				end

				-- If fire mode selector key pressed
				if IsDisabledControlJustReleased(1, Config.SelectorKey) then
					if Active == "full" then
						if FireMode.Weapons[PedWeapon] <= 2 then
							if FireMode.Weapons[PedWeapon] == 0 then
								NewNUIMessage("NewMode", "single")
							elseif FireMode.Weapons[PedWeapon] == 1 then
								NewNUIMessage("NewMode", "burst")
							elseif FireMode.Weapons[PedWeapon] == 2 then
								NewNUIMessage("NewMode", "full_auto")
							end
							PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
							FireMode.Weapons[PedWeapon] = FireMode.Weapons[PedWeapon] + 1
						elseif FireMode.Weapons[PedWeapon] >= 3 then
							NewNUIMessage("NewMode", "safety")
							PlaySoundFrontend(-1, "Reset_Prop_Position", "DLC_Dmod_Prop_Editor_Sounds", 0)
							FireMode.Weapons[PedWeapon] = 0
						end
					else
						if FireMode.Weapons[PedWeapon] == 0 then
							NewNUIMessage("NewMode", "single")
							PlaySoundFrontend(-1, "Reset_Prop_Position", "DLC_Dmod_Prop_Editor_Sounds", 0)
							FireMode.Weapons[PedWeapon] = FireMode.Weapons[PedWeapon] + 1
						elseif FireMode.Weapons[PedWeapon] >= 1 then
							NewNUIMessage("NewMode", "safety")
							PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
							FireMode.Weapons[PedWeapon] = 0
						end
					end
				end

				-- If fire mode is set to safety
				if FireMode.Weapons[PedWeapon] == 0 then FireMode.ShootingDisable = true end

				local _, Ammo = GetAmmoInClip(PlayerPed, PedWeapon)
				-- If R was just pressed and client is not already reloading
				if IsDisabledControlJustPressed(1, 45) and not FireMode.Reloading then
					FireMode.Reloading = true
					FireMode.ShootingDisable = true
					if IsPlayerFreeAiming(PlayerId) then SetPlayerForcedAim(PlayerId, true) end
					Citizen.Wait(400)
					MakePedReload(PlayerPed)
					Citizen.Wait(300)
					SetPlayerForcedAim(PlayerId, false)
					FireMode.ShootingDisable = false
					FireMode.Reloading = false
				-- If they is only one bullet left in the magazine
				-- Or if the firemode is burst, and out of ammo
				elseif (Ammo == 1 and FireMode.Weapons[PedWeapon] ~= 2) or (Ammo <= 3 and FireMode.Weapons[PedWeapon] == 2) then
					FireMode.ShootingDisable = true
					-- Set the ammo in the magazine to one
					SetAmmoInClip(PlayerPed, PedWeapon, 1)
					-- If left click just pressed
					if IsDisabledControlJustPressed(1, 24) then PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1) end
				-- If left click just pressed
				elseif IsDisabledControlJustPressed(1, 24) then
					-- If the fire mode is set to safety
					if FireMode.Weapons[PedWeapon] == 0 then
						PlaySoundFrontend(-1, "HACKING_MOVE_CURSOR", 0, 1)
					-- If fire mode is set to semi-automatic
					elseif FireMode.Weapons[PedWeapon] == 1 then
						-- While left click is still being held
						while IsDisabledControlPressed(1, 24) do
							-- Disable shooting (which allows for one shot to be fired)
							DisablePlayerFiring(PlayerId, true)
							Citizen.Wait(0)
						end
					-- If fire mode is set to burst
					elseif FireMode.Weapons[PedWeapon] == 2 then
						Citizen.Wait(200)
						-- While left click is still being held
						while IsDisabledControlPressed(1, 24) do
							-- Disable shooting
							DisablePlayerFiring(PlayerId, true)
							Citizen.Wait(0)
						end
					end
				-- If fire mode is not set to safety
				elseif FireMode.Weapons[PedWeapon] ~= 0 then
					FireMode.ShootingDisable = false
				end
			-- If weapon is not in any list
			else
				-- Enable shooting
				FireMode.ShootingDisable = false
			end
		-- If ped is not armed
		else
			FireMode.LastWeapon = false
			FireMode.LastWeaponActive = false
			FireMode.ShootingDisable = false
		end

	end
end)

-- Disable shooting loop
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		while FireMode.ShootingDisable do
			DisablePlayerFiring(PlayerId(), true)

			-- Disable fire mode selector key
			DisableControlAction(0, Config.SelectorKey, true)

			-- Disable reload and pistol whip
			DisableControlAction(0, 45, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
			Citizen.Wait(0)
		end

	end
end)

-- Disable controls while using weapon
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if FireMode.LastWeapon and FireMode.LastWeaponActive ~= "reticle" then
			-- Disable fire mode selector key
			DisableControlAction(0, Config.SelectorKey, true)

			-- Disable reload and pistol whip
			DisableControlAction(0, 45, true)
			DisableControlAction(0, 54, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
		end

	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local PlayerPed = PlayerPedId()

		if HasEntityBeenDamagedByAnyPed(PlayerPed) then
			ClearEntityLastDamageEntity(PlayerPed)

			RequestAnimDict("move_m@injured")
			if not HasAnimDictLoaded("move_m@injured") then
				RequestAnimDict("move_m@injured")
				while not HasAnimDictLoaded("move_m@injured") do Citizen.Wait(0) end
			end

			-- Apply random effect to ped
			ApplyPedDamagePack(PlayerPed, Config.BloodEffects[math.random(#Config.BloodEffects)], 0, 0)
			-- Set limp
			SetPedMovementClipset(PlayerPed, "move_m@injured", 5.0)
			-- Add random amount of limping time
			FireMode.Limp = FireMode.Limp + math.random(100, 200)
		end

		-- While there is still limp time remaining remove 1 tick from limp time
		if FireMode.Limp > 0 then FireMode.Limp = FireMode.Limp - 1 end

		-- When there is no limp time remaining
		if FireMode.Limp == 0 then
			-- Reset limp timer
			FireMode.Limp = -1

			-- Remove walking effect
			ResetPedMovementClipset(PlayerPed, false)
		end
	end
end)

local function NewNUIMessage (Type, Load)
	if Config.SelectorImages then
		SendNUIMessage({
			PayloadType = Type,
			Payload = Load
		})
	end
end