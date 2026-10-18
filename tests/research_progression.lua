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
script.on_init(function()
  module_unlocks()
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
