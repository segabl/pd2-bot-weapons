function NewNPCRaycastWeaponBase:get_gadget_by_type(gadget_type, gadgets)
  if not self._assembly_complete or not self._enabled then
    return
  end
  gadgets = gadgets or managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", self._factory_id, self._blueprint)
  if gadgets then
    local xd, yd = nil
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
        return i, id
      end
    end
  end
end

Hooks:PostHook(NewNPCRaycastWeaponBase, "clbk_assembly_complete", function (self)

  -- check if gadget activation is needed
  if Network:is_server() and self._is_team_ai then
    BotWeapons:check_set_gadget_state(self._setup and self._setup.user_unit, self)
  end

end)