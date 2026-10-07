local M = {}
local function is_quinityn(surface)
  return surface and surface.planet and surface.planet.name == "quinityn"
end
local function complete_bridges(force)
  for name, tech in pairs(force.technologies) do
    if name:match("^quinityn%-bridge%-") and not tech.researched then
      local ready=true
      for _, prerequisite in pairs(tech.prerequisites) do
        if not prerequisite.researched then ready=false; break end
      end
      if ready then force.script_trigger_research(name) end
    end
  end
end
function M.arrive(player)
  if not player or not player.valid or not player.character or not is_quinityn(player.physical_surface) then return end
  local force=player.force
  local tech=force.technologies["quinityn-arrival"]
  if tech and not tech.researched then
    force.script_trigger_research("quinityn-arrival")
    force.print({"quinityn.arrival-message"})
  end
  complete_bridges(force)
end
function M.research(event)
  if event.research.name == "quinityn-oil-processing" then
    event.research.force.technologies["oil-processing"].researched=true
  end
  complete_bridges(event.research.force)
end
function M.reconcile()
  -- New and existing saves: ensure no formerly enabled Yuoki recipe leaks through.
  for _, force in pairs(game.forces) do
    force.reset_recipes()
    complete_bridges(force)
  end
  for _, player in pairs(game.players) do M.arrive(player) end
end
function M.chunk(event)
  local surface=event.surface
  if not is_quinityn(surface) then return end
  local area=event.area
  -- Guaranteed hand-mineable stocks on the starting plateau, independent of seed.
  -- These supplement normal infinite-map ore placement and never award free items.
  for _, patch in ipairs({{name="y-res1",x=-28,y=-18},{name="y-res2",x=28,y=-18}}) do
    for x=patch.x-7,patch.x+7 do
      for y=patch.y-7,patch.y+7 do
        if x>=area.left_top.x and x<area.right_bottom.x and y>=area.left_top.y and y<area.right_bottom.y
          and (x-patch.x)^2+(y-patch.y)^2<=49 then
          local p={x=x+0.5,y=y+0.5}
          if surface.can_place_entity{name=patch.name,position=p,amount=5000} then
            surface.create_entity{name=patch.name,position=p,amount=5000}
          end
        end
      end
    end
  end
end
return M
