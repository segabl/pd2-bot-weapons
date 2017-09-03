local is_looped_reload_original = HuskPlayerMovement.is_looped_reload
function HuskPlayerMovement:is_looped_reload(crew_tweak, ...)
  -- check anim_usage before checking usage
  return crew_tweak and crew_tweak.anim_usage == HuskPlayerMovement.str_is_shotgun_pump or is_looped_reload_original(self, crew_tweak, ...)
end