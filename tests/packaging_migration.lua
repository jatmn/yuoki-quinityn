-- Reconstructed bulk Packaging effects; native save/reload of completed research.
local progression = require("__yuoki-quinityn__/scripts/progression")
local package_owners = {
  husbandry = { "ye_package_r_meat", "ye_package_c_meat" },
  genetics = { "ye_package_omtrinit", "ye_package_substratin", "ye_package_spliced_cells" },
  ["advanced-genetics"] = { "ye_package_verotin", "ye_package_carni" },
  ["industrial-biology"] = { "ye_package_organic" },
  ["trade-biology"] = {
    "ye_package_fish2",
    "ye_buechse_blau",
    "ye_buechse_braun",
    "ye_buechse_rosa",
    "ye_buechse_white",
  },
}
local function check(ok, message)
  assert(ok, "PACKAGING MIGRATION TEST FAILED: " .. message)
end
script.on_init(function()
  for _, completed in ipairs({ false, true }) do
    local force = game.create_force(completed and "packaging-completed" or "packaging-old")
    force.technologies["quinityn-packaging"].researched = true
    force.technologies.recycling.researched = true
    if completed then
      for stage in pairs(package_owners) do
        force.technologies["quinityn-" .. stage].researched = true
      end
    end
    progression.reconcile()
    for _, recipes in pairs(package_owners) do
      for _, name in ipairs(recipes) do
        check(force.recipes[name].enabled, "legacy Packaging grants " .. name)
        check(force.recipes[name .. "-recycling"].enabled, "legacy Packaging grants recycling " .. name)
      end
    end
  end
  storage.package_chest = game.surfaces.nauvis.create_entity({
    name = "steel-chest",
    position = { 0, 0 },
    force = game.forces["packaging-old"],
  })
  storage.package_chest.insert({ name = "ye_package_organic", count = 7 })
  log("QUINITYN PACKAGING MIGRATION SETUP")
end)
script.on_configuration_changed(function()
  -- The playable mod's callback runs first. Do not manually reconcile here.
  for _, completed in ipairs({ false, true }) do
    local force = game.forces[completed and "packaging-completed" or "packaging-old"]
    check(force.technologies["quinityn-packaging"].researched, "completed Packaging preserved")
    check(force.recipes.ye_buechse_gelb.enabled, "basic corn packaging preserved")
    for stage, recipes in pairs(package_owners) do
      check(force.technologies["quinityn-" .. stage].researched == completed, "branch research preserved: " .. stage)
      for _, name in ipairs(recipes) do
        check(force.recipes[name].enabled == completed, "moved package follows saved branch: " .. name)
        check(
          force.recipes[name .. "-recycling"].enabled == completed,
          "moved recycling follows saved branch: " .. name
        )
      end
    end
  end
  check(storage.package_chest.valid, "placed package storage preserved")
  check(storage.package_chest.get_item_count("ye_package_organic") == 7, "existing package stock preserved")
  storage.reconciled = true
end)
script.on_event(defines.events.on_tick, function()
  check(storage.reconciled, "configuration change actually ran")
  log("QUINITYN PACKAGING MIGRATION PASSED")
end)
