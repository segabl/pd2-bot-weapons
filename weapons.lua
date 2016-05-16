if BotWeapons ~= nil then
  if botweapons == false and BotWeapons._data["toggle_adjust_damage"] then

    local mult_dif = {
      normal = 0.4,
      hard = 0.6,
      overkill = 0.8,
      overkill_145 = 1,
      overkill_290 = 1
    }
    
    tweak_data.character.presets.weapon.gang_member.beretta92.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.beretta92.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.beretta92.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 5
    
    tweak_data.character.presets.weapon.gang_member.raging_bull.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.raging_bull.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.raging_bull.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 5
    
    tweak_data.character.presets.weapon.gang_member.m4.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.m4.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.m4.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 4
    
    tweak_data.character.presets.weapon.gang_member.ak47.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.ak47.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.ak47.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.35
    
    tweak_data.character.presets.weapon.gang_member.g36.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.g36.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.g36.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.35
    
    tweak_data.character.presets.weapon.gang_member.scar.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.scar.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.scar.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 2
    
    tweak_data.character.presets.weapon.gang_member.m249.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.m249.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.m249.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 2
    
    tweak_data.character.presets.weapon.gang_member.r870.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.8
    tweak_data.character.presets.weapon.gang_member.r870.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.1
    tweak_data.character.presets.weapon.gang_member.r870.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 0
    
    tweak_data.character.presets.weapon.gang_member.mossberg.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.mossberg.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1
    tweak_data.character.presets.weapon.gang_member.mossberg.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 0
    
    tweak_data.character.presets.weapon.gang_member.benelli.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.6
    tweak_data.character.presets.weapon.gang_member.benelli.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 0.8
    tweak_data.character.presets.weapon.gang_member.benelli.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 0
    
    tweak_data.character.presets.weapon.gang_member.saiga.FALLOFF[1].dmg_mul = mult_dif[Global.game_settings.difficulty] * 1.4
    tweak_data.character.presets.weapon.gang_member.saiga.FALLOFF[2].dmg_mul = mult_dif[Global.game_settings.difficulty] * 0.7
    tweak_data.character.presets.weapon.gang_member.saiga.FALLOFF[3].dmg_mul = mult_dif[Global.game_settings.difficulty] * 0

  end

  for i = 1, CriminalsManager.get_num_characters() do
    local c = CriminalsManager.character_names()[i]
    local w = BotWeapons._data[c] or 4
    if (BotWeapons._data["toggle_override"]) then
      w = BotWeapons._data["override"]
    end
    w = (w > #BotWeapons.weapon_unit_names) and math.random(#BotWeapons.weapon_unit_names) or w
    
    tweak_data.character[c].weapon = deep_clone(tweak_data.character.presets.weapon.gang_member)
    tweak_data.character[c].weapon.weapons_of_choice = {primary = BotWeapons.weapon_unit_names[w], secondary = BotWeapons.weapon_unit_names[w]}
  end
  
  botweapons = true
end