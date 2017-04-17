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
  -- setup weapons
  for _, weapon in ipairs(BotWeapons.weapons) do
    if weapon.tweak_data and weapon.tweak_data.name and self[weapon.tweak_data.name] then
      for field, value in pairs(weapon.tweak_data or {}) do
        if field ~= "name" then
          self[weapon.tweak_data.name][field] = value
        end
      end
    end
  end
end