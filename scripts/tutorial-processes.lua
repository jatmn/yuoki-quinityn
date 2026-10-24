-- Explicit recipe demonstrations for issue #24. Quantities come from live prototypes.
return {
  ["cimota-resources"] = {
    technology = "quinityn-cimota-resources",
    steps = {
      { "y-atomic-constructor", "y-ac-y-res12uc" },
      { "y-atomic-constructor", "y-ac-uc2y-res1" },
      { "y-atomic-constructor", "y-ac-y-res22uc" },
      { "y-atomic-constructor", "y-ac-uc2y-res2" },
      { "y-atomic-constructor", "y-ac-uranium-ore2uc" },
      { "y-atomic-constructor", "y-ac-uc2uranium-ore" },
    },
  },
  ["cimota-fluids"] = {
    technology = "quinityn-cimota-fluids",
    steps = {
      { "y-atomic-constructor", "y-heavyoil2uc" },
      { "y-atomic-constructor", "y-lightoil2uc" },
      { "y-atomic-constructor", "y-lubricant2uc" },
      { "y-atomic-constructor", "y-petroleum" },
      { "y-atomic-constructor", "y-uc2liquid" },
      { "y-atomic-constructor", "y-ac-uc2plastic" },
    },
  },
  ["cimota-residues"] = {
    technology = "quinityn-cimota-residues",
    steps = {
      { "y-atomic-constructor", "j-cw2uc-recipe" },
      { "y-atomic-constructor", "y-ac-crystal2uc" },
      { "y-atomic-constructor", "y-ac-mud2uc" },
      { "y-atomic-constructor", "y-ac-slag2uc" },
      { "y-atomic-constructor", "y-ac-toxic2uc" },
    },
  },
  ["cimota-vulcanus"] = {
    technology = "quinityn-cimota-vulcanus",
    steps = {
      { "y-atomic-constructor", "y-ac-calcite2uc" },
      { "y-atomic-constructor", "y-ac-uc2calcite" },
      { "y-atomic-constructor", "y-ac-tungsten-ore2uc" },
      { "y-atomic-constructor", "y-ac-uc2tungsten-ore" },
    },
  },
  ["cimota-fulgora"] = {
    technology = "quinityn-cimota-fulgora",
    steps = {
      { "y-atomic-constructor", "y-ac-holmium-ore2uc" },
      { "y-atomic-constructor", "y-ac-uc2holmium-ore" },
      { "y-atomic-constructor", "y-ac-scrap2uc" },
      { "y-atomic-constructor", "y-ac-uc2scrap" },
    },
  },
  briefing = { technology = "planet-discovery-quinityn", steps = {} },
  bootstrap = {
    technology = "quinityn-arrival",
    steps = {
      { "character", "quinityn-hand-sort" },
      { "character", "quinityn-iron" },
      { "character", "quinityn-copper" },
      { "character", "quinityn-carbon" },
      { "character", "quinityn-stone" },
      { "character", "quinityn-timber" },
      { "character", "quinityn-burner-separator" },
    },
  },
  unicomp = { technology = "quinityn-arrival", steps = {} },
  ["materials"] = {
    technology = "quinityn-materials",
    steps = {
      { "y-crusher", "quinityn-hand-sort", 3 },
      { "y-crusher", "y-crush-unicomp-raw" },
      { "y-crusher", "y-crush-fuel-raw" },
    },
  },
  ["power"] = {
    technology = "quinityn-power",
    steps = {
      { "y-heat-form-press", "y-coal-brikett" },
      { "y-crusher", "y-coal-dust" },
      { "assembling-machine-2", "y-heat-pipe" },
      { "assembling-machine-2", "y-notfall-generator-s2" },
      { "assembling-machine-2", "y-wooden-brikett" },
      { "assembling-machine-2", "y_bg-1" },
    },
  },
  ["cimota"] = {
    technology = "quinityn-cimota",
    steps = {
      { "assembling-machine-2", "y-atomic-constructor" },
      { "y-atomic-constructor", "y-liquid2uc" },
      { "y-atomic-constructor", "y-ac-stone2uc" },
      { "y-atomic-constructor", "y-ac-wood2uc" },
      { "y-atomic-constructor", "y-ac-uc2coal" },
      { "y-atomic-constructor", "y-ac-uc2iron-ore" },
      { "y-atomic-constructor", "y-ac-uc2copper-ore" },
      { "y-atomic-constructor", "y-ac-uc2wood" },
      { "y-atomic-constructor", "y-uc2crudeoil" },
    },
  },
  ["engines"] = {
    technology = "quinityn-engines",
    steps = {
      { "assembling-machine-2", "y-1stirling-engine" },
      { "y-sfe", "y-mf1a" },
      { "y-sfe", "y-mf1a1" },
      { "y-sfe", "y-mf1f" },
      { "assembling-machine-2", "y-mftrans-shaft" },
      { "assembling-machine-2", "y-mftrans-shaft-ground" },
      { "assembling-machine-2", "y-mftrans-shaft-ground-red" },
      { "assembling-machine-2", "y-mftrans-shaft-red" },
      { "y-mwater-pump", "y-mfwater" },
      { "assembling-machine-2", "y-mwater-pump" },
      { "assembling-machine-2", "y-sfe" },
      { "assembling-machine-2", "y-waste-condense" },
      { "assembling-machine-2", "y_flowcheck_10" },
      { "assembling-machine-2", "y_gauge_analog" },
      { "chemical-plant", "y_mixedfuel2rocketfuel" },
      { "assembling-machine-2", "ye_tranport_tube_orange" },
      { "assembling-machine-2", "ye_tranport_tube_orange_splitter" },
      { "assembling-machine-2", "ye_tranport_tube_orange_underground" },
    },
  },
  ["refining"] = {
    technology = "quinityn-refining",
    steps = {
      { "y-dirtwasher", "y-sulfuric-acid" },
      { "assembling-machine-2", "y-water-gen" },
      { "y-water-gen", "y-water-gen-fluid" },
      { "assembling-machine-2", "y_catalyst_bp" },
      { "assembling-machine-2", "y_catalyst_ft" },
      { "chemical-plant", "y_coal2liquid" },
      { "chemical-plant", "y_ft" },
      { "y-crusher", "y_granulate_wood" },
      { "chemical-plant", "y_rawsyngas1" },
      { "chemical-plant", "y_rawsyngas2" },
      { "chemical-plant", "y_refinehydrogen" },
      { "chemical-plant", "y_regcatbp" },
      { "chemical-plant", "y_regcatft" },
    },
  },
  ["foundation"] = {
    technology = "quinityn-foundation",
    steps = {
      { "y-heat-form-press", "quinityn-foundation" },
    },
  },
  ["logistics"] = {
    technology = "quinityn-logistics",
    steps = {
      { "assembling-machine-2", "y-inserter-fast" },
      { "assembling-machine-2", "y-inserter-s4" },
      { "assembling-machine-2", "y_sc11" },
    },
  },
  ["defense"] = {
    technology = "quinityn-defense",
    steps = {
      { "y-heat-form-press", "y-bullet-case" },
      { "assembling-machine-2", "y-mud-wall" },
      { "assembling-machine-2", "y_turret_gun1f12" },
      { "assembling-machine-2", "y_wood_wall" },
      { "assembling-machine-2", "yi_cannon_shell" },
    },
  },
  ["quantum"] = {
    technology = "quinityn-quantum",
    steps = {
      { "assembling-machine-2", "y-atomic-quantum-composer" },
      { "y-atomic-quantum-composer", "y-quantrinum" },
      { "y-atomic-quantum-composer", "y-crystal-cnd" },
      { "y-atomic-quantum-composer", "y_data_crystal" },
      { "y-atomic-quantum-composer", "yi_radar" },
      { "assembling-machine-2", "yi-monument1" },
      { "assembling-machine-2", "y_repair_quantrinum" },
    },
  },
  ["orbital"] = {
    technology = "quinityn-orbital",
    steps = {
      { "assembling-machine-2", "quinityn-low-density-structure" },
      { "assembling-machine-2", "quinityn-processing-unit" },
      { "assembling-machine-2", "y-waste-condense" },
      { "chemical-plant", "y_mixedfuel2rocketfuel" },
    },
  },
  ["endgame"] = {
    technology = "quinityn-mastery",
    requires = { "quinityn-orbital", "production-science-pack", "utility-science-pack", "space-science-pack" },
    steps = {
      { "ye_fassembly1", "quinityn-technic-sign" },
      { "ye_fassembly1", "quinityn-research-data" },
    },
  },
  ["pressing"] = {
    technology = "quinityn-pressing",
    steps = {
      { "assembling-machine-2", "y-heat-form-press" },
      { "y-heat-form-press", "y-smelt-crush-res1" },
      { "y-heat-form-press", "y-smelt-crush-res2" },
    },
  },
  ["compacting"] = {
    technology = "quinityn-compacting",
    steps = {
      { "y-heat-form-press", "y-raw-fuelnium" },
      { "y-heat-form-press", "y-unicomp-raw" },
    },
  },
  ["alloying"] = {
    technology = "quinityn-alloying",
    steps = {
      { "assembling-machine-2", "y-mixing-rich" },
      { "stone-furnace", "y-orange-stuff" },
    },
  },
  ["structures"] = {
    technology = "quinityn-structures",
    steps = {
      { "assembling-machine-2", "y-bluegear" },
      { "assembling-machine-2", "y_structure_element" },
      { "assembling-machine-2", "y_structure_vessel" },
    },
  },
  ["electronics"] = {
    technology = "quinityn-electronics",
    steps = {
      { "assembling-machine-2", "y-chip-1" },
      { "assembling-machine-2", "y-conductive-wire-1" },
      { "assembling-machine-2", "y_chip_plate" },
    },
  },
  ["fuel-processing"] = {
    technology = "quinityn-fuel-processing",
    steps = {
      { "assembling-machine-2", "y-fuel-reactor" },
    },
  },
  ["basic-factory"] = {
    technology = "quinityn-basic-factory",
    steps = {
      { "assembling-machine-2", "y-basic-t1-mf" },
      { "assembling-machine-2", "ye_fassembly1" },
    },
  },
  ["industrial-science"] = {
    technology = "quinityn-industrial-science",
    steps = {},
  },
  ["science-production"] = {
    technology = "quinityn-industrial-science",
    requires = { "quinityn-basic-factory" },
    steps = {
      { "ye_fassembly1", "quinityn-technic-sign" },
      { "ye_fassembly1", "quinityn-research-data" },
    },
  },
  ["air-scrubbing"] = {
    technology = "quinityn-air-scrubbing",
    steps = {
      { "assembling-machine-2", "y-emotor-s" },
      { "y-emotor-s", "y-mf1c" },
      { "assembling-machine-2", "y-electric-air-heater" },
      { "y-electric-air-heater", "y-rmvpol" },
    },
  },
  ["air-filters"] = {
    technology = "quinityn-air-filters",
    steps = {
      { "assembling-machine-2", "j-airfilter" },
      { "y-electric-air-heater", "j-airfilter_dirty" },
      { "y-dirtwasher", "j-airfilter_cleaning" },
    },
  },
  ["excavation"] = {
    technology = "quinityn-excavation",
    steps = {
      { "y-underground-drill", "y-digfdirt" },
      { "assembling-machine-2", "y-mining-drill-e2" },
      { "assembling-machine-2", "y-underground-drill" },
    },
  },
  ["washing"] = {
    technology = "quinityn-washing",
    steps = {
      { "assembling-machine-2", "y-dirtwasher" },
      { "y-dirtwasher", "y-pure-iron" },
      { "y-dirtwasher", "y-pure-copper" },
      { "stone-furnace", "y-refined-iron" },
      { "stone-furnace", "y-refined-copper" },
      { "y-heat-form-press", "y-release-cwater" },
      { "y-heat-form-press", "y-filtering-dust" },
      { "y-heat-form-press", "y-pressed_dry_mud" },
    },
  },
  ["tooling"] = {
    technology = "quinityn-tooling",
    steps = {
      { "y-crusher", "y-crush-blue_whead" },
      { "y-crusher", "y-crush-green_whead" },
      { "y-underground-drill", "y-digfdirt2" },
      { "assembling-machine-2", "y_drillhead" },
      { "y-dirtwasher", "y_pure_copper_wtool" },
      { "y-dirtwasher", "y_pure_iron_wtool" },
      { "assembling-machine-2", "y_toolhead" },
    },
  },
  ["advanced-machining"] = {
    technology = "quinityn-advanced-machining",
    steps = {
      { "assembling-machine-2", "y_crusher2" },
      { "assembling-machine-2", "y_formpress2" },
    },
  },
  ["advanced-components"] = {
    technology = "quinityn-advanced-components",
    steps = {
      { "assembling-machine-2", "y-basic-t2-mf" },
      { "assembling-machine-2", "y-chip-2" },
      { "assembling-machine-2", "y-conductive-coil-1" },
      { "y-heat-form-press", "y_block_cold" },
      { "assembling-machine-2", "y_dotzetron" },
      { "assembling-machine-2", "y_structure_electric" },
      { "assembling-machine-2", "yi_magnetron" },
    },
  },
  ["maintenance"] = {
    technology = "quinityn-maintenance",
    steps = {
      { "assembling-machine-2", "y-repair-krakon" },
      { "y_maintance_workshop", "y_drillhead_repair" },
      { "assembling-machine-2", "y_maintance_workshop" },
      { "y_maintance_workshop", "y_toolhead_repair" },
    },
  },
  ["energy-storage"] = {
    technology = "quinityn-energy-storage",
    steps = {
      { "assembling-machine-2", "y-accumulator-m" },
      { "assembling-machine-2", "y-battery-rip1" },
      { "assembling-machine-2", "y-battery-single-use1" },
      { "assembling-machine-2", "y-battery-single-use2" },
      { "assembling-machine-2", "y-battery-single-use3" },
      { "assembling-machine-2", "y_blocked_capa" },
    },
  },
  ["advanced-storage"] = {
    technology = "quinityn-advanced-storage",
    steps = {
      { "assembling-machine-2", "y-accumulator-b-t2" },
      { "assembling-machine-2", "y-accumulator-m-t2" },
    },
  },
  ["reactors"] = {
    technology = "quinityn-reactors",
    steps = {
      { "y-heat-form-press", "yi_graphite" },
      { "assembling-machine-2", "y_moxmixer" },
      { "y_moxmixer", "y_mox1mixed" },
      { "assembling-machine-2", "y-obninsk-reactor" },
      { "y-obninsk-reactor", "y_reactor_mox1" },
      { "y-dirtwasher", "y_mox1fuel" },
      { "y-obninsk-reactor", "y_reactor_mf1" },
      { "assembling-machine-2", "y-rare-wall-adv" },
    },
  },
  ["infusion"] = {
    technology = "quinityn-infusion",
    steps = {
      { "assembling-machine-2", "y-alien-infuser" },
      { "y-alien-infuser", "y-infused-mud" },
      { "y-alien-infuser", "y-infused-uca2" },
      { "y-alien-infuser", "y_quantrinum_infusion" },
    },
  },
  ["quantum-utilities"] = {
    technology = "quinityn-quantum-utilities",
    steps = {
      { "assembling-machine-2", "ye_center" },
      { "y-atomic-quantum-composer", "yi_beacon" },
    },
  },
  ["quantum-power"] = {
    technology = "quinityn-quantum-power",
    steps = {
      { "y-atomic-quantum-composer", "y-accumulator-b-tx" },
      { "y-atomic-quantum-composer", "y-accumulator-crystal-m" },
      { "y-quantrinum-reactor", "y-mf1-q1" },
      { "y-quantrinum-reactor", "y-mf1-q2" },
      { "y-quantrinum-reactor", "y-mf1-q3" },
      { "assembling-machine-2", "y-obninsk-turbine" },
      { "assembling-machine-2", "y-quantrinum-charge" },
      { "assembling-machine-2", "y-quantrinum-reactor" },
      { "assembling-machine-2", "y-substation-h" },
      { "assembling-machine-2", "y_alien_solar2" },
      { "y-dirtwasher", "y_mox2fuel" },
      { "y-atomic-quantum-composer", "y_mox2fuelsplited" },
      { "y_moxmixer", "y_mox2mixed" },
      { "y-obninsk-reactor", "y_reactor_mox2" },
      { "ye_rheinsberg", "ye_rheins_HT" },
      { "ye_rheinsberg", "ye_rheins_LT" },
      { "ye_rheinsberg", "ye_rheins_MT" },
      { "assembling-machine-2", "ye_rheinsberg" },
    },
  },
  ["fluid-handling"] = {
    technology = "quinityn-fluid-handling",
    steps = {
      { "assembling-machine-2", "ye_can_co_empty" },
      { "assembling-machine-2", "ye_can_eth_empty" },
      { "assembling-machine-2", "ye_can_ho_empty" },
      { "assembling-machine-2", "ye_can_lub_empty" },
      { "assembling-machine-2", "ye_can_mf_empty" },
      { "assembling-machine-2", "ye_can_petrol_empty" },
      { "assembling-machine-2", "ye_can_sa_empty" },
      { "assembling-machine-2", "ye_can_uc_empty" },
      { "ye_canmachine", "ye_canister" },
      { "stone-furnace", "ye_canister2plates_smelt" },
      { "assembling-machine-2", "ye_canmachine" },
      { "assembling-machine-2", "ye_ice_container_empty" },
      { "ye_icemaker", "ye_ice_container_filled" },
      { "assembling-machine-2", "ye_icemaker" },
      { "ye_canmachine", "ye_sealing" },
    },
  },
  ["advanced-factories"] = {
    technology = "quinityn-advanced-factories",
    requires_any = { "quinityn-quantum", "quinityn-utility-science" },
    steps = {
      { "assembling-machine-2", "ye_fassembly2" },
      { "ye_fassembly2", "quinityn-research-data" },
    },
  },
  ["p3-factory"] = {
    technology = "quinityn-p3-factory",
    steps = {
      { "assembling-machine-2", "ye_fassembly_sp" },
      { "ye_fassembly_sp", "quinityn-research-data" },
    },
  },
  ["research-center"] = {
    technology = "quinityn-research-center",
    steps = {
      { "yie_science_blue_gen", "ye_science_blue" },
      { "assembling-machine-2", "yie_science_blue_gen" },
    },
  },
  ["advanced-engines"] = {
    technology = "quinityn-advanced-engines",
    steps = {
      { "assembling-machine-2", "y-ffe" },
      { "y-ffe", "y-mf2a" },
      { "y-ffe", "y-mf2b" },
      { "ye_gasmotor", "y-mf2c" },
      { "ye_gasmotor", "y-mf2d" },
      { "y-ffe", "y-mf2e" },
      { "assembling-machine-2", "ye_gasmotor" },
    },
  },
  ["advanced-transmission"] = {
    technology = "quinityn-advanced-transmission",
    steps = {
      { "y-heat-form-press", "ye_buechsenblech" },
      { "foundry", "ye_tranport_tube_green" },
      { "foundry", "ye_tranport_tube_green_splitter" },
      { "foundry", "ye_tranport_tube_green_underground" },
    },
  },
  ["crystal-processing"] = {
    technology = "quinityn-crystal-processing",
    steps = {
      { "assembling-machine-2", "y_mixer_emu" },
      { "assembling-machine-2", "y_hppump" },
      { "assembling-machine-2", "y_crystalizer" },
      { "assembling-machine-2", "y_trockner" },
      { "y_mixer_emu", "y_emulsion" },
      { "y_hppump", "y_richemulsion" },
      { "y_trockner", "y_crystal_dust" },
      { "y_crystalizer", "y_chunks1" },
      { "y_crystalizer", "y_chunks2" },
    },
  },
  ["advanced-logistics"] = {
    technology = "quinityn-advanced-logistics",
    steps = {
      { "assembling-machine-2", "y-inserter-smart" },
      { "assembling-machine-2", "y-inserter-smart-long" },
      { "assembling-machine-2", "y_inserter_diagonal" },
      { "assembling-machine-2", "y_inserter_evade_shortL" },
      { "assembling-machine-2", "y_inserter_evade_shortR" },
      { "assembling-machine-2", "y_inserter_smart_LL" },
      { "assembling-machine-2", "y_inserter_smart_RR" },
      { "assembling-machine-2", "y_inserter_smart_leftR2" },
      { "assembling-machine-2", "y_inserter_smart_rightR2" },
    },
  },
  ["robotics"] = {
    technology = "quinityn-robotics",
    steps = {
      { "assembling-machine-2", "yi_construction-robot" },
      { "assembling-machine-2", "yi_logistic-robot" },
      { "y-atomic-quantum-composer", "yi_roboport" },
    },
  },
  ["robot-network-expansion"] = {
    technology = "quinityn-robot-network-expansion",
    steps = {
      { "y-atomic-quantum-composer", "j_yi_roboport1" },
    },
  },
  ["robot-production"] = {
    technology = "quinityn-robot-production",
    steps = {
      { "assembling-machine-2", "yi_logistic-robot" },
    },
  },
  ["advanced-robotics"] = {
    technology = "quinityn-advanced-robotics",
    steps = {
      { "assembling-machine-2", "j_construction2-robot" },
      { "assembling-machine-2", "j_logistic2-robot" },
    },
  },
  ["advanced-defense"] = {
    technology = "quinityn-advanced-defense",
    steps = {
      { "assembling-machine-2", "y-ammo-acid-2" },
      { "assembling-machine-2", "y-ammo-biggun" },
      { "assembling-machine-2", "y-ammo-explosiv" },
      { "assembling-machine-2", "y-ammo-hohlspitz" },
      { "assembling-machine-2", "y-ammo-krakon" },
      { "assembling-machine-2", "y-ammo-poison" },
      { "assembling-machine-2", "y_turret_gun2f12" },
    },
  },
  ["powered-armor"] = {
    technology = "quinityn-powered-armor",
    steps = {
      { "assembling-machine-2", "yi_ammo_energie" },
      { "assembling-machine-2", "yi_armor_gray" },
      { "y-atomic-quantum-composer", "yi_equip_battery_a" },
      { "y-atomic-quantum-composer", "yi_equip_legs_a" },
      { "y-atomic-quantum-composer", "yi_equip_roboport" },
      { "y-atomic-quantum-composer", "yi_equip_shield_a" },
      { "y-atomic-quantum-composer", "yi_lasergun" },
      { "y-atomic-quantum-composer", "yi_minigun" },
      { "y-atomic-quantum-composer", "yi_pld_equipment" },
    },
  },
  ["armor-2"] = {
    technology = "quinityn-armor-2",
    steps = {
      { "assembling-machine-2", "yi_armor_red" },
      { "y-atomic-quantum-composer", "yi_equip_shield_b" },
    },
  },
  ["armor-3"] = {
    technology = "quinityn-armor-3",
    steps = {
      { "assembling-machine-2", "yi_armor_gold" },
    },
  },
  ["walker-1"] = {
    technology = "quinityn-walker-1",
    steps = {
      { "y-atomic-quantum-composer", "yi_equip_generator_a" },
      { "assembling-machine-2", "yi_walker_a" },
    },
  },
  ["walker-2"] = {
    technology = "quinityn-walker-2",
    steps = {
      { "assembling-machine-2", "yi_walker_c" },
    },
  },
  ["modules"] = {
    technology = "quinityn-modules",
    steps = {
      { "assembling-machine-2", "y-speed-module-1" },
    },
  },
  ["advanced-modules"] = {
    technology = "quinityn-advanced-modules",
    steps = {
      { "assembling-machine-2", "y-speed-module-2" },
    },
  },
  ["efficiency-module"] = {
    technology = "quinityn-efficiency-module",
    steps = {
      { "assembling-machine-2", "y-green-module-1" },
    },
  },
  ["advanced-efficiency-module"] = {
    technology = "quinityn-advanced-efficiency-module",
    steps = {
      { "assembling-machine-2", "y-green-module-2" },
    },
  },
  ["productivity-module"] = {
    technology = "quinityn-productivity-module",
    steps = {
      { "assembling-machine-2", "y-pink-module-1" },
    },
  },
  ["advanced-productivity-module"] = {
    technology = "quinityn-advanced-productivity-module",
    steps = {
      { "assembling-machine-2", "y-pink-module-2" },
    },
  },
  ["quantum-modules"] = {
    technology = "quinityn-quantum-modules",
    steps = {
      { "assembling-machine-2", "y-pink-module-3" },
    },
  },
  ["combined-module"] = {
    technology = "quinityn-combined-module",
    steps = {
      { "assembling-machine-2", "y_modul_red2" },
    },
  },
  ["ultimate-efficiency-module"] = {
    technology = "quinityn-ultimate-efficiency-module",
    steps = {
      { "ye_green_ultimate", "y_modul_green_op" },
    },
  },
  ["science-module"] = {
    technology = "quinityn-science-module",
    steps = {
      { "assembling-machine-2", "y_modul_science" },
    },
  },
  ["quality-module"] = {
    technology = "quinityn-quality-module",
    steps = {
      { "assembling-machine-2", "y-quality-module-1" },
    },
  },
  ["advanced-generation"] = {
    technology = "quinityn-advanced-generation",
    steps = {
      { "assembling-machine-2", "y-seg" },
    },
  },
  ["plant-infrastructure"] = {
    technology = "quinityn-plant-infrastructure",
    steps = {
      { "assembling-machine-2", "y-pipe-ec" },
      { "assembling-machine-2", "y-pipe-h" },
      { "assembling-machine-2", "y-pipe-hc" },
      { "assembling-machine-2", "y-pipe-to-ground-ec" },
      { "assembling-machine-2", "y-pipe-to-ground-hc" },
      { "assembling-machine-2", "y-pipe-v" },
      { "assembling-machine-2", "y-powerlamp" },
      { "assembling-machine-2", "y-substation-m" },
      { "assembling-machine-2", "y-tank-1000" },
      { "assembling-machine-2", "y-tinylamp" },
      { "assembling-machine-2", "y_lampe_44basement_a" },
      { "assembling-machine-2", "y_lampe_44basement_b" },
      { "assembling-machine-2", "y_lampe_66basement" },
      { "assembling-machine-2", "y_lampe_corner" },
      { "assembling-machine-2", "y_lampe_neotix" },
      { "assembling-machine-2", "y_lampe_yuoki" },
      { "assembling-machine-2", "y_signal_pole" },
      { "assembling-machine-2", "yi_pipe_green" },
      { "assembling-machine-2", "yi_pipe_underground_green" },
    },
  },
  ["compressed-fuel"] = {
    technology = "quinityn-compressed-fuel",
    steps = {
      { "y-heat-form-press", "y-coal-stack" },
    },
  },
  ["mixed-fuel"] = {
    technology = "quinityn-mixed-fuel",
    steps = {
      { "y-heat-form-press", "y-coaldust-mixing" },
      { "y-heat-form-press", "y-mixfuel-load" },
    },
  },
  ["residue-fuel"] = {
    technology = "quinityn-residue-fuel",
    steps = {
      { "y-heat-form-press", "y_mud2solidfuel" },
    },
  },
  ["field-repair"] = {
    technology = "quinityn-field-repair",
    steps = {
      { "assembling-machine-2", "y-repair-durotal" },
    },
  },
  ["solar-dish"] = {
    technology = "quinityn-solar-dish",
    steps = {
      { "assembling-machine-2", "y-stirling-solar-dish" },
    },
  },
  ["solar-collector"] = {
    technology = "quinityn-solar-collector",
    steps = {
      { "assembling-machine-2", "y_alien_solar" },
    },
  },
  ["accumulator-capacity"] = {
    technology = "quinityn-accumulator-capacity",
    steps = {
      { "assembling-machine-2", "y-accumulator-b" },
    },
  },
  ["flywheel-storage"] = {
    technology = "quinityn-flywheel-storage",
    steps = {
      { "assembling-machine-2", "y-ups-flywheel-b" },
    },
  },
  ["high-flow-storage"] = {
    technology = "quinityn-high-flow-storage",
    steps = {
      { "assembling-machine-2", "y_compensator_25" },
    },
  },
  ["medium-generation"] = {
    technology = "quinityn-medium-generation",
    steps = {
      { "assembling-machine-2", "y-meg-s" },
    },
  },
  ["big-generation"] = {
    technology = "quinityn-big-generation",
    steps = {
      { "assembling-machine-2", "y-beg" },
    },
  },
  ["huge-generation"] = {
    technology = "quinityn-huge-generation",
    steps = {
      { "assembling-machine-2", "y-heg" },
    },
  },
  ["high-capacity-boiler"] = {
    technology = "quinityn-high-capacity-boiler",
    steps = {
      { "assembling-machine-2", "y-boiler-iv" },
    },
  },
  ["high-pressure-steam-turbine"] = {
    technology = "quinityn-high-pressure-steam-turbine",
    steps = {
      { "assembling-machine-2", "y-steam-turbine" },
    },
  },
  ["electric-water"] = {
    technology = "quinityn-electric-water",
    steps = {
      { "assembling-machine-2", "y-water-gen-e" },
      { "y-water-gen-e", "y-water-gen-fluid" },
    },
  },
  ["archaeology"] = {
    technology = "quinityn-archaeology",
    steps = {
      { "y-dirtwasher", "y-wash-dirt" },
      { "y-dirtwasher", "y-wash-special" },
    },
  },
  ["unicomp-compression"] = {
    technology = "quinityn-unicomp-compression",
    steps = {
      { "y-heat-form-press", "y-press-richdust" },
    },
  },
  ["slag-materials"] = {
    technology = "quinityn-slag-materials",
    steps = {
      { "y-crusher", "y_slag_granulate" },
      { "y-heat-form-press", "y_slag_brick" },
      { "stone-furnace", "y_slag_brick_burn" },
      { "y-crusher", "y_steinmehl" },
    },
  },
  ["slag-paving"] = {
    technology = "quinityn-slag-paving",
    steps = {
      { "y-heat-form-press", "y_tile_slagbricks" },
      { "y-heat-form-press", "y_tile_slagfilled" },
      { "y-heat-form-press", "y_tile_slagpattern" },
    },
  },
  ["thermal-smelting"] = {
    technology = "quinityn-thermal-smelting",
    steps = {
      { "y-heat-form-press", "y_block_cold" },
      { "assembling-machine-2", "y_charger" },
      { "assembling-machine-2", "y_smelter" },
      { "y_charger", "y_block_heat" },
      { "y_smelter", "y_hps_pureiron" },
      { "y_smelter", "y_hps_purecopper" },
      { "y_smelter", "y_hps_steel" },
    },
  },
  ["biological-feedstock"] = {
    technology = "quinityn-biological-feedstock",
    steps = {
      { "y-crusher", "ye_biofuel" },
      { "y-crusher", "ye_granulate_corn" },
      { "y-crusher", "ye_granulate_trifitan" },
      { "y-crusher", "ye_granulate_vuger" },
    },
  },
  ["slurry-syngas"] = {
    technology = "quinityn-slurry-syngas",
    steps = {
      { "chemical-plant", "ye_slurry2ethanol" },
    },
  },
  ["foundry-melting"] = {
    technology = "quinityn-foundry-melting",
    steps = {
      { "foundry", "yi-molten-copper" },
      { "foundry", "yi-molten-iron" },
    },
  },
  ["asteroid-crushing"] = {
    technology = "quinityn-asteroid-crushing",
    steps = {
      { "crusher", "j_crushing_to_f7" },
      { "crusher", "j_crushing_to_n4" },
    },
  },
  ["medium-mf-pump"] = {
    technology = "quinityn-medium-mf-pump",
    steps = {
      { "ye_wpump_m", "y_mpump_mf" },
      { "ye_wpump_m", "y_mpump_water" },
      { "assembling-machine-2", "ye_wpump_m" },
    },
  },
  ["substrat-neutralization"] = {
    technology = "quinityn-substrat-neutralization",
    steps = {
      { "chemical-plant", "ye_neutralisatzion" },
    },
  },
  ["medium-electric-motor"] = {
    technology = "quinityn-medium-electric-motor",
    steps = {
      { "assembling-machine-2", "ye_emotor_m" },
      { "ye_emotor_m", "ye_motorm_mf" },
    },
  },
  ["mf-heat-generator"] = {
    technology = "quinityn-mf-heat-generator",
    steps = {
      { "ye_mfheatmotor_m", "ye_mf_mfheatmotor_m" },
      { "assembling-machine-2", "ye_mfheatmotor_m" },
    },
  },
  ["steam-overheating"] = {
    technology = "quinityn-steam-overheating",
    steps = {
      { "ye_overheater", "ye_makesteam" },
      { "assembling-machine-2", "ye_overheater" },
    },
  },
  ["steam-turbine"] = {
    technology = "quinityn-steam-turbine",
    steps = {
      { "ye_sturbine", "ye_steam2mf" },
      { "ye_sturbine", "ye_steam3mf" },
      { "assembling-machine-2", "ye_sturbine" },
    },
  },
  ["high-temperature-generation"] = {
    technology = "quinityn-high-temperature-generation",
    steps = {
      { "assembling-machine-2", "ye_tfmw_generator-s" },
      { "assembling-machine-2", "ye_tfmw_turbine-s" },
    },
  },
  ["expanded-storage"] = {
    technology = "quinityn-expanded-storage",
    steps = {
      { "assembling-machine-2", "y_c22" },
    },
  },
  ["large-storage"] = {
    technology = "quinityn-large-storage",
    steps = {
      { "assembling-machine-2", "y_cg33" },
    },
  },
  ["bulk-storage"] = {
    technology = "quinityn-bulk-storage",
    steps = {
      { "assembling-machine-2", "y_sc44" },
    },
  },
  ["logistic-storage"] = {
    technology = "quinityn-logistic-storage",
    steps = {
      { "assembling-machine-2", "j-dl-provider" },
      { "assembling-machine-2", "y-rare-chest-log" },
    },
  },
  ["logistic-provider-capacity"] = {
    technology = "quinityn-logistic-provider-capacity",
    steps = {
      { "assembling-machine-2", "y_pc22" },
    },
  },
  ["logistic-bunker"] = {
    technology = "quinityn-logistic-bunker",
    steps = {
      { "assembling-machine-2", "y-rare-m1bunker-log" },
    },
  },
  ["logistic-requests"] = {
    technology = "quinityn-logistic-requests",
    steps = {
      { "assembling-machine-2", "j-dl-buffer" },
      { "assembling-machine-2", "j-dl-request" },
    },
  },
  ["wide-logistic-requests"] = {
    technology = "quinityn-wide-logistic-requests",
    steps = {
      { "assembling-machine-2", "y_bc22" },
      { "assembling-machine-2", "y_rc22" },
    },
  },
  ["durotal-walls"] = {
    technology = "quinityn-durotal-walls",
    steps = {
      { "assembling-machine-2", "y-rare-wall-basic" },
    },
  },
  ["forcefield-walls"] = {
    technology = "quinityn-forcefield-walls",
    steps = {
      { "assembling-machine-2", "y-wall-forcefield" },
    },
  },
  ["hardic-walls"] = {
    technology = "quinityn-hardic-walls",
    steps = {
      { "assembling-machine-2", "y_wall22_hardic" },
    },
  },
  ["ammunition-cases"] = {
    technology = "quinityn-ammunition-cases",
    steps = {
      { "y-heat-form-press", "y_ammo_case" },
    },
  },
  ["laser-turret"] = {
    technology = "quinityn-laser-turret",
    steps = {
      { "assembling-machine-2", "y_turret_laser22f12" },
    },
  },
  ["plasma-weapons"] = {
    technology = "quinityn-plasma-weapons",
    steps = {
      { "assembling-machine-2", "y_ammo_plasma" },
      { "assembling-machine-2", "y_turret_plasma" },
    },
  },
  ["chemical-weapons"] = {
    technology = "quinityn-chemical-weapons",
    steps = {
      { "assembling-machine-2", "y_ammo_flame" },
      { "assembling-machine-2", "y_turret_flame" },
    },
  },
  ["poison-mines"] = {
    technology = "quinityn-poison-mines",
    steps = {
      { "assembling-machine-2", "yi_mine_impact" },
    },
  },
  ["plasma-mines"] = {
    technology = "quinityn-plasma-mines",
    steps = {
      { "assembling-machine-2", "yi_mine_plasma" },
    },
  },
  ["artillery-shells"] = {
    technology = "quinityn-artillery-shells",
    steps = {
      { "assembling-machine-2", "yi_artillery_shell" },
    },
  },
  ["zero-time-weapon"] = {
    technology = "quinityn-zero-time-weapon",
    steps = {
      { "assembling-machine-2", "y-weapon-ztt" },
    },
  },
  ["fluid-storage-50k"] = {
    technology = "quinityn-fluid-storage-50k",
    steps = {
      { "assembling-machine-2", "y-tank-4500" },
    },
  },
  ["fluid-storage-80k"] = {
    technology = "quinityn-fluid-storage-80k",
    steps = {
      { "assembling-machine-2", "y-tank-8000" },
    },
  },
  ["surplus"] = {
    technology = "quinityn-surplus",
    steps = {
      { "quinityn-burner-separator", "quinityn-stone-to-uc" },
      { "quinityn-burner-separator", "quinityn-wood-to-uc" },
      { "quinityn-burner-separator", "quinityn-uc-to-coal" },
      { "quinityn-burner-separator", "quinityn-uc-to-iron" },
      { "quinityn-burner-separator", "quinityn-uc-to-copper" },
    },
  },
  ["oil-processing"] = {
    technology = "quinityn-oil-processing",
    requires = { "oil-processing" },
    steps = {
      { "y-atomic-constructor", "y-uc2crudeoil" },
      { "oil-refinery", "basic-oil-processing" },
    },
  },
}
