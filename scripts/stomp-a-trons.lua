local names = {
  ["quinityn-small-stomp-a-tron"] = true,
  ["quinityn-medium-stomp-a-tron"] = true,
  ["quinityn-big-stomp-a-tron"] = true,
}

return function(event)
  local entity = event.entity
  if entity.valid and names[entity.name] then
    local planet = entity.surface.planet
    -- Also covers a Quinityn nest transplanted to another planet by an editor
    -- or another mod. Destroy rather than die: no loot or death effects.
    if not planet or planet.name ~= "quinityn" then
      entity.destroy()
    end
  end
end
