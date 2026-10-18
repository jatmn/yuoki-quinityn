-- Reconstructed legacy Trade/Mastery effects, followed by a real config reload.
local progression = require("__yuoki-quinityn__/scripts/progression")
local moved = {
  reputation = { "y-fame-gen", "y-fame", "y_fame_tech" },
  ["chemical-science"] = { "y_chemical_science" },
  ["military-science"] = { "y_military_science" },
  ["production-science"] = { "y_production_science" },
  ["utility-science"] = { "y_high-tech_science", "ye_createbluesigns" },
  ["space-science"] = { "y_space_science" },
  ["genetic-trade"] = { "ye_export01", "ye_export02", "ye_export05" },
  ["advanced-genetic-trade"] = { "ye_export03", "ye_export06" },
  ["industrial-biology-trade"] = { "ye_export04" },
  ["trade-biology"] = {
    "ye_buechse_blau_export",
    "ye_buechse_fleisch_export",
    "ye_buechse_rosa_export",
    "ye_buechse_weiss_export",
    "ye_export_fish1",
    "ye_export_fish2",
    "ye_tradeblood",
    "ye_trademeat1",
    "ye_trademeat2",
  },
}
script.on_init(function()
  for _, completed in ipairs({ false, true }) do
    local force = game.create_force(completed and "trade-completed" or "trade-old")
    force.technologies["quinityn-trade"].researched = true
    force.technologies["quinityn-mastery"].researched = true
    force.technologies.recycling.researched = true
    if completed then
      for stage in pairs(moved) do
        force.technologies["quinityn-" .. stage].researched = true
      end
    end
    progression.reconcile()
    for _, recipes in pairs(moved) do
      for _, name in ipairs(recipes) do
        assert(force.recipes[name].enabled, "legacy effect missing: " .. name)
      end
    end
  end
  storage.machine = game.surfaces.nauvis.create_entity({
    name = "y-fame-gen",
    position = { 0, 0 },
    force = game.forces["trade-old"],
  })
  storage.chest = game.surfaces.nauvis.create_entity({
    name = "steel-chest",
    position = { 10, 0 },
    force = game.forces["trade-old"],
  })
  storage.chest.insert({ name = "y-fame", count = 10 })
  log("QUINITYN TRADE MIGRATION SETUP")
end)
script.on_configuration_changed(function()
  -- The production mod's native callback has already reconciled these forces.
  for _, completed in ipairs({ false, true }) do
    local force = game.forces[completed and "trade-completed" or "trade-old"]
    assert(force.technologies["quinityn-trade"].researched)
    assert(force.technologies["quinityn-mastery"].researched)
    assert(force.recipes.ye_buechse_gelb_export.enabled)
    assert(force.recipes.ypfw_trader_sign.enabled)
    for stage, recipes in pairs(moved) do
      assert(force.technologies["quinityn-" .. stage].researched == completed, stage)
      for _, name in ipairs(recipes) do
        assert(force.recipes[name].enabled == completed, "moved effect: " .. name)
        if force.recipes[name .. "-recycling"] then
          assert(force.recipes[name .. "-recycling"].enabled == completed, "moved recycling: " .. name)
        end
      end
    end
  end
  assert(storage.machine.valid and storage.chest.get_item_count("y-fame") == 10)
  local fresh = game.create_force("trade-fresh")
  for stage, recipes in pairs(moved) do
    for _, name in ipairs(recipes) do
      assert(not fresh.recipes[name].enabled, "fresh force leaked: " .. name)
    end
    fresh.technologies["quinityn-" .. stage].researched = true
    progression.reconcile()
    for _, name in ipairs(recipes) do
      assert(fresh.recipes[name].enabled, "owner did not unlock: " .. name)
      if fresh.recipes[name .. "-recycling"] then
        assert(not fresh.recipes[name .. "-recycling"].enabled, "upstream recycling gate bypassed: " .. name)
      end
    end
  end
  fresh.technologies["quinityn-trade"].researched = true
  assert(not fresh.recipes.ypfw_trader_sign.enabled, "Trade leaked direct Merchant Sign generation")
  fresh.technologies["quinityn-mastery"].researched = true
  progression.reconcile()
  assert(fresh.recipes.ypfw_trader_sign.enabled)
  storage.reconciled = true
end)
script.on_event(defines.events.on_tick, function()
  assert(storage.reconciled, "configuration change did not run")
  log("QUINITYN TRADE MIGRATION PASSED")
end)
