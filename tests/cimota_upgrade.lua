-- Primitive -> full Cimota replacement through the engine's planner, blueprint,
-- construction-robot and hand fast-replace paths. Items and power are injected.
local primitive, full = "quinityn-burner-separator", "y-atomic-constructor"
local east = defines.direction.east
local function machine(surface, force, x, recipe)
  local entity = surface.create_entity({ name = primitive, position = { x, 0.5 }, force = force })
  assert(entity and entity.valid, "primitive placement")
  -- Fluid boxes exist only with a fluid recipe; use the engine-reported input port.
  entity.set_recipe("quinityn-water")
  entity.direction = east
  assert(entity.direction == east, "primitive rotates east")
  local pipe = surface.create_entity({
    name = "pipe",
    position = entity.get_fluid_box_pipe_connections(1)[1].target_position,
    force = force,
  })
  entity.set_recipe(recipe)
  assert(entity.get_recipe().name == recipe, "primitive selects " .. recipe)
  entity.get_fuel_inventory().insert({ name = "coal", count = 5 })
  return { position = entity.position, pipe = pipe }
end
local function replaced(surface, record)
  local found =
    surface.find_entities_filtered({ position = record.position, radius = 0.1, type = "assembling-machine" })
  return #found == 1 and found[1].name == full and found[1] or nil
end
local function check_layout(surface, force, record, label)
  local entity = replaced(surface, record)
  assert(entity, label .. ": full Cimota replaced the primitive")
  assert(entity.position.x == record.position.x and entity.position.y == record.position.y, label .. " position")
  assert(not entity.get_recipe(), label .. ": unsupported primitive recipe is cleared")
  assert(record.pipe.valid and not record.pipe.to_be_deconstructed(), label .. ": surrounding pipe was kept")
  -- The full Cimota cannot keep a primitive recipe. As with vanilla assemblers, the
  -- engine faces a machine without a fluid recipe north, so the player rotates it once.
  force.recipes["y-liquid2uc"].enabled = true
  entity.set_recipe("y-liquid2uc")
  entity.direction = east
  local connected = false
  for _, neighbour in pairs(entity.get_fluid_box_neighbours(1)) do
    connected = connected or neighbour.entity == record.pipe
  end
  assert(connected, label .. ": upgraded machine uses the existing pipe")
end
script.on_init(function()
  local surface, force = game.surfaces.nauvis, game.forces.player
  surface.request_to_generate_chunks({ 0, 0 }, 2)
  surface.force_generate_chunk_requests()
  local tiles = {}
  for x = -12, 40 do
    for y = -12, 12 do
      tiles[#tiles + 1] = { name = "refined-concrete", position = { x, y } }
    end
  end
  surface.set_tiles(tiles)
  for _, entity in ipairs(surface.find_entities_filtered({ area = { { -13, -13 }, { 41, 13 } } })) do
    entity.destroy()
  end
  local roboport = surface.create_entity({ name = "roboport", position = { 0, 0 }, force = force })
  roboport.insert({ name = "construction-robot", count = 10 })
  storage.roboport = roboport
  surface
    .create_entity({ name = "storage-chest", position = { 0, 4 }, force = force })
    .insert({ name = full, count = 3 })
  local inventory = game.create_inventory(2)
  -- Blank planner: the engine's default target comes from next_upgrade.
  local water = machine(surface, force, 8, "quinityn-water")
  inventory[1].set_stack("upgrade-planner")
  surface.upgrade_area({ area = { { 6, -2 }, { 10, 3 } }, force = force, item = inventory[1] })
  -- Explicit primitive -> full mapping on a basic solids conversion.
  local solids = machine(surface, force, 14, "quinityn-stone-to-uc")
  assert(surface.find_entity(primitive, solids.position).insert({ name = "stone", count = 10 }) == 10)
  inventory[1].set_mapper(1, "from", { type = "entity", name = primitive })
  inventory[1].set_mapper(1, "to", { type = "entity", name = full })
  surface.upgrade_area({ area = { { 12, -2 }, { 16, 3 } }, force = force, item = inventory[1] })
  for label, record in pairs({ blank = water, configured = solids }) do
    local entity = surface.find_entity(primitive, record.position)
    assert(entity.to_be_upgraded(), label .. " planner marks the primitive")
    assert(entity.get_upgrade_target().name == full, label .. " planner targets the full Cimota")
  end
  -- A blueprint of the existing layout, with the machine upgraded, built back over it.
  local layout = machine(surface, force, 20, "quinityn-water")
  inventory[2].set_stack("blueprint")
  inventory[2].create_blueprint({ surface = surface, force = force, area = { { 18, -2 }, { 22, 3 } } })
  local entities = inventory[2].get_blueprint_entities()
  for _, entity in pairs(entities) do
    entity.name = entity.name == primitive and full or entity.name
    entity.position = { x = entity.position.x - layout.position.x, y = entity.position.y - layout.position.y }
  end
  inventory[2].set_blueprint_entities(entities)
  -- Through the API only super-forced placement marks upgrades, even for vanilla assemblers.
  inventory[2].build_blueprint({
    surface = surface,
    force = force,
    position = layout.position,
    build_mode = defines.build_mode.superforced,
  })
  local marked = surface.find_entity(primitive, layout.position)
  assert(marked.to_be_upgraded() and not marked.to_be_deconstructed(), "upgraded blueprint marks the primitive")
  assert(marked.get_upgrade_target().name == full, "upgraded blueprint targets the full Cimota")
  assert(#surface.find_entities_filtered({ name = "entity-ghost", area = { { 18, -2 }, { 22, 3 } } }) == 0)
  inventory.destroy()
  -- Hand fast-replacement by a character returns the machine, burner fuel and ingredients.
  local hand = machine(surface, force, 30, "quinityn-stone-to-uc")
  assert(surface.find_entity(primitive, hand.position).insert({ name = "stone", count = 10 }) == 10)
  local character = surface.create_entity({ name = "character", position = { 30, 6 }, force = force })
  local upgraded = surface.create_entity({
    name = full,
    position = hand.position,
    force = force,
    fast_replace = true,
    character = character,
  })
  assert(upgraded and upgraded.valid and replaced(surface, hand) == upgraded, "hand fast-replacement")
  check_layout(surface, force, hand, "hand")
  local main = character.get_main_inventory()
  assert(main.get_item_count(primitive) == 1, "hand replacement returns the primitive")
  assert(main.get_item_count("coal") == 5, "hand replacement returns burner fuel")
  assert(main.get_item_count("stone") == 10, "hand replacement returns unsupported-recipe ingredients")
  storage.records = { water = water, solids = solids, layout = layout }
  log("QUINITYN CIMOTA UPGRADE SETUP PASSED")
end)
script.on_event(defines.events.on_tick, function(event)
  storage.roboport.energy = 100000000
  if storage.passed then
    return
  end
  local surface, force = game.surfaces.nauvis, game.forces.player
  -- Robots return the primitives, their burner fuel and stranded ingredients to storage.
  local network = storage.roboport.logistic_network
  local expected = { [primitive] = 3, coal = 15, stone = 10 }
  local returned, complete = {}, true
  for name, count in pairs(expected) do
    returned[#returned + 1] = name .. "=" .. network.get_item_count(name)
    complete = complete and network.get_item_count(name) == count
  end
  for _, record in pairs(storage.records) do
    complete = complete and replaced(surface, record) ~= nil
  end
  if not complete then
    assert(event.tick < 2500, "robot Cimota upgrades incomplete: " .. table.concat(returned, " "))
    return
  end
  for label, record in pairs(storage.records) do
    check_layout(surface, force, record, label)
  end
  storage.passed = true
  log("QUINITYN CIMOTA UPGRADE PASSED at tick " .. event.tick)
end)
