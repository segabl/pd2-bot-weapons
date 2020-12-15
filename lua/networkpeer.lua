Hooks:PostHook(NetworkPeer, "spawn_unit", "spawn_unit_bot_weapons", function (self, spawn_point_id, is_drop_in)
	if is_drop_in and BotWeapons:should_sync_settings() then
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			LuaNetworking:SendToPeer(self:id(), "bot_weapons_sync", json.encode(BotWeapons:get_sync_data(data.unit)))
		end
	end
end)
