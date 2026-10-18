local progression = require("scripts.progression")
script.on_event(defines.events.on_entity_spawned, require("scripts.stomp-a-trons"))

-- The recipe carries the Quinityn surface condition, but a fueled crusher still
-- finishes quinityn-hand-sort after set_recipe on a surface where that property is 0.
-- Hold the craft only while the prototype still declares that condition.
local salvage_sort = "quinityn-hand-sort"
local crusher_names = { "y-crusher", "y_crusher2" }
local crusher_event_filters = {
  { filter = "name", name = "y-crusher" },
  { filter = "name", name = "y_crusher2" },
}

local function is_crusher_name(name)
  return name == "y-crusher" or name == "y_crusher2"
end

local function salvage_sort_is_surface_locked()
  local conditions = prototypes.recipe[salvage_sort].surface_conditions
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

local function on_startup()
  progression.reconcile()
  storage.salvage_sort_surface_locked = salvage_sort_is_surface_locked()
  rebuild_offworld_crushers()
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
  if storage.salvage_sort_surface_locked == nil then
    storage.salvage_sort_surface_locked = salvage_sort_is_surface_locked()
  end
  if storage.offworld_crushers == nil then
    rebuild_offworld_crushers()
  end
  if not storage.salvage_sort_surface_locked then
    return
  end
  for unit_number, machine in pairs(storage.offworld_crushers) do
    if not machine.valid then
      storage.offworld_crushers[unit_number] = nil
    else
      local recipe = machine.get_recipe()
      if recipe and recipe.name == salvage_sort and machine.crafting_progress > 0 then
        machine.crafting_progress = 0
      end
    end
  end
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
  })
end
