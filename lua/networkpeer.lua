CloneClass(NetworkPeer)

function NetworkPeer:spawn_unit(spawn_point_id, is_drop_in, spawn_as)
  self.orig.spawn_unit(self, spawn_point_id, is_drop_in, spawn_as)
  -- handle sync with dropped in peers
  if LuaNetworking:IsHost() and is_drop_in and managers.criminals:nr_AI_criminals() > 0 then
    for _, character in pairs(managers.criminals:characters()) do
      if character.taken and alive(character.unit) and character.data.ai then
        local movement = character.unit:movement()
        if movement then
          self:send_queued_sync("sync_run_sequence_char", character.unit, "var_model_0" .. movement._armor_index)
          LuaNetworking:SendToPeer(self:id(), "bot_weapons_equipment", character.name .. "/" .. movement._equipment_index)
        end
      end
    end 
  end
end