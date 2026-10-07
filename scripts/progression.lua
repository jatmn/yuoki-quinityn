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
  if not player or not player.valid or (not player.character and not player.cutscene_character and player.physical_controller_type ~= defines.controllers.character) or not is_quinityn(player.physical_surface) then return end
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
    local managed = {}
    for name, technology in pairs(force.technologies) do
      if name:match("^quinityn%-") then
        for _, effect in pairs(technology.prototype.effects) do
          if effect.type == "unlock-recipe" then
            managed[effect.recipe] = managed[effect.recipe] or technology.researched
          end
        end
      end
    end
    for recipe, enabled in pairs(managed) do force.recipes[recipe].enabled=enabled end
    if not settings.startup["yuoki-uc-heavyoil"].value then force.recipes["y-heavyoil2uc"].enabled=false end
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
    for x=patch.x-4,patch.x+4 do
      for y=patch.y-4,patch.y+4 do
        if x>=area.left_top.x and x<area.right_bottom.x and y>=area.left_top.y and y<area.right_bottom.y
          and (x-patch.x)^2+(y-patch.y)^2<=16 then
          local p={x=x+0.5,y=y+0.5}
          if surface.can_place_entity{name=patch.name,position=p,amount=200} then
            surface.create_entity{name=patch.name,position=p,amount=200}
          end
        end
      end
    end
  end
end
return M
