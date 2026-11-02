-- Injected depots, drones and reachable ore. Mining Drones performs the mining.
local parameters = require("__quinityn-tests__/parameters")
local progression = script.active_mods["yuoki-quinityn"] and require("__yuoki-quinityn__/scripts/progression")

local function check_states()
  local force = game.forces.player
  for name, recipe in pairs(force.recipes) do
    if recipe.prototype.has_category("mining-depot") then
      assert(recipe.enabled == recipe.prototype.enabled, "selector state changed: " .. name)
    end
  end
  if script.active_mods["yuoki-quinityn"] then
    assert(not force.technologies["quinityn-refining"].researched, "refining was researched")
    assert(not force.recipes["y-crusher"].enabled, "manufacturing leaked")
  end
end

script.on_init(function()
  storage.legacy = parameters.legacy
  local force = game.forces.player
  if parameters.legacy then
    assert(not force.recipes["mine-y-res1"].enabled)
    assert(not force.recipes["mine-y-res2"].enabled)
  else
    check_states()
  end
  local surface = game.create_surface("mining-integration", { width = 256, height = 128 })
  surface.request_to_generate_chunks({ 0, 0 }, 2)
  surface.force_generate_chunk_requests()
  for _, entity in pairs(surface.find_entities()) do
    entity.destroy()
  end
  local tiles = {}
  for x = -64, 64 do
    for y = -40, 16 do
      tiles[#tiles + 1] = { name = "refined-concrete", position = { x, y } }
    end
  end
  surface.set_tiles(tiles, true, "abort_on_collision", false, true)
  storage.cases = {}
  for index, ore in ipairs({ "y-res1", "y-res2" }) do
    local x = (index - 1) * 64 - 32
    local resource = assert(surface.create_entity({ name = ore, position = { x, -16 }, amount = 10000 }))
    local depot = assert(surface.create_entity({
      name = "mining-depot",
      position = { x, 0 },
      direction = defines.direction.north,
      force = force,
      raise_built = true,
    }))
    storage.cases[#storage.cases + 1] = { ore = ore, resource = resource, depot = depot }
  end
  log(parameters.legacy and "MINING LEGACY SETUP" or "MINING FRESH SETUP")
end)

script.on_event(defines.events.on_tick, function()
  if storage.done then
    return
  end
  if not storage.started then
    assert(not parameters.legacy, "still running legacy prototypes")
    check_states()
    local force = game.forces.player
    if script.active_mods["yuoki-quinityn"] then
      -- Later reconciliation must also preserve states set by other mods.
      for _, recipe in pairs(force.recipes) do
        if recipe.prototype.has_category("mining-depot") then
          recipe.enabled = not recipe.prototype.enabled
        end
      end
      progression.reconcile()
      for name, recipe in pairs(force.recipes) do
        if recipe.prototype.has_category("mining-depot") then
          assert(recipe.enabled ~= recipe.prototype.enabled, "reconciliation claimed selector: " .. name)
          recipe.enabled = recipe.prototype.enabled
        end
      end
    end
    -- Native selection covers the entire generated family, including other ores.
    local selector = storage.cases[1].depot
    for name, recipe in pairs(force.recipes) do
      if recipe.prototype.has_category("mining-depot") then
        assert(recipe.enabled, "selector unavailable: " .. name)
        selector.set_recipe(name)
        assert(selector.get_recipe().name == name, "selection failed: " .. name)
      end
    end
    for _, case in ipairs(storage.cases) do
      assert(case.depot.valid and case.resource.valid, "saved entity lost")
      case.depot.set_recipe("mine-" .. case.ore)
      assert(case.depot.get_recipe().name == "mine-" .. case.ore)
      assert(
        case.depot.get_inventory(defines.inventory.crafter_input).insert({ name = "mining-drone", count = 5 }) == 5
      )
    end
    storage.started = game.tick
  end
  for _, case in ipairs(storage.cases) do
    if case.depot.get_output_inventory().get_item_count(case.ore) == 0 then
      assert(game.tick - storage.started < 6000, "no mined ore returned: " .. case.ore)
      return
    end
    assert(not case.resource.valid or case.resource.amount < 10000, "ore was not mined: " .. case.ore)
  end
  check_states()
  log(storage.legacy and "MINING UPGRADE PASSED" or "MINING PASSED")
  storage.done = true
end)
