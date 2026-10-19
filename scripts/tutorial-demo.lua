-- Native Tips & Tricks worlds only. No handlers are installed in player saves.
local recipes = require("__yuoki-quinityn__/scripts/biology-demo")
local definitions = require("__yuoki-quinityn__/scripts/tutorial-processes")
local operations = require("__yuoki-quinityn__/scripts/tutorial-operations")
local world = require("__yuoki-quinityn__/scripts/tutorial-world")
local util = require("util")
local demo = {}

local function begin(state)
  if #state.definition.steps > 0 then
    state.recipe = recipes.start(state.stage, state.surface, state.force, state.full_duration, {
      technology = state.definition.technology,
      steps = state.definition.steps,
      notice = { "quinityn-demo.recipe-guide" },
    })
  else
    state.operation = world.start(assert(operations[state.stage][1]), state.surface, state.force)
  end
  state.operation_index = 1
end

function demo.start(stage, surface, force, full_duration)
  local definition = util.table.deepcopy(assert(definitions[stage], stage))
  local sequence = util.table.deepcopy(operations[stage] or {})
  -- Yuoki can hide its adjustable inserters. Keep that supported opt-out in
  -- tutorial worlds too, without masking a missing research prerequisite.
  for i = #definition.steps, 1, -1 do
    if prototypes.recipe[definition.steps[i][2]].hidden then
      table.remove(definition.steps, i)
    end
  end
  for i = #sequence, 1, -1 do
    local spec = sequence[i]
    if spec.kind == "transport" and prototypes.recipe[spec.entity].hidden then
      table.remove(sequence, i)
    end
  end
  local state = {
    stage = stage,
    definition = definition,
    surface = surface or game.surfaces[1],
    force = force or game.forces.player,
    full_duration = full_duration,
    cycles = 0,
    operations = sequence,
  }
  recipes.research(state.force, definition.technology)
  for _, name in ipairs(definition.requires or {}) do
    recipes.research(state.force, name)
  end
  if definition.requires_any then
    recipes.research(state.force, definition.requires_any[1])
  end
  begin(state)
  return state
end

function demo.update(state)
  local sequence = state.operations
  if state.recipe then
    recipes.update(state.recipe)
    if (state.recipe.cycles or 0) < #state.definition.steps then
      return
    end
    recipes.stop(state.recipe)
    state.recipe = nil
    if #sequence > 0 then
      state.operation = world.start(sequence[1], state.surface, state.force)
      return
    end
  elseif state.operation then
    if not world.update(state.operation) then
      return
    end
    world.stop(state.operation)
    state.operation_index = state.operation_index + 1
    if sequence[state.operation_index] then
      state.operation = world.start(sequence[state.operation_index], state.surface, state.force)
      return
    end
    state.operation = nil
  end
  state.cycles = state.cycles + 1
  log("QUINITYN TUTORIAL cycle " .. state.stage .. " " .. state.cycles)
  begin(state)
end

return demo
