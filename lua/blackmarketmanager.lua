local menu_allows = {
  minigun = true
}
function BlackMarketManager:is_weapon_category_allowed_for_crew(weapon_category)
  return table.contains(BotWeapons.weapon_categories, weapon_category) or menu_allows[weapon_category]
end

function BlackMarketManager:is_weapon_allowed_for_crew(weapon_id)
  if not weapon_id then
    return true
  end
  if not BotWeapons:get_npc_version(weapon_id) then
    return false
  end
  local data = tweak_data.weapon[weapon_id]
  local check_cat = BotWeapons:is_mwc_installed() and 2 or 1
  return data and self:is_weapon_category_allowed_for_crew(data.categories[check_cat] or data.categories[1])
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
  local sanitized_loadout = deep_clone(loadout)
  sanitized_loadout.primary = nil
  return henchman_loadout_string_from_loadout_original(self, sanitized_loadout, ...)
end

local henchman_loadout_original = BlackMarketManager.henchman_loadout
function BlackMarketManager:henchman_loadout(...)
  local loadout = henchman_loadout_original(self, ...)
  if loadout then
    loadout.mask = tweak_data.blackmarket.masks[loadout.mask] and loadout.mask
    loadout.primary = tweak_data.weapon.factory[loadout.primary] and loadout.primary
    loadout.armor = tweak_data.blackmarket.armors[loadout.armor] and loadout.armor
    loadout.armor_skin = tweak_data.economy.armor_skins[loadout.armor_skin] and loadout.armor_skin
    loadout.player_style = tweak_data.blackmarket.player_styles[loadout.player_style] and loadout.player_style
    loadout.suit_variation = loadout.player_style and tweak_data.blackmarket.player_styles[loadout.player_style].material_variations and tweak_data.blackmarket.player_styles[loadout.player_style].material_variations[loadout.suit_variation] and loadout.suit_variation
    loadout.glove_id = tweak_data.blackmarket.gloves[loadout.glove_id] and loadout.glove_id
    loadout.deployable = tweak_data.upgrades.definitions[loadout.deployable] and loadout.deployable
  end
  return loadout
end

function BlackMarketManager:set_preferred_henchmen(index, character_name)
  self._global._preferred_henchmen = self._global._preferred_henchmen or {}
  for i, name in pairs(self._global._preferred_henchmen) do
    if name == character_name and i ~= index then
      self._global._preferred_henchmen[i] = nil
    end
  end
  self._global._preferred_henchmen[index] = character_name
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

function BlackMarketManager:get_player_style_icon(player_style)
  local path = "textures/pd2/blackmarket/icons/player_styles/"
  local guis_catalog = "guis/"
  local bundle_folder = tweak_data.blackmarket.player_styles[player_style] and tweak_data.blackmarket.player_styles[player_style].texture_bundle_folder
  if bundle_folder then
    guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
  end
  if player_style:match("^las_") then -- LAS support
    player_style = player_style:sub(5, -1)
    path = "armor_skins/"
  end
  return guis_catalog .. path .. tostring(player_style)
end