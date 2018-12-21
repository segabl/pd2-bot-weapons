local init_original = TeamAIInventory.init
function TeamAIInventory:init(...)
  init_original(self, ...)
  -- Add missing align place for left hand to prevent crash with akimbo weapons
  self._align_places.left_hand = self._align_places.left_hand or {
    on_body = false,
    obj3d_name = Idstring("a_weapon_left_front")
  }
end