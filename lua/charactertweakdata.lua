if not BotWeapons.settings.weapon_balance then
  return
end

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(tweak_data, ...)
  local presets = _presets_original(self, tweak_data, ...)

  local gang_presets = presets.weapon.gang_member

  local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or "normal")
  local rifle_dmg_mul = StreamHeist and gang_presets.is_rifle.FALLOFF[1].dmg_mul or difficulty_index * 0.75
  local rifle_spread = 15

  BotWeapons:log("Fixing gang presets, reference dmg_mul is " .. rifle_dmg_mul)

  -- rifle preset
  gang_presets.is_rifle.FALLOFF = {
    { dmg_mul = rifle_dmg_mul * 0.8, r = 500, acc = { 0.6, 0.9 }, recoil = { 0.25, 0.35 }, mode = { 0, 0, 0, 1 } },
    { dmg_mul = rifle_dmg_mul * 0.6, r = 1500, acc = { 0.4, 0.7 }, recoil = { 0.35, 0.5 }, mode = { 0, 0, 3, 7 } },
    { dmg_mul = rifle_dmg_mul * 0.4, r = 3000, acc = { 0.2, 0.5 }, recoil = { 0.5, 0.75 }, mode = { 0.1, 0.3, 4, 7 } }
  }
  gang_presets.is_rifle.spread = rifle_spread
  gang_presets.is_bullpup = gang_presets.is_rifle
  gang_presets.is_smg = gang_presets.is_rifle

  -- sniper preset
  gang_presets.is_sniper.FALLOFF = {
    { dmg_mul = rifle_dmg_mul * 0.5, r = 4000, acc = { 0.5, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
  }
  gang_presets.is_sniper.spread = rifle_spread * 0.75
  gang_presets.is_pistol = gang_presets.is_sniper
  gang_presets.is_revolver = gang_presets.is_sniper

  -- LMG preset
  gang_presets.is_lmg.FALLOFF = {
    { dmg_mul = rifle_dmg_mul * 1.0, r = 500, acc = { 0.4, 0.8 }, recoil = { 0.25, 0.45 }, mode = { 0, 0, 0, 1 } },
    { dmg_mul = rifle_dmg_mul * 0.8, r = 2000, acc = { 0.2, 0.6 }, recoil = { 0.4, 0.65 }, mode = { 0, 0, 0, 1 } },
    { dmg_mul = rifle_dmg_mul * 0.4, r = 2500, acc = { 0, 0.4 }, recoil = { 0.6, 0.9 }, mode = { 0, 0, 0, 1 } },
    { dmg_mul = rifle_dmg_mul * 0.1, r = 4000, acc = { 0, 0.1 }, recoil = { 1, 2 }, mode = { 0, 0, 0, 1 } },
  }
  gang_presets.is_lmg.spread = rifle_spread * 1.2

  -- single shotgun preset
  gang_presets.is_shotgun_pump.FALLOFF = {
    { dmg_mul = rifle_dmg_mul * 1.0, r = 500, acc = { 0.8, 1 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = rifle_dmg_mul * 0.5, r = 1500, acc = { 0.7, 0.9 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = rifle_dmg_mul * 0.1, r = 2000, acc = { 0.6, 0.8 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = rifle_dmg_mul * 0.0, r = 4000, acc = { 0.5, 0.7 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
  }
  gang_presets.is_shotgun_pump.spread = rifle_spread * 0.75

  -- auto shotgun preset
  gang_presets.is_shotgun_mag.FALLOFF = {
    { dmg_mul = rifle_dmg_mul * 1.0, r = 500, acc = { 0.8, 1 }, recoil = { 0.1, 0.2 }, mode = { 0, 0, 0, 1 } },
    { dmg_mul = rifle_dmg_mul * 0.5, r = 1500, acc = { 0.7, 0.9 }, recoil = { 0.2, 0.35 }, mode = { 0, 0, 1, 3 } },
    { dmg_mul = rifle_dmg_mul * 0.1, r = 2000, acc = { 0.6, 0.8 }, recoil = { 0.35, 0.55 }, mode = { 0, 0, 2, 3 } },
    { dmg_mul = rifle_dmg_mul * 0.0, r = 4000, acc = { 0.5, 0.7 }, recoil = { 0.55, 1 }, mode = { 0, 0, 1, 1 } },
  }
  gang_presets.is_shotgun_mag.spread = rifle_spread

  -- akimbo pistol preset
  gang_presets.akimbo_pistol = deep_clone(gang_presets.is_rifle)
  gang_presets.akimbo_pistol.FALLOFF = {
    { dmg_mul = rifle_dmg_mul * 0.8, r = 500, acc = { 0.6, 0.9 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = rifle_dmg_mul * 0.6, r = 1500, acc = { 0.4, 0.7 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = rifle_dmg_mul * 0.4, r = 3000, acc = { 0.2, 0.5 }, recoil = { 1, 1 }, mode = { 1, 0, 0, 0 } }
  }
  gang_presets.akimbo_pistol.spread = rifle_spread * 0.9

  return presets
end