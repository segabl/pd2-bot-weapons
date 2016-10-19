dofile(ModPath .. "lua/botweapons.lua")

function TeamAIBase:default_weapon_name(slot)
  -- override default weapons
  if self._previous_weapon_choice then
    return self._previous_weapon_choice
  end
  local weapon_index = BotWeapons._data[self._tweak_table .. "_weapon"]
  if BotWeapons._data.toggle_override_weapons then
    weapon_index = BotWeapons._data.override_weapons or #BotWeapons.weapons
  end
  if not weapon_index then
    return tweak_data.character[self._tweak_table].weapon.weapons_of_choice[slot or "primary"]
  end
  if weapon_index > #BotWeapons.weapons - 1 then
    weapon_index = math.random(#BotWeapons.weapons - 1)
  end
  if not BotWeapons:custom_weapons_allowed() and weapon_index > BotWeapons.mp_disabled_index then
    local replacements = BotWeapons.replacements[BotWeapons.weapons[weapon_index].type]
    if replacements then
      weapon_index = replacements[math.random(#replacements)]
    else
      weapon_index = math.random(BotWeapons.mp_disabled_index)
    end
  end
  self._previous_weapon_choice = BotWeapons.weapons[weapon_index].unit
  return self._previous_weapon_choice
end