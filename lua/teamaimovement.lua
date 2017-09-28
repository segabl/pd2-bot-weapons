dofile(ModPath .. "botweapons.lua")

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
  local weapon = self._unit:inventory():equipped_unit()
  if weapon and redirect_name == "recoil_auto" then
    tweak = weapon:base():weapon_tweak_data()
    if tweak.hold == "akimbo_pistol" then
      redirect_name = "recoil_single"
    end
  end
  return play_redirect_original(self, redirect_name, ...)
end

local check_visual_equipment_original = TeamAIMovement.check_visual_equipment
function TeamAIMovement:check_visual_equipment(...)
  if Network:is_server() then
    -- set armor & deployables for team ai
    local loadout =  managers.criminals:get_loadout_for(self._ext_base._tweak_table)
    BotWeapons:set_armor(self._unit, loadout.armor, loadout.armor_skin)
    BotWeapons:set_equipment(self._unit, loadout.deployable)
    BotWeapons:set_special_character_material(self._unit)
  end
  return check_visual_equipment_original(self, ...)
end

local set_carrying_bag_original = TeamAIMovement.set_carrying_bag
function TeamAIMovement:set_carrying_bag(unit, ...)
  local enabled = BotWeapons._data.toggle_player_carry or BotWeapons._data.toggle_player_carry == nil
  self:set_visual_carry(enabled and unit and unit:carry_data():carry_id())
  local bag_unit = unit or self._carry_unit
  if bag_unit then
    bag_unit:set_visible(not (enabled and unit))
  end
  local name_label = managers.hud:_get_name_label(self._unit:unit_data().name_label_id)
  if name_label then
    bag_panel = name_label.panel and name_label.panel:child("bag")
    if bag_panel then
      bag_panel:set_visible(enabled and unit)
    end
  end
  set_carrying_bag_original(self, unit, ...)
end

-- link to HuskPlayerMovement for bag carrying
TeamAIMovement.set_visual_carry = HuskPlayerMovement.set_visual_carry
TeamAIMovement._destroy_current_carry_unit = HuskPlayerMovement._destroy_current_carry_unit
TeamAIMovement._create_carry_unit = HuskPlayerMovement._create_carry_unit