local init_original = TeamAIInventory.init
function TeamAIInventory:init(...)
  init_original(self, ...)
  -- Add missing align place for left hand to prevent crash with akimbo weapons
  self._align_places.left_hand = self._align_places.left_hand or {
    on_body = false,
    obj3d_name = Idstring("a_weapon_left_front")
  }
end

local save_original = TeamAIInventory.save
function TeamAIInventory:save(data, ...)
  save_original(self, data, ...)
  -- change the sync index to m4 in case the weapon is akimbo to prevent client crashes
  local wbase = alive(self:equipped_unit()) and self:equipped_unit():base()
  if wbase.AKIMBO then
    data.equipped_weapon_index = self._get_weapon_sync_index("wpn_fps_ass_m4_npc")
    data.blueprint_string = nil
    data.cosmetics_string = "nil-1-0"
    data.gadget_on = nil
    data.gadget_color = nil
  end
end

local _send_equipped_weapon_original = TeamAIInventory._send_equipped_weapon
function TeamAIInventory:_send_equipped_weapon(...)
  -- change the sync index to m4 in case the weapon is akimbo to prevent client crashes
  local wbase = alive(self:equipped_unit()) and self:equipped_unit():base()
  if wbase.AKIMBO then
    self._unit:network():send("set_equipped_weapon", self._get_weapon_sync_index("wpn_fps_ass_m4_npc"), "", "nil-1-0")
    return
  end
  _send_equipped_weapon_original(self, ...)
end