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