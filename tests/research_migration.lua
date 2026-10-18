-- Reconstructed legacy prerequisites, native save/reload and research state.
local progression = require("__yuoki-quinityn__/scripts/progression")
local cases = {
  { "quinityn-quantum", "quinityn-high-flow-storage" },
  { "quinityn-advanced-storage", "quinityn-accumulator-capacity" },
}
local function check(ok, message)
  assert(ok, "RESEARCH MIGRATION TEST FAILED: " .. message)
end
local function research_parents(technology)
  for _, parent in pairs(technology.prerequisites) do
    research_parents(parent)
    parent.researched = true
  end
end

script.on_init(function()
  for i, case in ipairs(cases) do
    local force = game.create_force("research-migration-" .. i)
    local technology = force.technologies[case[1]]
    research_parents(technology)
    progression.reconcile()
    check(not force.technologies[case[2]].researched, "legacy gate absent: " .. case[2])
    check(force.add_research(technology), "legacy research starts: " .. case[1])
    force.research_progress = 0.375
    if i == 1 then
      force.technologies["quinityn-infusion"].saved_progress = 0.125
      check(force.add_research("quinityn-infusion"), "dependent research queued")
      check(force.add_research("toolbelt"), "unrelated research queued")
    end
    check(force.current_research.name == case[1], "legacy target remains active")
    check(force.research_progress == 0.375, "legacy progress before save")
  end
  local completed = game.create_force("research-migration-completed")
  completed.technologies["quinityn-quantum"].researched = true
  completed.technologies["quinityn-advanced-storage"].researched = true
  local valid = game.create_force("research-migration-valid")
  research_parents(valid.technologies["quinityn-high-flow-storage"])
  valid.technologies["quinityn-high-flow-storage"].researched = true
  research_parents(valid.technologies["quinityn-quantum"])
  progression.reconcile()
  check(valid.add_research("quinityn-quantum"), "valid research starts")
  valid.research_progress = 0.625
  log("QUINITYN RESEARCH MIGRATION SETUP")
end)

script.on_configuration_changed(function()
  -- The playable mod's configuration handler runs before this dependent mod.
  -- Do not call reconcile here: assertions must exercise the actual callback.
  for i, case in ipairs(cases) do
    local force = game.forces["research-migration-" .. i]
    local technology = force.technologies[case[1]]
    check(not technology.researched, "blocked research stays incomplete")
    check(not force.current_research or force.current_research.name ~= case[1], "blocked research cancelled")
    check(
      technology.saved_progress == 0.375,
      "spent progress saved: " .. case[1] .. " got " .. technology.saved_progress
    )
    check(not force.add_research(technology), "new prerequisite prevents restarting")
    if i == 1 then
      check(force.current_research.name == "toolbelt", "unrelated queued research preserved")
      check(#force.research_queue == 1, "dependent research removed from queue")
      check(force.technologies["quinityn-infusion"].saved_progress == 0.125, "inactive progress preserved")
      force.cancel_current_research()
    end
    local gate = force.technologies[case[2]]
    research_parents(gate)
    gate.researched = true
    check(force.add_research(technology), "research resumes after new gate")
    check(force.research_progress == 0.375, "resumed research retains spent progress")
  end
  local completed = game.forces["research-migration-completed"]
  check(completed.technologies["quinityn-quantum"].researched, "completed Quantum preserved")
  check(completed.technologies["quinityn-advanced-storage"].researched, "completed storage preserved")
  check(not completed.technologies["quinityn-high-flow-storage"].researched, "no free new prerequisite")
  check(completed.recipes["y-atomic-quantum-composer"].enabled, "completed research effects preserved")
  local valid = game.forces["research-migration-valid"]
  check(valid.current_research.name == "quinityn-quantum", "valid force research unaffected")
  check(valid.research_progress == 0.625, "valid force progress unaffected")
  storage.reconciled = true
end)

script.on_event(defines.events.on_tick, function()
  check(storage.reconciled, "configuration change actually ran")
  log("QUINITYN RESEARCH MIGRATION PASSED")
end)
