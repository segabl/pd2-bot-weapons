function NewNPCRaycastWeaponBase:get_gadget_by_type(gadget_type, gadgets)
	if not self._assembly_complete or not self._enabled then
		return
	end

	local gadget
	for i, id in ipairs(gadgets or self._gadgets or {}) do
		gadget = self._parts[id]
		if gadget and gadget.unit:base().GADGET_TYPE == gadget_type then
			return i, id
		end
	end
end
