-- Native spawning/death fixture. Flat arenas isolate behavior, not game balance.
local function check(ok, message)
  assert(ok, "STOMP-A-TRON TEST FAILED: " .. message)
  log("QUINITYN STOMP-A-TRON PASS: " .. message)
end

local sizes = { "small", "medium", "big" }
local evolutions = { 0, 0.45, 0.8, 1 }
local stage_ticks = 3600
local function name(size)
  return "quinityn-" .. size .. "-stomp-a-tron"
end

local function clear_population(surface)
  for _, entity in pairs(surface.find_entities_filtered({ type = { "unit", "spider-unit" } })) do
    entity.destroy()
  end
end

script.on_init(function()
  storage.spawned = {}
  storage.foreign_spawns = {}
  storage.stage = 1
  storage.stage_spawns = {}
  storage.by_nest = {}
  for _, planet in ipairs({ "quinityn", "nauvis", "gleba", "vulcanus", "fulgora", "aquilo" }) do
    local surface = game.planets[planet].create_surface()
    surface.request_to_generate_chunks({ 0, 0 }, 4)
    surface.force_generate_chunk_requests()
    for _, entity in pairs(surface.find_entities_filtered({ area = { { -120, -120 }, { 120, 120 } } })) do
      entity.destroy()
    end
    local tiles = {}
    for x = -100, 100 do
      for y = -100, 100 do
        tiles[#tiles + 1] = { name = "stone-path", position = { x, y } }
      end
    end
    surface.set_tiles(tiles)
    game.forces.enemy.set_evolution_factor(planet == "quinityn" and 0 or 1, surface)
    for _, kind in ipairs({ "biter", "spitter" }) do
      for i = 1, (planet == "quinityn" and 8 or 1) do
        surface.create_entity({
          name = "quinityn-" .. kind .. "-spawner",
          position = { -80 + i * 18, kind == "biter" and -50 or 50 },
          force = "enemy",
        })
      end
    end
  end
  -- The real die() path must drop both specified products and no offspring.
  local surface = game.planets.quinityn.surface
  for i, size in ipairs(sizes) do
    local salvage = { { 1, 2 }, { 3, 4 }, { 6, 9 } }
    local data = { { "y-crystal2", 1, 5 }, { "y-crystal2", 4, 7 }, { "y_crystal2_combined", 1, 1 } }
    for _ = 1, 12 do
      local unit = surface.create_entity({ name = name(size), position = { 0, 0 }, force = "enemy" })
      check(unit ~= nil, "created half-size " .. size)
      local before = unit.health
      unit.damage(100, game.forces.player, "laser")
      check(math.abs(before - unit.health - (100 - ({ 3, 7, 11 })[i])) < 0.001, size .. " native laser resistance")
      unit.die(game.forces.player)
      local drops = {}
      for _, item in
        pairs(surface.find_entities_filtered({ type = "item-entity", area = { { -15, -15 }, { 15, 15 } } }))
      do
        drops[item.stack.name] = (drops[item.stack.name] or 0) + item.stack.count
        item.destroy()
      end
      check(
        drops["quinityn-salvage"]
          and drops["quinityn-salvage"] >= salvage[i][1]
          and drops["quinityn-salvage"] <= salvage[i][2],
        size .. " salvage range"
      )
      check(
        drops[data[i][1]] and drops[data[i][1]] >= data[i][2] and drops[data[i][1]] <= data[i][3],
        size .. " ancient data range"
      )
      drops["quinityn-salvage"] = nil
      drops[data[i][1]] = nil
      check(next(drops) == nil, size .. " no unexpected loot")
      check(surface.count_entities_filtered({
        type = { "unit", "spider-unit", "simple-entity" },
        area = { { -15, -15 }, { 15, 15 } },
      }) == 0, size .. " no wrigglers or mineable egg shell")
    end
  end
end)

script.on_event(defines.events.on_entity_spawned, function(event)
  local entity = event.entity
  -- Production's earlier handler removes forbidden off-planet Stomp-a-trons.
  if not entity.valid then
    return
  end
  local planet = entity.surface.planet.name
  local size = entity.name:match("^quinityn%-(%a+)%-stomp%-a%-tron$")
  if planet ~= "quinityn" then
    check(not size, "no Stomp-a-tron survives spawning on " .. planet)
    storage.foreign_spawns[planet] = (storage.foreign_spawns[planet] or 0) + 1
  else
    local evolution = evolutions[math.min(storage.stage, #evolutions)]
    storage.stage_spawns[storage.stage] = (storage.stage_spawns[storage.stage] or 0) + 1
    if size then
      check(size ~= "big" or evolution > 0.5, "big respects evolution gate")
      check(size ~= "medium" or evolution > 0.2, "medium respects evolution gate")
      storage.spawned[size] = (storage.spawned[size] or 0) + 1
      local nest = event.spawner.name
      storage.by_nest[nest] = (storage.by_nest[nest] or 0) + 1
    end
  end
end)

script.on_event(defines.events.on_tick, function()
  if game.tick % 120 == 0 then
    -- Free nest population slots while observing real, unmodified cooldowns.
    for _, planet in pairs(game.planets) do
      if planet.surface then
        clear_population(planet.surface)
      end
    end
  end
  if game.tick == 0 or game.tick % stage_ticks ~= 0 or storage.stage > #evolutions then
    return
  end
  local surface = game.planets.quinityn.surface
  for _, entity in
    pairs(surface.find_entities_filtered({ type = { "unit", "spider-unit", "unit-spawner", "simple-entity" } }))
  do
    check(
      not entity.name:find("wriggler")
        and not entity.name:find("gleba%-spawner")
        and not entity.name:find("stomper%-shell"),
      "no inherited Gleba reproduction"
    )
  end
  storage.stage = storage.stage + 1
  if storage.stage <= #evolutions then
    game.forces.enemy.set_evolution_factor(evolutions[storage.stage], surface)
    return
  end
  for _, size in ipairs(sizes) do
    check((storage.spawned[size] or 0) > 0, "native nests produced " .. size)
  end
  for stage = 1, #evolutions do
    check((storage.stage_spawns[stage] or 0) > 0, "native spawning exercised at evolution " .. evolutions[stage])
  end
  for _, kind in ipairs({ "biter", "spitter" }) do
    check((storage.by_nest["quinityn-" .. kind .. "-spawner"] or 0) > 0, kind .. " nests produce hybrids")
  end
  for _, planet in ipairs({ "nauvis", "gleba", "vulcanus", "fulgora", "aquilo" }) do
    check((storage.foreign_spawns[planet] or 0) > 0, "transplanted nests exercised on " .. planet)
    check(
      game.planets[planet].surface.count_entities_filtered({ name = { name("small"), name("medium"), name("big") } })
        == 0,
      "no hybrids on " .. planet
    )
  end
  log("QUINITYN STOMP-A-TRON TESTS PASSED")
end)
