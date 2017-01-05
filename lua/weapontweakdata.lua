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
  self.benelli_npc.usage = "benelli"
  self.m249_npc.usage = "m249"
  self.scar_npc.usage = "scar"
  self.g36_npc.usage = "g36"
  self.m95_npc.usage = "sniper"
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

-- some fixes for default weapon presets used by LQ version of some guns
local _init_data_beretta92_npc_original = WeaponTweakData._init_data_beretta92_npc
function WeaponTweakData:_init_data_beretta92_npc()
  _init_data_beretta92_npc_original(self)
  self.beretta92_npc.has_suppressor = "suppressed_a"
  self.beretta92_primary_npc.has_suppressor = "suppressed_a"
end

local _init_data_r870_npc_original = WeaponTweakData._init_data_r870_npc
function WeaponTweakData:_init_data_r870_npc()
  _init_data_r870_npc_original(self)
  self.benelli_npc.sounds.prefix = "benelli_m4_npc"
end

local _init_data_mossberg_npc_original = WeaponTweakData._init_data_mossberg_npc
function WeaponTweakData:_init_data_mossberg_npc()
  _init_data_mossberg_npc_original(self)
  self.mossberg_npc.sounds.prefix = "huntsman_npc"
  self.mossberg_npc.CLIP_AMMO_MAX = 2
end

local _init_data_mp5_npc_original = WeaponTweakData._init_data_mp5_npc
function WeaponTweakData:_init_data_mp5_npc()
  _init_data_mp5_npc_original(self)
  self.ump_npc.sounds.prefix = "schakal_npc"
  self.akmsu_smg_npc.sounds.prefix  = "akmsu_npc"
  self.akmsu_smg_npc.has_suppressor = "suppressed_a"
  self.asval_smg_npc.sounds.prefix  = "val_npc"
  self.asval_smg_npc.has_suppressor = "suppressed_a"
end

local _init_data_mac11_npc_original = WeaponTweakData._init_data_mac11_npc
function WeaponTweakData:_init_data_mac11_npc()
  _init_data_mac11_npc_original(self)
  self.mac11_npc.sounds.prefix = "mac10_npc"
end

local _init_data_mp9_npc_original = WeaponTweakData._init_data_mp9_npc
function WeaponTweakData:_init_data_mp9_npc()
  _init_data_mp9_npc_original(self)
  self.sr2_smg_npc.sounds.prefix = "sr2_npc"
end

local _init_data_m249_npc_original = WeaponTweakData._init_data_m249_npc
function WeaponTweakData:_init_data_m249_npc()
  _init_data_m249_npc_original(self)
  self.rpk_lmg_npc.sounds.prefix = "rpk_npc"
end