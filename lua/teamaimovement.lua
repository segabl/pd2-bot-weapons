dofile(ModPath .. "lua/botweapons.lua")

function TeamAIMovement:play_redirect(redirect_name, at_time)
  -- Fix buggy auto animations when shooting with guns that use pistol animations
  local new_redirect = redirect_name
  local weapon = self._unit:inventory():equipped_unit()
  if weapon and new_redirect == "recoil_auto" then
    tweak = weapon:base():weapon_tweak_data()
    if tweak.hold == "pistol" or tweak.hold == "akimbo_pistol" then
      new_redirect = "recoil_single"
    end
  end
  return TeamAIMovement.super.play_redirect(self, new_redirect, at_time)
end

function TeamAIMovement:check_visual_equipment()
  -- set armor & deployables for team ai
  local name = managers.criminals:character_name_by_unit(self._unit)
  -- choose armor models
  local armor = BotWeapons._data[name .. "_armor"] or 1
  if armor > 7 or BotWeapons._data.toggle_override_armor then
    armor = math.random(#BotWeapons.armor)
  end
  -- choose equipment models
  local equipment = BotWeapons._data[name .. "_equipment"] or 1
  if equipment > 8 or BotWeapons._data.toggle_override_equipment then
    equipment = math.random(#BotWeapons.equipment)
  end
  BotWeapons:set_equipment(self._unit, armor, equipment)
  if not Global.game_settings.single_player and LuaNetworking:IsHost() then
    LuaNetworking:SendToPeers("bot_weapons_equipment", json.encode({name = name, armor = armor, equipment = equipment}))
  end
end