dofile(ModPath .. "lua/botweapons.lua")

function TeamAIBase:default_weapon_name(slot)
  -- override default weapons
  if not BotWeapons._data[self._tweak_table .. "_weapon"] then
    return tweak_data.character[self._tweak_table].weapon.weapons_of_choice[slot or "primary"]
  end
  if self._previous_weapon_choice then
    return BotWeapons.weapons[self._previous_weapon_choice]
  end
  local w = BotWeapons._data[self._tweak_table .. "_weapon"]
  if (BotWeapons._data.toggle_override_weapons) then
    w = BotWeapons._data.override_weapons
  end
  w = (w > #BotWeapons.weapons) and math.random(#BotWeapons.weapons) or w
  while not BotWeapons:custom_weapons_allowed() and w > BotWeapons.mp_disabled_index do
    w = math.random(BotWeapons.mp_disabled_index)
  end
  self._previous_weapon_choice = w
  return BotWeapons.weapons[w]
end