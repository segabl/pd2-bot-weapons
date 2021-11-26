local init_original = CopActionAct.init
function CopActionAct:init(...)
	if not init_original(self, ...) then
		return
	end

	if self._action_desc.body_part and self._action_desc.body_part <= 2 then
		local equipped_unit = self._unit:inventory() and self._unit:inventory():equipped_unit()
		if alive(equipped_unit) and alive(equipped_unit:base()._second_gun) then
			self._second_gun = equipped_unit:base()._second_gun
			local second_gun_base = self._second_gun:base()
			self._was_gadget_on = second_gun_base.is_gadget_on and second_gun_base._gadget_on
			self._second_gun:set_visible(false)
			self._second_gun:base():on_disabled()
		end
	end

	return true
end

Hooks:PostHook(CopActionAct, "on_exit", "on_exit_bot_weapons", function (self)
	if alive(self._second_gun) then
		self._second_gun:set_visible(true)
		self._second_gun:base():on_enabled()
		if self._was_gadget_on then
			self._second_gun:base():set_gadget_on(self._was_gadget_on)
		end
	end
end)
