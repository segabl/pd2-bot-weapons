local clbk_inventory_original = CopMovement.clbk_inventory
function CopMovement:clbk_inventory(...)
  clbk_inventory_original(self, ...)
  -- get reload animation from new anim field instead of usage
  local weapon = self._ext_inventory:equipped_unit()
  if weapon then
    if self._weapon_anim_global then
      self._machine:set_global(self._weapon_anim_global, 0)
    end
    local weap_tweak = weapon:base():weapon_tweak_data()
    self._machine:set_global(weap_tweak.anim, 1)
    self._weapon_anim_global = weap_tweak.anim
  end
end