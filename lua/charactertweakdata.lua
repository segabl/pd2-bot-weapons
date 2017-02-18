dofile(ModPath .. "lua/botweapons.lua")

local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(...)
  log("[BotWeapons] Setting up weapon presets")
  local presets = _presets_original(self, ...)
  
  -- loop through all weapon presets and link new presets to old ones for all the weapons
  for k, v in pairs(presets.weapon) do
    v.benelli = v.r870
    v.g36 = v.m4
    v.scar = v.m4
    v.lmg = v.ak47
  end
  
  -- gang_member presets
  local m4_dmg_mul = presets.weapon.gang_member.m4.FALLOFF[1].dmg_mul
  -- pistols
  presets.weapon.gang_member.beretta92.range = { close = 2000, optimal = 3500, far = 7000 }
  BotWeapons:copy_falloff(presets.weapon.gang_member.beretta92, presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.beretta92, m4_dmg_mul * 1.5)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.beretta92, 1.5)
  
  presets.weapon.gang_member.c45 = deep_clone(presets.weapon.gang_member.beretta92)
  
  presets.weapon.gang_member.raging_bull = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.raging_bull.RELOAD_SPEED = 0.5
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.raging_bull, m4_dmg_mul * 0.8)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.raging_bull, { { 0.5, 1 }, { 0.75, 2 } })
  -- rifles
  presets.weapon.gang_member.ak47 = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.ak47, m4_dmg_mul * 0.3)
  
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.g36, m4_dmg_mul * 0.3)
  
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.scar, m4_dmg_mul * 0.5)
  
  presets.weapon.gang_member.m14 = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.m14.RELOAD_SPEED = 0.3
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.m14, m4_dmg_mul * 0.7)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.m14, { { 0.2, 0.5 }, { 0.75, 2 }, { 2, 3 } })
  -- smgs
  presets.weapon.gang_member.mp5 = deep_clone(presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.mp5, m4_dmg_mul * 0.8)
  
  presets.weapon.gang_member.p90 = deep_clone(presets.weapon.gang_member.mp5)
  presets.weapon.gang_member.p90.RELOAD_SPEED = 0.5
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.p90, 0.8)
  -- lmgs
  presets.weapon.gang_member.lmg = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.lmg.autofire_rounds = { 15, 40 }
  presets.weapon.gang_member.lmg.RELOAD_SPEED = 0.3
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.lmg, m4_dmg_mul * 0.4)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.lmg, 0.4)
  BotWeapons:set_auto_fire_mode(presets.weapon.gang_member.lmg, { { 0, 0, 0, 1 }, { 0, 0, 0.5, 1 }, { 0, 0, 1, 0 } })
  -- shotguns
  presets.weapon.gang_member.r870.range = { close = 750, optimal = 1500, far = 4000 }
  presets.weapon.gang_member.r870.FALLOFF[1].r = 300
  presets.weapon.gang_member.r870.FALLOFF[2].r = 2000
  presets.weapon.gang_member.r870.FALLOFF[3].r = 5000
  BotWeapons:copy_falloff(presets.weapon.gang_member.r870, presets.weapon.gang_member.m4)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.r870, m4_dmg_mul * 0.6)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.r870, { { 1, 1 }, { 1, 2 } })
  
  presets.weapon.gang_member.benelli = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.benelli, m4_dmg_mul * 0.5)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.benelli, { { 0.25, 0.25 }, { 0.25, 0.75 }, { 0.5, 1.5 } })

  presets.weapon.gang_member.mossberg = deep_clone(presets.weapon.gang_member.r870)
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.mossberg, m4_dmg_mul * 0.9)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.mossberg, { { 0.25, 0.5 }, { 0.5, 2 } })
  
  presets.weapon.gang_member.judge = deep_clone(presets.weapon.gang_member.benelli)
  presets.weapon.gang_member.judge.RELOAD_SPEED = 1
  -- akimbo
  presets.weapon.gang_member.akimbo_pistol = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.akimbo_pistol.RELOAD_SPEED = 0.7
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.akimbo_pistol, m4_dmg_mul)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.akimbo_pistol, { { 0.1, 0.2 }, { 0.2, 0.4 }, { 0.6, 1 } })
  
  presets.weapon.gang_member.akimbo_auto = deep_clone(presets.weapon.gang_member.mp5)
  presets.weapon.gang_member.akimbo_auto.RELOAD_SPEED = 0.4
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.akimbo_auto, 0.7)
  -- snipers
  presets.weapon.gang_member.sniper = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.sniper.range = { close = 5000, optimal = 10000, far = 15000 }
  presets.weapon.gang_member.sniper.RELOAD_SPEED = 0.3
  BotWeapons:set_damage_multiplicator(presets.weapon.gang_member.sniper, m4_dmg_mul * 3.5)
  BotWeapons:set_accuracy_multiplicator(presets.weapon.gang_member.sniper, 2)
  BotWeapons:set_single_fire_mode(presets.weapon.gang_member.sniper, { { 3, 4 }, { 4, 5 }, { 5, 6 } })
  
  return presets
end

local _init_tank_original = CharacterTweakData._init_tank
function CharacterTweakData:_init_tank(...)
  _init_tank_original(self, ...)
  -- transfer ak47 weapon settings to new lmg preset
  self.tank.weapon.lmg = self.tank.weapon.ak47
end

local _init_mobster_boss_original = CharacterTweakData._init_mobster_boss
function CharacterTweakData:_init_mobster_boss(...)
  _init_mobster_boss_original(self, ...)
  -- transfer ak47 weapon settings to new lmg preset
  self.mobster_boss.weapon.lmg = self.mobster_boss.weapon.ak47
end

local _init_biker_boss_original = CharacterTweakData._init_biker_boss
function CharacterTweakData:_init_biker_boss(...)
  _init_biker_boss_original(self, ...)
  -- transfer ak47 weapon settings to new lmg preset
  self.biker_boss.weapon.lmg = self.biker_boss.weapon.ak47
end