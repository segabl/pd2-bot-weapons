local fire_original = NPCAkimboWeaponBase.fire
function NPCAkimboWeaponBase:fire(...)
  if not self._is_team_ai then
    return fire_original(self, ...)
  end
  local result
  if self._fire_second_gun_next then
    if alive(self._second_gun) then
      result = self._second_gun:base().super.fire(self._second_gun:base(), ...)
      if result then
        self._second_gun:base():tweak_data_anim_play("fire")
      end
    end
    self._fire_second_gun_next = false
  else
    result = NPCAkimboWeaponBase.super.fire(self, ...)
    if result then
      NPCAkimboWeaponBase.super.tweak_data_anim_play(self, "fire")
    end
    self._fire_second_gun_next = true
  end
  return result
end