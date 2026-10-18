-- Execute the shipped tutorial machinery for full native craft durations.
-- Supplies/research/terrain are staged; this is not a progression playthrough.
local module_path = "__yuoki-quinityn__/scripts/biology-demo"
local demo = require(module_path)
local processes = require("__yuoki-quinityn__/scripts/biology-processes")
-- Runtime require is restricted to control parsing. Resolve the real module
-- here, then require the declared callbacks to use that exact cached module.
local function require_demo(path)
  assert(path == module_path, "Unexpected biology callback module: " .. path)
  return demo
end
local environment = { require = require_demo, storage = {} }
local callbacks = {}
for stage, scene in pairs(require("__quinityn-tests__/biology_callbacks")) do
  callbacks[stage] = {
    init = assert(load(scene.init, stage .. " init", "t", environment)),
    update = assert(load(scene.update, stage .. " update", "t", environment)),
  }
end
script.on_init(function()
  storage.demos = {}
  for stage in pairs(processes) do
    local surface = game.create_surface("biology-demo-" .. stage, {
      width = 64,
      height = 64,
      autoplace_settings = {
        entity = { treat_missing_as_default = false, settings = {} },
        decorative = { treat_missing_as_default = false, settings = {} },
      },
    })
    local force = game.create_force("biology-demo-" .. stage)
    -- Inject only the isolated test surface/force and full-duration mode at
    -- the native start boundary; all crafting and transport remain real.
    environment.require = function(path)
      local module = require_demo(path)
      return {
        start = function(requested_stage)
          assert(requested_stage == stage, "Tip starts the wrong biology stage: " .. stage)
          return module.start(requested_stage, surface, force, true)
        end,
      }
    end
    environment.storage = {}
    callbacks[stage].init()
    local state = assert(environment.storage.biology_demo, "Tip did not initialize: " .. stage)
    assert(state.surface == surface and state.force == force, "Tip escaped its test world: " .. stage)
    storage.demos[stage] = state
    if stage == "agriculture" or stage == "packaging" or stage == "husbandry" then
      assert(not force.technologies["quinityn-quantum"].researched)
      assert(not force.technologies["quinityn-trade"].researched)
    elseif stage == "genetics" or stage == "advanced-genetics" or stage == "industrial-biology" then
      assert(not force.technologies["quinityn-trade"].researched)
    end
  end
  environment.require = require_demo
end)
script.on_event(defines.events.on_tick, function()
  if storage.finished then
    return
  end
  local complete = true
  for stage, state in pairs(storage.demos) do
    if (state.cycles or 0) <= #processes[stage] then
      environment.storage.biology_demo = state
      callbacks[stage].update()
      complete = false
      assert(game.tick - state.started < 90000, "Biology demonstration stalled: " .. state.recipe)
    end
  end
  assert(
    not game.forces.player.technologies["quinityn-agriculture"].researched,
    "Demo leaked research to another force"
  )
  if complete then
    storage.finished = true
    log("QUINITYN BIOLOGY DEMONSTRATIONS PASSED: every native craft and first-step repeat")
  end
end)
