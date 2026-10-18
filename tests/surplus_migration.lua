local function check(condition, message)
  if not condition then
    error("QUINITYN TEST FAILED: " .. message)
  end
  log("QUINITYN PASS: " .. message)
end

local surplus_recipe_names = {
  "quinityn-stone-to-uc",
  "quinityn-wood-to-uc",
  "quinityn-uc-to-coal",
  "quinityn-uc-to-iron",
  "quinityn-uc-to-copper",
}

local function check_surplus_recipes_disabled(force)
  for _, name in ipairs(surplus_recipe_names) do
    check(not force.recipes[name].enabled, "surplus recipe locked: " .. name)
  end
end

local function check_surplus_recipes_enabled(force)
  for _, name in ipairs(surplus_recipe_names) do
    check(force.recipes[name].enabled, "surplus recipe enabled: " .. name)
  end
end

script.on_init(function()
  local surveyed_uncrafted = game.create_force("surveyed-uncrafted")
  surveyed_uncrafted.technologies["quinityn-arrival"].researched = true
  check_surplus_recipes_disabled(surveyed_uncrafted)
  local migration_crafted = game.create_force("migration-crafted")
  migration_crafted.technologies["quinityn-arrival"].researched = true
  migration_crafted.technologies["quinityn-materials"].researched = true
  migration_crafted.recipes["quinityn-uc-to-coal"].enabled = false
  local surplus_done = game.create_force("surplus-done")
  surplus_done.technologies["quinityn-surplus"].researched = true
  surplus_done.recipes["quinityn-uc-to-iron"].enabled = false
  check(not surveyed_uncrafted.technologies["quinityn-surplus"].researched, "surveyed uncrafted has no surplus yet")
  check(not migration_crafted.technologies["quinityn-surplus"].researched, "migration crafted has no surplus yet")
  log("QUINITYN SURPLUS MIGRATION SETUP")
end)

script.on_configuration_changed(function()
  local surveyed_uncrafted = game.forces["surveyed-uncrafted"]
  check(
    not surveyed_uncrafted.technologies["quinityn-surplus"].researched,
    "configuration change leaves arrival-only force without surplus"
  )
  check_surplus_recipes_disabled(surveyed_uncrafted)
  local migration_crafted = game.forces["migration-crafted"]
  check(migration_crafted.technologies["quinityn-surplus"].researched, "configuration change grants migration surplus")
  check_surplus_recipes_enabled(migration_crafted)
  local surplus_done = game.forces["surplus-done"]
  check(
    surplus_done.technologies["quinityn-surplus"].researched and surplus_done.recipes["quinityn-uc-to-iron"].enabled,
    "configuration change keeps completed surplus unlocked"
  )
  local reload_merge_uncrafted = game.create_force("reload-merge-uncrafted")
  reload_merge_uncrafted.technologies["quinityn-arrival"].researched = true
  game.create_force("reload-merge-uncrafted-src").technologies["quinityn-arrival"].researched = true
  game.merge_forces("reload-merge-uncrafted-src", "reload-merge-uncrafted")
  local reload_merge_crafted = game.create_force("reload-merge-crafted")
  reload_merge_crafted.technologies["quinityn-arrival"].researched = true
  reload_merge_crafted.technologies["quinityn-materials"].researched = true
  reload_merge_crafted.recipes["quinityn-uc-to-iron"].enabled = false
  game.create_force("reload-merge-crafted-src")
  game.merge_forces("reload-merge-crafted-src", "reload-merge-crafted")
end)

script.on_event(defines.events.on_forces_merged, function()
  local reload_merge_uncrafted = game.forces["reload-merge-uncrafted"]
  if reload_merge_uncrafted then
    check(
      not reload_merge_uncrafted.technologies["quinityn-surplus"].researched
        and not reload_merge_uncrafted.technologies["quinityn-materials"].researched,
      "reload merged uncrafted destination stays without materials or surplus"
    )
    check_surplus_recipes_disabled(reload_merge_uncrafted)
    local reload_merge_crafted = game.forces["reload-merge-crafted"]
    check(
      reload_merge_crafted.technologies["quinityn-surplus"].researched,
      "reload merged crafted destination receives surplus"
    )
    check_surplus_recipes_enabled(reload_merge_crafted)
    log("QUINITYN SURPLUS MIGRATION PASSED")
  end
end)
