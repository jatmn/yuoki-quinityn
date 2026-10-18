-- Native production/research with injected inputs and power, not a playthrough.
local progression = require("__yuoki-quinityn__/scripts/progression")
local function check(ok, message)
  assert(ok, "RESEARCH PROGRESSION TEST FAILED: " .. message)
  log("QUINITYN RESEARCH PASS: " .. message)
end
local withheld = {
  ["quinityn-advanced-factories"] = true,
  ["quinityn-p3-factory"] = true,
  ["quinityn-research-center"] = true,
  ["quinityn-robotics"] = true,
  ["quinityn-robot-network-expansion"] = true,
  ["quinityn-robot-production"] = true,
  ["quinityn-advanced-robotics"] = true,
}
local function supply(machine, recipe)
  if not machine.get_inventory(defines.inventory.crafter_input).is_empty() then
    return false
  end
  for _, p in pairs(prototypes.recipe[recipe].ingredients) do
    assert(machine.insert({ name = p.name, count = p.amount }) == p.amount, "Fixture cannot supply " .. p.name)
  end
  return true
end
local function power_storage_generation_restaging()
  local power_stayers = {
    "y-coal-dust",
    "y-coal-brikett",
    "y-wooden-brikett",
    "y-heat-pipe",
    "y-notfall-generator-s2",
    "y_bg-1",
  }
  local moved_power = {
    "y-coal-stack",
    "y-coaldust-mixing",
    "y-mixfuel-load",
    "y_mud2solidfuel",
    "y-repair-durotal",
    "y-stirling-solar-dish",
    "y_alien_solar",
    "y-steam-turbine",
    "yi_graphite",
  }
  local accumulators = {
    "y-accumulator-m",
    "y-accumulator-b",
    "y-ups-flywheel-b",
    "y_compensator_25",
    "y-accumulator-m-t2",
    "y-accumulator-b-t2",
    "y-accumulator-b-tx",
    "y-accumulator-crystal-m",
  }
  local function all_disabled(force, names)
    for _, name in ipairs(names) do
      check(not force.recipes[name].enabled, "initially locked: " .. name)
    end
  end
  local new_tiers = {
    ["quinityn-compressed-fuel"] = { "y-coal-stack" },
    ["quinityn-mixed-fuel"] = { "y-coaldust-mixing", "y-mixfuel-load" },
    ["quinityn-residue-fuel"] = { "y_mud2solidfuel" },
    ["quinityn-field-repair"] = { "y-repair-durotal" },
    ["quinityn-solar-dish"] = { "y-stirling-solar-dish" },
    ["quinityn-solar-collector"] = { "y_alien_solar" },
    ["quinityn-accumulator-capacity"] = { "y-accumulator-b" },
    ["quinityn-flywheel-storage"] = { "y-ups-flywheel-b" },
    ["quinityn-high-flow-storage"] = { "y_compensator_25" },
    ["quinityn-medium-generation"] = { "y-meg-s" },
    ["quinityn-big-generation"] = { "y-beg" },
    ["quinityn-huge-generation"] = { "y-heg" },
    ["quinityn-high-capacity-boiler"] = { "y-boiler-iv" },
    ["quinityn-high-pressure-steam-turbine"] = { "y-steam-turbine" },
    ["quinityn-electric-water"] = { "y-water-gen-e" },
  }
  local function other_new_tiers_locked(force)
    for id, recipes in pairs(new_tiers) do
      if not force.technologies[id].researched then
        for _, name in ipairs(recipes) do
          check(not force.recipes[name].enabled, "unresearched " .. id .. " leaves " .. name .. " locked")
        end
      end
    end
  end
  local fresh = game.create_force("power-restaging-fresh")
  progression.reconcile()
  all_disabled(fresh, power_stayers)
  all_disabled(fresh, moved_power)
  all_disabled(fresh, accumulators)
  fresh.technologies["quinityn-power"].researched = true
  progression.reconcile()
  for _, name in ipairs(power_stayers) do
    check(fresh.recipes[name].enabled, "power enables: " .. name)
  end
  other_new_tiers_locked(fresh)
  all_disabled(fresh, moved_power)
  all_disabled(fresh, accumulators)
  fresh.technologies["quinityn-energy-storage"].researched = true
  progression.reconcile()
  for _, name in ipairs({
    "y-battery-single-use1",
    "y-battery-single-use2",
    "y-battery-single-use3",
    "y-battery-rip1",
    "y_blocked_capa",
    "y-accumulator-m",
  }) do
    check(fresh.recipes[name].enabled, "energy storage enables: " .. name)
  end
  other_new_tiers_locked(fresh)
  check(not fresh.recipes["y-accumulator-b"].enabled, "large accumulator still locked after first storage")
  check(not fresh.recipes["y-ups-flywheel-b"].enabled, "flywheel still locked after first storage")
  check(not fresh.recipes["y_compensator_25"].enabled, "compensator still locked after first storage")
  fresh.technologies["quinityn-accumulator-capacity"].researched = true
  progression.reconcile()
  check(fresh.recipes["y-accumulator-b"].enabled, "large accumulator research enables large accumulator")
  other_new_tiers_locked(fresh)
  check(not fresh.recipes["y-ups-flywheel-b"].enabled, "flywheel still locked after large accumulator only")
  check(not fresh.recipes["y_compensator_25"].enabled, "compensator still locked after large accumulator only")
  fresh.technologies["quinityn-flywheel-storage"].researched = true
  progression.reconcile()
  check(fresh.recipes["y-ups-flywheel-b"].enabled, "flywheel research enables flywheel")
  other_new_tiers_locked(fresh)
  check(not fresh.recipes["y_compensator_25"].enabled, "compensator still locked after flywheel only")
  fresh.technologies["quinityn-high-flow-storage"].researched = true
  progression.reconcile()
  check(fresh.recipes["y_compensator_25"].enabled, "high-flow storage enables compensator")
  other_new_tiers_locked(fresh)
  local gen = game.create_force("power-restaging-generation")
  progression.reconcile()
  gen.technologies["quinityn-advanced-generation"].researched = true
  progression.reconcile()
  check(gen.recipes["y-seg"].enabled, "advanced generation enables small generator")
  for _, name in ipairs({ "y-meg-s", "y-beg", "y-heg", "y-boiler-iv", "y-water-gen-e" }) do
    check(not gen.recipes[name].enabled, "advanced generation alone leaves locked: " .. name)
  end
  other_new_tiers_locked(gen)
  local legacy = game.create_force("power-restaging-legacy")
  legacy.technologies["quinityn-power"].researched = true
  legacy.technologies["quinityn-energy-storage"].researched = true
  legacy.technologies["quinityn-advanced-generation"].researched = true
  progression.reconcile()
  check(legacy.technologies["quinityn-power"].researched, "legacy power stays researched")
  check(legacy.technologies["quinityn-energy-storage"].researched, "legacy storage stays researched")
  check(legacy.technologies["quinityn-advanced-generation"].researched, "legacy generation stays researched")
  for _, name in ipairs(power_stayers) do
    check(legacy.recipes[name].enabled, "legacy power recipes enabled: " .. name)
  end
  for _, name in ipairs(moved_power) do
    check(not legacy.recipes[name].enabled, "legacy moved power recipes disabled: " .. name)
  end
  for _, name in ipairs({
    "y-battery-single-use1",
    "y-battery-single-use2",
    "y-battery-single-use3",
    "y-battery-rip1",
    "y_blocked_capa",
    "y-accumulator-m",
    "y-seg",
  }) do
    check(legacy.recipes[name].enabled, "legacy retained recipe enabled: " .. name)
  end
  for _, name in ipairs({
    "y-accumulator-b",
    "y-ups-flywheel-b",
    "y_compensator_25",
    "y-meg-s",
    "y-beg",
    "y-heg",
    "y-boiler-iv",
    "y-water-gen-e",
  }) do
    check(not legacy.recipes[name].enabled, "legacy moved recipe disabled: " .. name)
  end
  local storage_stayers = {
    "y-battery-single-use1",
    "y-battery-single-use2",
    "y-battery-single-use3",
    "y-battery-rip1",
    "y_blocked_capa",
    "y-accumulator-m",
  }
  -- A fresh force per tier. Toggling researched on one force can leave an
  -- earlier tier researched, and the sibling check ignores researched tiers.
  local alone = 0
  for id, recipes in pairs(new_tiers) do
    alone = alone + 1
    local one = game.create_force("power-restaging-alone-" .. alone)
    one.technologies[id].researched = true
    progression.reconcile()
    check(one.technologies[id].researched, id .. " is researched on a fresh force")
    for other_id in pairs(new_tiers) do
      if other_id ~= id then
        check(not one.technologies[other_id].researched, id .. " leaves " .. other_id .. " unresearched")
      end
    end
    for _, name in ipairs(recipes) do
      check(one.recipes[name].enabled, id .. " alone enables " .. name)
    end
    other_new_tiers_locked(one)
    for _, name in ipairs(power_stayers) do
      check(not one.recipes[name].enabled, id .. " leaves power stayer locked: " .. name)
    end
    for _, name in ipairs(storage_stayers) do
      check(not one.recipes[name].enabled, id .. " leaves storage stayer locked: " .. name)
    end
    check(not one.recipes["y-seg"].enabled, id .. " leaves small generator locked")
    check(not one.recipes["yi_graphite"].enabled, id .. " leaves graphite locked")
  end
end
local function module_unlocks()
  local modules = {}
  for name, item in pairs(prototypes.item) do
    if item.type == "module" and name:sub(1, 1) == "y" then
      modules[name] = true
    end
  end
  local force = game.create_force("module-unlocks")
  local owners = {}
  for name in pairs(force.technologies) do
    for _, effect in pairs(prototypes.technology[name].effects) do
      if effect.type == "unlock-recipe" and modules[effect.recipe] then
        owners[name] = effect.recipe
      end
    end
  end
  for name, t in pairs(force.technologies) do
    if not owners[name] and not name:match("^quinityn%-bridge%-") then
      t.researched = true
    end
  end
  progression.reconcile()
  for name in pairs(modules) do
    check(not force.recipes[name].enabled, "module initially locked: " .. name)
  end
  -- Each native research unlocks just its module, independently of the others.
  for technology, recipe in pairs(owners) do
    force.technologies[technology].researched = true
    progression.reconcile()
    for name in pairs(modules) do
      check(force.recipes[name].enabled == (name == recipe), "individual " .. recipe .. " unlock: " .. name)
    end
    force.technologies[technology].researched = false
  end
  -- Simulate completed legacy bundles; moved recipes need their new researches.
  for _, name in ipairs({ "modules", "advanced-modules", "quantum-modules" }) do
    force.technologies["quinityn-" .. name].researched = true
  end
  progression.reconcile()
  local retained = { ["y-speed-module-1"] = true, ["y-speed-module-2"] = true, ["y-pink-module-3"] = true }
  for name in pairs(modules) do
    check(force.recipes[name].enabled == (retained[name] or false), "legacy module reconciliation: " .. name)
  end
  for _, name in ipairs({ "modules", "advanced-modules", "quantum-modules", "mastery" }) do
    check(force.technologies["quinityn-" .. name].researched, "completed research preserved: " .. name)
  end
end
local function defense_unlocks()
  local defense_recipes = {
    "y_wood_wall",
    "y-mud-wall",
    "y-bullet-case",
    "y_turret_gun1f12",
    "yi_cannon_shell",
    "y-rare-wall-basic",
    "y_ammo_case",
    "y-ammo-hohlspitz",
    "y-ammo-acid-2",
    "y-ammo-poison",
    "y-ammo-krakon",
    "y-ammo-explosiv",
    "y-ammo-biggun",
    "y_turret_gun2f12",
    "y-wall-forcefield",
    "y_wall22_hardic",
    "y_turret_laser22f12",
    "y_turret_plasma",
    "y_ammo_plasma",
    "y_turret_flame",
    "y_ammo_flame",
    "yi_mine_impact",
    "yi_mine_plasma",
    "yi_artillery_shell",
    "y-weapon-ztt",
    "y-rare-wall-adv",
  }
  local new_tiers = {
    ["quinityn-durotal-walls"] = true,
    ["quinityn-forcefield-walls"] = true,
    ["quinityn-hardic-walls"] = true,
    ["quinityn-ammunition-cases"] = true,
    ["quinityn-laser-turret"] = true,
    ["quinityn-plasma-weapons"] = true,
    ["quinityn-chemical-weapons"] = true,
    ["quinityn-poison-mines"] = true,
    ["quinityn-plasma-mines"] = true,
    ["quinityn-artillery-shells"] = true,
    ["quinityn-zero-time-weapon"] = true,
  }
  local tier_recipes = {
    ["quinityn-durotal-walls"] = { "y-rare-wall-basic" },
    ["quinityn-forcefield-walls"] = { "y-wall-forcefield" },
    ["quinityn-hardic-walls"] = { "y_wall22_hardic" },
    ["quinityn-ammunition-cases"] = { "y_ammo_case" },
    ["quinityn-laser-turret"] = { "y_turret_laser22f12" },
    ["quinityn-plasma-weapons"] = { "y_turret_plasma", "y_ammo_plasma" },
    ["quinityn-chemical-weapons"] = { "y_turret_flame", "y_ammo_flame" },
    ["quinityn-poison-mines"] = { "yi_mine_impact" },
    ["quinityn-plasma-mines"] = { "yi_mine_plasma" },
    ["quinityn-artillery-shells"] = { "yi_artillery_shell" },
    ["quinityn-zero-time-weapon"] = { "y-weapon-ztt" },
  }
  local force = game.create_force("defense-unlocks")
  for name, t in pairs(force.technologies) do
    if not name:match("^quinityn%-bridge%-") then
      t.researched = false
    end
  end
  local researched = {}
  local function mark(tech)
    researched[tech] = true
  end
  local function prereq_name(prereq)
    return type(prereq) == "string" and prereq or prereq.name
  end
  local function ensure_prereqs(tech)
    for _, prereq in pairs(prototypes.technology[tech].prerequisites or {}) do
      local name = prereq_name(prereq)
      if name == "concrete" or name == "artillery" then
        force.technologies[name].researched = true
      elseif name:sub(1, 9) == "quinityn-" and not researched[name] and not new_tiers[name] then
        ensure_prereqs(name)
        force.technologies[name].researched = true
        mark(name)
        progression.reconcile()
      elseif name:sub(1, 9) == "quinityn-" and new_tiers[name] and not researched[name] then
        ensure_prereqs(name)
        force.technologies[name].researched = true
        mark(name)
        progression.reconcile()
      end
    end
  end
  local function assert_new_unlocks(tech, expected)
    ensure_prereqs(tech)
    for _, name in ipairs(expected) do
      check(not force.recipes[name].enabled, tech .. " stays locked before research: " .. name)
    end
    local before = {}
    for _, name in ipairs(defense_recipes) do
      before[name] = force.recipes[name].enabled
    end
    force.technologies[tech].researched = true
    mark(tech)
    progression.reconcile()
    local newly = {}
    for _, name in ipairs(defense_recipes) do
      if force.recipes[name].enabled and not before[name] then
        newly[name] = true
      end
    end
    for _, name in ipairs(expected) do
      check(newly[name], tech .. " newly enables " .. name)
      newly[name] = nil
    end
    for name in pairs(newly) do
      check(false, tech .. " unexpectedly enabled " .. name)
    end
    for tier, recipes in pairs(tier_recipes) do
      if tier ~= tech and not researched[tier] then
        for _, name in ipairs(recipes) do
          check(not force.recipes[name].enabled, tech .. " leaves unresearched " .. tier .. " locked: " .. name)
        end
      end
    end
  end
  force.technologies["quinityn-defense"].researched = true
  mark("quinityn-defense")
  progression.reconcile()
  for _, name in ipairs({ "y_wood_wall", "y-mud-wall", "y-bullet-case", "y_turret_gun1f12", "yi_cannon_shell" }) do
    check(force.recipes[name].enabled, "defense enables " .. name)
  end
  for _, name in ipairs(defense_recipes) do
    if
      name ~= "y_wood_wall"
      and name ~= "y-mud-wall"
      and name ~= "y-bullet-case"
      and name ~= "y_turret_gun1f12"
      and name ~= "yi_cannon_shell"
    then
      check(not force.recipes[name].enabled, "defense leaves locked: " .. name)
    end
  end
  check(not force.recipes.yi_armor_gray.enabled, "defense leaves armor locked")
  force.technologies.concrete.researched = true
  force.technologies.artillery.researched = true
  assert_new_unlocks("quinityn-durotal-walls", { "y-rare-wall-basic" })
  assert_new_unlocks("quinityn-ammunition-cases", { "y_ammo_case" })
  assert_new_unlocks("quinityn-forcefield-walls", { "y-wall-forcefield" })
  assert_new_unlocks("quinityn-hardic-walls", { "y_wall22_hardic" })
  assert_new_unlocks("quinityn-chemical-weapons", { "y_turret_flame", "y_ammo_flame" })
  assert_new_unlocks("quinityn-plasma-weapons", { "y_turret_plasma", "y_ammo_plasma" })
  assert_new_unlocks("quinityn-laser-turret", { "y_turret_laser22f12" })
  assert_new_unlocks("quinityn-poison-mines", { "yi_mine_impact" })
  assert_new_unlocks("quinityn-plasma-mines", { "yi_mine_plasma" })
  assert_new_unlocks("quinityn-artillery-shells", { "yi_artillery_shell" })
  assert_new_unlocks("quinityn-reactors", { "y-rare-wall-adv" })
  assert_new_unlocks("quinityn-zero-time-weapon", { "y-weapon-ztt" })
  local quantum_unlocks = {}
  for _, effect in pairs(prototypes.technology["quinityn-quantum-power"].effects) do
    if effect.type == "unlock-recipe" then
      quantum_unlocks[effect.recipe] = true
    end
  end
  local before_quantum = {}
  for _, name in ipairs(defense_recipes) do
    before_quantum[name] = force.recipes[name].enabled
  end
  force.technologies["quinityn-quantum-power"].researched = true
  progression.reconcile()
  check(force.recipes["y-weapon-ztt"].enabled, "quantum power preserves D-ZTT")
  for _, name in ipairs(defense_recipes) do
    if not quantum_unlocks[name] then
      check(force.recipes[name].enabled == before_quantum[name], "quantum power unchanged defense recipe: " .. name)
    end
  end
end
local function washing_split()
  local force = game.create_force("washing-split")
  force.technologies["quinityn-washing"].researched = true
  progression.reconcile()
  local retained = {
    "y-dirtwasher",
    "y-filtering-dust",
    "y-pressed_dry_mud",
    "y-pure-copper",
    "y-pure-iron",
    "y-release-cwater",
    "y-refined-copper",
    "y-refined-iron",
  }
  for _, recipe in ipairs(retained) do
    check(force.recipes[recipe].enabled, "washing retains " .. recipe)
  end
  local split = {
    archaeology = { "y-wash-dirt", "y-wash-special" },
    ["unicomp-compression"] = { "y-press-richdust" },
    ["slag-materials"] = { "y_slag_granulate", "y_slag_brick", "y_slag_brick_burn", "y_steinmehl" },
    ["slag-paving"] = { "y_tile_slagbricks", "y_tile_slagfilled", "y_tile_slagpattern" },
  }
  for tier, recipes in pairs(split) do
    check(not force.technologies["quinityn-" .. tier].researched, tier .. " starts locked")
    for _, recipe in ipairs(recipes) do
      check(not force.recipes[recipe].enabled, tier .. " keeps " .. recipe .. " locked")
    end
  end
  check(force.technologies["quinityn-washing"].researched, "washing completion preserved")
  check(not force.recipes["y_mud2solidfuel"].enabled, "power recipe stays off washing alone")
  check(not force.recipes["y_mc_dirtwasher"].enabled, "mastery washer stays off washing alone")
  for _, tier in ipairs({ "archaeology", "unicomp-compression", "slag-materials", "slag-paving" }) do
    force.technologies["quinityn-" .. tier].researched = true
    progression.reconcile()
    for other, recipes in pairs(split) do
      for _, recipe in ipairs(recipes) do
        if other == tier then
          check(force.recipes[recipe].enabled, tier .. " unlocks " .. recipe)
        else
          check(not force.recipes[recipe].enabled, tier .. " leaves " .. other .. " " .. recipe .. " locked")
        end
      end
    end
    force.technologies["quinityn-" .. tier].researched = false
    progression.reconcile()
  end
end

local function recipe_enabled(force, name)
  return force.recipes[name].enabled
end
local function engine_unlocks()
  local kept = {
    ["y-1stirling-engine"] = true,
    ["y-mf1a"] = true,
    ["y-mf1a1"] = true,
    ["y-mf1f"] = true,
    ["y-mftrans-shaft"] = true,
    ["y-mftrans-shaft-ground"] = true,
    ["y-mftrans-shaft-ground-red"] = true,
    ["y-mftrans-shaft-red"] = true,
    ["y-mfwater"] = true,
    ["y-mwater-pump"] = true,
    ["y-sfe"] = true,
    ["y-waste-condense"] = true,
    ["y_flowcheck_10"] = true,
    ["y_gauge_analog"] = true,
    ["y_mixedfuel2rocketfuel"] = true,
    ["ye_tranport_tube_orange"] = true,
    ["ye_tranport_tube_orange_splitter"] = true,
    ["ye_tranport_tube_orange_underground"] = true,
    ["ye_water2mf"] = true,
  }
  local moved = {
    "ye_wpump_m",
    "y_mpump_mf",
    "y_mpump_water",
    "ye_buechsenblech",
    "ye_neutralisatzion",
    "y-ffe",
    "ye_gasmotor",
    "y-mf2a",
    "y-mf2b",
    "y-mf2c",
    "y-mf2d",
    "y-mf2e",
    "ye_tranport_tube_green",
    "ye_tranport_tube_green_splitter",
    "ye_tranport_tube_green_underground",
  }
  local new_tiers = {
    ["quinityn-medium-mf-pump"] = { "ye_wpump_m", "y_mpump_mf", "y_mpump_water" },
    ["quinityn-substrat-neutralization"] = { "ye_neutralisatzion" },
    ["quinityn-medium-electric-motor"] = { "ye_emotor_m", "ye_motorm_mf" },
    ["quinityn-mf-heat-generator"] = { "ye_mfheatmotor_m", "ye_mf_mfheatmotor_m" },
    ["quinityn-steam-overheating"] = { "ye_overheater", "ye_makesteam" },
    ["quinityn-steam-turbine"] = { "ye_sturbine", "ye_steam2mf", "ye_steam3mf" },
    ["quinityn-high-temperature-generation"] = { "ye_tfmw_generator-s", "ye_tfmw_turbine-s" },
  }
  local force = game.create_force("engine-unlocks")
  local function other_new_tiers_locked()
    for id, recipes in pairs(new_tiers) do
      if not force.technologies[id].researched then
        for _, name in ipairs(recipes) do
          check(not recipe_enabled(force, name), "unresearched " .. id .. " leaves " .. name .. " locked")
        end
      end
    end
  end
  force.technologies["quinityn-engines"].researched = true
  progression.reconcile()
  for name in pairs(kept) do
    check(recipe_enabled(force, name), "engines keeps " .. name)
  end
  for _, name in ipairs(moved) do
    check(not recipe_enabled(force, name), "engines alone leaves " .. name .. " locked")
  end
  for _, id in ipairs({
    "quinityn-medium-mf-pump",
    "quinityn-medium-electric-motor",
    "quinityn-mf-heat-generator",
    "quinityn-steam-overheating",
    "quinityn-steam-turbine",
    "quinityn-high-temperature-generation",
    "quinityn-substrat-neutralization",
  }) do
    check(not force.technologies[id].researched, "new tech unresearched: " .. id)
  end
  force.technologies["quinityn-medium-mf-pump"].researched = true
  progression.reconcile()
  for _, name in ipairs({ "ye_wpump_m", "y_mpump_mf", "y_mpump_water" }) do
    check(recipe_enabled(force, name), "medium pump unlocks " .. name)
  end
  other_new_tiers_locked()
  for _, name in ipairs(moved) do
    if name ~= "ye_wpump_m" and name ~= "y_mpump_mf" and name ~= "y_mpump_water" then
      check(not recipe_enabled(force, name), "medium pump alone leaves " .. name .. " locked")
    end
  end
  force.technologies["quinityn-medium-mf-pump"].researched = false
  force.technologies["quinityn-medium-electric-motor"].researched = true
  progression.reconcile()
  check(
    recipe_enabled(force, "ye_emotor_m") and recipe_enabled(force, "ye_motorm_mf"),
    "medium motor unlocks motor recipes"
  )
  check(
    not recipe_enabled(force, "ye_mfheatmotor_m") and not recipe_enabled(force, "ye_mf_mfheatmotor_m"),
    "medium motor leaves heat generator locked"
  )
  other_new_tiers_locked()
  force.technologies["quinityn-mf-heat-generator"].researched = true
  progression.reconcile()
  check(
    recipe_enabled(force, "ye_mfheatmotor_m") and recipe_enabled(force, "ye_mf_mfheatmotor_m"),
    "heat generator unlocks recipes"
  )
  other_new_tiers_locked()
  force.technologies["quinityn-mf-heat-generator"].researched = false
  force.technologies["quinityn-medium-electric-motor"].researched = false
  force.technologies["quinityn-steam-overheating"].researched = true
  progression.reconcile()
  check(
    recipe_enabled(force, "ye_overheater") and recipe_enabled(force, "ye_makesteam"),
    "steam overheating unlocks heater recipes"
  )
  check(
    not recipe_enabled(force, "ye_steam2mf") and not recipe_enabled(force, "ye_steam3mf"),
    "steam overheating leaves turbine MF recipes locked"
  )
  other_new_tiers_locked()
  force.technologies["quinityn-steam-turbine"].researched = true
  progression.reconcile()
  check(
    recipe_enabled(force, "ye_sturbine")
      and recipe_enabled(force, "ye_steam2mf")
      and recipe_enabled(force, "ye_steam3mf"),
    "steam turbine unlocks recipes"
  )
  other_new_tiers_locked()
  force.technologies["quinityn-steam-turbine"].researched = false
  force.technologies["quinityn-steam-overheating"].researched = false
  force.technologies["quinityn-high-temperature-generation"].researched = true
  progression.reconcile()
  check(
    recipe_enabled(force, "ye_tfmw_generator-s") and recipe_enabled(force, "ye_tfmw_turbine-s"),
    "HT generation unlocks generators"
  )
  other_new_tiers_locked()
  force.technologies["quinityn-high-temperature-generation"].researched = false
  force.technologies["quinityn-advanced-engines"].researched = true
  progression.reconcile()
  for _, name in ipairs({ "y-ffe", "ye_gasmotor", "y-mf2a", "y-mf2b", "y-mf2c", "y-mf2d", "y-mf2e" }) do
    check(recipe_enabled(force, name), "advanced engines unlocks " .. name)
  end
  for _, name in ipairs({
    "ye_emotor_m",
    "ye_motorm_mf",
    "ye_mfheatmotor_m",
    "ye_mf_mfheatmotor_m",
    "ye_overheater",
    "ye_makesteam",
    "ye_sturbine",
    "ye_steam2mf",
    "ye_steam3mf",
    "ye_tfmw_generator-s",
    "ye_tfmw_turbine-s",
  }) do
    check(not recipe_enabled(force, name), "advanced engines alone leaves " .. name .. " locked")
  end
  force.technologies["quinityn-advanced-engines"].researched = false
  force.technologies["quinityn-advanced-transmission"].researched = true
  progression.reconcile()
  for _, name in ipairs({
    "ye_buechsenblech",
    "ye_tranport_tube_green",
    "ye_tranport_tube_green_splitter",
    "ye_tranport_tube_green_underground",
  }) do
    check(recipe_enabled(force, name), "advanced transmission unlocks " .. name)
  end
  check(
    recipe_enabled(force, "y-mftrans-shaft-red") and recipe_enabled(force, "y-mftrans-shaft-ground-red"),
    "red shafts stay on engines"
  )
  force.technologies["quinityn-advanced-transmission"].researched = false
  force.technologies["quinityn-substrat-neutralization"].researched = true
  progression.reconcile()
  check(recipe_enabled(force, "ye_neutralisatzion"), "substrat neutralization unlocks recipe")
  other_new_tiers_locked()
  for id, recipes in pairs(new_tiers) do
    for other_id in pairs(new_tiers) do
      force.technologies[other_id].researched = other_id == id
    end
    progression.reconcile()
    for _, name in ipairs(recipes) do
      check(recipe_enabled(force, name), id .. " alone unlocks " .. name)
    end
    other_new_tiers_locked()
  end
  for id in pairs(new_tiers) do
    force.technologies[id].researched = false
  end
  progression.reconcile()
  local other = game.create_force("engine-other")
  other.technologies["quinityn-engines"].researched = true
  progression.reconcile()
  check(not recipe_enabled(other, "ye_wpump_m"), "other force does not inherit new unlocks")
  check(
    recipe_enabled(force, "y-waste-condense") and recipe_enabled(force, "y_mixedfuel2rocketfuel"),
    "engines alone enables flyash rocket path"
  )
end

local function refining_capability_unlocks()
  local kept = {
    ["y-sulfuric-acid"] = true,
    ["y-water-gen"] = true,
    ["y-water-gen-fluid"] = true,
    ["y_catalyst_bp"] = true,
    ["y_catalyst_ft"] = true,
    ["y_coal2liquid"] = true,
    ["y_ft"] = true,
    ["y_granulate_wood"] = true,
    ["y_rawsyngas1"] = true,
    ["y_rawsyngas2"] = true,
    ["y_refinehydrogen"] = true,
    ["y_regcatbp"] = true,
    ["y_regcatft"] = true,
  }
  local moved = {
    ["y_smelter"] = true,
    ["y_charger"] = true,
    ["y_block_heat"] = true,
    ["y_hps_purecopper"] = true,
    ["y_hps_pureiron"] = true,
    ["y_hps_steel"] = true,
    ["ye_biofuel"] = true,
    ["ye_granulate_corn"] = true,
    ["ye_granulate_trifitan"] = true,
    ["ye_granulate_vuger"] = true,
    ["ye_slurry2ethanol"] = true,
    ["yi-molten-iron"] = true,
    ["yi-molten-copper"] = true,
    ["j_crushing_to_n4"] = true,
    ["j_crushing_to_f7"] = true,
  }
  local new_tech = {
    "quinityn-thermal-smelting",
    "quinityn-biological-feedstock",
    "quinityn-slurry-syngas",
    "quinityn-foundry-melting",
    "quinityn-asteroid-crushing",
  }
  local force = game.create_force("refining-capability")
  for name, t in pairs(force.technologies) do
    if not name:match("^quinityn%-bridge%-") then
      t.researched = true
    end
  end
  for _, name in ipairs(new_tech) do
    force.technologies[name].researched = false
  end
  force.technologies["quinityn-refining"].researched = true
  progression.reconcile()
  for name in pairs(kept) do
    check(force.recipes[name].enabled, "refining keeps " .. name)
  end
  for name in pairs(moved) do
    check(not force.recipes[name].enabled, "refining alone leaves " .. name .. " locked")
  end
  force.technologies["quinityn-thermal-smelting"].researched = true
  progression.reconcile()
  for name in pairs({
    ["y_smelter"] = true,
    ["y_charger"] = true,
    ["y_block_heat"] = true,
    ["y_hps_purecopper"] = true,
    ["y_hps_pureiron"] = true,
    ["y_hps_steel"] = true,
  }) do
    check(force.recipes[name].enabled, "thermal smelting enables " .. name)
  end
  for name in pairs(moved) do
    if
      not ({
        ["y_smelter"] = true,
        ["y_charger"] = true,
        ["y_block_heat"] = true,
        ["y_hps_purecopper"] = true,
        ["y_hps_pureiron"] = true,
        ["y_hps_steel"] = true,
      })[name]
    then
      check(not force.recipes[name].enabled, "thermal smelting leaves " .. name .. " locked")
    end
  end
  force.technologies["quinityn-biological-feedstock"].researched = true
  progression.reconcile()
  for name in pairs({
    ["ye_biofuel"] = true,
    ["ye_granulate_corn"] = true,
    ["ye_granulate_trifitan"] = true,
    ["ye_granulate_vuger"] = true,
  }) do
    check(force.recipes[name].enabled, "biological feedstock enables " .. name)
  end
  check(not force.recipes["ye_slurry2ethanol"].enabled, "biological feedstock leaves slurry Frumital-R gas locked")
  force.technologies["quinityn-slurry-syngas"].researched = true
  progression.reconcile()
  check(force.recipes["ye_slurry2ethanol"].enabled, "slurry syngas enables Frumital-R gas")
  force.technologies["quinityn-foundry-melting"].researched = true
  progression.reconcile()
  check(
    force.recipes["yi-molten-iron"].enabled and force.recipes["yi-molten-copper"].enabled,
    "foundry melting enables molten recipes"
  )
  check(not force.recipes["j_crushing_to_n4"].enabled, "foundry melting leaves asteroid crushing locked")
  force.technologies["quinityn-asteroid-crushing"].researched = true
  progression.reconcile()
  check(
    force.recipes["j_crushing_to_n4"].enabled and force.recipes["j_crushing_to_f7"].enabled,
    "asteroid crushing enables crushing recipes"
  )
  local other = game.create_force("refining-capability-other")
  for name, t in pairs(other.technologies) do
    if not name:match("^quinityn%-bridge%-") then
      t.researched = true
    end
  end
  for _, name in ipairs(new_tech) do
    other.technologies[name].researched = false
  end
  progression.reconcile()
  for name in pairs(moved) do
    check(not other.recipes[name].enabled, "other force without new tech keeps " .. name .. " locked")
  end
end
local function refining_tier_alone()
  local stayers = {
    ["y-sulfuric-acid"] = true,
    ["y-water-gen"] = true,
    ["y-water-gen-fluid"] = true,
    ["y_catalyst_bp"] = true,
    ["y_catalyst_ft"] = true,
    ["y_coal2liquid"] = true,
    ["y_ft"] = true,
    ["y_granulate_wood"] = true,
    ["y_rawsyngas1"] = true,
    ["y_rawsyngas2"] = true,
    ["y_refinehydrogen"] = true,
    ["y_regcatbp"] = true,
    ["y_regcatft"] = true,
  }
  local tiers = {
    {
      force = "refining-alone-1",
      tech = "quinityn-thermal-smelting",
      recipes = {
        "y_smelter",
        "y_charger",
        "y_block_heat",
        "y_hps_purecopper",
        "y_hps_pureiron",
        "y_hps_steel",
      },
    },
    {
      force = "refining-alone-2",
      tech = "quinityn-biological-feedstock",
      recipes = { "ye_biofuel", "ye_granulate_corn", "ye_granulate_trifitan", "ye_granulate_vuger" },
    },
    {
      force = "refining-alone-3",
      tech = "quinityn-slurry-syngas",
      recipes = { "ye_slurry2ethanol" },
    },
    {
      force = "refining-alone-4",
      tech = "quinityn-foundry-melting",
      recipes = { "yi-molten-iron", "yi-molten-copper" },
    },
    {
      force = "refining-alone-5",
      tech = "quinityn-asteroid-crushing",
      recipes = { "j_crushing_to_n4", "j_crushing_to_f7" },
    },
  }
  local other_recipes = {
    ["quinityn-thermal-smelting"] = {
      "y_smelter",
      "y_charger",
      "y_block_heat",
      "y_hps_purecopper",
      "y_hps_pureiron",
      "y_hps_steel",
    },
    ["quinityn-biological-feedstock"] = {
      "ye_biofuel",
      "ye_granulate_corn",
      "ye_granulate_trifitan",
      "ye_granulate_vuger",
    },
    ["quinityn-slurry-syngas"] = { "ye_slurry2ethanol" },
    ["quinityn-foundry-melting"] = { "yi-molten-iron", "yi-molten-copper" },
    ["quinityn-asteroid-crushing"] = { "j_crushing_to_n4", "j_crushing_to_f7" },
  }
  for _, tier in ipairs(tiers) do
    local force = game.create_force(tier.force)
    force.technologies[tier.tech].researched = true
    progression.reconcile()
    for _, recipe in ipairs(tier.recipes) do
      check(force.recipes[recipe].enabled, tier.tech .. " alone enables " .. recipe)
    end
    for name in pairs(stayers) do
      check(not force.recipes[name].enabled, tier.tech .. " alone leaves stayer " .. name .. " locked")
    end
    for other_tech, recipes in pairs(other_recipes) do
      if other_tech ~= tier.tech then
        check(
          not force.technologies[other_tech].researched,
          tier.tech .. " alone leaves " .. other_tech .. " unresearched"
        )
        for _, recipe in ipairs(recipes) do
          check(not force.recipes[recipe].enabled, tier.tech .. " alone leaves " .. recipe .. " locked")
        end
      end
    end
  end
end
local function logistics_unlocks()
  local moved = {
    "y_c22",
    "y_cg33",
    "y_sc44",
    "j-dl-provider",
    "y-rare-chest-log",
    "y_pc22",
    "y-rare-m1bunker-log",
    "j-dl-request",
    "j-dl-buffer",
    "y_rc22",
    "y_bc22",
  }
  local retained = { "y_sc11", "y-inserter-fast", "y-inserter-s4" }
  local new_tech = {
    "quinityn-expanded-storage",
    "quinityn-large-storage",
    "quinityn-bulk-storage",
    "quinityn-logistic-storage",
    "quinityn-logistic-provider-capacity",
    "quinityn-logistic-bunker",
    "quinityn-logistic-requests",
    "quinityn-wide-logistic-requests",
  }
  local force = game.create_force("logistics-unlocks")
  force.technologies["quinityn-logistics"].researched = true
  progression.reconcile()
  for _, name in ipairs(retained) do
    check(recipe_enabled(force, name), "logistics keeps " .. name)
  end
  for _, name in ipairs(moved) do
    check(not recipe_enabled(force, name), "logistics alone leaves " .. name .. " locked")
  end
  for _, id in ipairs(new_tech) do
    check(not force.technologies[id].researched, "new tech unresearched: " .. id)
  end
  check(not force.add_research("quinityn-logistic-requests"), "requests blocked before robotics and logistic system")
  local tiers = {
    { "quinityn-expanded-storage", { "y_c22" } },
    { "quinityn-large-storage", { "y_cg33" } },
    { "quinityn-bulk-storage", { "y_sc44" } },
    { "quinityn-logistic-storage", { "j-dl-provider", "y-rare-chest-log" } },
    { "quinityn-logistic-provider-capacity", { "y_pc22" } },
    { "quinityn-logistic-bunker", { "y-rare-m1bunker-log" } },
    { "quinityn-logistic-requests", { "j-dl-request", "j-dl-buffer" } },
    { "quinityn-wide-logistic-requests", { "y_rc22", "y_bc22" } },
  }
  local researched = {}
  local function assert_tier_locks()
    for _, tier in ipairs(tiers) do
      local open = researched[tier[1]] == true
      for _, name in ipairs(tier[2]) do
        if open then
          check(recipe_enabled(force, name), tier[1] .. " unlocks " .. name)
        else
          check(not recipe_enabled(force, name), tier[1] .. " stays locked: " .. name)
        end
      end
    end
    for _, name in ipairs(retained) do
      check(recipe_enabled(force, name), "retained stays enabled: " .. name)
    end
  end
  assert_tier_locks()
  for _, tier in ipairs(tiers) do
    if tier[1] == "quinityn-logistic-requests" then
      force.technologies["quinityn-robotics"].researched = true
      force.technologies["logistic-system"].researched = true
      progression.reconcile()
      assert_tier_locks()
    end
    force.technologies[tier[1]].researched = true
    researched[tier[1]] = true
    progression.reconcile()
    assert_tier_locks()
  end
  local legacy = game.create_force("logistics-legacy")
  legacy.technologies["quinityn-logistics"].researched = true
  progression.reconcile()
  progression.reconcile()
  for _, name in ipairs(retained) do
    check(recipe_enabled(legacy, name), "legacy keeps " .. name)
  end
  for _, name in ipairs(moved) do
    check(not recipe_enabled(legacy, name), "legacy leaves moved locked: " .. name)
  end
  check(legacy.technologies["quinityn-logistics"].researched, "legacy logistics stays completed")
  for _, id in ipairs(new_tech) do
    check(not legacy.technologies[id].researched, "legacy does not grant " .. id)
  end
end
local function thermal_prerequisite_lock()
  local thermal = {
    "y_smelter",
    "y_charger",
    "y_block_heat",
    "y_hps_purecopper",
    "y_hps_pureiron",
    "y_hps_steel",
  }
  local kept = {
    ["y-sulfuric-acid"] = true,
    ["y-water-gen"] = true,
    ["y-water-gen-fluid"] = true,
    ["y_catalyst_bp"] = true,
    ["y_catalyst_ft"] = true,
    ["y_coal2liquid"] = true,
    ["y_ft"] = true,
    ["y_granulate_wood"] = true,
    ["y_rawsyngas1"] = true,
    ["y_rawsyngas2"] = true,
    ["y_refinehydrogen"] = true,
    ["y_regcatbp"] = true,
    ["y_regcatft"] = true,
  }
  local other_new = {
    "quinityn-biological-feedstock",
    "quinityn-slurry-syngas",
    "quinityn-foundry-melting",
    "quinityn-asteroid-crushing",
  }
  local other_recipes = {
    ["quinityn-biological-feedstock"] = {
      "ye_biofuel",
      "ye_granulate_corn",
      "ye_granulate_trifitan",
      "ye_granulate_vuger",
    },
    ["quinityn-slurry-syngas"] = { "ye_slurry2ethanol" },
    ["quinityn-foundry-melting"] = { "yi-molten-iron", "yi-molten-copper" },
    ["quinityn-asteroid-crushing"] = { "j_crushing_to_n4", "j_crushing_to_f7" },
  }
  local function thermal_locked(force)
    for _, name in ipairs(thermal) do
      check(not force.recipes[name].enabled, "thermal recipe locked: " .. name)
    end
  end
  local function thermal_enabled(force)
    for _, name in ipairs(thermal) do
      check(force.recipes[name].enabled, "thermal recipe enabled: " .. name)
    end
  end
  local function other_new_locked(force)
    for _, tech in ipairs(other_new) do
      check(not force.technologies[tech].researched, tech .. " stays unresearched")
      for _, recipe in ipairs(other_recipes[tech]) do
        check(not force.recipes[recipe].enabled, tech .. " leaves " .. recipe .. " locked")
      end
    end
  end
  local force = game.create_force("thermal-prereq")
  force.technologies["quinityn-refining"].researched = true
  progression.reconcile()
  check(not force.add_research("quinityn-thermal-smelting"), "refining alone cannot open thermal smelting")
  thermal_locked(force)
  for name in pairs(kept) do
    check(force.recipes[name].enabled, "refining keeps " .. name)
  end
  other_new_locked(force)
  force.technologies["quinityn-quantum"].researched = true
  progression.reconcile()
  thermal_locked(force)
  check(force.add_research("quinityn-thermal-smelting"), "refining and quantum enable thermal smelting research")
  local thermal_tech = force.technologies["quinityn-thermal-smelting"]
  if thermal_tech.researched then
    progression.reconcile()
    thermal_enabled(force)
  else
    thermal_locked(force)
    thermal_tech.researched = true
    progression.reconcile()
    thermal_enabled(force)
  end
  for name in pairs(kept) do
    check(force.recipes[name].enabled, "stayers stay enabled: " .. name)
  end
  other_new_locked(force)
end
script.on_init(function()
  power_storage_generation_restaging()
  washing_split()
  module_unlocks()
  engine_unlocks()
  logistics_unlocks()
  refining_capability_unlocks()
  refining_tier_alone()
  thermal_prerequisite_lock()
  defense_unlocks()
  local force = game.forces.player
  for name, t in pairs(force.technologies) do
    if not withheld[name] and not name:match("^quinityn%-bridge%-") then
      t.researched = true
    end
  end
  progression.reconcile()
  local surface = game.create_surface("research-fixture", { width = 64, height = 64 })
  surface.request_to_generate_chunks({ 0, 0 }, 1)
  surface.force_generate_chunk_requests()
  local tiles = {}
  for x = -20, 20 do
    for y = -20, 20 do
      tiles[#tiles + 1] = { name = "landfill", position = { x, y } }
    end
  end
  surface.set_tiles(tiles)
  storage.surface = surface.index
  game.create_force("research-other")
  force.technologies["quinityn-advanced-factories"].researched = true
  check(force.recipes.ye_fassembly2.enabled, "Y2 research unlocks Y2")
  check(
    not force.recipes.ye_fassembly_sp.enabled and not force.recipes.yie_science_blue_gen.enabled,
    "Y2 research leaves P3 and research center locked"
  )
  storage.machine = surface.create_entity({ name = "y-atomic-quantum-composer", position = { 0, 0 }, force = force })
  check(storage.machine.set_recipe("yi_radar"), "existing radar recipe supplies reputation")
  storage.phase = "reputation"
  storage.funded = 0
  storage.signs = 0
end)
script.on_event(defines.events.on_tick, function()
  if storage.finished then
    return
  end
  local force = game.forces.player
  local surface = game.surfaces[storage.surface]
  local machine = storage.machine
  if machine then
    machine.energy = 100000000
  end
  if storage.phase == "reputation" then
    if storage.funded < 4 and supply(machine, "yi_radar") then
      storage.funded = storage.funded + 1
    end
    storage.signs = storage.signs + machine.get_output_inventory().remove({ name = "ye_science_blue", count = 4 })
    machine.get_output_inventory().clear()
    if storage.signs == 4 then
      check(
        not force.technologies["quinityn-research-center"].researched,
        "four native byproduct signs before the center"
      )
      machine.destroy()
      storage.machine = surface.create_entity({ name = "assembling-machine-3", position = { 0, 0 }, force = force })
      storage.machine.set_recipe("ye_fassembly2")
      for _, p in pairs(prototypes.recipe.ye_fassembly2.ingredients) do
        storage.machine.insert({ name = p.name, count = p.amount })
      end
      storage.signs = storage.signs - 1
      storage.phase = "y2"
    end
  elseif storage.phase == "y2" or storage.phase == "p3" then
    if machine.products_finished == 0 then
      return
    end
    check(not force.recipes.yie_science_blue_gen.enabled, "factory constructed before research center unlock")
    if storage.phase == "y2" then
      check(machine.get_output_inventory().get_item_count("ye_fassembly2") == 1, "native Y2 manufacture")
      force.technologies["quinityn-p3-factory"].researched = true
      machine.get_output_inventory().clear()
      machine.set_recipe("ye_fassembly_sp")
      -- products_finished is cumulative, so use output inventory for the second recipe.
      for _, p in pairs(prototypes.recipe.ye_fassembly_sp.ingredients) do
        machine.insert({ name = p.name, count = p.amount })
      end
      storage.signs = storage.signs - 3
      storage.phase = "p3"
    elseif machine.get_output_inventory().get_item_count("ye_fassembly_sp") == 1 then
      check(storage.signs == 0, "native P3 manufacture uses the remaining byproduct signs")
      machine.destroy()
      force.technologies["quinityn-robotics"].researched = true
      progression.reconcile()
      check(
        force.recipes["yi_logistic-robot"].enabled
          and force.recipes["yi_construction-robot"].enabled
          and force.recipes.yi_roboport.enabled,
        "robotics unlocks basic bots and roboport"
      )
      check(not force.recipes.j_yi_roboport1.enabled, "robotics leaves 8080 locked")
      force.technologies["quinityn-robot-network-expansion"].researched = true
      check(force.recipes.j_yi_roboport1.enabled, "separate research unlocks 8080")
      check(
        not force.add_research("quinityn-advanced-robotics"),
        "advanced robots cannot be researched before production"
      )
      storage.machine = surface.create_entity({ name = "assembling-machine-3", position = { 0, 0 }, force = force })
      storage.machine.set_recipe("yi_logistic-robot")
      -- Merely owning 500 robots must not satisfy a crafting trigger.
      local chest = surface.create_entity({ name = "steel-chest", position = { 5, 0 }, force = force })
      chest.insert({ name = "yi_logistic-robot", count = 500 })
      storage.funded = 0
      storage.phase = "robots"
    end
  elseif storage.phase == "robots" then
    machine.get_output_inventory().clear()
    if storage.funded < 499 and supply(machine, "yi_logistic-robot") then
      storage.funded = storage.funded + 1
    end
    if machine.products_finished == 499 then
      storage.paused = storage.paused or game.tick
      check(not force.technologies["quinityn-robot-production"].researched, "499 crafted robots leave milestone locked")
      if game.tick - storage.paused >= 60 then
        check(not force.add_research("quinityn-advanced-robotics"), "499 robots cannot open advanced research")
        check(supply(machine, "yi_logistic-robot"), "supply final robot")
        storage.phase = "last-robot"
      end
    end
  elseif storage.phase == "last-robot" then
    if not force.technologies["quinityn-robot-production"].researched then
      return
    end
    check(machine.products_finished == 500, "500th native craft completes milestone")
    check(
      not game.forces["research-other"].technologies["quinityn-robot-production"].researched,
      "production is force-local"
    )
    check(
      not force.recipes["j_logistic2-robot"].enabled and not force.recipes["j_construction2-robot"].enabled,
      "milestone alone does not unlock advanced bots"
    )
    machine.destroy()
    storage.machine = nil
    check(force.add_research("quinityn-advanced-robotics"), "milestone enables separate lab research")
    storage.lab = surface.create_entity({ name = "lab", position = { 0, 0 }, force = force })
    force.laboratory_speed_modifier = 1000
    storage.started = game.tick
    storage.phase = "labs"
  elseif storage.phase == "labs" then
    storage.lab.energy = 100000000
    for _, p in pairs(prototypes.technology["quinityn-advanced-robotics"].research_unit_ingredients) do
      if p.name ~= "chemical-science-pack" or game.tick - storage.started >= 120 then
        storage.lab.insert({ name = p.name, count = 20 })
      end
    end
    if game.tick - storage.started == 119 then
      check(force.research_progress == 0, "lab cannot research without chemical science")
    end
    if force.technologies["quinityn-advanced-robotics"].researched then
      check(
        force.recipes["j_logistic2-robot"].enabled and force.recipes["j_construction2-robot"].enabled,
        "science-funded research unlocks both advanced robots"
      )
      -- Existing saves may have completed advanced robots before this milestone existed.
      force.technologies["quinityn-robot-production"].researched = false
      progression.reconcile()
      check(
        force.technologies["quinityn-advanced-robotics"].researched and force.recipes["j_logistic2-robot"].enabled,
        "reconciliation preserves previously completed advanced robot research"
      )
      storage.lab.destroy()
      storage.finished = true
      log("QUINITYN RESEARCH PROGRESSION TESTS PASSED")
    end
  end
end)
