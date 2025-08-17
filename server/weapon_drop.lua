local ox_inventory = exports["ox_inventory"]

RegisterNetEvent('mbt_malisling:dropWeapon', function(data)
    local slot = data and data.slot
    if type(slot) ~= 'number' then
        warn(('dropWeapon: invalid slot from %s'):format(source))
        return
    end

    local item = ox_inventory:GetSlot(source, slot)
    if not item then
        warn(('dropWeapon: no item in slot %s from %s'):format(slot, source))
        return
    end

    if ox_inventory:RemoveItem(source, item.name, item.count, nil, item.slot) then
        ox_inventory:CustomDrop(('DeadDrop %s000000000'):format(os.time()),
            { { item.name, item.count, item.metadata } },
            GetEntityCoords(GetPlayerPed(source)), 1, 10000, nil, data.hash or `prop_water_corpse_01`)
    end
end)
