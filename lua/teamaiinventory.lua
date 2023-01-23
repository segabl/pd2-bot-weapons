if StreamHeist then
	return -- Don't need these fixes with Streamlined Heisting
end

Hooks:PostHook(TeamAIInventory, "save", "save_bot_weapons", function (self, data)
	-- change the sync index to m4 in case the weapon is akimbo to prevent client crashes
	local wbase = alive(self:equipped_unit()) and self:equipped_unit():base()
	if data.inventory and wbase and wbase.AKIMBO then
		data.inventory.equipped_weapon_index = self._get_weapon_sync_index("wpn_fps_ass_m4_npc")
		data.inventory.blueprint_string = nil
		data.inventory.cosmetics_string = "nil-1-0"
		data.inventory.gadget_on = nil
		data.inventory.gadget_color = nil
	end
end)

local _send_equipped_weapon_original = TeamAIInventory._send_equipped_weapon
function TeamAIInventory:_send_equipped_weapon(...)
	-- change the sync index to m4 in case the weapon is akimbo to prevent client crashes
	local wbase = alive(self:equipped_unit()) and self:equipped_unit():base()
	if wbase and wbase.AKIMBO then
		self._unit:network():send("set_equipped_weapon", self._get_weapon_sync_index("wpn_fps_ass_m4_npc"), "", "nil-1-0")
		return
	end
	_send_equipped_weapon_original(self, ...)
end
