-- Exercise the actual callbacks exported from the loaded Tips prototypes.
-- Worlds, ingredients and power are staged; production and transport are native.
local demo = require("__yuoki-quinityn__/scripts/tutorial-demo")
local callbacks = require("__quinityn-tests__/tutorial_callbacks")
local environment = { storage = {} }
local compiled = {}
for stage, scene in pairs(callbacks) do
  compiled[stage] = {
    init = assert(load(scene.init, stage .. " init", "t", environment)),
    update = assert(load(scene.update, stage .. " update", "t", environment)),
  }
end
local function module(path)
  assert(path == "__yuoki-quinityn__/scripts/tutorial-demo", path)
  return demo
end
environment.require = module

script.on_init(function()
  storage.tutorials = {}
  for stage in pairs(callbacks) do
    local surface = game.create_surface("tutorial-" .. stage, {
      width = stage == "robot-network-expansion" and 320 or 64,
      height = 64,
      autoplace_settings = {
        entity = { treat_missing_as_default = false, settings = {} },
        decorative = { treat_missing_as_default = false, settings = {} },
      },
    })
    surface.set_property("quinityn-industry", 1)
    local force = game.create_force("tutorial-" .. stage)
    environment.require = function(path)
      local actual = module(path)
      return {
        start = function(requested)
          assert(requested == stage)
          return actual.start(stage, surface, force, true)
        end,
      }
    end
    environment.storage = {}
    compiled[stage].init()
    local state = assert(environment.storage.tutorial_demo)
    assert(state.surface == surface and state.force == force)
    storage.tutorials[stage] = state
    log("QUINITYN TUTORIAL started " .. stage)
  end
  environment.require = module
end)

script.on_event(defines.events.on_tick, function()
  if storage.finished then
    return
  end
  local finished = true
  for stage, state in pairs(storage.tutorials) do
    if state.cycles < 2 then
      environment.storage.tutorial_demo = state
      compiled[stage].update()
      finished = false
      if state.recipe then
        assert(
          game.tick - state.recipe.started < state.recipe.seconds * 60 + 9000,
          "Tutorial recipe stalled: " .. stage .. "/" .. state.recipe.recipe
        )
      elseif state.operation then
        assert(
          game.tick - state.operation.started < 15000,
          "Tutorial operation stalled: " .. stage .. "/" .. state.operation.spec.kind
        )
      end
    end
  end
  assert(
    not game.forces.player.technologies["planet-discovery-quinityn"].researched,
    "Tutorial altered the real force's progression"
  )
  if finished then
    storage.finished = true
    log("QUINITYN TUTORIAL DEMONSTRATIONS PASSED: native operation, repeat and isolation")
  end
end)
