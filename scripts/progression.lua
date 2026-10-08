local M = {}
local function is_quinityn(surface)
  return surface and surface.planet and surface.planet.name == "quinityn"
end
local function complete_bridges(force)
  for name, tech in pairs(force.technologies) do
    if name:match("^quinityn%-bridge%-") and not tech.researched then
      local ready = true
      for _, prerequisite in pairs(tech.prerequisites) do
        if not prerequisite.researched then
          ready = false
          break
        end
      end
      if ready then
        force.script_trigger_research(name)
      end
    end
  end
end
function M.arrive(player)
  if
    not player
    or not player.valid
    or (not player.character and not player.cutscene_character and player.physical_controller_type ~= defines.controllers.character)
    or not is_quinityn(player.physical_surface)
  then
    return
  end
  local force = player.force
  -- Discovery anchors this whole branch and must precede the scripted survey.
  if not force.technologies["planet-discovery-quinityn"].researched then
    return
  end
  local tech = force.technologies["quinityn-arrival"]
  if tech and not tech.researched then
    force.script_trigger_research("quinityn-arrival")
    force.print({ "quinityn.arrival-message" })
  end
  complete_bridges(force)
end
function M.research(event)
  if event.research.name == "planet-discovery-quinityn" then
    -- Discovery can finish after a character changes force while on Quinityn.
    for _, player in pairs(event.research.force.players) do
      M.arrive(player)
    end
  elseif event.research.name == "quinityn-oil-processing" then
    event.research.force.technologies["oil-processing"].researched = true
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
    for recipe, enabled in pairs(managed) do
      force.recipes[recipe].enabled = enabled
    end
    if not settings.startup["yuoki-uc-heavyoil"].value then
      force.recipes["y-heavyoil2uc"].enabled = false
    end
    complete_bridges(force)
  end
  for _, player in pairs(game.players) do
    M.arrive(player)
  end
end
function M.chunk(event)
  local surface = event.surface
  if not is_quinityn(surface) then
    return
  end
  local area = event.area
  if area.right_bottom.x < -90 or area.left_top.x > 90 or area.right_bottom.y < -90 or area.left_top.y > 90 then
    return
  end
  -- Recreate the same small plan per nearby chunk: no shared RNG state, exploration
  -- order dependence, or migration state. The 80-tile dry core contains both patches.
  local rng = game.create_random_generator(surface.map_gen_settings.seed)
  -- Warm up the generator so neighboring map seeds do not share a first bearing.
  for _ = 1, 8 do
    rng()
  end
  local first_angle = rng() * 2 * math.pi
  for i, name in ipairs({ "y-res1", "y-res2" }) do
    local angle = first_angle + (i == 1 and 0 or 1.9 + rng() * 1.8)
    local radius = 36 + rng() * 23
    local cx, cy = math.floor(math.cos(angle) * radius), math.floor(math.sin(angle) * radius)
    local rx, ry = 10 + rng() * 3, 8 + rng() * 3
    local phase = rng() * 2 * math.pi
    local target = 125000 + rng(0, 25000)
    local points, total = {}, 0
    for x = -16, 16 do
      for y = -16, 16 do
        local theta = math.atan2(y / ry, x / rx)
        local edge = 1 + 0.13 * math.sin(3 * theta + phase) + 0.08 * math.cos(5 * theta - phase)
        local d = (x / rx) ^ 2 + (y / ry) ^ 2
        if d < edge ^ 2 then
          local weight = 1.6 - math.min(d, 1)
          points[#points + 1] = { x = x + cx, y = y + cy, weight = weight }
          total = total + weight
        end
      end
    end
    local allocated = 0
    for j, p in ipairs(points) do
      local amount = j == #points and target - allocated or math.floor(target * p.weight / total)
      allocated = allocated + amount
      if
        p.x >= area.left_top.x
        and p.x < area.right_bottom.x
        and p.y >= area.left_top.y
        and p.y < area.right_bottom.y
      then
        local position = { p.x + 0.5, p.y + 0.5 }
        if surface.can_place_entity({ name = name, position = position, amount = amount }) then
          surface.create_entity({ name = name, position = position, amount = amount })
        end
      end
    end
  end
end
return M
