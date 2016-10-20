function TeamAIInventory:add_unit_by_name(factory_name, equip)
  log("[BotWeapons] " .. factory_name)
  
  --local outfit = managers.network:session():local_peer():blackmarket_outfit()
  --factory_name = outfit.primary.factory_id .. "_npc"
  local factory_weapon = tweak_data.weapon.factory[factory_name]
  --local blueprint = outfit.primary.blueprint
  local blueprint = factory_weapon.default_blueprint
  --local cosmetics = outfit.primary.cosmetics
  
  local ids_unit_name = Idstring(factory_weapon.unit)
  if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
    managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
  end
  HuskPlayerInventory.add_unit_by_factory_blueprint(self, factory_name, equip, true, blueprint, cosmetics)
end