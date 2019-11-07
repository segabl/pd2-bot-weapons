local set_unit_teamAI_original = GroupAIStateBase.set_unit_teamAI
function GroupAIStateBase:set_unit_teamAI(unit, character_name, team_id, visual_seed, loadout, ...)
  set_unit_teamAI_original(self, unit, character_name, team_id, visual_seed, loadout, ...)

  if Network:is_server() then
    -- set armor & deployables for team ai
    BotWeapons:set_special_material(unit, loadout.special_material)
    BotWeapons:set_armor(unit, loadout.armor, loadout.armor_skin)
    BotWeapons:set_equipment(unit, loadout.deployable)

    BotWeapons:sync_to_all_peers(unit, loadout, 2)
  end
end