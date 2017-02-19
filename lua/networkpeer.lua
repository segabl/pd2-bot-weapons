dofile(ModPath .. "lua/botweapons.lua")

local spawn_unit_original = NetworkPeer.spawn_unit
function NetworkPeer:spawn_unit(spawn_point_id, is_drop_in, spawn_as)
  spawn_unit_original(self, spawn_point_id, is_drop_in, spawn_as)
  -- handle sync with dropped in peers
  if LuaNetworking:IsHost() and is_drop_in and managers.groupai then
    for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
      if alive(data.unit) then
        local movement = data.unit:movement()
        local inventory = data.unit:inventory()
        local name = data.unit:base()._tweak_table
        self:send_queued_sync("sync_run_sequence_char", data.unit, "var_model_0" .. (movement._armor_index or 1))
        LuaNetworking:SendToPeer(self:id(), "bot_weapons_equipment", name .. "," .. (movement._equipment_index or 1))
        LuaNetworking:SendToPeer(self:id(), "bot_weapons_mask", name .. "," .. BotWeapons:build_mask_string(inventory._mask_id, inventory._mask_blueprint))
      end
    end 
  end
end

local send_original = NetworkPeer.send
function NetworkPeer:send(func_name, ...)
  if not self._has_bot_weapons and func_name == "set_equipped_weapon" then
    local unit, index, blueprint_string, cosmetics_string = unpack{...}
    if alive(unit) and unit:inventory()._has_non_standard_gun then
      local replacement = BotWeapons:replacement_by_index(index)
      log("[BotWeapons] Replaced weapon (" .. unit:base()._tweak_table .. " " .. index .. "->" .. replacement .. ")")
      return send_original(self, func_name, unit, replacement, blueprint_string, cosmetics_string)
    end
  end
  return send_original(self, func_name, ...)
end