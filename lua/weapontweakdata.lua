local _create_table_structureORIG = WeaponTweakData._create_table_structure

function WeaponTweakData:_create_table_structure()
  log("[BotWeapons] Setting up additional npc weapon usages")
  _create_table_structureORIG(self)
  
  self.g36_npc.usage = "g36"
  self.m249_npc.usage = "m249"
  self.scar_npc.usage = "scar"
end

function WeaponTweakData:_init_data_boot_npc()
  self.boot_npc = deep_clone(self.r870_npc)
  self.boot_npc.sounds.prefix = "boot_npc"
end

function WeaponTweakData:_init_data_famas_npc()
  self.famas_npc = deep_clone(self.ak47_npc)
  self.famas_npc.sounds.prefix = "famas_npc"
  self.famas_npc.auto.fire_rate = 0.15
end

function WeaponTweakData:_init_data_m14_npc()
  self.m14_npc.sounds.prefix = "m14_npc"
  self.m14_npc.use_data.selection_index = 2
  self.m14_npc.DAMAGE = 4
  self.m14_npc.muzzleflash = "effects/payday2/particles/weapons/762_auto"
  self.m14_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
  self.m14_npc.CLIP_AMMO_MAX = 10
  self.m14_npc.NR_CLIPS_MAX = 8
  self.m14_npc.auto.fire_rate = 0.3
  self.m14_npc.hold = "rifle"
  self.m14_npc.alert_size = 5000
  self.m14_npc.suppression = 2
  self.m14_npc.usage = "m14"
end

function WeaponTweakData:_init_data_judge_npc()
  self.judge_npc.sounds.prefix = "judge_npc"
  self.judge_npc.use_data.selection_index = 1
  self.judge_npc.DAMAGE = 4
  self.judge_npc.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
  self.judge_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug_semi"
  self.judge_npc.CLIP_AMMO_MAX = 6
  self.judge_npc.NR_CLIPS_MAX = 8
  self.judge_npc.hold = "pistol"
  self.judge_npc.alert_size = 5000
  self.judge_npc.suppression = 1.8
  self.judge_npc.is_shotgun = true
  self.judge_npc.auto = nil
  self.judge_npc.usage = "judge"
end

function WeaponTweakData:_init_data_x_c45_npc()
  self.x_c45_npc.sounds.prefix = "c45_npc"
  self.x_c45_npc.use_data.selection_index = 1
  self.x_c45_npc.DAMAGE = 1
  self.x_c45_npc.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
  self.x_c45_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
  self.x_c45_npc.CLIP_AMMO_MAX = 26
  self.x_c45_npc.NR_CLIPS_MAX = 5
  self.x_c45_npc.hold = "akimbo_pistol"
  self.x_c45_npc.alert_size = 2500
  self.x_c45_npc.suppression = 1
end

function WeaponTweakData:_init_data_x_mp5_npc()
  self.x_mp5_npc.sounds.prefix = "mp5_x_npc"
  self.x_mp5_npc.use_data.selection_index = 2
  self.x_mp5_npc.DAMAGE = 1
  self.x_mp5_npc.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
  self.x_mp5_npc.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
  self.x_mp5_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
  self.x_mp5_npc.CLIP_AMMO_MAX = 60
  self.x_mp5_npc.NR_CLIPS_MAX = 5
  self.x_mp5_npc.auto = { fire_rate = 0.12 }
  self.x_mp5_npc.hold = "akimbo_pistol"
  self.x_mp5_npc.alert_size = 1800
  self.x_mp5_npc.suppression = 2
  self.x_mp5_npc.usage = "akimbo_auto"
end

function WeaponTweakData:_init_data_x_akmsu_npc()
  self.x_akmsu_npc = deep_clone(self.x_mp5_npc)
  self.x_akmsu_npc.sounds.prefix = "akmsu_x_npc"
end

function WeaponTweakData:_init_data_ksg_npc()
  self.ksg_npc = deep_clone(self.r870_npc)
  self.ksg_npc.sounds.prefix = "keltec_npc"
  self.ksg_npc.has_suppressor = "suppressed_a"
end

function WeaponTweakData:_init_data_l85a2_npc()
  self.l85a2_npc = deep_clone(self.m4_npc)
  self.l85a2_npc.sounds.prefix = "l85_npc"
end

function WeaponTweakData:_init_data_sterling_npc()
  self.sterling_npc = deep_clone(self.mp5_npc)
  self.sterling_npc.sounds.prefix = "sterling_npc"
  self.sterling_npc.CLIP_AMMO_MAX = 40
  self.sterling_npc.auto.fire_rate = 0.4
  self.sterling_npc.hold = "pistol"
end

function WeaponTweakData:_init_data_s552_npc()
  self.s552_npc = deep_clone(self.m4_npc)
  self.s552_npc.sounds.prefix = "sig552_npc"
  self.s552_secondary_npc = deep_clone(self.s552_npc)
  self.s552_secondary_npc.use_data.selection_index = 1
end