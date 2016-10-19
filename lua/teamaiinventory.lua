function TeamAIInventory:add_unit_by_name(factory_name, equip)
  log("[BotWeapons] " .. factory_name)
  local factory_weapon = tweak_data.weapon.factory[factory_name]
  local ids_unit_name = Idstring(factory_weapon.unit)
  if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
    managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
  end
  local new_unit = World:spawn_unit(ids_unit_name, Vector3(), Rotation())
  new_unit:base():set_factory_data(factory_name)
  new_unit:base():assemble_from_blueprint(factory_name, blueprint or factory_weapon.default_blueprint)
  new_unit:base():check_npc()
  local setup_data = {}
  setup_data.user_unit = self._unit
  setup_data.ignore_units = {
    self._unit,
    new_unit
  }
  setup_data.expend_ammo = false
  setup_data.hit_slotmask = managers.slot:get_mask("bullet_impact_targets")
  setup_data.user_sound_variant = "1"
  setup_data.alert_AI = true
  setup_data.alert_filter = self._unit:brain():SO_access()
  new_unit:base():setup(setup_data)
  if new_unit:base().AKIMBO then
    new_unit:base():create_second_gun()
  end
  self:add_unit(new_unit, equip)
end