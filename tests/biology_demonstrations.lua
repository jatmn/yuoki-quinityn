-- Execute the shipped tutorial machinery for full native craft durations.
-- Supplies/research/terrain are staged; this is not a progression playthrough.
local demo = require("__yuoki-quinityn__/scripts/biology-demo")
local processes = require("__yuoki-quinityn__/scripts/biology-processes")
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
    storage.demos[stage] = demo.start(stage, surface, force, true)
    if stage == "agriculture" or stage == "husbandry" then
      assert(not force.technologies["quinityn-quantum"].researched)
      assert(not force.technologies["quinityn-trade"].researched)
    elseif stage == "genetics" or stage == "advanced-genetics" or stage == "industrial-biology" then
      assert(not force.technologies["quinityn-trade"].researched)
    end
  end
end)
script.on_event(defines.events.on_tick, function()
  if storage.finished then
    return
  end
  local complete = true
  for stage, state in pairs(storage.demos) do
    if (state.cycles or 0) <= #processes[stage] then
      demo.update(state)
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
