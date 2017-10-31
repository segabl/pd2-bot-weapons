dofile(ModPath .. "botweapons.lua")

function NewRaycastWeaponBase:set_gadget_on_by_type(gadget_type, gadgets)
  if not self._assembly_complete or not self._enabled then
    return
  end
  gadgets = gadgets or managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", self._factory_id, self._blueprint)
  if gadgets then
    local xd, yd = nil
    local part_factory = tweak_data.weapon.factory.parts
    table.sort(gadgets, function (x, y)
      xd = self._parts[x]
      yd = self._parts[y]
      if not xd then
        return false
      end
      if not yd then
        return true
      end
      return yd.unit:base().GADGET_TYPE < xd.unit:base().GADGET_TYPE
    end)
    local gadget = nil
    for i, id in ipairs(gadgets) do
      gadget = self._parts[id]
      if gadget and gadget.unit:base().GADGET_TYPE == gadget_type then
        self._gadget_on = i
        gadget.unit:base():set_on()
        return gadget.unit, id
      end
    end
  end
end

local clbk_assembly_complete_original = NewRaycastWeaponBase.clbk_assembly_complete
function NewRaycastWeaponBase:clbk_assembly_complete(...)
  local result = clbk_assembly_complete_original(self, ...)
  if Network:is_server() and (self._is_team_ai or alive(self.parent_weapon) and self.parent_weapon:base()._is_team_ai) then
    -- Enable flashlight / laser
    BotWeapons:set_gadget_colors(self._setup and self._setup.user_unit, self)
    BotWeapons:check_set_gadget_state(self._setup and self._setup.user_unit, self, 2)
  end
  return result
end