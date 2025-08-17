local ox_inventory = exports["ox_inventory"]

RegisterNetEvent('mbt_malisling:createWeaponDrop', function(data)
    if type(data.WeaponInfo?.slot) ~= 'number' then return end
    local item = ox_inventory:GetSlot(source, data.WeaponInfo.slot)
    if not item then return end

    local coords = GetEntityCoords(GetPlayerPed(source))
    if #(coords - data.Coords) > 10.0 then return end -- drop must be near player

    if ox_inventory:RemoveItem(source, item.name, item.count, nil, item.slot) then
        ox_inventory:CustomDrop(('ThrownDrop %s000000000'):format(os.time()),
            { { item.name, item.count, item.metadata } },
            coords, 1, 10000, nil, data.WeaponInfo.ObjHash or `prop_water_corpse_01`)
    end
end)
