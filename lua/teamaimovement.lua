-- Fix for some broken reload anim time check code
setmetatable(HuskPlayerMovement.reload_times, {
	__index = function (t, k)
		if type(k) == "table" then
			for _, v in pairs(k) do
				local r = rawget(t, v)
				if r then
					return r
				end
			end
		end
		BLT:Log(LogLevel.WARN, "[BWE] No reload time definition for " .. tostring(k) .. "!")
		rawset(t, k, 2)
		return 2
	end
})

if BotWeapons.settings.weapon_balance and TeamAIActionShoot then
	CopMovement._action_variants.team_ai.shoot = TeamAIActionShoot
end

-- link to HuskPlayerMovement for bag carrying
TeamAIMovement.set_visual_carry = HuskPlayerMovement.set_visual_carry
TeamAIMovement._destroy_current_carry_unit = HuskPlayerMovement._destroy_current_carry_unit
TeamAIMovement._create_carry_unit = HuskPlayerMovement._create_carry_unit

function TeamAIMovement:add_weapons()
	if Network:is_server() then
		local loadout = managers.criminals:get_loadout_for(self._ext_base._tweak_table)
		local crafted = managers.blackmarket:get_crafted_category_slot(loadout.primary_category or "primaries", loadout.primary_slot)
		if crafted then
			self._unit:inventory():add_unit_by_factory_blueprint(loadout.primary, false, false, crafted.blueprint, crafted.cosmetics)
		elseif loadout.primary and tweak_data.weapon.factory[loadout.primary] then
			self._unit:inventory():add_unit_by_factory_blueprint(loadout.primary, false, false, loadout.primary_blueprint or tweak_data.weapon.factory[loadout.primary].default_blueprint, loadout.primary_cosmetics)
		else
			local weapon = self._ext_base:default_weapon_name("primary")
			local _ = weapon and self._unit:inventory():add_unit_by_factory_name(weapon, false, false, nil, "")
		end
	else
		TeamAIMovement.super.add_weapons(self)
	end
end

local play_redirect_original = TeamAIMovement.play_redirect
function TeamAIMovement:play_redirect(redirect_name, ...)
	-- Fix buggy autofire animations when shooting with akimbo guns
	local weapon = self._ext_inventory:equipped_unit()
	if weapon and redirect_name == "recoil_auto" and weapon:base():weapon_tweak_data().hold == "akimbo_pistol" then
			return
	end
	return play_redirect_original(self, redirect_name, ...)
end

if Network:is_server() then
	-- send cool state and activate gadgets on going loud
	Hooks:PostHook(TeamAIMovement, "_switch_to_not_cool_clbk_func", "_switch_to_not_cool_clbk_func_bot_weapons", function (self)
		if not self._cool then
			self._ext_network:send("set_cool_state", self._cool)
			local weapon = self._ext_inventory:equipped_unit()
			BotWeapons:check_set_gadget_state(self._unit, weapon and weapon:base())
		end
	end)
else
	-- update cool state if stance is swapped to hos or cbt, workaround for cool state not being sent by vanilla host
	Hooks:PreHook(TeamAIMovement, "sync_stance", "sync_stance_bot_weapons", function (self, i_stance)
		if self._stance and self._stance.code == 1 and i_stance > 1 then
			self:set_cool(false)
		end
	end)
end

Hooks:PreHook(TeamAIMovement, "set_carrying_bag", "set_carrying_bag_bot_weapons", function (self, unit)
	local enabled = BotWeapons.settings.player_carry
	self:set_visual_carry(enabled and alive(unit) and unit:carry_data():carry_id())
	local bag_unit = unit or self._carry_unit
	if bag_unit then
		bag_unit:set_visible(not (enabled and unit))
	end
	local name_label = managers.hud:_get_name_label(self._unit:unit_data().name_label_id)
	if name_label then
		local bag_panel = name_label.panel and name_label.panel:child("bag")
		if bag_panel then
			bag_panel:set_visible(enabled and unit)
		end
	end
end)

Hooks:PostHook(TeamAIMovement, "clbk_inventory", "clbk_inventory_bot_weapons", function (self)
	local weapon = self._ext_inventory:equipped_unit()
	if not alive(weapon) then
		return
	end

	local weap_tweak = weapon:base():weapon_tweak_data()

	-- Fix broken hold types
	if type(weap_tweak.hold) == "table" then
		local num = #weap_tweak.hold + 1
		for i, hold_type in ipairs(weap_tweak.hold) do
			self._machine:set_global(hold_type, self:get_hold_type_weight(hold_type) or num - i)
			table.insert(self._weapon_hold, hold_type)
		end
	end

	if not weap_tweak.reload_time then
		return
	end

	if self._looped_reload_time then
		self._looped_reload_time = weap_tweak.reload_time
		self._reload_speed_multiplier = (0.45 * (weap_tweak.looped_reload_single and 1 or weap_tweak.CLIP_AMMO_MAX)) / self._looped_reload_time
	else
		self._reload_speed_multiplier = HuskPlayerMovement:get_reload_animation_time(weap_tweak.reload or weap_tweak.hold) / weap_tweak.reload_time
	end
end)
