function TeamAIMovement:play_redirect(redirect_name, at_time)
  -- Fix buggy auto animations when shooting with guns that use pistol animations
  local new_redirect = redirect_name
  local weapon = self._unit:inventory():equipped_unit()
  if weapon and new_redirect == "recoil_auto" then
    tweak = weapon:base():weapon_tweak_data()
    if tweak.hold == "pistol" or tweak.hold == "akimbo_pistol" then
      new_redirect = "recoil_single"
    end
  end

  local result = self._unit:play_redirect(Idstring(new_redirect), at_time)
  return result ~= Idstring("") and result
end