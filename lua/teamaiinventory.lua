dofile(ModPath .. "lua/botweapons.lua")

local save_original = TeamAIInventory.save
function TeamAIInventory:save(data)
  save_original(self, data)
  if BotWeapons._replace_guns then
    local replacement = BotWeapons:replacement_by_index(data.equipped_weapon_index)
    log("[BotWeapons] Replaced weapon (" .. self._unit:base()._tweak_table .. " " .. data.equipped_weapon_index .. "->" .. replacement .. ")")
    data.equipped_weapon_index = replacement
  end
end

function PlayerInventory:remove_all_selections()
  for i_sel, selection_data in pairs(self._available_selections) do
    if selection_data.unit and selection_data.unit:base() then
      selection_data.unit:base():remove_destroy_listener(self._listener_id)
      selection_data.unit:base():set_slot(selection_data.unit, 0)
    end
  end
  self._equipped_selection = nil
  self._available_selections = {}
end

function TeamAIInventory:add_unit_by_factory_name(...)
  self._has_non_standard_gun = true
  HuskPlayerInventory.add_unit_by_factory_name(self, ...)
end

function TeamAIInventory:add_unit_by_factory_blueprint(...)
  self._has_non_standard_gun = true
  HuskPlayerInventory.add_unit_by_factory_blueprint(self, ...)
end

function TeamAIInventory:set_mask(id, blueprint)
  if id and tweak_data.blackmarket.masks[id] and tweak_data.blackmarket.masks[id].characters then
    id = tweak_data.blackmarket.masks[id].characters[managers.criminals.convert_old_to_new_character_workname(self._unit:base()._tweak_table)] or id
  end
  self._mask_id = id or managers.criminals:character_data_by_unit(self._unit).mask_id
  self._mask_unit_name = tweak_data.blackmarket.masks[self._mask_id].unit
  self._mask_blueprint = blueprint
  local vis = self._mask_visibility
  self:set_mask_visibility(false)
  self._mask_visibility = vis
  if self._mask_unit_name then
    managers.dyn_resource:load(Idstring("unit"), Idstring(self._mask_unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_mask_unit_loaded"))
  end
end

function TeamAIInventory:preload_mask()
  local id, blueprint = nil, nil
  local masks_data = BotWeapons:get_masks_data()
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
      id = masks_data.masks[math.random(#masks_data.masks)]
      if math.random() < (BotWeapons._data.slider_mask_customized_chance or 0.5) then
        blueprint = {
          color = {id = masks_data.colors[math.random(#masks_data.colors)]},
          pattern = {id = masks_data.patterns[math.random(#masks_data.patterns)]},
          material = {id = masks_data.materials[math.random(#masks_data.materials)]}
        }
      end
    end
  end
  self:set_mask(id, blueprint)
  BotWeapons:sync_mask(self._unit, self._mask_id, self._mask_blueprint)
end

function TeamAIInventory:set_mask_visibility(state)
  self._mask_visibility = state
  if alive(self._mask_unit) and not state then
    for _, linked_unit in ipairs(self._mask_unit:children()) do
      linked_unit:unlink()
      World:delete_unit(linked_unit)
    end
    self._mask_unit:unlink()
    World:delete_unit(self._mask_unit)
    local name = CriminalsManager.convert_old_to_new_character_workname(self._unit:base()._tweak_table)
    local mask_off_sequence = tweak_data.blackmarket.characters[name] and tweak_data.blackmarket.characters[name].mask_off_sequence
    if mask_off_sequence then
      self._unit:damage():run_sequence_simple(mask_off_sequence)
    end
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
    local mask_on_sequence = managers.blackmarket:character_mask_on_sequence_by_character_name(self._unit:base()._tweak_table)
    if mask_on_sequence then
      self._unit:damage():run_sequence_simple(mask_on_sequence)
    end
  end
end