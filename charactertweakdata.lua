local _presetsORIG = CharacterTweakData._presets

function CharacterTweakData:_presets(tweak_data)
  log("[BotWeapons] Setting up additional npc weapon presets")
  local presets = _presetsORIG(self, tweak_data)
  
  -- loop through all weapon presets and create new presets from old ones
  for k, v in pairs(presets.weapon) do
    if v.m4 ~= nil then
      v.g36 = deep_clone(v.m4)
      v.scar = deep_clone(v.m4)
    end
    
    if v.r870 ~= nil then
      v.benelli = deep_clone(v.r870)
    end

    if v.ak47 ~= nil then
      v.m249 = deep_clone(v.ak47)
    end
  end
  
  -- gang_member presets
  -- pistols
  presets.weapon.gang_member.raging_bull = deep_clone(presets.weapon.gang_member.beretta92)
  presets.weapon.gang_member.raging_bull.RELOAD_SPEED = 0.7
  -- rifles
  presets.weapon.gang_member.ak47 = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.g36 = deep_clone(presets.weapon.gang_member.m4)
  presets.weapon.gang_member.scar = deep_clone(presets.weapon.gang_member.m4)
  -- lmg
  presets.weapon.gang_member.m249.autofire_rounds = { 20, 40 }
  presets.weapon.gang_member.m249.RELOAD_SPEED = 0.25
  presets.weapon.gang_member.m249.FALLOFF[1].acc = {0.3, 0.7}
  presets.weapon.gang_member.m249.FALLOFF[2].acc = {0.1, 0.2}
  presets.weapon.gang_member.m249.FALLOFF[3].acc = {0, 0.1}
  presets.weapon.gang_member.m249.FALLOFF[1].recoil = {0, 1}
  presets.weapon.gang_member.m249.FALLOFF[2].recoil = {1, 2}
  presets.weapon.gang_member.m249.FALLOFF[3].recoil = {2, 3}
  -- shotguns
  presets.weapon.gang_member.r870.FALLOFF[2].r = 2000
  presets.weapon.gang_member.r870.FALLOFF[3].r = 10000
  presets.weapon.gang_member.mossberg = deep_clone(presets.weapon.gang_member.r870)
  -- auto shotguns
  presets.weapon.gang_member.benelli = deep_clone(presets.weapon.gang_member.r870)
  presets.weapon.gang_member.benelli.autofire_rounds = { 3, 7 }
  presets.weapon.gang_member.saiga = deep_clone(presets.weapon.gang_member.benelli)
  presets.weapon.gang_member.saiga.RELOAD_SPEED = 0.4
  
  return presets
end

local _init_tankORIG = CharacterTweakData._init_tank
function CharacterTweakData:_init_tank(presets)
  _init_tankORIG(self, presets)
  -- transfer ak47 weapon settings to new m249 preset
  self.tank.weapon.m249 = deep_clone(self.tank.weapon.ak47)
end

local _init_mobster_bossORIG = CharacterTweakData._init_mobster_boss
function CharacterTweakData:_init_mobster_boss(presets)
  _init_mobster_bossORIG(self, presets)
  -- transfer ak47 weapon settings to new m249 preset
  self.mobster_boss.weapon.m249 = deep_clone(self.mobster_boss.weapon.ak47)
end