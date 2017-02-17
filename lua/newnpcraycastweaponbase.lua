local _fire_raycast_original = NewNPCRaycastWeaponBase._fire_raycast
function NewNPCRaycastWeaponBase:_fire_raycast(...)
  -- use NPCShotgunBase to fire raycast if it is a shotgun to be compatible with my NPC Shotgun Pellets mod
  if self:weapon_tweak_data().is_shotgun and NPCShotgunBase._fire_raycast then
    return NPCShotgunBase._fire_raycast(self, ...)
  else
    return _fire_raycast_original(self, ...)
  end
end