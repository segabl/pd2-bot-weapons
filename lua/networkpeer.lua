dofile(ModPath .. "lua/botweapons.lua")

local spawn_unit_original = NetworkPeer.spawn_unit
function NetworkPeer:spawn_unit(spawn_point_id, is_drop_in, spawn_as)
  spawn_unit_original(self, spawn_point_id, is_drop_in, spawn_as)
  -- handle sync with dropped in peers
  if LuaNetworking:IsHost() and is_drop_in and managers.groupai then
    for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
      if alive(data.unit) then
        local name = data.unit:base()._tweak_table
        local loadout = managers.criminals:get_loadout_for(name)
        local current_level = managers.job and managers.job:current_level_id()
        if current_level ~= "glace" and loadout.armor then
          self:send_queued_sync("sync_run_sequence_char", data.unit, tweak_data.blackmarket.armors[loadout.armor].sequence)
        end
        LuaNetworking:SendToPeer(self:id(), "bot_weapons_equipment", name .. "," .. tostring(loadout.deployable))
      end
    end 
  end
end