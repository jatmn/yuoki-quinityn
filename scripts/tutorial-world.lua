-- Operating scenes complement the recipe demonstrations. All resources are
-- staged in this separate preview world; products and transfers are native.
local world = {}

local function make(s, name, x, y, direction)
  local e = assert(
    s.surface.create_entity({
      name = name,
      position = { x, y },
      direction = direction,
      force = s.force,
      create_build_effect_smoke = false,
    }),
    name
  )
  s.entities[#s.entities + 1] = e
  return e
end

local function text(s, value, x, y, scale)
  local object = rendering.draw_text({
    text = value,
    surface = s.surface,
    target = { x, y },
    color = { 1, 1, 1 },
    alignment = "center",
    scale = scale or 1.5,
    use_rich_text = true,
  })
  s.labels[#s.labels + 1] = object
  return object
end

local function power(s, row)
  local source = make(s, "electric-energy-interface", -8, 6)
  source.power_production = 1000000000
  source.electric_buffer_size = 1000000000
  for x = -12, 12, 6 do
    make(s, "substation", x, row or 4)
  end
  text(s, { "quinityn-demo.electric" }, -8, 8, 1)
  return source
end

local function port(s, machine, index, amount, temperature)
  local c = assert(machine.get_fluid_box_pipe_connections(index)[1], machine.name .. " port")
  local pipe = make(s, "pipe", c.target_position.x, c.target_position.y)
  if amount then
    local filter = machine.get_fluid_filter(index)
    if type(filter) == "table" and not filter.object_name then
      filter = filter.fluid
    end
    local name = type(filter) == "string" and filter or filter.name
    s.supplies[#s.supplies + 1] = { pipe = pipe, name = name, amount = amount, temperature = temperature }
    text(s, { "", "[fluid=" .. name .. "] →" }, pipe.position.x, pipe.position.y - 1, 1)
  end
  return pipe
end

local function fuel(machine)
  if machine.burner then
    assert(machine.get_fuel_inventory().insert({ name = "coal", count = 50 }) > 0, machine.name .. " fuel")
  end
end

function world.stop(s)
  for _, object in pairs(s.labels) do
    if object.valid then
      object.destroy()
    end
  end
  for _, entity in pairs(s.entities) do
    if entity.valid then
      entity.destroy()
    end
  end
  -- Construction robots create real entities outside the original entity
  -- list. Remove their work and any flying robots before the next loop.
  for _, entity in pairs(s.surface.find_entities_filtered({ area = { { -24, -14 }, { 24, 14 } }, force = s.force })) do
    entity.destroy()
  end
  if s.build_position then
    for _, entity in
      pairs(s.surface.find_entities_filtered({ position = s.build_position, radius = 1, force = s.force }))
    do
      entity.destroy()
    end
  end
end

function world.start(spec, surface, force)
  local s =
    { spec = spec, surface = surface, force = force, entities = {}, labels = {}, supplies = {}, started = game.tick }
  surface.request_to_generate_chunks({ 0, 0 }, 1)
  surface.force_generate_chunk_requests()
  for _, e in pairs(surface.find_entities_filtered({ area = { { -24, -14 }, { 24, 14 } } })) do
    e.destroy()
  end
  surface.destroy_decoratives({ area = { { -24, -14 }, { 24, 14 } } })
  local tiles = {}
  for x = -24, 24 do
    for y = -14, 14 do
      tiles[#tiles + 1] = { position = { x, y }, name = "quinityn-basalt" }
    end
  end
  surface.set_tiles(tiles)
  surface.daytime = 0
  surface.freeze_daytime = true
  if game.simulation then
    game.simulation.camera_position = { 0, 0 }
    game.simulation.camera_zoom = 0.9
    game.simulation.camera_alt_info = true
  end
  text(s, { spec.rock and "quinityn-demo.mine-ash" or "quinityn-demo.operation-" .. spec.kind }, 0, -10)
  text(s, { "quinityn-demo.supplied-operation" }, 0, 10, 1)
  s.status = text(s, "", 0, 8)
  local kind = spec.kind
  if kind == "landscape" or kind == "mining" or kind == "water" or kind == "disposal" or kind == "foundation" then
    local coast = {}
    for x = -24, 24 do
      for y = -14, -4 do
        coast[#coast + 1] = { position = { x, y }, name = "quinityn-unicomp-sea" }
      end
    end
    surface.set_tiles(coast)
  end
  if kind == "landscape" then
    local terrain = {}
    for x = -24, 24 do
      for y = -14, 14 do
        local shoreline = -5 + math.floor(2 * math.sin(x / 5))
        local tile = y <= shoreline and "quinityn-unicomp-sea"
          or x < -10 and "quinityn-ash"
          or x > 10 and "quinityn-rubble"
          or y > 5 and "quinityn-weathered-soil"
          or "quinityn-ruined-district"
        terrain[#terrain + 1] = { position = { x, y }, name = tile }
      end
    end
    surface.set_tiles(terrain)
    for x = -10, -7 do
      for y = 0, 3 do
        make(s, "y-res1", x, y).amount = 1000
      end
    end
    for x = 6, 9 do
      for y = 0, 3 do
        make(s, "y-res2", x, y).amount = 1000
      end
    end
    make(s, "quinityn-wreck", 0, 0)
    make(s, "quinityn-big-rock", -3, 5)
    make(s, "quinityn-dry-tree", 4, 5)
    text(s, "[item=y-res1] N4", -8, 5)
    text(s, "[item=y-res2] F7", 8, 5)
    text(s, "[fluid=y-liquid-uc2]", 0, -6)
  elseif kind == "mining" then
    s.character = make(s, "character", -2, 0)
    s.target = make(s, spec.rock and "quinityn-big-rock" or "quinityn-wreck", 0, 0)
    s.character.mining_state = { mining = true, position = s.target.position }
    s.phase = "mining"
  elseif kind == "disposal" then
    power(s)
    s.input = make(s, "steel-chest", 0.5, -0.5)
    s.input.insert({ name = "stone", count = 20 })
    s.input.insert({ name = "quinityn-research-data", count = 5 })
    local inserter = make(s, "fast-inserter", 0.5, -1.5, defines.direction.south)
    inserter.use_filters = true
    inserter.set_filter(1, "stone")
    surface.set_tiles({ { position = { 0, -3 }, name = "quinityn-unicomp-sea" } })
  elseif kind == "water" then
    -- Native pump, separator, boiler and steam engine: no injected water,
    -- steam or electricity. The demand fixture makes generation visible.
    s.pump = make(s, "offshore-pump", 0.5, -3.5)
    s.separator = make(s, "quinityn-burner-separator", 0.5, 0.5)
    assert(s.separator.set_recipe("quinityn-water"))
    s.separator.get_fuel_inventory().insert({ name = "y-res2", count = 50 })
    make(s, "pipe", 0.5, -2.5)
    make(s, "pipe", 0.5, -1.5)
    make(s, "pipe", 0.5, 2.5)
    s.boiler = make(s, "boiler", 3.5, 2, defines.direction.north)
    fuel(s.boiler)
    make(s, "pipe", 1.5, 2.5)
    s.generator = make(s, "steam-engine", 3.5, -2.5)
    make(s, "pipe", 3.5, 0.5)
    make(s, "small-electric-pole", 6, 0)
    s.sink = make(s, "radar", 7, 2)
    text(s, "[fluid=y-liquid-uc2] → [fluid=water] → [fluid=steam]", 0, 6)
  elseif kind == "scrubbing" or kind == "filters" then
    power(s, 6)
    s.machine = make(s, "y-electric-air-heater", 0.5, 0.5)
    assert(s.machine.set_recipe(kind == "filters" and "j-airfilter_dirty" or "y-rmvpol"))
    local motor = make(s, "y-emotor-s", -4, 2)
    assert(motor.set_recipe("y-mf1c"))
    for x = -3.5, -1.5 do
      make(s, "pipe", x, 0.5)
    end
    port(s, s.machine, 1, 100)
    text(s, "[fluid=y-mechanical-force]", -5, -1, 1)
    if kind == "filters" then
      s.machine.insert({ name = "j-airfilter", count = 2 })
      s.washer = make(s, "y-dirtwasher", 6.5, 0.5)
      assert(s.washer.set_recipe("j-airfilter_cleaning"))
      s.washer.insert({ name = "y-coal-dust", count = 200 })
      port(s, s.washer, 1, 200)
      make(s, "fast-inserter", 2.5, 0.5, defines.direction.west)
      make(s, "steel-chest", 3.5, 0.5)
      make(s, "fast-inserter", 4.5, 0.5, defines.direction.west)
      local clean = make(s, "fast-inserter", 6.5, 2.5, defines.direction.north)
      clean.use_filters = true
      clean.set_filter(1, "j-airfilter")
      for x = -7.5, 6.5 do
        make(s, "transport-belt", x, 3.5, defines.direction.west)
      end
      for y = -1.5, 3.5 do
        make(s, "transport-belt", -8.5, y, defines.direction.north)
      end
      make(s, "transport-belt", -8.5, -2.5, defines.direction.east)
      for x = -7.5, 0.5 do
        make(s, "transport-belt", x, -2.5, defines.direction.east)
      end
      make(s, "fast-inserter", 0.5, -1.5, defines.direction.north)
      local ash = make(s, "fast-inserter", 8.5, 0.5, defines.direction.west)
      ash.use_filters = true
      ash.set_filter(1, "y-pol-waste")
      s.output = make(s, "steel-chest", 9.5, 0.5)
      text(s, "[item=j-airfilter] ← [item=j-airfilter_dirty] → [item=y-pol-waste]", 2, -6)
    else
      make(s, "fast-inserter", 2.5, 0.5, defines.direction.west)
      s.output = make(s, "steel-chest", 3.5, 0.5)
    end
  elseif kind == "thermal" then
    power(s, 6)
    s.machine = make(s, "y_charger", 0.5, 0.5)
    assert(s.machine.set_recipe("y_block_heat"))
    s.machine.insert({ name = "y_block_cold", count = 10 })
    s.machine.insert({ name = "y-richdust", count = 2 })
    s.smelter = make(s, "y_smelter", 6.5, 0.5)
    assert(s.smelter.set_recipe("y_hps_pureiron"))
    s.smelter.insert({ name = "y-pure-iron", count = 90 })
    port(s, s.smelter, 1, 100)
    make(s, "fast-inserter", 2.5, 0.5, defines.direction.west)
    make(s, "steel-chest", 3.5, 0.5)
    make(s, "fast-inserter", 4.5, 0.5, defines.direction.west)
    local cold = make(s, "fast-inserter", 6.5, -1.5, defines.direction.south)
    cold.use_filters = true
    cold.set_filter(1, "y_block_cold")
    for x = 0.5, 6.5 do
      make(s, "transport-belt", x, -2.5, defines.direction.west)
    end
    make(s, "fast-inserter", 0.5, -1.5, defines.direction.north)
    local products = make(s, "fast-inserter", 8.5, 0.5, defines.direction.west)
    products.use_filters = true
    products.set_filter(1, "iron-plate")
    products.set_filter(2, "y-slag")
    s.output = make(s, "steel-chest", 9.5, 0.5)
  elseif kind == "mf" then
    power(s, 6)
    s.machine = make(s, "y-sfe", 0.5, -2.5)
    assert(s.machine.set_recipe("y-mf1f"))
    fuel(s.machine)
    s.consumer = make(s, "y-mwater-pump", 1, 2)
    assert(s.consumer.set_recipe("y-mfwater"))
    make(s, "y-mftrans-shaft", 0.5, -0.5)
    make(s, "y-mftrans-shaft", 0.5, 0.5)
    s.output = port(s, s.consumer, 2)
  elseif kind == "power" or kind == "storage" then
    s.machine = make(s, spec.entity, 0, 0)
    make(s, "substation", 4, 0)
    s.sink = make(s, "radar", 7, 0)
    fuel(s.machine)
    if kind == "storage" then
      s.source = make(s, "electric-energy-interface", -3, 0)
      s.source.electric_interface_mode = defines.electric_interface_mode.secondary_output
      s.source.power_production = 100000000
      s.source.electric_buffer_size = 100000000
    elseif s.machine.type == "generator" then
      port(s, s.machine, 1, 100, s.machine.prototype.maximum_temperature)
    end
    text(s, s.machine.localised_name, 0, -5)
  elseif kind == "boiler" then
    s.machine = make(s, spec.entity, 0, 0)
    fuel(s.machine)
    port(s, s.machine, 1, 100)
    s.output = port(s, s.machine, 2)
    text(s, "[fluid=water] → [fluid=steam]", 0, 5)
  elseif kind == "tank" then
    s.machine = make(s, spec.entity, 0, 0)
    local c = s.machine.get_fluid_box_pipe_connections(1)
    s.input = make(s, "pipe", c[1].target_position.x, c[1].target_position.y)
    s.supplies[1] = { pipe = s.input, name = "water", amount = 1000 }
    text(s, s.machine.localised_name, 0, -5)
  elseif kind == "transport" then
    power(s)
    s.input = make(s, "steel-chest", -3, 0)
    s.input.insert({ name = "y-res1", count = 20 })
    s.machine = make(s, spec.entity, 0, 0, defines.direction.west)
    -- Respect the selected inserter's real reach and offsets.
    s.input.teleport(s.machine.pickup_position)
    s.output = make(s, "steel-chest", s.machine.drop_position.x, s.machine.drop_position.y)
    text(s, s.machine.localised_name, 0, -4)
  elseif kind == "robots" then
    power(s, 6)
    local expander = spec.port == "j_yi_roboport1"
    local roboport = make(s, expander and "yi_roboport" or spec.port or "yi_roboport", expander and -2 or 0, 0)
    if expander then
      surface.request_to_generate_chunks({ 90, 0 }, 1)
      surface.force_generate_chunk_requests()
      local ground = {}
      for x = 75, 94 do
        for y = -6, 8 do
          ground[#ground + 1] = { position = { x, y }, name = "quinityn-basalt" }
        end
      end
      surface.set_tiles(ground)
      make(s, spec.port, 80, 0)
      local source = make(s, "electric-energy-interface", 84, 4)
      source.power_production = 100000000
      source.electric_buffer_size = 100000000
      make(s, "substation", 80, 4)
      if game.simulation then
        game.simulation.camera_position = { 40, 0 }
        game.simulation.camera_zoom = 0.25
      end
      text(s, { "quinityn-demo.expanded-network" }, 40, -12, 4)
    end
    roboport.insert({ name = spec.robot or "yi_construction-robot", count = 5 })
    s.input = make(s, spec.provider or "passive-provider-chest", -5, 0)
    s.input.insert({ name = "stone-wall", count = 10 })
    if spec.requester then
      roboport.insert({ name = "yi_logistic-robot", count = 5 })
      s.output = make(s, spec.requester, 5, 0)
      local section = s.output.get_requester_point().add_section()
      section.set_slot(1, { value = { type = "item", name = "stone-wall", quality = "normal" }, min = 5 })
    else
      s.build_position = { expander and 90 or 5, -2 }
      s.ghost = s.surface.create_entity({
        name = "entity-ghost",
        inner_name = "stone-wall",
        position = s.build_position,
        force = s.force,
      })
      s.entities[#s.entities + 1] = assert(s.ghost)
    end
    text(s, s.input.localised_name, -5, -4)
  elseif kind == "chest" then
    power(s)
    s.machine = make(s, spec.entity, 3, 0)
    local left = math.floor(s.machine.bounding_box.left_top.x)
    local inserter = make(s, "fast-inserter", left - 0.5, 0.5, defines.direction.west)
    s.input = make(s, "steel-chest", inserter.pickup_position.x, inserter.pickup_position.y)
    s.input.insert({ name = "y-res1", count = 200 })
    text(s, s.machine.localised_name, 3, -4)
  elseif kind == "turret" then
    power(s)
    s.machine = make(s, spec.entity, -4, 0)
    if spec.ammo then
      assert(s.machine.insert({ name = spec.ammo, count = 20 }) > 0)
    end
    s.target = make(s, "quinityn-big-biter", 6, 0)
    s.target.force = game.forces.enemy
    s.initial_health = s.target.health
    text(s, spec.ammo and "[item=" .. spec.ammo .. "]" or { "quinityn-demo.electric" }, -4, -4)
  elseif kind == "equipment" then
    s.character = make(s, "character", 0, 0)
    local armor = s.character.get_inventory(defines.inventory.character_armor)
    armor.insert({ name = spec.entity, count = 1 })
    local grid = assert(armor[1].grid)
    s.shield = assert(grid.put({ name = spec.shield or "yi_equip_shield_a" }))
    s.legs = assert(grid.put({ name = "yi_equip_legs_a" }))
    if spec.generator then
      assert(grid.put({ name = spec.generator }))
    else
      for _ = 1, 60 do
        assert(grid.put({ name = "solar-panel-equipment" }))
      end
    end
    text(s, {
      "",
      "[item="
        .. (spec.generator or "solar-panel-equipment")
        .. "] → [item="
        .. s.shield.name
        .. "] + [item=yi_equip_legs_a]",
    }, 0, -6)
    text(s, armor[1].prototype.localised_name, 0, -4)
  elseif kind == "foundation" then
    power(s)
    local roboport = make(s, "roboport", 0, 0)
    roboport.insert({ name = "construction-robot", count = 5 })
    local chest = make(s, "passive-provider-chest", 4, 0)
    chest.insert({ name = "quinityn-foundation", count = 30 })
    s.foundation_x = -5
  elseif kind == "research" then
    power(s)
    s.machine = make(s, "lab", 0, 0)
    for _, name in ipairs({
      "automation-science-pack",
      "logistic-science-pack",
      "chemical-science-pack",
      "production-science-pack",
      "utility-science-pack",
      "space-science-pack",
      "quinityn-research-data",
    }) do
      s.machine.insert({ name = name, count = 100 })
    end
    assert(force.add_research("quinityn-mining-productivity"))
  else
    error("Unknown tutorial operation: " .. kind)
  end
  return s
end

function world.update(s)
  local elapsed = game.tick - s.started
  for _, supply in pairs(s.supplies) do
    supply.pipe.insert_fluid({ name = supply.name, amount = supply.amount, temperature = supply.temperature })
  end
  local kind = s.spec.kind
  if kind == "landscape" then
    if game.simulation then
      game.simulation.camera_position = { math.sin(elapsed / 360) * 2, 0 }
    end
    s.proven = elapsed > 120
  elseif kind == "mining" then
    if s.target.valid then
      s.character.update_selected_entity(s.target.position)
      s.character.mining_state = { mining = true, position = s.target.position }
    elseif s.spec.rock then
      s.proven = s.character.get_item_count("y-pol-waste") > 0
      s.status.text = "[item=y-pol-waste]"
    elseif s.phase == "mining" then
      s.character.mining_state = { mining = false }
      assert(s.character.get_item_count("quinityn-salvage") > 0)
      assert(s.character.begin_crafting({ recipe = "quinityn-hand-sort", count = 4 }) == 4)
      s.phase = "sorting"
    elseif s.character.crafting_queue_size == 0 then
      s.proven = s.character.get_item_count("y-res1") >= 8 and s.character.get_item_count("y-res2") >= 8
      s.status.text = "[item=y-res1] + [item=y-res2] + [item=stone] + [item=wood]"
    end
  elseif kind == "water" then
    s.proven = s.separator.products_finished > 0 and s.sink.energy > 0
    s.status.text = { "quinityn-demo.power-value", math.floor(s.sink.energy) }
  elseif kind == "power" then
    s.proven = s.proven or s.sink.energy > 0
    s.status.text = { "quinityn-demo.power-value", math.floor(s.sink.energy) }
  elseif kind == "scrubbing" then
    s.proven = s.output.get_item_count("y-pol-waste") > 0
  elseif kind == "filters" then
    -- Only two clean filters were supplied: a third completed wash proves reuse.
    s.proven = s.washer.products_finished >= 3 and s.output.get_item_count("y-pol-waste") >= 18
  elseif kind == "thermal" then
    if not s.first_charge and s.machine.products_finished > 0 then
      s.first_charge = s.machine.products_finished
    end
    s.proven = s.first_charge
      and s.machine.products_finished > s.first_charge
      and s.output.get_item_count("iron-plate") >= 180
  elseif kind == "mf" then
    s.proven = s.machine.products_finished > 0
      and s.consumer.products_finished > 0
      and s.output.get_fluid_count("water") > 0
  elseif kind == "storage" then
    local energy = s.machine.energy
    if elapsed < 300 then
      s.charged = math.max(s.charged or 0, energy)
    else
      if s.source.valid then
        s.source.destroy()
      end
      s.proven = s.charged > 0 and energy < s.charged
    end
    s.status.text = { "quinityn-demo.storage-value", math.floor(energy / 1000) }
  elseif kind == "boiler" then
    s.proven = s.output.get_fluid_count("steam") > 0
  elseif kind == "tank" then
    s.proven = s.machine.get_fluid_count("water") > 0
    s.status.text = {
      "quinityn-demo.fluid-value",
      math.floor(s.machine.get_fluid_count("water")),
      s.machine.get_fluid_capacity(1),
    }
  elseif kind == "transport" then
    s.proven = s.output.get_item_count("y-res1") > 0
  elseif kind == "robots" then
    if s.output then
      s.proven = s.output.get_item_count("stone-wall") >= 5
    else
      s.proven = s.surface.count_entities_filtered({ name = "stone-wall", position = s.build_position, radius = 1 })
        == 1
    end
  elseif kind == "chest" then
    local inventory = s.machine.get_inventory(defines.inventory.chest)
    s.proven = inventory.get_item_count("y-res1") > 0
    s.status.text = { "quinityn-demo.chest-value", #inventory, inventory.get_item_count("y-res1") }
  elseif kind == "disposal" then
    s.proven = s.input.get_item_count("stone") == 0 and s.input.get_item_count("quinityn-research-data") == 5
  elseif kind == "turret" then
    s.proven = not s.target.valid or s.target.health < s.initial_health
  elseif kind == "equipment" then
    if s.character.position.x > 5 then
      s.walking_direction = defines.direction.west
    elseif s.character.position.x < -5 or not s.walking_direction then
      s.walking_direction = defines.direction.east
    end
    s.character.walking_state = { walking = true, direction = s.walking_direction }
    s.proven = elapsed > 120 and s.character.position.x ~= 0 and s.shield.shield > 0 and s.legs.energy > 0
    s.status.text = { "quinityn-demo.shield-value", math.floor(s.shield.shield) }
  elseif kind == "foundation" then
    if elapsed % 30 == 0 and s.foundation_x < 5 then
      s.foundation_x = s.foundation_x + 1
      local ghost = s.surface.create_entity({
        name = "tile-ghost",
        inner_name = "quinityn-foundation",
        position = { s.foundation_x, -4 },
        force = s.force,
      })
      s.entities[#s.entities + 1] = assert(ghost)
    end
    s.proven = s.surface.get_tile(0, -4).name == "quinityn-foundation"
  elseif kind == "research" then
    s.proven = s.force.research_progress > 0
    s.status.text = { "quinityn-demo.research-value", string.format("%.2f", s.force.research_progress * 100) }
  end
  return s.proven and elapsed >= 600
end

return world
