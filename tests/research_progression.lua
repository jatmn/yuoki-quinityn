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

local function plant_storage_tiers_alone()
  local stayers = {
    "y-pipe-ec",
    "y-pipe-h",
    "y-pipe-hc",
    "y-pipe-to-ground-ec",
    "y-pipe-to-ground-hc",
    "y-pipe-v",
    "y-powerlamp",
    "y-substation-m",
    "y-tank-1000",
    "y-tinylamp",
    "y_lampe_44basement_a",
    "y_lampe_44basement_b",
    "y_lampe_66basement",
    "y_lampe_corner",
    "y_lampe_neotix",
    "y_lampe_yuoki",
    "y_signal_pole",
    "yi_pipe_green",
    "yi_pipe_underground_green",
  }
  local force50 = game.create_force("plant-50k-alone")
  force50.technologies["quinityn-plant-infrastructure"].researched = true
  progression.reconcile()
  check(not recipe_enabled(force50, "y-tank-4500"), "50k baseline locks y-tank-4500")
  check(not recipe_enabled(force50, "y-tank-8000"), "50k baseline locks y-tank-8000")
  check(not recipe_enabled(force50, "yi_radar"), "50k baseline locks yi_radar")
  check(not recipe_enabled(force50, "yi-monument1"), "50k baseline locks yi-monument1")
  for _, name in ipairs(stayers) do
    check(recipe_enabled(force50, name), "50k baseline enables stayer " .. name)
  end
  check(
    not force50.technologies["quinityn-fluid-storage-50k"].researched
      and not force50.technologies["quinityn-fluid-storage-80k"].researched
      and not force50.technologies["quinityn-quantum"].researched,
    "50k baseline leaves fluid tiers and quantum unresearched"
  )
  force50.technologies["quinityn-fluid-storage-50k"].researched = true
  progression.reconcile()
  check(recipe_enabled(force50, "y-tank-4500"), "50k research enables y-tank-4500")
  check(not recipe_enabled(force50, "y-tank-8000"), "50k research leaves y-tank-8000 locked")
  check(not recipe_enabled(force50, "yi_radar"), "50k research leaves yi_radar locked")
  check(not recipe_enabled(force50, "yi-monument1"), "50k research leaves yi-monument1 locked")
  for _, name in ipairs(stayers) do
    check(recipe_enabled(force50, name), "50k research keeps stayer " .. name)
  end
  check(
    not force50.technologies["quinityn-fluid-storage-80k"].researched
      and not force50.technologies["quinityn-quantum"].researched,
    "50k research leaves 80k and quantum unresearched"
  )
  local force80 = game.create_force("plant-80k-alone")
  force80.technologies["quinityn-fluid-storage-50k"].researched = true
  progression.reconcile()
  check(not recipe_enabled(force80, "y-tank-8000"), "80k baseline locks y-tank-8000")
  for _, name in ipairs(stayers) do
    check(not recipe_enabled(force80, name), "80k baseline locks stayer " .. name)
  end
  check(not recipe_enabled(force80, "yi_radar"), "80k baseline locks yi_radar")
  check(not recipe_enabled(force80, "yi-monument1"), "80k baseline locks yi-monument1")
  check(recipe_enabled(force80, "y-tank-4500"), "80k baseline enables y-tank-4500 from prerequisite")
  check(
    not force80.technologies["quinityn-fluid-storage-80k"].researched
      and not force80.technologies["quinityn-quantum"].researched,
    "80k baseline leaves 80k tier and quantum unresearched"
  )
  force80.technologies["quinityn-fluid-storage-80k"].researched = true
  progression.reconcile()
  check(recipe_enabled(force80, "y-tank-8000"), "80k research enables y-tank-8000")
  for _, name in ipairs(stayers) do
    check(not recipe_enabled(force80, name), "80k research keeps stayer locked " .. name)
  end
  check(not recipe_enabled(force80, "yi_radar"), "80k research leaves yi_radar locked")
  check(not recipe_enabled(force80, "yi-monument1"), "80k research leaves yi-monument1 locked")
  check(recipe_enabled(force80, "y-tank-4500"), "80k research keeps y-tank-4500 enabled")
  check(not force80.technologies["quinityn-quantum"].researched, "80k research leaves quantum unresearched")
  check(force80.technologies["quinityn-fluid-storage-50k"].researched, "80k research keeps 50k tier researched")
  local forceQuantum = game.create_force("plant-quantum-moves")
  forceQuantum.technologies["quinityn-crystal-processing"].researched = true
  forceQuantum.technologies["quinityn-energy-storage"].researched = true
  progression.reconcile()
  check(not recipe_enabled(forceQuantum, "yi_radar"), "quantum baseline locks yi_radar")
  check(not recipe_enabled(forceQuantum, "yi-monument1"), "quantum baseline locks yi-monument1")
  check(not recipe_enabled(forceQuantum, "y-tank-4500"), "quantum baseline locks y-tank-4500")
  check(not recipe_enabled(forceQuantum, "y-tank-8000"), "quantum baseline locks y-tank-8000")
  for _, name in ipairs(stayers) do
    check(not recipe_enabled(forceQuantum, name), "quantum baseline locks stayer " .. name)
  end
  forceQuantum.technologies["quinityn-quantum"].researched = true
  progression.reconcile()
  check(recipe_enabled(forceQuantum, "yi_radar"), "quantum research enables yi_radar")
  check(recipe_enabled(forceQuantum, "yi-monument1"), "quantum research enables yi-monument1")
  check(not recipe_enabled(forceQuantum, "y-tank-4500"), "quantum research leaves y-tank-4500 locked")
  check(not recipe_enabled(forceQuantum, "y-tank-8000"), "quantum research leaves y-tank-8000 locked")
  for _, name in ipairs(stayers) do
    check(not recipe_enabled(forceQuantum, name), "quantum research keeps stayer locked " .. name)
  end
  check(
    not forceQuantum.technologies["quinityn-fluid-storage-50k"].researched
      and not forceQuantum.technologies["quinityn-fluid-storage-80k"].researched,
    "quantum research leaves fluid tiers unresearched"
  )
end
script.on_init(function()
  module_unlocks()
  engine_unlocks()
  logistics_unlocks()
  washing_split()
  plant_storage_tiers_alone()
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
