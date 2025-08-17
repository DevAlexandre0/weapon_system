local ox_inventory = exports["ox_inventory"]

RegisterNetEvent('mbt_malisling:createWeaponDrop', function(data)
    local slot = data and data.WeaponInfo and data.WeaponInfo.slot
    if type(slot) ~= 'number' then
        warn(('createWeaponDrop: invalid slot from %s'):format(source))
        return
    end

    local item = ox_inventory:GetSlot(source, slot)
    if not item then
        warn(('createWeaponDrop: no item in slot %s from %s'):format(slot, source))
        return
    end

    local coords = GetEntityCoords(GetPlayerPed(source))
    if #(coords - data.Coords) > 10.0 then return end -- drop must be near player

    if ox_inventory:RemoveItem(source, item.name, item.count, nil, item.slot) then
        ox_inventory:CustomDrop(('ThrownDrop %s000000000'):format(os.time()),
            { { item.name, item.count, item.metadata } },
            coords, 1, 10000, nil, data.WeaponInfo.ObjHash or `prop_water_corpse_01`)
    end
end)
