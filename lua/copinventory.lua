Hooks:PostHook(CopInventory, "init", "init_bot_weapons", function (self)

  -- Add missing align place for left hand to prevent crash with akimbo weapons
  self._align_places.left_hand = self._align_places.left_hand or {
    on_body = true,
    obj3d_name = Idstring("a_weapon_left_front")
  }

end)