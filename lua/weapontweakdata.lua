dofile(ModPath .. "lua/botweapons.lua")

local init_original = WeaponTweakData.init
function WeaponTweakData:init(...)
  init_original(self, ...)
  -- copy animations from usage
  for _, v in pairs(self) do
    if type(v) == "table" then
      if v.usage then
        v.anim = v.usage
      end
    end
  end
  -- fix stuff
  self.tecci_crew.auto = { fire_rate = 0.09 }
  self.x_mp5_crew.auto = { fire_rate = 0.08 }
  self.x_akmsu_crew.auto = { fire_rate = 0.073 }
  self.x_sr2_crew.auto = { fire_rate = 0.08 }
  self.desertfox_crew.auto = { fire_rate = 1 }
  -- setup weapons
  local m4_dps = self.m4_crew.DAMAGE / self.m4_crew.auto.fire_rate
  for _, weapon in ipairs(BotWeapons.weapons) do
    local preset = weapon.tweak_data and weapon.tweak_data.name and self[weapon.tweak_data.name]
    if preset then
      -- calculate damage based on fire rate and m4 damage
      if preset.auto and preset.auto.fire_rate then
        preset.DAMAGE = m4_dps * preset.auto.fire_rate
      end
      -- overwrite fields given in in weapon definition
      for field, value in pairs(weapon.tweak_data) do
        if field ~= "name" then
          preset[field] = value
        end
      end
    end
  end
end