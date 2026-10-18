local function check(condition, message)
  if not condition then
    error("QUINITYN TEST FAILED: " .. message)
  end
  log("QUINITYN PASS: " .. message)
end

local function prepare_pad(surface, position, tile_name)
  local origin_x = position.x or position[1]
  local origin_y = position.y or position[2]
  surface.request_to_generate_chunks({ origin_x, origin_y }, 1)
  surface.force_generate_chunk_requests()
  local x0 = math.floor(origin_x) - 3
  local y0 = math.floor(origin_y) - 3
  local tiles = {}
  for x = x0, x0 + 6 do
    for y = y0, y0 + 6 do
      tiles[#tiles + 1] = { name = tile_name, position = { x, y } }
    end
  end
  surface.set_tiles(tiles)
  for _, entity in ipairs(surface.find_entities_filtered({ area = { { x0, y0 }, { x0 + 7, y0 + 7 } } })) do
    entity.destroy()
  end
end

local function place_loaded_crusher(surface, position, tile_name)
  prepare_pad(surface, position, tile_name)
  local machine = surface.create_entity({
    name = "y-crusher",
    position = position,
    force = game.forces.player,
    raise_built = true,
  })
  check(machine and machine.valid, "migration crusher created on " .. surface.name)
  machine.set_recipe("quinityn-hand-sort")
  check(
    machine.get_recipe().name == "quinityn-hand-sort",
    "migration crusher selects salvage sorting on " .. surface.name
  )
  machine.get_fuel_inventory().insert({ name = "coal", count = 20 })
  check(
    machine.insert({ name = "quinityn-salvage", count = 1 }) == 1,
    "migration crusher holds salvage on " .. surface.name
  )
  return machine
end

local function ground_salvage(surface, position)
  local count = 0
  for _, entity in
    ipairs(surface.find_entities_filtered({
      name = "item-on-ground",
      area = { { position.x - 3, position.y - 3 }, { position.x + 3, position.y + 3 } },
    }))
  do
    if entity.stack and entity.stack.name == "quinityn-salvage" then
      count = count + entity.stack.count
    end
  end
  return count
end

script.on_init(function()
  local force = game.forces.player
  force.recipes["quinityn-hand-sort"].enabled = true
  place_loaded_crusher(game.surfaces.nauvis, { x = 0, y = 0 }, "grass-1")
  local quinityn = game.planets.quinityn.create_surface()
  place_loaded_crusher(quinityn, { x = 8, y = 8 }, "quinityn-basalt")
  -- This save stands in for one written before the one-shot migration flag existed.
  remote.call("yuoki-quinityn", "clear_salvage_sort_migration_flag")
  log("QUINITYN SALVAGE SORT MIGRATION SETUP")
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick ~= 240 then
    return
  end
  local nauvis_crusher =
    game.surfaces.nauvis.find_entities_filtered({ name = "y-crusher", position = { 0, 0 }, radius = 1 })[1]
  check(nauvis_crusher and nauvis_crusher.valid, "preselected nauvis crusher still exists")
  check(not nauvis_crusher.get_recipe(), "migration clears salvage sorting off quinityn")
  check(nauvis_crusher.products_finished == 0, "preselected offworld crusher finishes no salvage sorts")
  check(ground_salvage(game.surfaces.nauvis, nauvis_crusher.position) == 1, "cleared crusher spills its salvage")
  local quinityn = game.planets.quinityn.surface or game.surfaces.quinityn
  local home = quinityn.find_entities_filtered({ name = "y-crusher", position = { 8, 8 }, radius = 1 })[1]
  check(
    home and home.get_recipe() and home.get_recipe().name == "quinityn-hand-sort",
    "migration keeps salvage sorting on quinityn"
  )
  log("QUINITYN SALVAGE SORT MIGRATION PASSED")
end)
