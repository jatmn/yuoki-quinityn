-- Native nest spawning, colony construction and damage, with isolated flat
-- arenas. This fixture does not claim a timed autonomous expansion playthrough.
local function check(ok, message)
  assert(ok, "ENEMY TEST FAILED: " .. message)
  log("QUINITYN ENEMY PASS: " .. message)
end

script.on_init(function()
  storage.arenas = {}
  for _, planet in ipairs({ "nauvis", "quinityn" }) do
    local surface = game.planets[planet].create_surface()
    surface.request_to_generate_chunks({ 0, 0 }, 3)
    surface.force_generate_chunk_requests()
    for _, entity in pairs(surface.find_entities_filtered({ area = { { -80, -80 }, { 80, 80 } } })) do
      entity.destroy()
    end
    local tiles = {}
    for x = -80, 80 do
      for y = -80, 80 do
        tiles[#tiles + 1] = { name = "stone-path", position = { x, y } }
      end
    end
    surface.set_tiles(tiles)
    local prefix = planet == "quinityn" and "quinityn-" or ""
    game.forces.enemy.set_evolution_factor(1, surface)
    for i, kind in ipairs({ "biter", "spitter" }) do
      surface.create_entity({ name = prefix .. kind .. "-spawner", position = { -50, i * 20 }, force = "enemy" })
    end
    -- Exercise the engine's build_base command, which consumes buildable_entities.
    local group = surface.create_unit_group({ position = { 30, 30 }, force = "enemy" })
    for i = 1, 24 do
      local unit = surface.create_entity({
        name = prefix .. "behemoth-biter",
        position = { 25 + i % 6, 25 + math.floor(i / 6) },
        force = "enemy",
      })
      group.add_member(unit)
    end
    group.set_command({
      type = defines.command.build_base,
      destination = { 35, 35 },
      distraction = defines.distraction.none,
    })
    group.start_moving()
    storage.arenas[#storage.arenas + 1] = { surface = surface.index, prefix = prefix, spawned = 0 }

    -- Native laser damage covers every size/type, without healing between hits.
    local names = { "biter-spawner", "spitter-spawner" }
    for _, size in ipairs({ "small", "medium", "big", "behemoth" }) do
      for _, kind in ipairs({ "biter", "spitter", "worm-turret" }) do
        names[#names + 1] = size .. "-" .. kind
      end
    end
    for _, name in ipairs(names) do
      local ordinary = surface.create_entity({ name = name, position = { 0, -40 }, force = "enemy" })
      local native = ordinary.damage(4, game.forces.player, "laser")
      ordinary.destroy()
      local entity = surface.create_entity({ name = prefix .. name, position = { 0, -40 }, force = "enemy" })
      local before = entity.health
      entity.damage(4, game.forces.player, "laser")
      local expected = native * (planet == "quinityn" and 0.95 or 1)
      check(math.abs(before - entity.health - expected) < 0.001, prefix .. name .. " laser damage = " .. expected)
      entity.destroy()
    end
  end
end)

script.on_event(defines.events.on_entity_spawned, function(event)
  -- The capture phase deliberately introduces ordinary nests on Quinityn.
  if storage.captures then
    return
  end
  for _, arena in ipairs(storage.arenas) do
    if event.entity.surface.index == arena.surface then
      check(
        (event.entity.name:find("^quinityn%-") ~= nil) == (arena.prefix ~= ""),
        "native nest offspring belongs to " .. event.entity.surface.name
      )
      arena.spawned = arena.spawned + 1
    end
  end
end)

script.on_event(defines.events.on_tick, function()
  if storage.captures then
    for _, case in ipairs(storage.captures) do
      if case.nest.valid then
        case.character.update_selected_entity(case.position)
        case.character.shooting_state = { state = defines.shooting.shooting_enemies, position = case.position }
      end
      if game.tick == 4800 then
        check(not case.nest.valid, "capture rocket converted " .. case.name)
        local captive = game.planets.quinityn.surface.find_entity("captive-biter-spawner", case.position)
        check(captive and captive.force == game.forces.player, "native captive destination for " .. case.name)
        check(case.character.get_item_count("capture-robot-rocket") == 0, "capture rocket consumed for " .. case.name)
      end
    end
    if game.tick == 4800 then
      log("QUINITYN ENEMY TESTS PASSED")
    end
    return
  end
  if game.tick ~= 2400 then
    return
  end
  for _, arena in ipairs(storage.arenas) do
    local surface = game.surfaces[arena.surface]
    check(arena.spawned > 0, "nests spawned native units on " .. surface.name)
    local colonies =
      surface.find_entities_filtered({ area = { { 10, 10 }, { 70, 70 } }, type = { "unit-spawner", "turret" } })
    check(#colonies > 0, "native build_base constructed a colony on " .. surface.name)
    for _, entity in
      pairs(surface.find_entities_filtered({ force = "enemy", type = { "unit", "unit-spawner", "turret" } }))
    do
      check(
        (entity.name:find("^quinityn%-") ~= nil) == (arena.prefix ~= ""),
        "spawned and expanded population stays local: " .. entity.name
      )
    end
  end
  -- Normal enemy targeting must accept both vanilla and new nests on Quinityn.
  -- Forced firing or directly creating capture robots bypasses the target filter.
  local surface = game.planets.quinityn.surface
  surface.peaceful_mode = true
  storage.captures = {}
  for i, name in ipairs({ "biter-spawner", "spitter-spawner", "quinityn-biter-spawner", "quinityn-spitter-spawner" }) do
    local position = { x = -100 + i * 40, y = -60 }
    local nest = surface.create_entity({ name = name, position = position, force = "enemy" })
    local character = surface.create_entity({ name = "character", position = { position.x, -48 }, force = "player" })
    character.destructible = false
    character.get_inventory(defines.inventory.character_guns).insert({ name = "rocket-launcher", count = 1 })
    character.get_inventory(defines.inventory.character_ammo).insert({ name = "capture-robot-rocket", count = 1 })
    storage.captures[#storage.captures + 1] = { name = name, position = position, nest = nest, character = character }
  end
end)
