local fire_original = NPCAkimboWeaponBase.fire
function NPCAkimboWeaponBase:fire(...)
	if not self._is_team_ai then
		return fire_original(self, ...)
	end
	local result = NPCAkimboWeaponBase.super.fire(self, ...)
	if alive(self._second_gun) then
		table.insert(self._fire_callbacks, {
			t = self:get_fire_time(),
			callback = callback(self, self, "_fire_second", {...})
		})
	end
	return result
end

function NPCAkimboWeaponBase:_fire_second(params)
	if alive(self._second_gun) and self._setup and alive(self._setup.user_unit) then
		return self._second_gun:base().super.fire(self._second_gun:base(), unpack(params))
	end
end
