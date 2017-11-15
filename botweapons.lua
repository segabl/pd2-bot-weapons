if not _G.BotWeapons then

  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath .. "bot_weapons_data.txt"
  BotWeapons._data = {
    debug = false,
    weapon_balance = true,
    player_carry = true,
    use_flashlights = true,
    use_lasers = false,
    mask_customized_chance = 0.5,
    weapon_customized_chance = 0.5,
    sync_settings = true
  }
  BotWeapons.allowed_weapon_categories = {
    "assault_rifle",
    "shotgun",
    "snp",
    "lmg",
    "smg",
    "akimbo",
    "pistol"
  }

  function BotWeapons:log(message, condition)
    if condition or condition == nil then
      log("[BotWeapons] " .. message)
    end
  end
  
  function BotWeapons:init()
    self._version = "1.0"
    local file = io.open(BotWeapons._path .. "mod.txt", "r")
    if file then
      local data = json.decode(file:read("*all"))
      file:close()
      self._version = data and data.version or self._version
    end
    self:log("Version " .. self._version)
    
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
  
  function BotWeapons:should_use_armor()
    local current_level_data = managers.job and managers.job:current_level_data() or {}
    return not current_level_data.player_sequence and true or false
  end
  
  function BotWeapons:set_armor(unit, armor)
    if not alive(unit) then
      return
    end
    armor = armor or "level_1"
    if self:should_use_armor() then
      unit:damage():run_sequence_simple(tweak_data.blackmarket.armors[armor].sequence)
      if self._data.sync_settings and Utils:IsInGameState() and not Global.game_settings.single_player and Network:is_server() then
        managers.network:session():send_to_peers_synched("sync_run_sequence_char", unit, tweak_data.blackmarket.armors[armor].sequence)
      end
    end
  end
  
  function BotWeapons:set_equipment(unit, equipment, sync_delay)
    if not alive(unit) then
      return
    end
    local visual_object = equipment and tweak_data.equipments[equipment] and tweak_data.equipments[equipment].visual_object
    for k, v in pairs(tweak_data.equipments) do
      if v.visual_object then
        local mesh_obj = unit:get_object(Idstring(v.visual_object))
        if mesh_obj then
          mesh_obj:set_visibility(v.visual_object == visual_object)
        end
      end
    end
    if self._data.sync_settings and Utils:IsInGameState() and not Global.game_settings.single_player and Network:is_server() then
      local name = unit:base()._tweak_table
      DelayedCalls:Add("bot_weapons_sync_equipment_" .. name, sync_delay or 0, function ()
        LuaNetworking:SendToPeers("bot_weapons_equipment", name .. "," .. tostring(equipment))
      end)
    end
  end
  
  function BotWeapons:set_special_material(unit, material_name)
    if not alive(unit) or not material_name then
      return
    end
    local mtr_ids = Idstring(material_name)
    if DB:has(Idstring("material_config"), mtr_ids) then
      unit:set_material_config(mtr_ids, true)
      if unit:base().on_material_applied then
        unit:base():on_material_applied()
      end
      if self._data.sync_settings and Utils:IsInGameState() and not Global.game_settings.single_player and Network:is_server() then
        managers.network:session():send_to_peers_synched("sync_special_character_material", unit, material_name)
      end
    end
  end
  
  function BotWeapons:check_setup_gadget_colors(unit, weapon_base)
    if weapon_base._setup_team_ai_colors then
      return
    end
    local loadout = managers.criminals:get_loadout_for(unit:base()._tweak_table)
    local category = loadout.primary_category or "primaries"
    local slot = loadout.primary_slot or 0
    local parts = weapon_base._parts
    local colors, data, sub_type, part_base
    for part_id, part_data in pairs(parts) do
      part_base = part_data.unit and part_data.unit:base()
      if part_base and part_base.set_color then
        colors = managers.blackmarket:get_part_custom_colors(category, slot, part_id, true) or loadout.primary_random and {
          laser = loadout.gadget_laser_color or tweak_data.custom_colors.defaults.laser,
          flashlight = tweak_data.custom_colors.defaults.flashlight
        }
        if colors then
          data = tweak_data.weapon.factory.parts[part_id]
          if colors[data.sub_type] then
            part_base:set_color(colors[data.sub_type]:with_alpha(part_base.GADGET_TYPE == "laser" and tweak_data.custom_colors.defaults.laser_alpha or 1))
          end
          for _, add_part_id in ipairs(data.adds or {}) do
            part_data = parts[add_part_id]
            part_base = part_data and part_data.unit and part_data.unit:base()
            if part_base and part_base.set_color then
              sub_type = tweak_data.weapon.factory.parts[add_part_id].sub_type
              if colors[sub_type] then
                part_base:set_color(colors[sub_type])
              end
            end
          end
        end
      end
    end
    weapon_base._setup_team_ai_colors = true
    if alive(weapon_base._second_gun) then
      self:set_gadget_colors(unit, weapon_base._second_gun:base())
    end
  end
  
  function BotWeapons:check_set_gadget_state(unit, weapon_base, sync_delay)
    if not weapon_base or not weapon_base._assembly_complete or not alive(unit) or unit:movement():cool() then
      return
    end
    local gadget = self:should_use_flashlight(unit:position()) and weapon_base:get_gadget_by_type("flashlight") or self:should_use_laser() and weapon_base:get_gadget_by_type("laser")
    if gadget == weapon_base._gadget_on then
      return
    end
    self:check_setup_gadget_colors(unit, weapon_base)
    weapon_base:set_gadget_on(gadget)
    if self._data.sync_settings and not Global.game_settings.single_player and Network:is_server() then
      DelayedCalls:Add("bot_weapons_sync_gadget_" .. unit:base()._tweak_table, sync_delay or 0, function ()
        if not weapon_base or not alive(unit) then
          return
        end
        local gadget_base = weapon_base:get_active_gadget()
        if gadget_base and gadget_base.color then
          local col = gadget_base:color()
          managers.network:session():send_to_peers_synched("set_weapon_gadget_color", unit, col.r * 255, col.g * 255, col.b * 255)
        end
        managers.network:session():send_to_peers_synched("set_weapon_gadget_state", unit, weapon_base._gadget_on or 0)
      end)
    end
    if alive(weapon_base._second_gun) then
      self:check_set_gadget_state(unit, weapon_base._second_gun:base(), sync_delay)
    end
  end

  function BotWeapons:sync_to_peer(peer, unit)
    if not peer or not alive(unit) then
      return
    end
    local name = unit:base()._tweak_table
    local loadout = managers.criminals:get_loadout_for(name)
    -- send special material
    if loadout.special_material then
      peer:send_queued_sync("sync_special_character_material", unit, loadout.special_material)
    end
    -- send armor
    if self:should_use_armor() and loadout.armor then
      peer:send_queued_sync("sync_run_sequence_char", unit, tweak_data.blackmarket.armors[loadout.armor].sequence)
    end
    -- send gadget state
    local weapon = unit:inventory():equipped_unit()
    if weapon then
      local weapon_base = weapon:base()
      local gadget = weapon_base.get_active_gadget and weapon_base:get_active_gadget()
      if gadget and gadget.color then
        local col = gadget:color()
        peer:send_queued_sync("set_weapon_gadget_color", unit, col.r * 255, col.g * 255, col.b * 255)
      end
      peer:send_queued_sync("set_weapon_gadget_state", unit, weapon_base._gadget_on or 0)
    end
    -- send equipement
    LuaNetworking:SendToPeer(peer:id(), "bot_weapons_equipment", name .. "," .. tostring(loadout.deployable))
  end
  
  local env_triggers = {
    "night", "glace", "foggy", "_n2", "framing_frame", "dah_outdoor", "dark", "mad_lab", "underground",
    "nail", "kosugi", "help", "fork_01", "spa_outside", "stern_01", "hlm1", "hvh", "berry_connection"
  }
  function BotWeapons:should_use_flashlight(position)
    if not self._data.use_flashlights or not position then
      return false
    end
    local environment = managers.environment_area and managers.environment_area:environment_at_position(position)
    if not environment then
      return false
    end
    environment = environment:gsub(".+/(.+)", "%1")
    for _, v in ipairs(env_triggers) do
      if environment:find(v) then
        return true
      end
    end
    return false
  end
  
  function BotWeapons:should_use_laser()
    return self._data.use_lasers
  end
  
  function BotWeapons:masks_data()
    if not self._masks_data then
      self._masks_data = {}
      self._masks_data.masks = table.map_keys(table.filter(tweak_data.blackmarket.masks, function (v, k) return not v.inaccessible end))
      self._masks_data.colors = table.map_keys(tweak_data.blackmarket.colors)
      self._masks_data.patterns = table.map_keys(tweak_data.blackmarket.textures)
      self._masks_data.materials = table.map_keys(tweak_data.blackmarket.materials)
    end
    return self._masks_data
  end
  
  function BotWeapons:armors()
    if not self._armors then
      self._armors = table.map_keys(tweak_data.blackmarket.armors)
    end
    return self._armors
  end
  
  function BotWeapons:deployables()
    if not self._deployables then
      self._deployables = table.map_keys(tweak_data.blackmarket.deployables)
    end
    return self._deployables
  end

  -- returns npc version of weapon if it exists
  function BotWeapons:get_npc_version(weapon_id)
    local factory_id = weapon_id and managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
    local tweak = factory_id and tweak_data.weapon.factory[factory_id .. "_npc"]
    return tweak and (not tweak.custom or DB:has(Idstring("unit"), tweak.unit:id())) and factory_id .. "_npc"
  end

  -- selects a random weapon and constructs a random blueprint for it
  function BotWeapons:get_random_weapon(category)
    local cat = type(category) ~= "string" and table.random(self.allowed_weapon_categories) or category
    if not self._weapons or not self._weapons[cat] then
      self._weapons = self._weapons or {}
      self._weapons[cat] = {}
      for weapon_id, data in pairs(tweak_data.weapon) do
        if data.autohit and data.categories[1] == cat then
          local factory_id = self:get_npc_version(weapon_id)
          if factory_id then
            local data = {
              category = data.use_data.selection_index == 2 and "primaries" or "secondaries",
              factory_id = factory_id,
              weapon_id = weapon_id,
            }
            table.insert(self._weapons[cat], data)
          end
        end
      end
    end
    local weapon = table.random(self._weapons[cat])
    if not weapon then
      return {}
    end
    weapon.blueprint = deep_clone(tweak_data.weapon.factory[weapon.factory_id].default_blueprint)
    for part_type, parts_data in pairs(managers.blackmarket:get_dropable_mods_by_weapon_id(weapon.weapon_id)) do
      if math.random() < self._data.weapon_customized_chance then
        local part_data = table.random(parts_data)
        if part_data then
          managers.weapon_factory:change_part_blueprint_only(weapon.factory_id, part_data[1], weapon.blueprint)
        end
      end
    end
    return weapon
  end
  
  function BotWeapons:get_char_loadout(char_name)
    return char_name and type(self._data[char_name]) == "table" and self._data[char_name] or {}
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
    if not Utils:IsInGameState() or Network:is_server() then
    
      local char_loadout = self:get_char_loadout(char_name)
    
      -- choose mask
      if loadout.mask == "character_locked" or loadout.mask_random then
        loadout.mask_slot = nil
        if not loadout.mask_random then
          loadout.mask = char_loadout.mask or "character_locked"
          loadout.mask_random = char_loadout.mask_random
          loadout.mask_blueprint = char_loadout.mask_blueprint
        end
        if type(loadout.mask_random) == "string" and self.masks[loadout.mask_random] and (self.masks[loadout.mask_random].character and self.masks[loadout.mask_random].character[char_name] or self.masks[loadout.mask_random].pool) then
          local selection = self.masks[loadout.mask_random].character and self.masks[loadout.mask_random].character[char_name] or table.random(self.masks[loadout.mask_random].pool)
          loadout.mask = selection.id
          loadout.mask_blueprint = selection.blueprint
        elseif loadout.mask_random then
          local masks_data = self:masks_data()
          loadout.mask = table.random(masks_data.masks)
          if math.random() < self._data.mask_customized_chance then
            loadout.mask_blueprint = {
              color = { id = table.random(masks_data.colors) },
              pattern = { id = table.random(masks_data.patterns) },
              material = { id = table.random(masks_data.materials) }
            }
          end
        end
      elseif loadout.mask_slot then
        local crafted = managers.blackmarket:get_crafted_category_slot("masks", loadout.mask_slot)
        if crafted then
          loadout.mask_blueprint = crafted.blueprint
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
          local weapon = self:get_random_weapon(loadout.primary_random)
          loadout.primary = weapon.factory_id
          loadout.primary_category = weapon.category
          loadout.primary_blueprint = weapon.blueprint
          loadout.gadget_laser_color = Color(hsv_to_rgb(math.random(360), 1, 0.4 + math.random() * 0.4))
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
          loadout.armor = table.random(self:armors())
        end
      end
      
      -- choose equipment models
      if not loadout.deployable or loadout.deployable_random then
        if not loadout.deployable_random then
          loadout.deployable = char_loadout.deployable
          loadout.deployable_random = char_loadout.deployable_random
        end
        if loadout.deployable_random then
          loadout.deployable = table.random(self:deployables())
        end
      end
      
      -- choose special material (Sangres)
      local char_tweak = tweak_data.blackmarket.characters.locked[char_name] or tweak_data.blackmarket.characters[char_name]
      if char_tweak and char_tweak.special_materials then
        local special_material = nil
        local special_materials = char_tweak.special_materials
        for material, chance in pairs(special_materials) do
          if type(chance) == "number" then
            local rand = math.rand(chance)
            if rand <= 1 then
              special_material = material
              break
            end
          end
        end
        special_material = special_material or table.random(special_materials)
        loadout.special_material = special_material
      else
        loadout.special_material = nil
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
    if not loadout then
      self._data[char_name] = nil
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
    local file = io.open(self._data_path, "w+")
    if file then
      file:write(json.encode(self._data))
      file:close()
    end
  end

  function BotWeapons:load()
    local file = io.open(self._data_path, "r")
    if file then
      local data = json.decode(file:read("*all"))
      file:close()
      if data then
        for k, v in pairs(data) do
          self._data[k] = v
        end
      end
    end
  end

  -- initialize
  BotWeapons:init()

end

if Keepers and not BotWeapons._keepers_modified then

  local ResetLabel_original = Keepers.ResetLabel
  function Keepers:ResetLabel(unit, is_converted, icon, ...)
    return ResetLabel_original(self, unit, is_converted, BotWeapons._data.player_carry and icon == "pd2_loot" and "wp_arrow" or icon, ...)
  end

  BotWeapons._keepers_modified = true

end