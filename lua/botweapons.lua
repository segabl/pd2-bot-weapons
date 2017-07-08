if not _G.BotWeapons then

  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath
  BotWeapons._data = {}

  function BotWeapons:log(message, condition)
    if condition or condition == nil then
      log("[BotWeapons] " .. message)
    end
  end
  
  function BotWeapons:init()
    self._revision = 0
    local file = io.open(BotWeapons._path .. "mod.txt", "r")
    if file then
      local data = json.decode(file:read("*all"))
      file:close()
      self._revision = data and data.updates and data.updates[1] and data.updates[1].revision or 0
    end
    self:log("Revision " .. self._revision)
  
    self.armor = {
      { menu_name = "bm_armor_level_1" },
      { menu_name = "bm_armor_level_2" },
      { menu_name = "bm_armor_level_3" },
      { menu_name = "bm_armor_level_4" },
      { menu_name = "bm_armor_level_5" },
      { menu_name = "bm_armor_level_6" },
      { menu_name = "bm_armor_level_7" }
    }
  
    self.equipment = {
      { menu_name = "item_none" },
      { menu_name = "bm_equipment_ammo_bag", name = "ammo_bag" },
      { menu_name = "bm_equipment_armor_kit", name = "armor_kit" },
      { menu_name = "bm_equipment_bodybags_bag", name = "bodybags_bag" },
      { menu_name = "bm_equipment_doctor_bag", name = "doctor_bag" },
      { menu_name = "bm_equipment_ecm_jammer", name = "ecm_jammer" },
      { menu_name = "bm_equipment_first_aid_kit", name = "first_aid_kit" },
      { menu_name = "bm_equipment_sentry_gun", name = "sentry_gun" }
    }
    
    -- load mask sets
    file = io.open(BotWeapons._path .. "masks.json", "r")
    if file then
      self.masks = json.decode(file:read("*all"))
      file:close()
    end
    self.masks = self.masks or {}
    
    -- load settings
    self:load()
  end
  
  function BotWeapons:get_menu_list(tbl, add)
    if not tbl then
      return {}
    end
    local menu_list = {}
    local names = {}
    local item_name
    local localized_name
    for _, v in ipairs(tbl) do
      item_name = v.menu_name:gsub("^bm_w_", "item_")
      localized_name = managers.localization:text(v.menu_name):upper()     
      if v.menu_name:match("^bm_w_.+") then
        localized_name = localized_name:gsub(" PISTOLS?$", ""):gsub(" REVOLVERS?$", ""):gsub(" RIFLES?$", ""):gsub(" SHOTGUNS?$", ""):gsub(" GUNS?$", ""):gsub(" LIGHT MACHINE$", ""):gsub(" SUBMACHINE$", ""):gsub(" ASSAULT$", ""):gsub(" SNIPER$", "")
      end
      table.insert(menu_list, item_name)
      names[item_name] = localized_name
    end
    if add then
      for _, v in ipairs(add) do
        table.insert(menu_list, v)
      end
    end
    managers.localization:add_localized_strings(names)
    return menu_list
  end
  
  function BotWeapons:set_recoil(weapon, rec)
    if not weapon or not rec then
      return
    end
    for _, v in ipairs(weapon.FALLOFF) do
      v.recoil = rec
    end
  end
  
  function BotWeapons:set_mode(weapon, mode)
    if not weapon or not mode then
      return
    end
    for _, v in ipairs(weapon.FALLOFF) do
      v.mode = mode
    end
  end
  
  function BotWeapons:set_armor(unit, armor, armor_skin)
    if not alive(unit) or not armor then
      return
    end
    local current_level = managers.job and managers.job:current_level_id()
    if current_level ~= "glace" then
      unit:damage():run_sequence_simple(tweak_data.blackmarket.armors[armor].sequence)
      if Utils:IsInGameState() and not Global.game_settings.single_player and LuaNetworking:IsHost() then
        managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, tweak_data.blackmarket.armors[armor].sequence)
      end
    end
  end
  
  function BotWeapons:set_equipment(unit, equipment)
    if not alive(unit) or not equipment then
      return
    end
    local visual_object = tweak_data.equipments[equipment] and tweak_data.equipments[equipment].visual_object
    for k, v in pairs(tweak_data.equipments) do
      if v.visual_object then
        local mesh_obj = unit:get_object(Idstring(v.visual_object))
        if mesh_obj then
          mesh_obj:set_visibility(v.visual_object == visual_object)
        end
      end
    end
    if Utils:IsInGameState() and not Global.game_settings.single_player and LuaNetworking:IsHost() then
      local name = unit:base()._tweak_table
      DelayedCalls:Add("bot_weapons_sync_equipment_" .. name, 1, function ()
        LuaNetworking:SendToPeers("bot_weapons_equipment", name .. "," .. tostring(equipment))
      end)
    end
  end
   
  function BotWeapons:get_masks_data()
    if not self._masks_data then
      self._masks_data = {}
      self._masks_data.masks = {}
      for k, v in pairs(tweak_data.blackmarket.masks) do
        if not v.inaccessible then
          table.insert(self._masks_data.masks, k)
        end
      end
      self._masks_data.colors = {}
      for k, _ in pairs(tweak_data.blackmarket.colors) do
        table.insert(self._masks_data.colors, k)
      end
      self._masks_data.patterns = {}
      for k, _ in pairs(tweak_data.blackmarket.textures) do
        table.insert(self._masks_data.patterns, k)
      end
      self._masks_data.materials = {}
      for k, _ in pairs(tweak_data.blackmarket.materials) do
        table.insert(self._masks_data.materials, k)
      end
    end
    return self._masks_data
  end

  function BotWeapons:get_npc_version(weapon_id)
    local factory_id = weapon_id and managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
    local tweak = factory_id and tweak_data.weapon.factory[factory_id .. "_npc"]
    return tweak and (not tweak.custom or DB:has(Idstring("unit"), tweak.unit:id())) and factory_id .. "_npc"
  end
  
  function BotWeapons:get_random_weapon(category)
    local cat = type(category) ~= "string" and "all" or category
    if not self.weapons or not self.weapons[cat] then
      self.weapons = self.weapons or {}
      self.weapons[cat] = {}
      for weapon_id, data in pairs(tweak_data.weapon) do
        if data.autohit then
          local factory_id = self:get_npc_version(weapon_id)
          if factory_id and (type(category) ~= "string" or data.categories[1] == category) and managers.blackmarket:is_weapon_category_allowed_for_crew(data.categories[1]) then
            local data = {
              category = data.use_data.selection_index == 2 and "primaries" or "secondaries",
              factory_id = factory_id
            }
            table.insert(self.weapons[cat], data)
          end
        end
      end
    end
    local weapon = self.weapons[cat][math.random(#self.weapons[cat])]
    if not weapon then
      return {}
    end
    weapon.blueprint = {}
    local has_part_of_type = {}
    local parts = deep_clone(tweak_data.weapon.factory[weapon.factory_id].uses_parts)
    local adds = tweak_data.weapon.factory[weapon.factory_id].adds or {}
    local must_use = {}
    for _, part_name in ipairs(tweak_data.weapon.factory[weapon.factory_id].default_blueprint) do
      local part_type = tweak_data.weapon.factory.parts[part_name].type
      must_use[part_type] = true
    end   
    while #parts > 0 do
      local index = math.random(#parts)
      local part_name = parts[index]
      local part = tweak_data.weapon.factory.parts[part_name]
      local is_forbidden = part.unatainable or table.contains(adds, part_name) or managers.weapon_factory:_get_forbidden_parts(weapon.factory_id, weapon.blueprint)[part_name]
      if not has_part_of_type[part.type] and not is_forbidden then
        if (must_use[part.type] or math.random() < 0.5) then
          table.insert(weapon.blueprint, part_name)
          for i, v in ipairs(adds[part_name] or {}) do
            table.insert(weapon.blueprint, v)
            local add_type = tweak_data.weapon.factory.parts[v].type
            has_part_of_type[add_type] = v
          end
        end
        has_part_of_type[part.type] = part_name
      end
      table.remove(parts, index)
    end
    return weapon
  end
  
  function BotWeapons:get_loadout(char_name, original_loadout, refresh)
    if not char_name then
      return original_loadout
    end
    if not refresh and self._loadouts and self._loadouts[char_name] then
      return self._loadouts[char_name]
    end
    if not original_loadout then
      return
    end
    local loadout = deep_clone(original_loadout)
    if LuaNetworking:IsHost() then
    
      local char_loadout = self._data[char_name] or {}
    
      -- choose mask     
      if loadout.mask == "character_locked" or loadout.mask_random then
        loadout.mask_slot = nil

        if not loadout.mask_random then
          loadout.mask = char_loadout.mask or "character_locked"
          loadout.mask_random = char_loadout.mask_random
          loadout.mask_blueprint = char_loadout.mask_blueprint
        end
        
        if loadout.mask_random and type(loadout.mask_random) ~= "string" then
          local masks_data = self:get_masks_data()
          loadout.mask = masks_data.masks[math.random(#masks_data.masks)]
          if math.random() < (self._data.slider_mask_customized_chance or 0.5) then
            loadout.mask_blueprint = {
              color = {id = masks_data.colors[math.random(#masks_data.colors)]},
              pattern = {id = masks_data.patterns[math.random(#masks_data.patterns)]},
              material = {id = masks_data.materials[math.random(#masks_data.materials)]}
            }
          end
        elseif type(loadout.mask_random) == "string" and (self.masks[loadout.mask_random].character and self.masks[loadout.mask_random].character[char_name] or self.masks[loadout.mask_random].pool) then
          local selection = self.masks[loadout.mask_random].character and self.masks[loadout.mask_random].character[char_name] or self.masks[loadout.mask_random].pool[math.random(#self.masks[loadout.mask_random].pool)]
          loadout.mask = selection.id
          loadout.mask_blueprint = selection.blueprint
        end
      end
      
      -- choose weapon
      if not loadout.primary or loadout.primary_random then
        loadout.primary_slot = nil
        
        if not loadout.primary_random then
          loadout.primary = char_loadout.primary
          loadout.primary_random = char_loadout.primary_random
          loadout.primary_blueprint = char_loadout.primary_blueprint
        end
        
        if loadout.primary_random then
          local weapon = self:get_random_weapon(type(loadout.primary_random) == "string" and loadout.primary_random or nil)
          loadout.primary = weapon.factory_id
          loadout.primary_category = weapon.category
          loadout.primary_blueprint = weapon.blueprint
        end
      elseif loadout.primary_slot then
        local crafted = managers.blackmarket:get_crafted_category_slot(loadout.primary_category or "primaries", loadout.primary_slot)
        if crafted then
          loadout.primary_blueprint = crafted.blueprint
        end
      end
      
      -- choose armor models
      if not loadout.armor or loadout.armor_random then
      
        if not loadout.armor_random then
          loadout.armor = char_loadout.armor
          loadout.armor_random = char_loadout.armor_random
        end

        if loadout.armor_random then
          loadout.armor = "level_" .. math.random(#BotWeapons.armor)
        end
      end
      
      -- choose equipment models
      if not loadout.deployable or loadout.deployable_random then
      
        if not loadout.deployable_random then
          loadout.deployable = char_loadout.deployable
          loadout.deployable_random = char_loadout.deployable_random
        end
      
        if loadout.deployable_random then
          loadout.deployable = BotWeapons.equipment[1 + math.random(#BotWeapons.equipment - 1)].name
        end
      end
      
    end
    self._loadouts = self._loadouts or {}
    self._loadouts[char_name] = loadout
    return loadout
  end
  
  function BotWeapons:set_character_loadout(char_name, loadout)
    if not char_name then
      return
    end
    self._data[char_name] = {
      armor = not loadout.armor_random and loadout.armor or nil,
      armor_random = loadout.armor_random,
      deployable = not loadout.deployable_random and loadout.deployable or nil,
      deployable_random = loadout.deployable_random,
      mask = not loadout.mask_random and loadout.mask or nil,
      mask_blueprint = not loadout.mask_random and loadout.mask_blueprint or nil,
      mask_random = loadout.mask_random,
      primary = not loadout.primary_random and loadout.primary or nil,
      primary_blueprint = not loadout.primary_random and loadout.primary_blueprint or nil,
      primary_random = loadout.primary_random
    }
  end
  
  Hooks:Add("NetworkReceivedData", "NetworkReceivedDataBotWeapons", function(sender, id, data)
    local peer = LuaNetworking:GetPeers()[sender]
    local params = string.split(data or "", ",", true)
    if id == "bot_weapons_equipment" and managers.criminals then
      if #params == 2 then
        local name = params[1]
        local equipment = params[2]
        BotWeapons:set_equipment(managers.criminals:character_unit_by_name(name), equipment)
      end
    end
  end)

  function BotWeapons:save()
    local file = io.open(self._data_path .. "bot_weapons_data.txt", "w+")
    if file then
      file:write(json.encode(self._data))
      file:close()
    end
  end

  function BotWeapons:load()
    local file = io.open(self._data_path .. "bot_weapons_data.txt", "r")
    if file then
      self._data = json.decode(file:read("*all"))
      file:close()
    end
  end
  
  -- initialize
  BotWeapons:init()
  
end