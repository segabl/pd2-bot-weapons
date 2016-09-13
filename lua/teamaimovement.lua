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

  local result = self._unit:play_redirect(Idstring(new_redirect), at_time)
  return result ~= Idstring("") and result
end

function TeamAIMovement:check_visual_equipment()
  -- set armor & deployables for team ai
  local name = managers.criminals:character_name_by_unit(self._unit)
  -- set armor models
  local armor = BotWeapons._data[name .. "_armor"] or 1
  if armor > 7 or BotWeapons._data["toggle_override_armor"] then
    armor = math.random(#BotWeapons.armor)
  end
  for k, v in pairs(BotWeapons.armor[armor]) do
    local mesh_name = Idstring(k)
    local mesh_obj = self._unit:get_object(mesh_name)
    if mesh_obj then
      mesh_obj:set_visibility(v)
    end
  end
  -- set equipment models
  local equipment = BotWeapons._data[name .. "_equipment"] or 1
  if equipment > 7 or BotWeapons._data["toggle_override_equipment"] then
    equipment = math.random(#BotWeapons.equipment)
  end
  for k, v in pairs(BotWeapons.equipment[equipment]) do
    local mesh_name = Idstring(k)
    local mesh_obj = self._unit:get_object(mesh_name)
    if mesh_obj then
      mesh_obj:set_visibility(v)
    end
  end
end