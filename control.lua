local progression = require("scripts.progression")
script.on_event(defines.events.on_entity_spawned, require("scripts.stomp-a-trons"))

-- Off-world Yuoki crushers are recorded so a save without this list can be rebuilt.
-- Native selection rejects quinityn-hand-sort when quinityn-industry is not 1.
-- A save that already has that recipe selected is cleared once, not on every tick.
local crusher_names = { "y-crusher", "y_crusher2" }
local crusher_event_filters = {
  { filter = "name", name = "y-crusher" },
  { filter = "name", name = "y_crusher2" },
}

local function is_crusher_name(name)
  return name == "y-crusher" or name == "y_crusher2"
end

local function surface_is_offworld(surface)
  return surface.valid and surface.get_property("quinityn-industry") ~= 1
end

local function rebuild_offworld_crushers()
  storage.offworld_crushers = {}
  for _, surface in pairs(game.surfaces) do
    if surface_is_offworld(surface) then
      for _, machine in pairs(surface.find_entities_filtered({ name = crusher_names })) do
        if machine.valid then
          storage.offworld_crushers[machine.unit_number] = machine
        end
      end
    end
  end
end

local function remember_crusher(entity)
  if not entity or not entity.valid or not is_crusher_name(entity.name) then
    return
  end
  if storage.offworld_crushers == nil then
    rebuild_offworld_crushers()
  end
  if surface_is_offworld(entity.surface) then
    storage.offworld_crushers[entity.unit_number] = entity
  else
    storage.offworld_crushers[entity.unit_number] = nil
  end
end

local function forget_crusher(entity)
  if storage.offworld_crushers == nil or not entity then
    return
  end
  if entity.valid then
    storage.offworld_crushers[entity.unit_number] = nil
  end
end

local function prune_invalid_offworld_crushers()
  if storage.offworld_crushers == nil then
    return
  end
  for unit_number, entity in pairs(storage.offworld_crushers) do
    if not entity.valid then
      storage.offworld_crushers[unit_number] = nil
    end
  end
end

local function salvage_recipe_is_surface_locked()
  local recipe = prototypes.recipe["quinityn-hand-sort"]
  local conditions = recipe and recipe.surface_conditions
  if not conditions then
    return false
  end
  for _, condition in pairs(conditions) do
    if condition.property == "quinityn-industry" and condition.min == 1 and condition.max == 1 then
      return true
    end
  end
  return false
end

local function spill_cleared_items(machine, returned)
  if type(returned) ~= "table" then
    return
  end
  for _, stack in pairs(returned) do
    if type(stack) == "table" and stack.name and stack.count and stack.count > 0 then
      machine.surface.spill_item_stack({
        position = machine.position,
        stack = { name = stack.name, count = stack.count, quality = stack.quality },
        force = machine.force,
      })
    end
  end
end

local function clear_saved_offworld_salvage_sort()
  if not salvage_recipe_is_surface_locked() or storage.offworld_crushers == nil then
    return
  end
  for _, machine in pairs(storage.offworld_crushers) do
    if machine.valid then
      local selected = machine.get_recipe()
      if selected and selected.name == "quinityn-hand-sort" then
        spill_cleared_items(machine, machine.set_recipe(nil))
      end
    end
  end
end

local function on_startup()
  progression.reconcile()
  rebuild_offworld_crushers()
  clear_saved_offworld_salvage_sort()
  storage.salvage_sort_migration_done = true
end

script.on_init(on_startup)
script.on_configuration_changed(on_startup)
script.on_event(defines.events.on_player_changed_surface, function(e)
  progression.arrive(game.get_player(e.player_index))
end)
script.on_event(defines.events.on_player_created, function(e)
  progression.arrive(game.get_player(e.player_index))
end)
script.on_event(defines.events.on_player_respawned, function(e)
  progression.arrive(game.get_player(e.player_index))
end)
script.on_event(defines.events.on_player_changed_force, function(e)
  progression.arrive(game.get_player(e.player_index))
end)
script.on_event(defines.events.on_research_finished, progression.research)
script.on_event(defines.events.on_forces_merged, progression.reconcile)
script.on_event(defines.events.on_chunk_generated, progression.chunk)
script.on_event(defines.events.on_player_joined_game, function(e)
  progression.arrive(game.get_player(e.player_index))
end)
script.on_event(defines.events.on_player_controller_changed, function(e)
  progression.arrive(game.get_player(e.player_index))
end)

local function on_crusher_built(event)
  remember_crusher(event.entity)
end

local function on_crusher_removed(event)
  forget_crusher(event.entity)
end

local build_events = {
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_space_platform_built_entity,
}
for _, build_event in ipairs(build_events) do
  script.on_event(build_event, on_crusher_built, crusher_event_filters)
end

script.on_event(defines.events.on_entity_cloned, function(event)
  remember_crusher(event.destination)
end)

local removal_events = {
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
  defines.events.on_entity_died,
  defines.events.script_raised_destroy,
}
for _, removal_event in ipairs(removal_events) do
  script.on_event(removal_event, on_crusher_removed, crusher_event_filters)
end

script.on_event({ defines.events.on_surface_deleted, defines.events.on_surface_cleared }, function()
  prune_invalid_offworld_crushers()
end)

script.on_event(defines.events.on_tick, function()
  if storage.offworld_crushers == nil then
    rebuild_offworld_crushers()
  end
  -- Old saves have no flag. One pass clears a recipe selected before this migration.
  if storage.salvage_sort_migration_done then
    return
  end
  clear_saved_offworld_salvage_sort()
  storage.salvage_sort_migration_done = true
end)

if script.active_mods["quinityn-tests"] then
  remote.add_interface("yuoki-quinityn", {
    offworld_crusher_tracked = function(unit_number)
      local entity = storage.offworld_crushers and storage.offworld_crushers[unit_number]
      return entity ~= nil and entity.valid
    end,
    clear_offworld_crusher_list = function()
      storage.offworld_crushers = nil
    end,
    clear_salvage_sort_migration_flag = function()
      storage.salvage_sort_migration_done = nil
    end,
  })
end
