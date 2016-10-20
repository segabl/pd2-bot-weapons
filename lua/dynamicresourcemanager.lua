dofile(ModPath .. "lua/botweapons.lua")

local preload_units_original = DynamicResourceManager.preload_units
function DynamicResourceManager:preload_units(...)
  preload_units_original(self, ...)
  -- load weapon units
  BotWeapons:load_weapon_units()
end