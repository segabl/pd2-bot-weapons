if botweapons == false and BotWeapons ~= nil and Utils:IsInGameState() then

  if BotWeapons._data["toggle_adjust_damage"] then

    tweak_data.character.presets.weapon.gang_member.c45.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.c45.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.c45.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    
    tweak_data.character.presets.weapon.gang_member.beretta92.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.beretta92.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.beretta92.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    
    tweak_data.character.presets.weapon.gang_member.raging_bull.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.raging_bull.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.raging_bull.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    
    tweak_data.character.presets.weapon.gang_member.m4.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.m4.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.m4.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    
    tweak_data.character.presets.weapon.gang_member.mp5.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.mp5.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.mp5.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    
    tweak_data.character.presets.weapon.gang_member.ak47.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.ak47.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.ak47.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.35
    
    tweak_data.character.presets.weapon.gang_member.g36.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.g36.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.35
    tweak_data.character.presets.weapon.gang_member.g36.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.35
    
    tweak_data.character.presets.weapon.gang_member.scar.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.scar.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.scar.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    
    tweak_data.character.presets.weapon.gang_member.m14.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.m14.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.m14.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    
    tweak_data.character.presets.weapon.gang_member.m249.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.m249.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.m249.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    
    tweak_data.character.presets.weapon.gang_member.r870.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.r870.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.5
    tweak_data.character.presets.weapon.gang_member.r870.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 0.7
    
    tweak_data.character.presets.weapon.gang_member.mossberg.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 3.2
    tweak_data.character.presets.weapon.gang_member.mossberg.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 2
    tweak_data.character.presets.weapon.gang_member.mossberg.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1
    
    tweak_data.character.presets.weapon.gang_member.saiga.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.5
    tweak_data.character.presets.weapon.gang_member.saiga.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1
    tweak_data.character.presets.weapon.gang_member.saiga.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 0.5
    
    tweak_data.character.presets.weapon.gang_member.judge.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 3.5
    tweak_data.character.presets.weapon.gang_member.judge.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 1.8
    tweak_data.character.presets.weapon.gang_member.judge.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 0.9
    
    tweak_data.character.presets.weapon.gang_member.akimbo_pistol.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.akimbo_pistol.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    tweak_data.character.presets.weapon.gang_member.akimbo_pistol.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 5
    
    tweak_data.character.presets.weapon.gang_member.akimbo_auto.FALLOFF[1].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.akimbo_auto.FALLOFF[2].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4
    tweak_data.character.presets.weapon.gang_member.akimbo_auto.FALLOFF[3].dmg_mul = BotWeapons.multiplier[Global.game_settings.difficulty] * 4

  end

  for i, c in ipairs(CriminalsManager.character_names()) do
    local w = BotWeapons._data[c .. "_weapon"] or 4
    if (BotWeapons._data["toggle_override_weapons"]) then
      w = BotWeapons._data["override_weapons"]
    end
    w = (w > #BotWeapons.weapons) and math.random(#BotWeapons.weapons) or w
    
    -- if we are in multiplayer, remove weapons that would crash clients
    while not Global.game_settings.single_player and w > BotWeapons.mp_disabled_index do
      log("[BotWeapons] Removing custom weapon from bot in multiplayer!")
      w = math.random(BotWeapons.mp_disabled_index)
    end
    
    tweak_data.character[c].weapon = deep_clone(tweak_data.character.presets.weapon.gang_member)
    tweak_data.character[c].weapon.weapons_of_choice = {primary = BotWeapons.weapons[w], secondary = BotWeapons.weapons[w]}
  end
  
  botweapons = true
end