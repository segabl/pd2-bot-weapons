dofile(ModPath .. "lua/botweapons.lua")

function TeamAIBase:default_weapon_name(slot)
  -- override default weapons
  local weapon_index = BotWeapons._data[self._tweak_table .. "_weapon"]
  if BotWeapons._data.toggle_override_weapons then
    weapon_index = BotWeapons._data.override_weapons or #BotWeapons.weapon_ids
  end
  if not weapon_index then
    return tweak_data.character[self._tweak_table].weapon.weapons_of_choice[slot or "primary"]
  end
  if self._previous_weapon_choice then
    return BotWeapons.weapons[self._previous_weapon_choice].unit
  end
  weapon_index = (weapon_index > #BotWeapons.weapons) and math.random(#BotWeapons.weapons) or weapon_index
  if not BotWeapons:custom_weapons_allowed() and weapon_index > BotWeapons.mp_disabled_index then
    local replacements = BotWeapons.replacements[BotWeapons.weapons[weapon_index].type]
    if replacements then
      weapon_index = replacements[math.random(#replacements)]
    else
      weapon_index = math.random(BotWeapons.mp_disabled_index)
    end
  end
  self._previous_weapon_choice = weapon_index
  return BotWeapons.weapons[weapon_index].unit
end