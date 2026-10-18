-- Native tutorial worlds only; never registered with the real save's control.lua.
local processes = require("__yuoki-quinityn__/scripts/biology-processes")
local demo = {}

local function label(state, text, position, color, scale)
  local object = rendering.draw_text({
    text = text,
    surface = state.surface,
    target = position,
    color = color or { 1, 1, 1 },
    scale = scale or 1.8,
    alignment = "center",
    use_rich_text = true,
  })
  state.labels[#state.labels + 1] = object
  return object
end

local function entity(state, name, position, direction)
  local result = assert(
    state.surface.create_entity({
      name = name,
      position = position,
      direction = direction,
      force = state.force,
      create_build_effect_smoke = false,
    }),
    "Cannot place biology demonstration entity: " .. name
  )
  state.entities[#state.entities + 1] = result
  return result
end

local function research(force, name)
  local technology = assert(force.technologies[name], name)
  if technology.researched then
    return
  end
  for _, parent in pairs(technology.prerequisites) do
    research(force, parent.name)
  end
  technology.researched = true
end

local function clear(state)
  for _, object in pairs(state.labels) do
    object.destroy()
  end
  for _, object in pairs(state.entities) do
    if object.valid then
      object.destroy()
    end
  end
  state.labels, state.entities = {}, {}
end

local function amounts(state, parts, x)
  for i, part in ipairs(parts) do
    local icon = "[" .. part.type .. "=" .. part.name .. "]"
    local prototype = prototypes[part.type][part.name]
    label(
      state,
      { "", icon, " ", string.format("%.6g", part.amount or part.amount_min), " ", prototype.localised_name },
      { x, -2.5 + i * 1.1 },
      nil,
      1.5
    )
  end
end

local function begin_step(state)
  clear(state)
  local step = processes[state.stage][state.step]
  local recipe = prototypes.recipe[step[2]]
  assert(state.force.recipes[step[2]].enabled, "Tutorial recipe is not researched: " .. step[2])
  state.recipe = step[2]
  state.started = game.tick
  state.completed, state.skipped_wait = nil, false
  local machine = entity(state, step[1], { 0, 0 })
  state.machine = machine
  if machine.type == "assembling-machine" then
    assert(machine.set_recipe(step[2]), "Tutorial machine rejects " .. step[2])
  end
  state.seconds = recipe.energy / machine.crafting_speed
  label(state, {
    "",
    "[technology=quinityn-" .. state.stage .. "] ",
    { "technology-name.quinityn-" .. state.stage },
    "  ",
    state.step,
    "/",
    #processes[state.stage],
  }, { 0, -7 })
  label(state, { "", "[recipe=" .. step[2] .. "] ", recipe.localised_name }, { 0, -6 })
  label(state, { "quinityn-demo.inputs" }, { -10, -3.3 }, { 0.6, 0.9, 1 })
  label(state, { "quinityn-demo.outputs" }, { 10, -3.3 }, { 0.7, 1, 0.6 })
  amounts(state, recipe.ingredients, -10)
  amounts(state, recipe.products, 10)
  label(state, machine.localised_name, { 0, 4.6 })
  label(state, { "quinityn-demo.duration", string.format("%.1f", state.seconds) }, { 0, 5.5 })
  label(state, { "quinityn-demo." .. state.stage }, { 0, 7.2 }, { 1, 0.85, 0.5 }, 1.3)
  label(state, { "quinityn-demo.staged" }, { 0, 8.1 }, { 0.8, 0.8, 0.8 }, 1.2)
  state.status = label(state, { "quinityn-demo.running" }, { 0, -4.7 }, { 0.7, 1, 0.6 })

  -- An actual powered network, with a clearly labelled editor energy source.
  local power = entity(state, "electric-energy-interface", { -4, 4 })
  power.power_production = 100000000
  power.electric_buffer_size = 100000000
  entity(state, "substation", { -4, 1 })
  if machine.burner then
    machine.get_fuel_inventory().insert({ name = "coal", count = 50 })
  end
  label(state, { "quinityn-demo." .. (machine.burner and "fuel" or "electric") }, { -5, 6.3 }, nil, 1)

  -- A real input chest and inserter make consumption visible. Native crafting
  -- consumes exact supplied quantities; every output remains in the scene.
  local left = math.floor(machine.bounding_box.left_top.x)
  local input_chest = entity(state, "steel-chest", { left - 1.5, machine.position.y })
  entity(state, "fast-inserter", { left - 0.5, machine.position.y }, defines.direction.west)
  entity(state, "small-electric-pole", { left - 0.5, machine.position.y + 2 })
  for _, part in ipairs(recipe.ingredients) do
    if part.type == "item" then
      assert(input_chest.insert({ name = part.name, count = part.amount }) == part.amount, part.name)
    end
  end
  local edge = math.ceil(machine.bounding_box.right_bottom.x)
  entity(state, "fast-inserter", { edge + 0.5, machine.position.y }, defines.direction.west)
  state.chest = entity(state, "steel-chest", { edge + 1.5, machine.position.y })
  entity(state, "small-electric-pole", { edge + 0.5, machine.position.y + 2 })

  -- Attach real pipes at the engine-reported ports, never guessed sprite
  -- coordinates. Each input has a finite, labelled staged reservoir. Outputs
  -- remain separate; no script inserts products or clears blocked outputs.
  state.fluids = {}
  for index = 1, machine.fluids_count do
    local filter = machine.get_fluid_filter(index)
    -- 2.1.21 returns FluidFilter; 2.1.22 returns its FluidID directly.
    if type(filter) == "table" and not filter.object_name then
      filter = filter.fluid
    end
    local fluid_name = type(filter) == "string" and filter or filter and filter.name
    if fluid_name then
      local connections = machine.get_fluid_box_pipe_connections(index)
      local connection = connections and connections[1]
      if connection then
        local pipe = entity(state, "pipe", connection.target_position)
        local input
        for _, part in ipairs(recipe.ingredients) do
          if part.type == "fluid" and part.name == fluid_name then
            input = part
          end
        end
        state.fluids[#state.fluids + 1] = {
          pipe = pipe,
          name = fluid_name,
          remaining = input and input.amount or 0,
          temperature = input and (input.temperature or input.minimum_temperature),
        }
        local pos = pipe.position
        label(
          state,
          { "", input and "IN " or "OUT ", "[fluid=" .. fluid_name .. "]" },
          { pos.x, pos.y + (pos.y < 0 and -0.8 or 0.6) },
          { 0.6, 0.9, 1 },
          1
        )
      end
    end
  end
end

function demo.start(stage, surface, force, full_duration)
  assert(processes[stage], stage)
  local state = {
    stage = stage,
    step = 1,
    surface = surface or game.surfaces[1],
    force = force or game.forces.player,
    labels = {},
    entities = {},
    full_duration = full_duration,
  }
  research(state.force, "quinityn-" .. stage)
  -- Preview logistics are accelerated, explicitly labelled separately from
  -- the unmodified machine recipe and its full-duration regression.
  state.force.inserter_stack_size_bonus = 254
  state.surface.request_to_generate_chunks({ 0, 0 }, 1)
  state.surface.force_generate_chunk_requests()
  for _, obstacle in
    pairs(state.surface.find_entities_filtered({
      area = { { -16, -10 }, { 16, 10 } },
      type = { "tree", "simple-entity", "resource" },
    }))
  do
    obstacle.destroy()
  end
  state.surface.daytime = 0
  state.surface.freeze_daytime = true
  state.surface.destroy_decoratives({ area = { { -16, -10 }, { 16, 10 } } })
  local tiles = {}
  for x = -16, 16 do
    for y = -10, 10 do
      tiles[#tiles + 1] = { name = "quinityn-basalt", position = { x, y } }
    end
  end
  state.surface.set_tiles(tiles)
  if game.simulation then
    game.simulation.camera_position = { 0, 0.5 }
    game.simulation.camera_zoom = 1
    game.simulation.camera_alt_info = true
  end
  begin_step(state)
  return state
end

function demo.update(state)
  local machine = state.machine
  for _, fluid in ipairs(state.fluids) do
    if fluid.remaining > 0 then
      local added = fluid.pipe.insert_fluid({
        name = fluid.name,
        amount = fluid.remaining,
        temperature = fluid.temperature,
      })
      fluid.remaining = fluid.remaining - added
    end
  end
  -- Tutorials show the last eight seconds of long crafts after native input
  -- consumption. The separate engine regression runs the full native duration.
  if not state.full_duration and not state.skipped_wait and machine.crafting_progress > 0 then
    if state.seconds > 8 then
      machine.crafting_progress = math.max(machine.crafting_progress, 1 - 8 / state.seconds)
    end
    state.skipped_wait = true
  end
  if machine.products_finished > 0 and not state.completed then
    if machine.type == "assembling-machine" then
      assert(machine.get_recipe().name == state.recipe, "Wrong native recipe completed")
    end
    state.completed = game.tick
    state.status.text = { "quinityn-demo.complete" }
    log("QUINITYN BIOLOGY DEMO completed " .. state.stage .. "/" .. state.recipe)
  end
  if state.completed and game.tick - state.completed >= 240 then
    state.step = state.step % #processes[state.stage] + 1
    state.cycles = (state.cycles or 0) + 1
    begin_step(state)
  end
end

return demo
