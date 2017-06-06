dofile(ModPath .. "lua/botweapons.lua")

function BlackMarketManager:is_weapon_category_allowed_for_crew(weapon_category)
  local allowed = {
    assault_rifle = true,
    shotgun = true,
    snp = true,
    lmg = true,
    smg = true,
    akimbo = true,
    pistol = true
  }
  return allowed[weapon_category]
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

local henchman_loadout_string_from_loadout_original = BlackMarketManager.henchman_loadout_string_from_loadout
function BlackMarketManager:henchman_loadout_string_from_loadout(loadout, ...)
  local loadout = deep_clone(loadout)
  loadout.primary = nil
  return henchman_loadout_string_from_loadout_original(self, loadout, ...)
end

function BlackMarketManager:get_deployable_icon(deployable)
  local guis_catalog = "guis/"
  local bundle_folder = tweak_data.blackmarket.deployables[deployable] and tweak_data.blackmarket.deployables[deployable].texture_bundle_folder
  if bundle_folder then
    guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
  end
  return guis_catalog .. "textures/pd2/blackmarket/icons/deployables/" .. tostring(deployable)
end

function BlackMarketManager:get_armor_icon(armor)
  local guis_catalog = "guis/"
  local bundle_folder = tweak_data.blackmarket.armors[armor] and tweak_data.blackmarket.armors[armor].texture_bundle_folder
  if bundle_folder then
    guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
  end
  return guis_catalog .. "textures/pd2/blackmarket/icons/armors/" .. tostring(armor)
end