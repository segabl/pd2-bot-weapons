local set_henchmen_loadout_original = MenuSceneManager.set_henchmen_loadout
function MenuSceneManager:set_henchmen_loadout(index, character, loadout, ...)
  set_henchmen_loadout_original(self, index, character, loadout, ...)
  loadout = loadout or managers.blackmarket:henchman_loadout(index)
  local unit = self._henchmen_characters[index]
  local crafted_primary = managers.blackmarket:get_crafted_category_slot(loadout.primary_category or "primaries", loadout.primary_slot)
	if crafted_primary then
		local primary = crafted_primary.factory_id
		local primary_id = crafted_primary.weapon_id
		local primary_blueprint = crafted_primary.blueprint
		local primary_cosmetics = crafted_primary.cosmetics
		self:set_character_equipped_weapon(unit, primary, primary_blueprint, "primary", primary_cosmetics)
    self:_select_henchmen_pose(unit, primary_id, index)
	end
end