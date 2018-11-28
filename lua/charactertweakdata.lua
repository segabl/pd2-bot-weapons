if BotWeapons._data.weapon_balance then

  local _presets_original = CharacterTweakData._presets
  function CharacterTweakData:_presets(...)
    local presets = _presets_original(self, ...)
    BotWeapons:log("Fixing gang presets")
    
    local gang_presets = presets.weapon.gang_member
    for _, v in pairs(gang_presets) do
      v.aim_delay = gang_presets.is_rifle.aim_delay
      v.focus_delay = gang_presets.is_rifle.focus_delay
    end
    
    local rifle_dmg_mul = gang_presets.is_rifle.FALLOFF[1].dmg_mul
    local rifle_spread = math.min(gang_presets.is_rifle.spread, 20)
    
    -- rifle preset
    gang_presets.is_rifle.FALLOFF = {
      { dmg_mul = rifle_dmg_mul * 0.8, r = 500, acc = { 1, 1 }, recoil = { 0.25, 0.35 }, mode = { 0, 0, 0, 1 } },
      { dmg_mul = rifle_dmg_mul * 0.6, r = 1500, acc = { 1, 1 }, recoil = { 0.35, 0.5 }, mode = { 0, 0, 3, 7 } },
      { dmg_mul = rifle_dmg_mul * 0.4, r = 3000, acc = { 1, 1 }, recoil = { 0.5, 0.75 }, mode = { 0.1, 0.3, 4, 7 } }
    }
    gang_presets.is_rifle.spread = rifle_spread
    gang_presets.is_bullpup = gang_presets.is_rifle
    gang_presets.is_smg = gang_presets.is_rifle
    
    -- sniper preset
    gang_presets.is_sniper.FALLOFF = {
      { dmg_mul = rifle_dmg_mul * 0.5, r = 4000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
    }
    gang_presets.is_sniper.spread = rifle_spread * 0.75
    gang_presets.is_pistol = gang_presets.is_sniper
    gang_presets.is_revolver = gang_presets.is_sniper
    
    -- LMG preset
    gang_presets.is_lmg.FALLOFF = {
      { dmg_mul = rifle_dmg_mul * 1.0, r = 500, acc = { 1, 1 }, recoil = { 0.25, 0.45 }, mode = { 0, 0, 0, 1 } },
      { dmg_mul = rifle_dmg_mul * 0.8, r = 2000, acc = { 0.8, 0.9 }, recoil = { 0.4, 0.65 }, mode = { 0, 0, 0, 1 } },
      { dmg_mul = rifle_dmg_mul * 0.4, r = 2500, acc = { 0.4, 0.7 }, recoil = { 0.6, 0.9 }, mode = { 0, 0, 0, 1 } },
      { dmg_mul = rifle_dmg_mul * 0.02, r = 4000, acc = { 0.1, 0.4 }, recoil = { 1, 2 }, mode = { 0, 0, 0, 1 } },
    }
    gang_presets.is_lmg.spread = rifle_spread
    
    -- single shotgun preset
    gang_presets.is_shotgun_pump.FALLOFF = {
      { dmg_mul = rifle_dmg_mul * 1.0, r = 500, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
      { dmg_mul = rifle_dmg_mul * 0.5, r = 1500, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
      { dmg_mul = rifle_dmg_mul * 0.1, r = 2000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
      { dmg_mul = rifle_dmg_mul * 0.0, r = 4000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
    }
    gang_presets.is_shotgun_pump.spread = rifle_spread * 0.75
    
    -- auto shotgun preset
    gang_presets.is_shotgun_mag.FALLOFF = {
      { dmg_mul = rifle_dmg_mul * 1.0, r = 500, acc = { 1, 1 }, recoil = { 0.1, 0.2 }, mode = { 0, 0, 0, 1 } },
      { dmg_mul = rifle_dmg_mul * 0.5, r = 1500, acc = { 0.9, 1 }, recoil = { 0.2, 0.35 }, mode = { 0, 0, 1, 3 } },
      { dmg_mul = rifle_dmg_mul * 0.1, r = 2000, acc = { 0.8, 0.9 }, recoil = { 0.35, 0.55 }, mode = { 0, 0, 2, 3 } },
      { dmg_mul = rifle_dmg_mul * 0.0, r = 4000, acc = { 0.6, 0.8 }, recoil = { 0.55, 1 }, mode = { 0, 0, 1, 1 } },
    }
    gang_presets.is_shotgun_mag.spread = rifle_spread
    
    -- akimbo pistol preset
    gang_presets.akimbo_pistol = deep_clone(gang_presets.is_rifle)
    gang_presets.akimbo_pistol.FALLOFF = {
      { dmg_mul = rifle_dmg_mul * 0.8, r = 500, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
      { dmg_mul = rifle_dmg_mul * 0.6, r = 1500, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
      { dmg_mul = rifle_dmg_mul * 0.4, r = 3000, acc = { 1, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
    }
    gang_presets.akimbo_pistol.spread = rifle_spread * 0.9
    
    return presets
  end

end