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
  -- set new usage
  self.m249_npc.usage = "m249"
  self.scar_npc.usage = "scar"
  self.g36_npc.usage = "g36"
  -- setup weapons
  log("[BotWeapons] Setting up weapons")
  for _, weapon in ipairs(BotWeapons.weapons) do
    if weapon.tweak_data and self[weapon.tweak_data] then
      --log("[BotWeapons] Setting up " .. weapon.tweak_data)
      local fields_change = weapon.fields_change or {}
      if weapon.based_on and self[weapon.based_on] and weapon.tweak_data ~= weapon.based_on then
        for _, field in ipairs(weapon.fields_preserve or {}) do
          --log("[BotWeapons] Preserving field " .. field)
          if type(self[weapon.tweak_data][field]) == "table" then
            fields_change[field] = deep_clone(self[weapon.tweak_data][field])
          else
            fields_change[field] = self[weapon.tweak_data][field]
          end
        end
        --log("[BotWeapons] Copying settings from " .. weapon.based_on)
        self[weapon.tweak_data] = deep_clone(self[weapon.based_on])
      end
      for field, value in pairs(fields_change) do
        --log("[BotWeapons] Setting field " .. field)
        self[weapon.tweak_data][field] = value
      end
    elseif weapon.tweak_data then
      log("[BotWeapons] Could not find preset " .. weapon.tweak_data)
    end
  end
end