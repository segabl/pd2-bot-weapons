dofile(ModPath .. "lua/botweapons.lua")

local ALLOWED_CREW_WEAPON_CATEGORIES = {
	assault_rifle = true,
	shotgun = true,
	snp = true,
	lmg = true,
	smg = true,
  akimbo = true,
  pistol = true,
  revolver = true
}
function BlackMarketManager:is_weapon_category_allowed_for_crew(weapon_category)
	return ALLOWED_CREW_WEAPON_CATEGORIES[weapon_category]
end

function BlackMarketManager:verfify_crew_loadout()
	if not self._global._selected_henchmen then
		return
	end
	for k, v in pairs(self._global._selected_henchmen) do
		v.skill = self:verify_has_crew_skill(v.skill) and v.skill or self._defaults.henchman.skill
		v.ability = self:verify_has_crew_ability(v.ability) and v.ability or self._defaults.henchman.ability
		local valid = self:_verify_crew_weapon(v.primary_category or "primaries", v.primary, v.primary_slot)
		v.primary_slot = valid and v.primary_slot or nil
		v.primary = valid and v.primary or self._defaults.henchman.primary
		local valid = self:_verify_crew_mask(v.mask, v.mask_slot)
		v.mask_slot = valid and v.mask_slot or nil
		v.mask = valid and v.mask or self._defaults.henchman.mask
	end
end