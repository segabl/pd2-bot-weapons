dofile(ModPath .. "lua/botweapons.lua")

function TeamAIMovement:play_redirect(redirect_name, at_time)
  -- Fix buggy autofire animations when shooting with guns that use pistol animations
  local weapon = self._unit:inventory():equipped_unit()
  if weapon and redirect_name == "recoil_auto" then
    tweak = weapon:base():weapon_tweak_data()
    if tweak.hold == "pistol" or tweak.hold == "akimbo_pistol" then
      redirect_name = "recoil_single"
    end
  end
  return TeamAIMovement.super.play_redirect(self, redirect_name, at_time)
end

function TeamAIMovement:check_visual_equipment()
  -- set armor & deployables for team ai
  local name = managers.criminals:character_name_by_unit(self._unit)
  -- choose armor models
  local armor = BotWeapons._data.toggle_override_armor and BotWeapons._data.override_armor or BotWeapons._data[name .. "_armor"] or 1
  if armor > #BotWeapons.armor_ids - 1 then
    armor = math.random(#BotWeapons.armor_ids - 1)
  end
  -- choose equipment models
  local equipment = BotWeapons._data.toggle_override_equipment and BotWeapons._data.override_equipment or BotWeapons._data[name .. "_equipment"] or 1
  if equipment > #BotWeapons.equipment_ids - 1 then
    equipment = math.random(#BotWeapons.equipment_ids - 1)
  end
  BotWeapons:set_equipment(self._unit, armor, equipment)
  self._bot_weapons_armor = armor
  self._bot_weapons_equipment = equipment
end