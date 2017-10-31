-- Make this function usable for Team AI
function HuskTeamAIInventory:synch_weapon_gadget_state(state)
  if self:equipped_unit():base().set_gadget_on then
    self:equipped_unit():base():set_gadget_on(state, true)
  end
end