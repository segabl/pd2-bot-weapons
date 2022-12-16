-- Add an armor skin extension and hook its updating to base update
Hooks:PostHook(TeamAIBase, "init", "init_bot_weapons", function (self)
	if self._unit:armor_skin() then
		return
	end

	getmetatable(self._unit).armor_skin = function (unit)
		if not unit:base()._armor_skin_ext then
			unit:base()._armor_skin_ext = ArmorSkinExt:new(unit)
			unit:base()._armor_skin_ext:set_character(unit:base()._tweak_table)
			unit:set_extension_update_enabled(Idstring("base"), true)
		end
		return unit:base()._armor_skin_ext
	end
end)

function TeamAIBase:update(...)
	if self._armor_skin_ext and self._armor_skin_ext._request_update then
		self._armor_skin_ext:update(...)
	end
end
