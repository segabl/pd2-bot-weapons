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
  if type(weapon) ~= "table" then
    add_unit_by_name_original(self, weapon, equip)
    return
  end
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
  local type_replacement = online_replacements[weapon.type] and online_replacements[weapon.type][math.random(#online_replacements[weapon.type])]
  local replacement = weapon.online_name or type_replacement or "units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"
  add_unit_by_name_original(self, Idstring(replacement), equip)
end

TeamAIInventory.masks = TeamAIInventory.masks or {}
for k, v in pairs(tweak_data.blackmarket.masks) do
  if not v.inaccessible then
    table.insert(TeamAIInventory.masks, k)
  end
end

TeamAIInventory.colors = TeamAIInventory.colors or {}
for k, _ in pairs(tweak_data.blackmarket.colors) do
  table.insert(TeamAIInventory.colors, k)
end

TeamAIInventory.patterns = TeamAIInventory.patterns or {}
for k, _ in pairs(tweak_data.blackmarket.textures) do
  table.insert(TeamAIInventory.patterns, k)
end

TeamAIInventory.materials = TeamAIInventory.materials or {}
for k, _ in pairs(tweak_data.blackmarket.materials) do
  table.insert(TeamAIInventory.materials, k)
end

function TeamAIInventory:set_mask(id, blueprint)
  local vis = self._mask_visibility
  self:set_mask_visibility(false)
  self._mask_visibility = vis
  -- set default mask first
  self._mask_id = managers.criminals:character_data_by_unit(self._unit).mask_id
  local mask_unit_name = managers.criminals:character_data_by_unit(self._unit).mask_obj
  self._mask_unit_name = mask_unit_name[Global.level_data.level_id] or mask_unit_name.default or mask_unit_name
  self._mask_blueprint = nil
  -- then try to set mask given by params
  if id and tweak_data.blackmarket.masks[id] then
    if tweak_data.blackmarket.masks[id].characters then
      id = tweak_data.blackmarket.masks[id].characters[managers.criminals.convert_old_to_new_character_workname(self._unit:base()._tweak_table)]
    end
    self._mask_id = id
    self._mask_unit_name = tweak_data.blackmarket.masks[id].unit
    self._mask_blueprint = blueprint
  end
  managers.dyn_resource:load(Idstring("unit"), Idstring(self._mask_unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_unit_loaded"))
end

function TeamAIInventory:preload_mask()
  local id, blueprint
  if LuaNetworking:IsHost() then
    local name = self._unit:base()._tweak_table
    
    local index = BotWeapons._data[name .. "_mask"] or 1
    if BotWeapons._data.toggle_override_masks then
      index = BotWeapons._data.override_masks or (#BotWeapons.masks + 1)
    end
    
    if index == 2 then
      local player_mask = managers.blackmarket:equipped_mask()
      if player_mask then
        id = player_mask.mask_id
        blueprint = player_mask.blueprint
      end
    elseif index > #BotWeapons.masks then
      id = TeamAIInventory.masks[math.random(#TeamAIInventory.masks)]
      if math.random() < BotWeapons._data.slider_mask_customized_chance then
        blueprint = {
          color = {id = TeamAIInventory.colors[math.random(#TeamAIInventory.colors)]},
          pattern = {id = TeamAIInventory.patterns[math.random(#TeamAIInventory.patterns)]},
          material = {id = TeamAIInventory.materials[math.random(#TeamAIInventory.materials)]}
        }
      end
    end
  end
  self:set_mask(id, blueprint)
  BotWeapons:sync_mask(self._unit, self._mask_id, self._mask_blueprint)
end

function TeamAIInventory:set_mask_visibility(state)
  self._mask_visibility = state
  local character_name = CriminalsManager.convert_old_to_new_character_workname(self._unit:base()._tweak_table) 
  if not character_name then
    return
  end
  if alive(self._mask_unit) and not state then
    for _, linked_unit in ipairs(self._mask_unit:children()) do
      linked_unit:unlink()
      World:delete_unit(linked_unit)
    end
    self._mask_unit:unlink()
    local name = self._mask_unit:name()
    World:delete_unit(self._mask_unit)
    local mask_off_sequence = (tweak_data.blackmarket.characters[character_name] or tweak_data.blackmarket.characters.locked[character_name]).mask_off_sequence
    if mask_off_sequence then
      self._unit:damage():run_sequence_simple(mask_off_sequence)
    end
    return
  end
  if not state then
    return
  end
  if not managers.dyn_resource:is_resource_ready(Idstring("unit"), self._mask_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
    return
  end
  local mask_align = self._unit:get_object(Idstring("Head"))
  self._mask_unit = World:spawn_unit(Idstring(self._mask_unit_name), mask_align:position(), mask_align:rotation())
  self._mask_unit:base():apply_blueprint(self._mask_blueprint)
  self._unit:link(mask_align:name(), self._mask_unit, self._mask_unit:orientation_object():name())
  if not self._mask_id or not tweak_data.blackmarket.masks[self._mask_id].type then
    local backside = World:spawn_unit(Idstring("units/payday2/masks/msk_backside/msk_backside"), mask_align:position(), mask_align:rotation())
    self._mask_unit:link(self._mask_unit:orientation_object():name(), backside, backside:orientation_object():name())
  end
  if not self._mask_id or not tweak_data.blackmarket.masks[self._mask_id].skip_mask_on_sequence then
    local mask_on_sequence = (tweak_data.blackmarket.characters[character_name] or tweak_data.blackmarket.characters.locked[character_name]).mask_on_sequence
    if mask_on_sequence then
      self._unit:damage():run_sequence_simple(mask_on_sequence)
    end
  end
end