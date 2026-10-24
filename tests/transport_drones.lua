-- Real Transport Drones, injected stock/roads, no Quinityn manufacturing research.
local parameters = require("__quinityn-tests__/parameters")
local progression = require("__yuoki-quinityn__/scripts/progression")
local categories = { ["transport-drone-request"] = true, ["transport-fluid-request"] = true, ["fuel-depot"] = true }

local function helper(recipe)
  for category in pairs(categories) do
    if recipe.has_category(category) then
      return true
    end
  end
  return false
end

local function check_states(force)
  for name, recipe in pairs(force.recipes) do
    if helper(recipe.prototype) then
      assert(recipe.enabled == recipe.prototype.enabled, "upstream state lost: " .. name)
    end
  end
  assert(not force.technologies["quinityn-trade"].researched)
  assert(not force.technologies["quinityn-engines"].researched)
  assert(not force.recipes["y-pink-module-2"].enabled, "manufacturing leaked")
end

local function setup_network()
  local force = game.forces.player
  check_states(force)
  -- Reconciliation must leave even deliberately customized helper states alone.
  for _, recipe in pairs(force.recipes) do
    if helper(recipe.prototype) then
      recipe.enabled = not recipe.prototype.enabled
    end
  end
  progression.reconcile()
  for name, recipe in pairs(force.recipes) do
    if helper(recipe.prototype) then
      assert(recipe.enabled ~= recipe.prototype.enabled, "Quinityn changed helper state: " .. name)
      recipe.enabled = recipe.prototype.enabled
    end
  end
  local surface = game.create_surface("drone-integration", { width = 2048, height = 64 })
  local cases = {
    "y_rwtechsign",
    "y_greensign",
    "ypfw_trader_sign",
    "ye_science_blue",
    "y-fame",
    "y-pol-waste",
    "y-pink-module-2",
    "y-accumulator-b",
    "y-crusher",
    "y-rare-chest-log",
    "y-ammo-acid-2",
    "ye_corn_a",
    "y-stargate",
    "y-atomic-constructor",
    "quinityn-salvage",
    "quinityn-burner-separator",
  }
  -- Every Yuoki/Engines fluid, including empty-output selectors, remains usable.
  for name in pairs(prototypes.fluid) do
    if name:match("^y[-_]") or name:match("^ye[-_]") or name:match("^yie[-_]") then
      table.insert(cases, name)
    end
  end
  table.sort(cases)
  local tiles = {}
  for x = -24, #cases * 32 do
    for y = -10, 10 do
      tiles[#tiles + 1] = { name = "transport-drone-road", position = { x, y } }
    end
  end
  surface.set_tiles(tiles, true, "abort_on_collision", false, true)
  local function build(name, x, y, direction)
    return assert(surface.create_entity({
      name = name,
      position = { x, y },
      direction = direction,
      force = force,
      raise_built = true,
    }))
  end
  local function drones(entity)
    assert(entity.get_inventory(defines.inventory.crafter_input).insert({ name = "transport-drone", count = 10 }) == 10)
  end
  storage.deliveries = {}
  for index, name in ipairs(cases) do
    local x = (index - 1) * 32
    local fuel = build("fuel-depot", x - 16, -6, defines.direction.south)
    fuel.insert_fluid({ name = settings.startup["fuel-fluid"].value, amount = 100000 })
    drones(fuel)
    local fluid = prototypes.fluid[name] ~= nil
    local supply = build(fluid and "fluid-depot" or "supply-depot", x - 8, -3, defines.direction.south)
    if fluid then
      assert(force.recipes["fluid-depot-" .. name].enabled)
      supply.insert_fluid({ name = name, amount = 100000 })
    else
      assert(supply.insert({ name = name, count = prototypes.item[name].stack_size * 100 }) > 0)
    end
    local request = build("request-depot", x - 8, 3, defines.direction.north)
    local buffer = build("buffer-depot", x + 8, -3, defines.direction.south)
    -- Audit native selection across the entire current generated helper set.
    if index == 1 then
      for recipe_name, recipe in pairs(force.recipes) do
        if helper(recipe.prototype) then
          assert(recipe.enabled, "selector unavailable: " .. recipe_name)
          if recipe.prototype.has_category("transport-drone-request") then
            for _, selector in ipairs({ request, buffer }) do
              selector.set_recipe(recipe_name)
              assert(selector.get_recipe().name == recipe_name, "selection failed: " .. recipe_name)
            end
          end
        end
      end
    end
    assert(force.recipes["request-" .. name].enabled)
    request.set_recipe("request-" .. name)
    buffer.set_recipe("request-" .. name)
    drones(request)
    drones(buffer)
    storage.deliveries[#storage.deliveries + 1] =
      { name = name, fluid = fluid, request = request, buffer = buffer, supply = supply }
  end
  storage.started = game.tick
end

script.on_init(function()
  storage.legacy = parameters.legacy
  if parameters.legacy then
    for name, recipe in pairs(game.forces.player.recipes) do
      if helper(recipe.prototype) then
        assert(not recipe.enabled, "legacy gate missing: " .. name)
      end
    end
    local completed = game.create_force("drone-completed")
    completed.technologies["quinityn-trade"].researched = true
    storage.stock = game.surfaces.nauvis.create_entity({ name = "steel-chest", position = { 0, 0 }, force = completed })
    storage.stock.insert({ name = "y_rwtechsign", count = 10 })
    log("DRONE LEGACY SETUP")
  else
    log("DRONE FRESH SETUP")
  end
end)

script.on_event(defines.events.on_tick, function()
  if storage.done then
    return
  end
  if not storage.deliveries then
    assert(not parameters.legacy, "still running legacy prototypes")
    if storage.legacy then
      local completed = game.forces["drone-completed"]
      assert(completed.technologies["quinityn-trade"].researched, "completed research lost")
      assert(storage.stock.valid and storage.stock.get_item_count("y_rwtechsign") == 10)
      for name, recipe in pairs(completed.recipes) do
        if helper(recipe.prototype) then
          assert(recipe.enabled == recipe.prototype.enabled, "completed-force helper changed: " .. name)
        end
      end
    end
    setup_network()
  end
  local ready = true
  for _, case in ipairs(storage.deliveries) do
    for _, kind in ipairs({ "request", "buffer" }) do
      local depot = case[kind]
      -- Cargo is storage 2; storage 1 may hold the same fluid as drone fuel.
      local cargo = case.fluid and depot.get_fluid(2)
      local count = case.fluid and (cargo and cargo.name == case.name and cargo.amount or 0)
        or depot.get_item_count(case.name)
      case[kind .. "_received"] = case[kind .. "_received"] or count > 0
      if not case[kind .. "_received"] then
        ready = false
        assert(game.tick - storage.started < 12000, "no delivery: " .. case.name .. " to " .. depot.name)
      end
    end
  end
  if ready then
    check_states(game.forces.player)
    log(
      (storage.legacy and "DRONE UPGRADE DELIVERY PASSED" or "DRONE DELIVERY PASSED")
        .. ": "
        .. #storage.deliveries
        .. " item/fluid pairs"
    )
    storage.done = true
  end
end)
