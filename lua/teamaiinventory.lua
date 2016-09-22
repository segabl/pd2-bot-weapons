function TeamAIInventory:add_unit_by_name(new_unit_name, equip)
  local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())
  local setup_data = {}
  setup_data.user_unit = self._unit
  setup_data.ignore_units = {
    self._unit,
    new_unit
  }
  setup_data.expend_ammo = false
  setup_data.hit_slotmask = managers.slot:get_mask("bullet_impact_targets")
  setup_data.user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice
  setup_data.alert_AI = true
  setup_data.alert_filter = self._unit:brain():SO_access()
  new_unit:base():setup(setup_data)
  -- Enable akimbo for team AI
  if new_unit:base().AKIMBO then
    new_unit:base():create_second_gun(new_unit_name)
  end
  self:add_unit(new_unit, equip)
end