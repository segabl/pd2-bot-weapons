dofile(ModPath .. "lua/botweapons.lua")

function TeamAIBase:default_weapon_name(slot)
  -- override default weapons
  if self._previous_weapon_choice then
    return self._previous_weapon_choice
  end
  local weapon_index = BotWeapons._data[self._tweak_table .. "_weapon"] or 1
  if BotWeapons._data.toggle_override_weapons then
    weapon_index = BotWeapons._data.override_weapons or #BotWeapons.weapons
  end
  if weapon_index > #BotWeapons.weapons - 1 then
    weapon_index = math.random(#BotWeapons.weapons - 1)
  end
  self._previous_weapon_choice = BotWeapons.weapons[weapon_index].unit
  return self._previous_weapon_choice
end