dofile(ModPath .. "botweapons.lua")

function NewRaycastWeaponBase:set_gadget_on_by_type(gadget_type, gadgets)
  if not self._assembly_complete or not self._enabled then
    return
  end
  gadgets = gadgets or managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", self._factory_id, self._blueprint)
  if gadgets then
    local gadget = nil
    for i, id in ipairs(gadgets) do
      gadget = self._parts[id]
      if gadget and gadget.unit:base().GADGET_TYPE == gadget_type then
        gadget.unit:base():set_on()
        return
      end
    end
  end
end

local clbk_assembly_complete_original = NewRaycastWeaponBase.clbk_assembly_complete
function NewRaycastWeaponBase:clbk_assembly_complete(...)
  local result = clbk_assembly_complete_original(self, ...)
  local is_team_ai = self._is_team_ai or alive(self.parent_weapon) and self.parent_weapon:base()._is_team_ai
  if is_team_ai and BotWeapons:should_use_flashlights() then
    -- enable flashlights
    self:set_gadget_on_by_type("flashlight")
  end
  return result
end