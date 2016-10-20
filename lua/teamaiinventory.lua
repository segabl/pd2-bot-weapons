dofile(ModPath .. "lua/botweapons.lua")

local online_replacements = {
  pistol = {
    "units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92",
    "units/payday2/weapons/wpn_npc_c45/wpn_npc_c45",
    "units/payday2/weapons/wpn_npc_raging_bull/wpn_npc_raging_bull"
  },
  rifle = {
    "units/payday2/weapons/wpn_npc_m4/wpn_npc_m4",
    "units/payday2/weapons/wpn_npc_ak47/wpn_npc_ak47",
    "units/payday2/weapons/wpn_npc_g36/wpn_npc_g36",
    "units/payday2/weapons/wpn_npc_scar_murkywater/wpn_npc_scar_murkywater",
    "units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval"
  },
  smg = {
    "units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5",
    "units/payday2/weapons/wpn_npc_mp5_tactical/wpn_npc_mp5_tactical",
    "units/payday2/weapons/wpn_npc_smg_mp9/wpn_npc_smg_mp9",
    "units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11",
    "units/payday2/weapons/wpn_npc_ump/wpn_npc_ump",
    "units/pd2_dlc_mad/weapons/wpn_npc_akmsu/wpn_npc_akmsu",
    "units/pd2_dlc_mad/weapons/wpn_npc_sr2/wpn_npc_sr2"
  },
  shotgun = {
    "units/payday2/weapons/wpn_npc_r870/wpn_npc_r870",
    "units/payday2/weapons/wpn_npc_sawnoff_shotgun/wpn_npc_sawnoff_shotgun",
    "units/payday2/weapons/wpn_npc_benelli/wpn_npc_benelli"
  },
  lmg = {
    "units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249",
    "units/pd2_dlc_mad/weapons/wpn_npc_rpk/wpn_npc_rpk"
  }
}

local add_unit_by_name_original = TeamAIInventory.add_unit_by_name
function TeamAIInventory:add_unit_by_name(weapon, equip) 
  if BotWeapons:custom_weapons_allowed() then
    local factory_name = weapon.factory_name
    local factory_weapon = tweak_data.weapon.factory[factory_name]
    if factory_weapon then
      HuskPlayerInventory.add_unit_by_factory_blueprint(self, factory_name, equip, true, weapon.blueprint or factory_weapon.default_blueprint)
      return
    else
      log("[BotWeapons] Could not find weapon " .. factory_name)
    end
  end
  local type_replacement = online_replacements[weapon.type] and online_replacements[weapon.type][math.random(#online_replacements[weapon.type])] or "units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"
  local replacement = weapon.online_name or type_replacement
  add_unit_by_name_original(self, Idstring(replacement), equip)
end