dofile(ModPath .. "botweapons.lua")

if BotWeapons._data.weapon_balance then

  local _presets_original = CharacterTweakData._presets
  function CharacterTweakData:_presets(...)
    local presets = _presets_original(self, ...)
    BotWeapons:log("Fixing gang presets")
    -- gang_member presets
    local gang_presets = presets.weapon.gang_member
    -- fix rifle recoil
    for i, v in ipairs(gang_presets.is_rifle.FALLOFF) do
      v.recoil = gang_presets.is_rifle.FALLOFF[1].recoil
    end
    -- set presets
    gang_presets.is_pistol.spread = gang_presets.is_rifle.spread * 0.85
    gang_presets.is_revolver = gang_presets.is_pistol
    gang_presets.akimbo_pistol = gang_presets.is_pistol
    gang_presets.is_bullpup = gang_presets.is_rifle
    gang_presets.is_smg = gang_presets.is_rifle
    gang_presets.is_lmg.spread = gang_presets.is_rifle.spread
    gang_presets.is_shotgun_pump.spread = gang_presets.is_rifle.spread * 0.75
    gang_presets.is_shotgun_mag.spread = gang_presets.is_rifle.spread
    gang_presets.is_sniper.spread = gang_presets.is_rifle.spread * 0.9
    return presets
  end

end