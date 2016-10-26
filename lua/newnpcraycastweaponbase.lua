local _fire_raycast_original = NewNPCRaycastWeaponBase._fire_raycast
function NewNPCRaycastWeaponBase:_fire_raycast(...)
  -- use NPCShotgunBase to fire raycast if it is a shotgun to be compatible with my NPC Shotgun Pellets mod
  if self:weapon_tweak_data().is_shotgun and NPCShotgunBase._fire_raycast then
    return NPCShotgunBase._fire_raycast(self, ...)
  else
    return _fire_raycast_original(self, ...)
  end
end

function NewNPCRaycastWeaponBase:_find_gadget_type_index(gadget_type)
  -- helper function to get the first gadget of a type
  local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", self._factory_id, self._blueprint) or {}
  local xd, yd
  table.sort(gadgets, function(x, y)
    xd = self._parts[x]
    yd = self._parts[y]
    if not xd then
      return false
    end
    if not yd then
      return true
    end
    return xd.unit:base().GADGET_TYPE > yd.unit:base().GADGET_TYPE
  end)
  local index
  local gadget
  for i, id in ipairs(gadgets) do
    gadget = self._parts[id]
    if gadget and gadget.unit and gadget.unit:base().GADGET_TYPE == gadget_type then
      return i, gadgets
    end
  end
end