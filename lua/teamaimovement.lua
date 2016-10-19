dofile(ModPath .. "lua/botweapons.lua")

function TeamAIMovement:play_redirect(redirect_name, at_time)
  -- Fix buggy autofire animations when shooting with akimbo guns
  local weapon = self._unit:inventory():equipped_unit()
  if weapon and redirect_name == "recoil_auto" then
    tweak = weapon:base():weapon_tweak_data()
    if tweak.hold == "akimbo_pistol" then
      redirect_name = "recoil_single"
    end
  end
  return TeamAIMovement.super.play_redirect(self, redirect_name, at_time)
end

function TeamAIMovement:check_visual_equipment()
  -- set armor & deployables for team ai
  local name = managers.criminals:character_name_by_unit(self._unit)
  -- choose armor models
  local armor_index = BotWeapons._data[name .. "_armor"] or 1
  if BotWeapons._data.toggle_override_armor then
    armor_index = BotWeapons._data.override_armor or #BotWeapons.armor
  end
  if armor_index > #BotWeapons.armor - 1 then
    armor_index = math.random(#BotWeapons.armor - 1)
  end
  -- choose equipment models
  local equipment_index = BotWeapons._data[name .. "_equipment"] or 1
  if BotWeapons._data.toggle_override_equipment then
    equipment_index = BotWeapons._data.override_equipment or #BotWeapons.equipment
  end
  if equipment_index > #BotWeapons.equipment - 1 then
    equipment_index = math.random(#BotWeapons.equipment - 1)
  end
  self._armor_index = armor_index
  self._equipment_index = equipment_index
  BotWeapons:set_armor(self._unit, armor_index)
  BotWeapons:set_equipment(self._unit, equipment_index)
  BotWeapons:sync_armor_and_equipment(self._unit, armor_index, equipment_index)
end