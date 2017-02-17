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
    "units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval",
    "units/pd2_dlc_chico/weapons/wpn_npc_sg417/wpn_npc_sg417"
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

local _post_init_original = TeamAIMovement._post_init
function TeamAIMovement:_post_init()
  if LuaNetworking:IsHost() then
    -- choose weapon
    local weapon_index = BotWeapons._data[self._ext_base._tweak_table .. "_weapon"] or 1
    if BotWeapons._data.toggle_override_weapons then
      weapon_index = BotWeapons._data.override_weapons or (#BotWeapons.weapons + 1)
    end
    if weapon_index > #BotWeapons.weapons then
      weapon_index = math.random(#BotWeapons.weapons)
    end
    local weapon = BotWeapons.weapons[weapon_index]
    local type_replacement = online_replacements[weapon.type] and online_replacements[weapon.type][math.random(#online_replacements[weapon.type])]
    local replacement = weapon.online_name or type_replacement
    
    if BotWeapons:custom_weapons_allowed() then
      self._ext_inventory:remove_all_selections()
      local factory_weapon = tweak_data.weapon.factory[weapon.factory_name]
      local blueprint_string = managers.weapon_factory:blueprint_to_string(weapon.factory_name, weapon.blueprint or factory_weapon.default_blueprint)
      self._ext_inventory:add_unit_by_factory_name(weapon.factory_name, true, true, blueprint_string, "")
      self._ext_inventory:equipped_unit():base()._alert_events = not self._ext_inventory:equipped_unit():base():got_silencer() and {} or nil
    elseif replacement then
      self._ext_inventory:remove_all_selections()
      self._ext_inventory:add_unit_by_name(Idstring(replacement), true)
    end
    
    if managers.groupai:state():whisper_mode() then
      self._ext_inventory:set_weapon_enabled(false)
    end
  end
  return _post_init_original(self)
end

function TeamAIMovement:play_redirect(redirect_name, at_time)
  -- Fix buggy autofire animations when shooting with akimbo guns
  local weapon = self._unit:inventory():equipped_unit()
  if weapon and redirect_name == "recoil_auto" then
    tweak = weapon:base():weapon_tweak_data()
    if tweak.hold == "akimbo_pistol" then
      redirect_name = "recoil_single"
    end
  end
  return TeamAIMovement.super.play_redirect(self, redirect_name, at_time)
end

function TeamAIMovement:check_visual_equipment()
  if not LuaNetworking:IsHost() then
    return
  end
  -- set armor & deployables for team ai
  local name = self._unit:base()._tweak_table
  -- choose armor models
  local armor_index = BotWeapons._data[name .. "_armor"] or 1
  if BotWeapons._data.toggle_override_armor then
    armor_index = BotWeapons._data.override_armor or (#BotWeapons.armor + 1)
  end
  if armor_index > #BotWeapons.armor then
    armor_index = math.random(#BotWeapons.armor)
  end
  -- choose equipment models
  local equipment_index = BotWeapons._data[name .. "_equipment"] or 1
  if BotWeapons._data.toggle_override_equipment then
    equipment_index = BotWeapons._data.override_equipment or (#BotWeapons.equipment + 1)
  end
  if equipment_index > #BotWeapons.equipment then
    equipment_index = math.random(#BotWeapons.equipment)
  end
  self._armor_index = armor_index
  self._equipment_index = equipment_index
  BotWeapons:set_armor(self._unit, armor_index)
  BotWeapons:set_equipment(self._unit, equipment_index)
  BotWeapons:sync_armor_and_equipment(self._unit, armor_index, equipment_index)
end

local set_carrying_bag_original = TeamAIMovement.set_carrying_bag
function TeamAIMovement:set_carrying_bag(unit, ...)
  local enabled = BotWeapons._data.toggle_player_carry or BotWeapons._data.toggle_player_carry == nil
  self:set_visual_carry(enabled and unit and unit:carry_data():carry_id())
  local bag_unit = unit or self._carry_unit
  if bag_unit then
    bag_unit:set_visible(not (enabled and unit))
  end
  local name_label = managers.hud:_get_name_label(self._unit:unit_data().name_label_id)
  if name_label then
    name_label.panel:child("bag"):set_visible(enabled and unit)
  end
  set_carrying_bag_original(self, unit, ...)
end

-- link to HuskPlayerMovement for bag carrying
function TeamAIMovement:set_visual_carry(...)
  HuskPlayerMovement.set_visual_carry(self, ...)
end

function TeamAIMovement:_destroy_current_carry_unit(...)
  HuskPlayerMovement._destroy_current_carry_unit(self, ...)
end

function TeamAIMovement:_create_carry_unit(...)
  HuskPlayerMovement._create_carry_unit(self, ...)
end