dofile(ModPath .. "botweapons.lua")

local spawn_unit_original = NetworkPeer.spawn_unit
function NetworkPeer:spawn_unit(spawn_point_id, is_drop_in, spawn_as)
  spawn_unit_original(self, spawn_point_id, is_drop_in, spawn_as)
  -- handle sync with dropped in peers
  if is_drop_in and BotWeapons._data.sync_settings and Network:is_server() then
    for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
      BotWeapons:sync_to_peer(self, data.unit)
    end
  end
end