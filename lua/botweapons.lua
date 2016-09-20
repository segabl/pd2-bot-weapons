if _G.BotWeapons == nil then
  _G.BotWeapons = {}
  BotWeapons._path = ModPath
  BotWeapons._data_path = SavePath .. "bot_weapons_data.txt"
  BotWeapons._data = {}

  -- load custom models
  if ModCore then
    ModCore:init(BotWeapons._path .. "config.xml", true, true)
  end
  
  BotWeapons.armor_ids = {
    "bm_armor_level_1",
    "bm_armor_level_2",
    "bm_armor_level_3",
    "bm_armor_level_4",
    "bm_armor_level_5",
    "bm_armor_level_6",
    "bm_armor_level_7",
    "item_random"
  }
  
  BotWeapons.armor = {
    -- suit
    { g_vest_body = false, g_vest_leg_arm = false, g_vest_neck = false, g_vest_shoulder = false, g_vest_small = false, g_vest_thies = false },
    -- light
    { g_vest_body = false, g_vest_leg_arm = false, g_vest_neck = false, g_vest_shoulder = false, g_vest_small = true, g_vest_thies = false },
    -- normal
    { g_vest_body = true, g_vest_leg_arm = false, g_vest_neck = false, g_vest_shoulder = false, g_vest_small = false, g_vest_thies = false },
    -- heavy
    { g_vest_body = true, g_vest_leg_arm = false, g_vest_neck = true, g_vest_shoulder = false, g_vest_small = false, g_vest_thies = false },
    -- flak
    { g_vest_body = true, g_vest_leg_arm = false, g_vest_neck = true, g_vest_shoulder = true, g_vest_small = false, g_vest_thies = false },
    -- combined
    { g_vest_body = true, g_vest_leg_arm = false, g_vest_neck = true, g_vest_shoulder = true, g_vest_small = false, g_vest_thies = true },
    -- ictv
    { g_vest_body = true, g_vest_leg_arm = true, g_vest_neck = true, g_vest_shoulder = true, g_vest_small = false, g_vest_thies = true }
  }
  
  BotWeapons.equipment_ids = {
    "item_none",
    "bm_equipment_ammo_bag",
    "bm_equipment_armor_kit",
    "bm_equipment_bodybags_bag",
    "bm_equipment_doctor_bag",
    "bm_equipment_ecm_jammer",
    "bm_equipment_first_aid_kit",
    "bm_equipment_sentry_gun",
    "item_random"
  }
  
  BotWeapons.equipment = {
    -- none
    { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false },
    -- ammo
    { g_ammobag = true, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false },
    -- armor
    { g_ammobag = false, g_armorbag = true, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false },
    -- bodybags
    { g_ammobag = false, g_armorbag = false, g_bodybagsbag = true, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = false },
    -- doctor
    { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = true, g_sentrybag = false, g_toolbag = false },
    -- ecm
    { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = false, g_toolbag = true },
    -- firstaid
    { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = true, g_medicbag = false, g_sentrybag = false, g_toolbag = false },
    -- sentry
    { g_ammobag = false, g_armorbag = false, g_bodybagsbag = false, g_firstaidbag = false, g_medicbag = false, g_sentrybag = true, g_toolbag = false }
  }
  
  BotWeapons.weapon_ids = {
    "item_beretta92",
    "item_c45",
    "item_raging_bull",
    "item_m4",
    "item_ak47",
    "item_r870",
    "item_mossberg",
    "item_mp5",
    "item_mp5_tactical",
    "item_mp9",
    "item_mac11",
    "item_m249",
    "item_benelli",
    "item_g36",
    "item_ump",
    "item_scar_murky",
    "item_asval",
    "item_sr2",
    "item_akmsu",
    "item_rpk",
    -- weapons disabled in mp from here on
    "item_saiga",
    -- own weapons from here on
    "item_famas",
    "item_m14",
    "item_p90",
    "item_judge",
    "item_boot",
    "item_x_c45",
    "item_x_mp5",
    "item_x_akmsu",
    "item_ksg",
    "item_l85a2",
    "item_sterling",
    "item_s552",
    "item_deagle",
    "item_x_sr2",
    "item_hk21",
    "item_tecci",
    -- random
    "item_random"
  }

  BotWeapons.weapons = {
    Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92"),
    Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45"),
    Idstring("units/payday2/weapons/wpn_npc_raging_bull/wpn_npc_raging_bull"),
    Idstring("units/payday2/weapons/wpn_npc_m4/wpn_npc_m4"),
    Idstring("units/payday2/weapons/wpn_npc_ak47/wpn_npc_ak47"),
    Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870"),
    Idstring("units/payday2/weapons/wpn_npc_sawnoff_shotgun/wpn_npc_sawnoff_shotgun"),
    Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5"),
    Idstring("units/payday2/weapons/wpn_npc_mp5_tactical/wpn_npc_mp5_tactical"),
    Idstring("units/payday2/weapons/wpn_npc_smg_mp9/wpn_npc_smg_mp9"),
    Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11"),
    Idstring("units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249"),
    Idstring("units/payday2/weapons/wpn_npc_benelli/wpn_npc_benelli"),
    Idstring("units/payday2/weapons/wpn_npc_g36/wpn_npc_g36"),
    Idstring("units/payday2/weapons/wpn_npc_ump/wpn_npc_ump"),
    Idstring("units/payday2/weapons/wpn_npc_scar_murkywater/wpn_npc_scar_murkywater"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_sr2/wpn_npc_sr2"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_akmsu/wpn_npc_akmsu"),
    Idstring("units/pd2_dlc_mad/weapons/wpn_npc_rpk/wpn_npc_rpk"),
    -- weapons disabled in mp from here on
    Idstring("units/payday2/weapons/wpn_npc_saiga/wpn_npc_saiga"),
    -- own weapons from here on
    Idstring("units/payday2/weapons/wpn_npc_famas/wpn_npc_famas"),
    Idstring("units/payday2/weapons/wpn_npc_m14/wpn_npc_m14"),
    Idstring("units/payday2/weapons/wpn_npc_p90/wpn_npc_p90"),
    Idstring("units/payday2/weapons/wpn_npc_judge/wpn_npc_judge"),
    Idstring("units/payday2/weapons/wpn_npc_boot/wpn_npc_boot"),
    Idstring("units/payday2/weapons/wpn_npc_x_c45/wpn_npc_x_c45"),
    Idstring("units/payday2/weapons/wpn_npc_x_mp5/wpn_npc_x_mp5"),
    Idstring("units/payday2/weapons/wpn_npc_x_akmsu/wpn_npc_x_akmsu"),
    Idstring("units/payday2/weapons/wpn_npc_ksg/wpn_npc_ksg"),
    Idstring("units/payday2/weapons/wpn_npc_l85a2/wpn_npc_l85a2"),
    Idstring("units/payday2/weapons/wpn_npc_sterling/wpn_npc_sterling"),
    Idstring("units/payday2/weapons/wpn_npc_s552/wpn_npc_s552"),
    Idstring("units/payday2/weapons/wpn_npc_deagle/wpn_npc_deagle"),
    Idstring("units/payday2/weapons/wpn_npc_x_sr2/wpn_npc_x_sr2"),
    Idstring("units/payday2/weapons/wpn_npc_hk21/wpn_npc_hk21"),
    Idstring("units/payday2/weapons/wpn_npc_tecci/wpn_npc_tecci")
  }
  
  -- maybe do something with this in the future :P
  BotWeapons.pistols = { 1, 2, 3, 34 }
  BotWeapons.rifles = { 4, 5, 14, 16, 17, 22, 23, 31, 33, 37 }
  BotWeapons.smgs = { 8, 9, 10, 11, 15, 18, 19, 24, 32 }
  BotWeapons.shotguns = { 6, 7, 13, 21, 25, 26, 30 }
  BotWeapons.lmgs = { 12, 20, 36 }
  BotWeapons.akimbos = { 27, 28, 29, 35 }
  
  BotWeapons.mp_disabled_index = 20
  
  -- difficulty multiplier
  BotWeapons.multiplier = {
    normal = 0.4,
    hard = 0.6,
    overkill = 0.8,
    overkill_145 = 1,
    overkill_290 = 1
  }
  
  function BotWeapons:Save()
    local file = io.open(self._data_path, "w+")
    if file then
      file:write(json.encode(self._data))
      file:close()
    end
  end

  function BotWeapons:Load()
    local file = io.open(self._data_path, "r")
    if file then
      self._data = json.decode(file:read("*all"))
      file:close()
    end
  end
   
  -- Load settings
  BotWeapons:Load()
end