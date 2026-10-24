-- Rebuild legacy Cimota effects, then exercise the real configuration callback.
local progression = require("__yuoki-quinityn__/scripts/progression")
local moved = {
  "cimota-resources",
  "cimota-fluids",
  "cimota-residues",
  "cimota-vulcanus",
  "cimota-fulgora",
}
local function parents(technology)
  for _, parent in pairs(technology.prerequisites) do
    parents(parent)
    parent.researched = true
  end
end
script.on_init(function()
  local force = game.create_force("cimota-legacy")
  parents(force.technologies["quinityn-cimota"])
  force.technologies["quinityn-cimota"].researched = true
  progression.reconcile()
  assert(force.recipes["y-ac-uc2calcite"].enabled, "legacy fixture lacks reported unlock")
  storage.machine =
    game.surfaces.nauvis.create_entity({ name = "y-atomic-constructor", position = { 0, 0 }, force = force })
  storage.machine.set_recipe("y-ac-uc2calcite")
  storage.machine.insert({ name = "y-unicomp-a2", count = 10 })
  storage.chest = game.surfaces.nauvis.create_entity({ name = "steel-chest", position = { 10, 0 }, force = force })
  storage.chest.insert({ name = "calcite", count = 20 })
  local pending = game.create_force("cimota-pending")
  parents(pending.technologies["quinityn-cimota"])
  assert(pending.add_research("quinityn-cimota"))
  pending.research_progress = 0.375
  log("QUINITYN CIMOTA MIGRATION SETUP")
end)
script.on_configuration_changed(function()
  local force = game.forces["cimota-legacy"]
  assert(force.technologies["quinityn-cimota"].researched)
  assert(force.recipes["y-liquid2uc"].enabled and force.recipes["y-uc2crudeoil"].enabled)
  for _, stage in ipairs(moved) do
    local technology = force.technologies["quinityn-" .. stage]
    assert(not technology.researched, "legacy Cimota granted " .. stage)
    for _, effect in pairs(technology.prototype.effects) do
      if effect.type == "unlock-recipe" then
        assert(not force.recipes[effect.recipe].enabled, "legacy effect leaked: " .. effect.recipe)
      end
    end
  end
  assert(not force.technologies["quinityn-arrival-vulcanus"].researched)
  assert(not force.technologies["quinityn-arrival-fulgora"].researched)
  assert(storage.machine.valid and storage.machine.get_item_count("y-unicomp-a2") == 10)
  assert(storage.chest.get_item_count("calcite") == 20, "earned stock removed")
  local pending = game.forces["cimota-pending"]
  assert(pending.current_research.name == "quinityn-cimota" and pending.research_progress == 0.375)
  pending.technologies["quinityn-cimota"].researched = true
  progression.research({ research = pending.technologies["quinityn-cimota"] })
  assert(not pending.recipes["y-ac-uc2calcite"].enabled, "in-progress research restored old effects")
  storage.reconciled = true
end)
script.on_event(defines.events.on_tick, function()
  assert(storage.reconciled, "native configuration callback did not run")
  storage.machine.energy = 100000000
  if game.tick == 300 then
    assert(storage.machine.products_finished == 0, "saved recipe bypasses the new planet gate")
    assert(storage.chest.get_item_count("calcite") == 20)
    local technology = storage.machine.force.technologies["quinityn-cimota-vulcanus"]
    parents(technology)
    technology.researched = true
    progression.research({ research = technology })
  elseif game.tick == 600 then
    assert(storage.machine.products_finished > 0, "saved machine cannot resume after earning its branch")
    log("QUINITYN CIMOTA MIGRATION PASSED")
  end
end)
