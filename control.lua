local progression = require("scripts.progression")
script.on_event(defines.events.on_entity_spawned, require("scripts.stomp-a-trons"))
script.on_init(progression.reconcile)
script.on_configuration_changed(progression.reconcile)
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

-- The recipe carries the Quinityn surface condition, but a fueled crusher still
-- finishes quinityn-hand-sort after set_recipe on a surface where that property is 0.
-- Hold the craft only while the prototype still declares that condition.
local salvage_sort = "quinityn-hand-sort"

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

script.on_event(defines.events.on_tick, function()
  if not salvage_sort_is_surface_locked() then
    return
  end
  for _, surface in pairs(game.surfaces) do
    if surface.get_property("quinityn-industry") ~= 1 then
      for _, machine in pairs(surface.find_entities_filtered({ name = { "y-crusher", "y_crusher2" } })) do
        local recipe = machine.valid and machine.get_recipe()
        if recipe and recipe.name == salvage_sort and machine.crafting_progress > 0 then
          machine.crafting_progress = 0
        end
      end
    end
  end
end)
