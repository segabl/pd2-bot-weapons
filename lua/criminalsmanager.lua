local _reserve_loadout_for_original = CriminalsManager._reserve_loadout_for
function CriminalsManager:_reserve_loadout_for(char_name, ...)
  return BotWeapons:get_loadout(char_name, _reserve_loadout_for_original(self, char_name, ...))
end

local get_loadout_for_original = CriminalsManager.get_loadout_for
function CriminalsManager:get_loadout_for(char_name, ...)
  return BotWeapons:get_loadout(char_name, get_loadout_for_original(self, char_name, ...))
end

local update_character_visual_state_original = CriminalsManager.update_character_visual_state
function CriminalsManager:update_character_visual_state(character_name, visual_state, ...)
  local character = self:character_by_name(character_name)
  if character and character.taken and character.data.ai and alive(character.unit) then
    local loadout = self:get_loadout_for(character_name)

    visual_state = visual_state or {}
    if BotWeapons:should_use_armor() then
      visual_state.armor_id = loadout.armor
      visual_state.armor_skin = loadout.armor_skin
      BotWeapons:set_armor(character.unit, loadout.armor, loadout.armor_skin)
    end
    BotWeapons:set_equipment(character.unit, loadout.deployable)

    if Network:is_server() then
      BotWeapons:sync_to_all_peers(character.unit, loadout, 2)
    end
  end
  return update_character_visual_state_original(self, character_name, visual_state, ...)
end