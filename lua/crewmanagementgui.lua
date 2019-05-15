-- lots of stuff to copy from the original file since OVK made it local
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size
local make_fine_text = function(text)
  local x, y, w, h = text:text_rect()
  text:set_size(w, h)
  text:set_position(math.round(text:x()), math.round(text:y()))
end
local fit_texture = function(bitmap, target_w, target_h)
  local texture_width = bitmap:texture_width()
  local texture_height = bitmap:texture_height()
  local panel_width, panel_height = bitmap:parent():size()
  target_w = target_w or bitmap:parent():w()
  target_h = target_h or bitmap:parent():h()
  local aspect = target_w / target_h
  local sw = math.max(texture_width, texture_height * aspect)
  local sh = math.max(texture_height, texture_width / aspect)
  local dw = texture_width / sw
  local dh = texture_height / sh
  bitmap:set_size(math.round(dw * target_w), math.round(dh * target_h))
end
local select_anim = function(object, size, instant)
  local current_width = object:w()
  local current_height = object:h()
  local end_width = size[1]
  local end_height = size[2]
  local cx, cy = object:center()
  if instant then
    object:set_size(end_width, end_height)
    object:set_center(cx, cy)
  else
    over(0.2, function(p)
      object:set_size(math.lerp(current_width, end_width, p), math.lerp(current_height, end_height, p))
      object:set_center(cx, cy)
    end)
  end
end
local unselect_anim = function(object, size, instant)
  local current_width = object:w()
  local current_height = object:h()
  local end_width = size[1] * 0.8
  local end_height = size[2] * 0.8
  local cx, cy = object:center()
  if instant then
    object:set_size(end_width, end_height)
    object:set_center(cx, cy)
  else
    over(0.2, function(p)
      object:set_size(math.lerp(current_width, end_width, p), math.lerp(current_height, end_height, p))
      object:set_center(cx, cy)
    end)
  end
end
local function select_anim_text(object, font_size, instant)
  local current_size = object:font_size()
  local end_font_size = font_size
  local cx, cy = object:center()
  if instant then
    object:set_size(end_width, end_height)
    make_fine_text(object)
    object:set_center(cx, cy)
  else
    over(0.2, function(p)
      object:set_font_size(math.lerp(current_size, end_font_size, p))
      make_fine_text(object)
      object:set_center(cx, cy)
    end)
  end
end
local function unselect_anim_text(object, font_size, instant)
  local current_size = object:font_size()
  local end_font_size = font_size * 0.8
  local cx, cy = object:center()
  if instant then
    object:set_font_size(end_font_size)
    make_fine_text(object)
    object:set_center(cx, cy)
  else
    over(0.2, function(p)
      object:set_font_size(math.lerp(current_size, end_font_size, p))
      make_fine_text(object)
      object:set_center(cx, cy)
    end)
  end
end

function CrewManagementGui:init(ws, fullscreen_ws, node)
  CriminalsManager.MAX_NR_TEAM_AI = LobbySettings and LobbySettings.original_MAX_NR_TEAM_AI or CriminalsManager.MAX_NR_TEAM_AI

  self._node = node
  self._item_w = 128
  self._item_h = 88
  self._image_max_h = 64
  
  managers.menu_component:close_contract_gui()
  managers.blackmarket:verfify_crew_loadout()
  managers.menu_scene:set_henchmen_visible(true)
  for i = 1, 3 do
    managers.menu_scene:set_henchmen_loadout(i)
  end
  if alive(CrewManagementGui.panel_crash_protection) then
    CrewManagementGui.panel_crash_protection:parent():remove(CrewManagementGui.panel_crash_protection)
  end
  self._panel = ws:panel():panel()
  CrewManagementGui.panel_crash_protection = self._panel
  self._buttons = {}
  self._buttons_no_nav = {}
  local title_text = self._panel:text({
    text = managers.localization:to_upper_text("menu_crew_management"),
    font = large_font,
    font_size = large_font_size
  })
  make_fine_text(title_text)
  local loadout_text = self._panel:text({
    text = managers.localization:text("menu_crew_loadout_order"),
    font = medium_font,
    font_size = medium_font_size,
    y = 20
  })
  make_fine_text(loadout_text)
  -- removed info panel from here
  self._1_panel = self._panel:panel({
    h = 0,
    w = self._item_w,
    y = loadout_text:bottom()
  })
  self._2_panel = self._panel:panel({
    h = 0,
    w = self._item_w,
    y = loadout_text:bottom()
  })
  self._3_panel = self._panel:panel({
    h = 0,
    w = self._item_w,
    y = loadout_text:bottom()
  })
  self._btn_panels = {
    self._1_panel,
    self._2_panel,
    self._3_panel
  }
  self._3_panel:set_right(self._panel:right() - 10)
  self._2_panel:set_right(self._3_panel:left() - 10)
  self._1_panel:set_right(self._2_panel:left() - 10)
  for i, panel in pairs(self._btn_panels) do
    local slot_text = self._panel:text({
      text = managers.localization:text("menu_crew_slot_index", {index = i}),
      font = small_font,
      font_size = small_font_size
    })
    make_fine_text(slot_text)
    slot_text:set_lefttop(panel:lefttop())
    panel:set_top(slot_text:bottom())
  end
  loadout_text:set_left(self._1_panel:left())
    -- character specific settings here
  local character_text = self._panel:text({
    text = managers.localization:to_upper_text("menu_crew_character_settings"),
    font = medium_font,
    font_size = medium_font_size,
    y = 20
  })
  make_fine_text(character_text)
  character_text:set_right(self._3_panel:right())
  local character_settings = CrewManagementGuiButton:new(self, function()
    self:show_character_specific_settings()
  end, true)
  character_settings._panel = character_text
  character_settings._select_col = tweak_data.screen_colors.button_stage_2
  character_settings._normal_col = tweak_data.screen_colors.button_stage_3
  character_settings._selected_changed = CrewManagementGuiTextButton._selected_changed
  -- end of char specific stuff
  self:create_mask_button(self._1_panel, 1)
  self:create_mask_button(self._2_panel, 2)
  self:create_mask_button(self._3_panel, 3)
  self:new_row()
  self:create_weapon_button(self._1_panel, 1)
  self:create_weapon_button(self._2_panel, 2)
  self:create_weapon_button(self._3_panel, 3)
  self:new_row()
  self:create_deployable_button(self._1_panel, 1)
  self:create_deployable_button(self._2_panel, 2)
  self:create_deployable_button(self._3_panel, 3)
  self:new_row()
  self:create_armor_button(self._1_panel, 1)
  self:create_armor_button(self._2_panel, 2)
  self:create_armor_button(self._3_panel, 3)
  self:new_row()
  self:create_ability_button(self._1_panel, 1)
  self:create_ability_button(self._2_panel, 2)
  self:create_ability_button(self._3_panel, 3)
  self:new_row()
  self:create_skill_button(self._1_panel, 1)
  self:create_skill_button(self._2_panel, 2)
  self:create_skill_button(self._3_panel, 3)
  self:new_row()
  local char_text = self._panel:text({
    text = managers.localization:text("menu_crew_character_order"),
    font = medium_font,
    font_size = medium_font_size
  })
  make_fine_text(char_text)
  
  local cc_panel = self._panel:panel({
    w = 300
  })
  cc_panel:set_right(self._1_panel:left() - 32)
  cc_panel:set_top(self._1_panel:top())
  char_text:set_center_y(loadout_text:center_y())
  char_text:set_left(cc_panel:left())
  local char_panel = cc_panel:panel({
    h = 88,
    w = 0
  })
  local char_images = {}
  for i = 1, CriminalsManager.MAX_NR_TEAM_AI do
    local character = managers.blackmarket:preferred_henchmen(i)
    local texture = character and managers.blackmarket:get_character_icon(character) or "guis/textures/pd2/dice_icon"
    local _, img = self:_add_bitmap_panel_row(char_panel, {texture = texture}, 70, 64)
    table.insert(char_images, img)
  end
  char_panel:set_center_x(cc_panel:w() / 2)
  cc_panel:set_h(char_panel:h())
  local char_btn = CrewManagementGuiButton:new(self, callback(self, self, "open_character_menu", 1))
  char_btn._panel = cc_panel
  char_btn._select_panel = BoxGuiObject:new(cc_panel, {
    sides = {
      2,
      2,
      2,
      2
    }
  })
  local char_panel_size = {
    char_images[1]:size()
  }
  function char_btn:_selected_changed(state, instant)
    CrewManagementGuiButton._selected_changed(self, state, instant)
    for _, img in pairs(char_images) do
      img:animate(state and select_anim or unselect_anim, char_panel_size, instant)
    end
  end
  char_btn:_selected_changed(false, true)
  do
    local v = cc_panel
    BoxGuiObject:new(v, {
      sides = {
        1,
        1,
        1,
        1
      }
    })
    v:bitmap({
      texture = "guis/textures/test_blur_df",
      render_template = "VertexColorTexturedBlur3D",
      w = v:w(),
      h = v:h(),
      halign = "scale",
      valign = "scale",
      layer = -1,
      alpha = 1
    })
    v:rect({
      color = Color.black,
      alpha = 0.4,
      layer = -1
    })
  end
  for _, v in pairs(self._btn_panels) do
    BoxGuiObject:new(v, {
      sides = {
        1,
        1,
        2,
        1
      }
    })
    v:bitmap({
      texture = "guis/textures/test_blur_df",
      render_template = "VertexColorTexturedBlur3D",
      w = v:w(),
      h = v:h(),
      halign = "scale",
      valign = "scale",
      layer = -1,
      alpha = 1
    })
    v:rect({
      color = Color.black,
      alpha = 0.4,
      layer = -1
    })
  end
  WalletGuiObject.set_wallet(self._panel)
  self:select_index(1, 1)
  local back_button = self._panel:text({
    name = "back_button",
    text = managers.localization:text("menu_back"),
    align = "right",
    vertical = "bottom",
    font_size = tweak_data.menu.pd2_large_font_size,
    font = tweak_data.menu.pd2_large_font,
    color = tweak_data.screen_colors.button_stage_3,
    layer = 40,
    blend_mode = "add"
  })
  make_fine_text(back_button)
  back_button:set_right(self._panel:w() - 10)
  back_button:set_bottom(self._panel:h() - 10)
  back_button:set_visible(managers.menu:is_pc_controller())
  local back = CrewManagementGuiButton:new(self, function()
    managers.menu:back(true)
  end, true)
  back._panel = back_button
  back._select_col = tweak_data.screen_colors.button_stage_2
  back._normal_col = tweak_data.screen_colors.button_stage_3
  back._selected_changed = CrewManagementGuiTextButton._selected_changed
  
  CriminalsManager.MAX_NR_TEAM_AI = Global.game_settings.max_bots or CriminalsManager.MAX_NR_TEAM_AI
end

local create_pages_original = CrewManagementGui.create_pages
function CrewManagementGui:create_pages(new_node_data, params, identifier, selected_slot, rows, columns, max_pages, selected_category)
  local correct_category = not new_node_data.category or not selected_category or new_node_data.category == selected_category
  local selected_tab = create_pages_original(self, new_node_data, params, identifier, selected_slot, rows, columns, max_pages, selected_category)
  return correct_category and selected_tab or 1
end

--[[ WEAPONS ]]
function CrewManagementGui:create_weapon_button(panel, index)
  local loadout = managers.blackmarket:henchman_loadout(index)
  local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
  local data = managers.blackmarket:get_crafted_category_slot(loadout.primary_category or "primaries", loadout.primary_slot) or {}
  local texture, rarity = managers.blackmarket:get_weapon_icon_path(data.weapon_id, data.cosmetics)
  local text = loadout.primary_slot and managers.blackmarket:get_weapon_name_by_category_slot(loadout.primary_category or "primaries", loadout.primary_slot) or ""
  local cat_text = managers.localization:to_upper_text("item_weapon")
  local weapon_text = loadout.primary_random and managers.localization:to_upper_text("item_random") or (char_loadout.primary or char_loadout.primary_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
  if type(loadout.primary_random) == "string" then
    weapon_text = managers.localization:to_upper_text("menu_" .. loadout.primary_random)
  end
  local item = CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or weapon_text, text, cat_text, callback(self, self, "show_weapon_selection", index))
  if rarity then
    local rare_item = item._panel:bitmap({
      texture = rarity,
      blend_mode = "add",
      layer = 0
    })
    fit_texture(rare_item, item._panel:size())
    rare_item:set_world_center(item._panel:world_center())
  end
  return item
end

function CrewManagementGui:open_weapon_category_menu(category, henchman_index)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  local new_node_data = {category = category}
  local selected_tab = self:create_pages(new_node_data, henchman_index, "weapon", loadout.primary_slot, tweak_data.gui.WEAPON_ROWS_PER_PAGE, tweak_data.gui.WEAPON_COLUMNS_PER_PAGE, tweak_data.gui.MAX_WEAPON_PAGES, loadout.primary_category or "primaries")
  new_node_data.can_move_over_tabs = true
  new_node_data.selected_tab = selected_tab
  new_node_data.scroll_tab_anywhere = true
  new_node_data.hide_detection_panel = true
  new_node_data.custom_callback = {
    w_equip = callback(self, self, "select_weapon", henchman_index),
    w_unequip = callback(self, self, "select_weapon", henchman_index)
  }
  new_node_data.topic_id = "bm_menu_" .. category
  new_node_data.topic_params = {
    weapon_category = managers.localization:text("bm_menu_weapons")
  }
  managers.menu:open_node("blackmarket_node", {new_node_data})
end

function CrewManagementGui:populate_primaries(henchman_index, data, gui)
  gui:populate_weapon_category_new(data)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  local check_cat = tweak_data.weapon.judge.categories[1] == "revolver" and 2 or 1 -- more weapon categories compat
  for k, v in ipairs(data) do
    local tweak = tweak_data.weapon[v.name]
    v.equipped = not v.locked_slot and not v.empty_slot and loadout.primary_slot == v.slot and loadout.primary_category == v.category
    v.comparision_data = nil
    if tweak and (not managers.blackmarket:is_weapon_category_allowed_for_crew(tweak.categories[check_cat] or tweak.categories[1]) or not BotWeapons:get_npc_version(v.name)) then
      v.buttons = {}
      v.unlocked = false
      v.lock_texture = "guis/textures/pd2/lock_incompatible"
      v.lock_text = managers.localization:text("menu_data_crew_not_allowed")
    else
      v.buttons = not v.empty_slot and {v.equipped and "w_unequip" or "w_equip", "w_mod", "w_preview", "w_sell"} or {v.locked_slot and "ew_unlock" or "ew_buy"}
    end
  end
end
CrewManagementGui.populate_secondaries = CrewManagementGui.populate_primaries

function CrewManagementGui:select_weapon(index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(index)
  if not data or data.equipped or data.random then
    loadout.primary = nil
    loadout.primary_slot = nil
    loadout.primary_category = nil
    loadout.primary_random = data and not data.equipped and data.random
  else
    local crafted = managers.blackmarket:get_crafted_category_slot(data.category, data.slot)
    loadout.primary = crafted.factory_id .. "_npc"
    loadout.primary_slot = data.slot
    loadout.primary_category = data.category
    loadout.primary_random = nil
  end
  return gui and gui:reload()
end

function CrewManagementGui:show_weapon_selection(henchman_index)
  local menu_title = managers.localization:text("menu_action_select_name")
  local menu_message = managers.localization:text("menu_action_select_desc")
  local menu_options = {
    {
      text = managers.localization:text("menu_action_inventory_primaries_name"),
      callback = function () self:open_weapon_category_menu("primaries", henchman_index) end
    },
    {
      text = managers.localization:text("menu_action_inventory_secondaries_name"),
      callback = function () self:open_weapon_category_menu("secondaries", henchman_index) end
    },
    {
      text = managers.localization:text("menu_action_random_weapon_name"),
      callback = function()
        local menu_title = managers.localization:text("menu_category_select_name")
        local menu_message = managers.localization:text("menu_category_select_desc")
        local menu_options = {
          {
            text = managers.localization:text("item_random"),
            callback = function () 
              self:select_weapon(henchman_index, { random = true })
              self:reload()
            end
          },
          {--[[seperator]]},
          {
            text = managers.localization:text("menu_back"),
            callback = function () self:show_weapon_selection(henchman_index) end,
            is_cancel_button = true
          }
        }
        for i, v in ipairs(BotWeapons.weapon_categories) do
          table.insert(menu_options, #menu_options - 2, {
            text = managers.localization:text("menu_" .. v),
            callback = function () 
              self:select_weapon(henchman_index, { random = v })
              self:reload()
            end
          })
        end
        QuickMenu:new(menu_title, menu_message, menu_options, true)
      end
    },
    {--[[seperator]]},
    {
      text = managers.localization:text("menu_back"),
      is_cancel_button = true
    }
  }
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if loadout.primary or loadout.primary_random then
    table.insert(menu_options, #menu_options, {
      text = managers.localization:text("bm_menu_btn_unequip_weapon"),
      callback = function ()
        self:select_weapon(henchman_index)
        self:reload()
      end
    })
    table.insert(menu_options, #menu_options, {--[[seperator]]})
  end
  QuickMenu:new(menu_title, menu_message, menu_options, true)
end

--[[ MASKS ]]
function CrewManagementGui:create_mask_button(panel, index)
  local loadout = managers.blackmarket:henchman_loadout(index)
  local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
  local texture = loadout.mask ~= "character_locked" and managers.blackmarket:get_mask_icon(loadout.mask)
  local text = loadout.mask ~= "character_locked" and managers.blackmarket:get_mask_name_by_category_slot("masks", loadout.mask_slot) or ""
  local cat_text = managers.localization:to_upper_text("bm_menu_masks")
  local mask_text = loadout.mask_random and managers.localization:to_upper_text("item_random") or (char_loadout.mask or char_loadout.mask_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
  if type(loadout.mask_random) == "string" then
    mask_text = managers.localization:to_upper_text("item_" .. loadout.mask_random)
  end
  return CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or mask_text, text, cat_text, callback(self, self, "show_mask_selection", index))
end

function CrewManagementGui:select_mask(index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(index)
  if not data or data.random then
    loadout.mask = "character_locked"
    loadout.mask_slot = 1
    loadout.mask_random = data and data.random
  else
    loadout.mask = data.name
    loadout.mask_slot = data.slot
    loadout.mask_random = nil
  end
  return gui and gui:reload()
end

function CrewManagementGui:show_mask_selection(henchman_index)
  local menu_title = managers.localization:text("menu_action_select_name")
  local menu_message = managers.localization:text("menu_action_select_desc")
  local menu_options = {
    {
      text = managers.localization:text("menu_action_inventory_masks_name"),
      callback = function () self:open_mask_category_menu(henchman_index) end
    },
    {
      text = managers.localization:text("menu_action_mask_set_name"),
      callback = function()
        local menu_title = managers.localization:text("menu_mask_set_select_name")
        local menu_message = managers.localization:text("menu_mask_set_select_desc")
        local menu_options = {
          {--[[seperator]]},
          {
            text = managers.localization:text("menu_back"),
            callback = function () self:show_mask_selection(henchman_index) end,
            is_cancel_button = true
          }
        }
        for k, v in pairs(BotWeapons.masks) do
          table.insert(menu_options, #menu_options - 1, {
            text = managers.localization:text("item_" .. k),
            callback = function () 
              self:select_mask(henchman_index, { random = k })
              self:reload()
            end
          })
        end
        QuickMenu:new(menu_title, menu_message, menu_options, true)
      end
    },
    {
      text = managers.localization:text("menu_action_random_mask_name"),
      callback = function () 
        self:select_mask(henchman_index, { random = true })
        self:reload()
      end
    },
    {--[[seperator]]},
    {
      text = managers.localization:text("menu_back"),
      is_cancel_button = true
    }
  }
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if loadout.mask ~= "character_locked" or loadout.mask_random then
    table.insert(menu_options, #menu_options, {
      text = managers.localization:text("menu_action_unequip_mask"),
      callback = function ()
        self:select_mask(henchman_index)
        self:reload()
      end
    })
    table.insert(menu_options, #menu_options, {--[[seperator]]})
  end
  QuickMenu:new(menu_title, menu_message, menu_options, true)
end

local function pad_data(data, amount)
  if data[#data].name == "empty" and data[#data - 1].name == "empty" then
    table.remove(data, #data)
    table.remove(data, #data)
  else
    for i = 1, amount - (#data % amount), 1 do
      table.insert(data, {
        name = "empty",
        name_localized = "",
        category = data.category,
        unlocked = true,
        equipped = false
      })
    end
  end
end

--[[ DEPLOYABLES ]]
function CrewManagementGui:create_deployable_button(panel, index)
  local loadout = managers.blackmarket:henchman_loadout(index)
  local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
  local texture = loadout.deployable and managers.blackmarket:get_deployable_icon(loadout.deployable)
  local text = loadout.deployable and managers.localization:to_upper_text(tweak_data.upgrades.definitions[loadout.deployable].name_id) or ""
  local cat_text = managers.localization:to_upper_text("bm_menu_deployables")
  local deployable_text = loadout.deployable_random and managers.localization:to_upper_text("item_random") or (char_loadout.deployable or char_loadout.deployable_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
  return CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or deployable_text, text, cat_text, callback(self, self, "open_deployables_category_menu", index))
end

function CrewManagementGui:open_deployables_category_menu(henchman_index)
  local new_node_data = {
    category = "deployables"
  }
  self:create_pages(new_node_data, henchman_index, "deployable", nil, 3, 3, 1)
  new_node_data.hide_detection_panel = true
  new_node_data.custom_callback = {
    lo_d_equip = callback(self, self, "select_deployable", henchman_index),
    lo_d_unequip = callback(self, self, "select_deployable", henchman_index)
  }
  new_node_data.topic_id = "bm_menu_deployables"
  new_node_data.topic_params = {
    weapon_category = managers.localization:text("bm_menu_deployables")
  }
  managers.menu:open_node("blackmarket_node", {new_node_data})
end

function CrewManagementGui:populate_deployables(henchman_index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if not self._deployables_data then
    gui:populate_deployables(data)

    table.insert(data, 1, {
      category = data.category,
      button_text = managers.localization:to_upper_text("item_random"),
      name = "ammo_bag",
      name_localized = managers.localization:text("item_random_deployable"),
      random = true
    })
    table.insert(data, 1, {
      category = data.category,
      button_text = managers.localization:to_upper_text("menu_crew_defualt"),
      name = "ammo_bag",
      name_localized = managers.localization:text("item_default_deployable"),
      default = true
    })
    pad_data(data, data.override_slots[2])

    self._deployables_data = true
  end

  for i, v in ipairs(data) do
    v.slot = i
    v.equipped = i == 1 and not loadout.deployable and not loadout.deployable_random or i == 2 and loadout.deployable_random or i > 2 and loadout.deployable == v.name
    v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
    v.unlocked = true
    v.lock_texture = nil
    v.lock_text = nil
    v.comparision_data = nil
    if not v.empty_slot and not v.equipped then
      v.buttons = {"lo_d_equip"}
    end
  end
end

function CrewManagementGui:select_deployable(henchman_index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if not data or data.default or data.random then
    loadout.deployable = nil
    loadout.deployable_random = data and data.random
  else
    loadout.deployable = data.name
    loadout.deployable_random = nil
  end
  return gui and gui:reload()
end

--[[ ARMOR ]]
function CrewManagementGui:create_armor_button(panel, index)
  local loadout = managers.blackmarket:henchman_loadout(index)
  local char_loadout = BotWeapons:get_char_loadout(managers.menu_scene._picked_character_position[index])
  local texture = loadout.armor and managers.blackmarket:get_armor_icon(loadout.armor)
  local text = loadout.armor and managers.localization:text(tweak_data.blackmarket.armors[loadout.armor].name_id) or ""
  local cat_text = managers.localization:to_upper_text("bm_menu_armor")
  local armor_text = loadout.armor_random and managers.localization:to_upper_text("item_random") or (char_loadout.armor or char_loadout.armor_random) and managers.localization:to_upper_text("menu_crew_character") or managers.localization:to_upper_text("menu_crew_defualt")
  return CrewManagementGuiLoadoutItem:new(self, panel, texture and {texture = texture, layer = 1} or armor_text, text, cat_text, callback(self, self, "open_armor_category_menu", index))
end

function CrewManagementGui:open_armor_category_menu(henchman_index)
  local new_node_data = {
    category = "armors"
  }
  self:create_pages(new_node_data, henchman_index, "armor", nil, 3, 3, 1)
  new_node_data.hide_detection_panel = true
  new_node_data.custom_callback = {
    a_equip = callback(self, self, "select_armor", henchman_index),
    a_mod = callback(self, self, "open_armor_skins_menu", henchman_index)
  }
  new_node_data.topic_id = "bm_menu_armor"
  managers.menu:open_node("blackmarket_node", {new_node_data})
end

function CrewManagementGui:populate_armors(henchman_index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if not self._armors_data then
    gui:populate_armors(data)

    table.insert(data, 1, {
      category = data.category,
      button_text = managers.localization:to_upper_text("item_random"),
      bitmap_texture = "guis/textures/empty",
      name = "level_1",
      name_localized = managers.localization:text("item_random_armor"),
      random = true
    })
    table.insert(data, 1, {
      category = data.category,
      button_text = managers.localization:to_upper_text("menu_crew_defualt"),
      bitmap_texture = "guis/textures/empty",
      name = "level_1",
      name_localized = managers.localization:text("item_default_armor"),
      default = true
    })
    pad_data(data, data.override_slots[2])

    self._armors_data = true
  end

  for i, v in ipairs(data) do
    v.slot = i
    v.equipped = i == 1 and not loadout.armor and not loadout.armor_random or i == 2 and loadout.armor_random or i > 2 and loadout.armor == v.name
    v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
    v.unlocked = true
    v.lock_texture = nil
    v.lock_text = nil
    v.comparision_data = nil
    v.buttons = {"a_mod"}
    if not v.empty_slot and not v.equipped then
      table.insert(v.buttons, 1, "a_equip")
    end
  end
end

function CrewManagementGui:select_armor(henchman_index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if not data or data.default or data.random then
    loadout.armor = nil
    loadout.armor_random = data and data.random
  else
    loadout.armor = data.name
    loadout.armor_random = nil
  end
  return gui and gui:reload()
end

function CrewManagementGui:open_armor_skins_menu(henchman_index)
  local new_node_data = {
    category = "armor_skins"
  }
  self:create_pages(new_node_data, henchman_index, "armor_skins", nil, 3, 3, 1)
  new_node_data.hide_detection_panel = true
  new_node_data.custom_callback = {
    as_equip = callback(self, self, "select_armor_skin", henchman_index)
  }
  new_node_data.topic_id = "bm_menu_armor_skins"
  managers.menu:open_node("blackmarket_node", {new_node_data})
end

function CrewManagementGui:populate_armor_skins(henchman_index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if not self._armor_skins_data then
    gui:populate_armor_skins(data)

    table.insert(data, 1, {
      category = data.category,
      button_text = managers.localization:to_upper_text("item_random"),
      name = "none",
      name_localized = managers.localization:text("item_random_armor_skin"),
      unlocked = true,
      cosmetic_unlocked = true,
      random = true
    })
    table.insert(data, 1, {
      category = data.category,
      button_text = managers.localization:to_upper_text("menu_crew_defualt"),
      name = "none",
      name_localized = managers.localization:text("item_default_armor_skin"),
      unlocked = true,
      cosmetic_unlocked = true,
      default = true
    })
    pad_data(data, data.override_slots[2])

    self._armor_skins_data = true
  end

  for i, v in ipairs(data) do
    v.slot = i
    v.equipped = i == 1 and not loadout.armor_skin and not loadout.armor_skin_random or i == 2 and loadout.armor_skin_random == true or i > 2 and loadout.armor_skin == v.name
    v.equipped_text = v.equipped and managers.localization:text("bm_menu_chosen") or ""
    v.comparision_data = nil
    if not v.equipped and v.cosmetic_unlocked then
      v.buttons = {"as_equip"}
    else
      v.buttons = {}
    end
  end
end

function CrewManagementGui:select_armor_skin(henchman_index, data, gui)
  local loadout = managers.blackmarket:henchman_loadout(henchman_index)
  if not data or data.default or data.random then
    loadout.armor_skin = nil
    loadout.armor_skin_random = data and data.random
  else
    loadout.armor_skin = data.name
    loadout.armor_skin_random = nil
  end
  return gui and gui:reload()
end

function CrewManagementGui:show_character_specific_settings()
  local menu_title = managers.localization:text("menu_character_settings_name")
  local menu_message = managers.localization:text("menu_character_settings_desc")
  local menu_options = {
    {
      text = managers.localization:text("menu_action_set_character_loadout"),
      callback = function ()
        for i = 1, 3 do
          local character = managers.menu_scene._picked_character_position[i]
          BotWeapons:set_character_loadout(character, BotWeapons:get_loadout(character, managers.blackmarket:henchman_loadout(i), true))
          self:select_armor(i, nil)
          self:select_armor_skin(i, nil)
          self:select_deployable(i, nil)
          self:select_mask(i, nil)
          self:select_weapon(i, nil)
        end
        BotWeapons:save()
        self:reload()
      end
    },
    {
      text = managers.localization:text("menu_action_clear_character_loadout"),
      callback = function ()
        for i = 1, 3 do
          BotWeapons:set_character_loadout(managers.menu_scene._picked_character_position[i], nil)
        end
        BotWeapons:save()
        self:reload()
      end
    },
    {
      text = managers.localization:text("menu_action_clear_all_character_loadout"),
      callback = function ()
        for _, char_name in ipairs(CriminalsManager.character_names()) do
          BotWeapons:set_character_loadout(char_name, nil)
        end
        BotWeapons:save()
        self:reload()
      end
    },
    {--[[seperator]]},
    {
      text = managers.localization:text("menu_back"),
      is_cancel_button = true
    }
  }
  QuickMenu:new(menu_title, menu_message, menu_options, true)
end

-- custom reload since it doesnt have one
function CrewManagementGui:reload()
  managers.menu_component:close_crew_management_gui()
  managers.menu_component:create_crew_management_gui(self._node)
end