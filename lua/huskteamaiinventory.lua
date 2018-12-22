local init_original = HuskTeamAIInventory.init
function HuskTeamAIInventory:init(...)
  init_original(self, ...)
  -- Add missing align place for left hand to prevent crash with akimbo weapons
  self._align_places.left_hand = self._align_places.left_hand or {
    on_body = false,
    obj3d_name = Idstring("a_weapon_left_front")
  }
end

-- Make this function usable for Team AI
function HuskTeamAIInventory:synch_weapon_gadget_state(state)
  if self:equipped_unit():base().set_gadget_on then
    self:equipped_unit():base():set_gadget_on(state, true)
  end
end