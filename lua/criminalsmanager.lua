dofile(ModPath .. "lua/botweapons.lua")

local _reserve_loadout_for_original = CriminalsManager._reserve_loadout_for
function CriminalsManager:_reserve_loadout_for(char_name, ...)
  return BotWeapons:set_loadout(char_name, _reserve_loadout_for_original(self, char_name, ...))
end

local get_loadout_for_original = CriminalsManager.get_loadout_for
function CriminalsManager:get_loadout_for(char_name, ...)
  return BotWeapons:set_loadout(char_name, get_loadout_for_original(self, char_name, ...))
end