-- Native operation paired with each manufacturing demonstration.
return {
  ["thermal-smelting"] = { { kind = "thermal" } },
  robotics = { { kind = "robots" } },
  ["robot-network-expansion"] = { { kind = "robots", port = "j_yi_roboport1" } },
  ["robot-production"] = { { kind = "robots" } },
  ["advanced-robotics"] = { { kind = "robots", robot = "j_construction2-robot" } },
  ["expanded-storage"] = { { kind = "chest", entity = "y_c22" } },
  ["large-storage"] = { { kind = "chest", entity = "y_cg33" } },
  ["bulk-storage"] = { { kind = "chest", entity = "y_sc44" } },
  ["logistic-storage"] = {
    { kind = "robots", provider = "j-dl-provider", port = "roboport", robot = "construction-robot" },
    { kind = "robots", provider = "y-rare-chest-log", port = "roboport", robot = "construction-robot" },
  },
  ["logistic-provider-capacity"] = {
    { kind = "robots", provider = "y_pc22", port = "roboport", robot = "construction-robot" },
  },
  ["logistic-bunker"] = {
    { kind = "robots", provider = "y-rare-m1bunker-log", port = "roboport", robot = "construction-robot" },
  },
  ["logistic-requests"] = {
    { kind = "robots", requester = "j-dl-request" },
    { kind = "robots", requester = "j-dl-buffer" },
  },
  ["wide-logistic-requests"] = { { kind = "robots", requester = "y_rc22" }, { kind = "robots", requester = "y_bc22" } },
  ["air-scrubbing"] = { { kind = "scrubbing" } },
  ["air-filters"] = { { kind = "filters" } },
  ["briefing"] = {
    { kind = "landscape" },
  },
  ["bootstrap"] = {
    { kind = "mining" },
    { kind = "mining", rock = true },
    { kind = "water" },
  },
  ["industrial-science"] = { { kind = "mining", rock = true } },
  ["unicomp"] = {
    { kind = "water" },
    { kind = "disposal" },
  },
  ["foundation"] = {
    { kind = "foundation" },
  },
  ["endgame"] = {
    { kind = "research" },
  },
  ["power"] = {
    { kind = "power", entity = "y-notfall-generator-s2" },
    { kind = "power", entity = "y_bg-1" },
  },
  ["engines"] = {
    { kind = "mf" },
    { kind = "tank", entity = "y_flowcheck_10" },
  },
  ["logistics"] = {
    { kind = "transport", entity = "y-inserter-fast" },
    { kind = "transport", entity = "y-inserter-s4" },
  },
  ["defense"] = {
    { kind = "turret", entity = "y_turret_gun1f12", ammo = "yi_cannon_shell" },
  },
  ["energy-storage"] = {
    { kind = "storage", entity = "y-accumulator-m" },
  },
  ["advanced-storage"] = {
    { kind = "storage", entity = "y-accumulator-b-t2" },
    { kind = "storage", entity = "y-accumulator-m-t2" },
  },
  ["quantum-power"] = {
    { kind = "storage", entity = "y-accumulator-b-tx" },
    { kind = "storage", entity = "y-accumulator-crystal-m" },
    { kind = "power", entity = "y-obninsk-turbine" },
    { kind = "power", entity = "y_alien_solar2" },
  },
  ["advanced-logistics"] = {
    { kind = "transport", entity = "y-inserter-smart" },
    { kind = "transport", entity = "y-inserter-smart-long" },
    { kind = "transport", entity = "y_inserter_diagonal" },
    { kind = "transport", entity = "y_inserter_evade_shortL" },
    { kind = "transport", entity = "y_inserter_evade_shortR" },
    { kind = "transport", entity = "y_inserter_smart_LL" },
    { kind = "transport", entity = "y_inserter_smart_RR" },
    { kind = "transport", entity = "y_inserter_smart_leftR2" },
    { kind = "transport", entity = "y_inserter_smart_rightR2" },
  },
  ["advanced-defense"] = {
    { kind = "turret", entity = "y_turret_gun2f12", ammo = "y-ammo-biggun" },
  },
  ["powered-armor"] = {
    { kind = "equipment", entity = "yi_armor_gray" },
  },
  ["armor-2"] = {
    { kind = "equipment", entity = "yi_armor_red", shield = "yi_equip_shield_b" },
  },
  ["armor-3"] = {
    { kind = "equipment", entity = "yi_armor_gold" },
  },
  ["walker-1"] = {
    { kind = "equipment", entity = "yi_walker_a", generator = "yi_equip_generator_a" },
  },
  ["walker-2"] = {
    { kind = "equipment", entity = "yi_walker_c", generator = "yi_equip_generator_a" },
  },
  ["advanced-generation"] = {
    { kind = "power", entity = "y-seg" },
  },
  ["plant-infrastructure"] = {
    { kind = "tank", entity = "y-tank-1000" },
  },
  ["solar-dish"] = {
    { kind = "power", entity = "y-stirling-solar-dish" },
  },
  ["solar-collector"] = {
    { kind = "power", entity = "y_alien_solar" },
  },
  ["accumulator-capacity"] = {
    { kind = "storage", entity = "y-accumulator-b" },
  },
  ["flywheel-storage"] = {
    { kind = "storage", entity = "y-ups-flywheel-b" },
  },
  ["high-flow-storage"] = {
    { kind = "storage", entity = "y_compensator_25" },
  },
  ["medium-generation"] = {
    { kind = "power", entity = "y-meg-s" },
  },
  ["big-generation"] = {
    { kind = "power", entity = "y-beg" },
  },
  ["huge-generation"] = {
    { kind = "power", entity = "y-heg" },
  },
  ["high-capacity-boiler"] = {
    { kind = "boiler", entity = "y-boiler-iv" },
  },
  ["high-pressure-steam-turbine"] = {
    { kind = "power", entity = "y-steam-turbine" },
  },
  ["high-temperature-generation"] = {
    { kind = "power", entity = "ye_tfmw_generator-s" },
    { kind = "power", entity = "ye_tfmw_turbine-s" },
  },
  ["laser-turret"] = {
    { kind = "turret", entity = "y_turret_laser22f12" },
  },
  ["plasma-weapons"] = {
    { kind = "turret", entity = "y_turret_plasma", ammo = "y_ammo_plasma" },
  },
  ["chemical-weapons"] = {
    { kind = "turret", entity = "y_turret_flame", ammo = "y_ammo_flame" },
  },
  ["zero-time-weapon"] = {
    { kind = "turret", entity = "y-weapon-ztt" },
  },
  ["fluid-storage-50k"] = {
    { kind = "tank", entity = "y-tank-4500" },
  },
  ["fluid-storage-80k"] = {
    { kind = "tank", entity = "y-tank-8000" },
  },
}
