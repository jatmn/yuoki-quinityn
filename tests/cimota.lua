-- Real forces/research and characters. Only LuaPlayer fields use the existing
-- headless facade; the production arrival and research handlers own the gates.
local progression = require("__yuoki-quinityn__/scripts/progression")
local branches = {
  vulcanus = { "calcite", "tungsten-ore" },
  fulgora = { "holmium-ore", "scrap" },
}
local function locked(force, planet)
  for _, item in ipairs(branches[planet]) do
    assert(not force.recipes["y-ac-uc2" .. item].enabled, "reconstruction leaked: " .. item)
    assert(not force.recipes["y-ac-" .. item .. "2uc"].enabled, "reverse conversion leaked: " .. item)
  end
end
local function research_parents(technology)
  for _, parent in pairs(technology.prerequisites) do
    research_parents(parent)
    parent.researched = true
  end
end
local function discover(force, planet, player)
  force.technologies["planet-discovery-" .. planet].researched = true
  progression.research({
    research = {
      name = "planet-discovery-" .. planet,
      force = setmetatable({ players = { player } }, {
        __index = function(_, key)
          return force[key]
        end,
      }),
    },
  })
end
script.on_init(function()
  local other = game.create_force("cimota-other")
  for planet in pairs(branches) do
    local force = game.create_force("cimota-" .. planet)
    local surface = game.planets[planet].create_surface()
    local first = force.technologies["quinityn-cimota"]
    research_parents(first)
    first.researched = true
    progression.reconcile()
    assert(force.recipes["y-liquid2uc"].enabled and force.recipes["y-uc2crudeoil"].enabled)
    assert(not force.recipes["y-ac-uc2uranium-ore"].enabled)
    assert(not force.recipes["y-ac-slag2uc"].enabled and not force.recipes["y-ac-uc2plastic"].enabled)
    locked(force, "vulcanus")
    locked(force, "fulgora")
    local resources = force.technologies["quinityn-cimota-resources"]
    research_parents(resources)
    resources.researched = true
    progression.reconcile()
    assert(force.recipes["y-ac-uc2uranium-ore"].enabled)
    local character = game.surfaces.nauvis.create_entity({ name = "character", position = { 0, 0 }, force = force })
    local player =
      { valid = true, character = character, force = force, physical_surface = game.surfaces.nauvis, surface = surface }
    discover(force, planet, player)
    local arrival = force.technologies["quinityn-arrival-" .. planet]
    local conversion = force.technologies["quinityn-cimota-" .. planet]
    assert(not arrival.researched, "remote view counted as arrival")
    assert(not force.add_research(conversion), "discovery alone permits conversion research")
    progression.arrive({
      valid = true,
      force = force,
      physical_surface = surface,
      physical_controller_type = defines.controllers.god,
    })
    assert(not arrival.researched, "characterless presence counted")
    locked(force, planet)
    -- Physical surface is native even though the player wrapper is a facade.
    assert(character.teleport({ 0, 0 }, surface))
    player.physical_surface = surface
    progression.arrive(player)
    assert(arrival.researched, "physical arrival not recorded")
    locked(force, planet)
    assert(not other.technologies["quinityn-arrival-" .. planet].researched, "arrival crossed force boundary")
    assert(force.add_research(conversion), "earned branch cannot be researched")
    conversion.researched = true
    progression.research({ research = conversion })
    for _, item in ipairs(branches[planet]) do
      assert(force.recipes["y-ac-uc2" .. item].enabled and force.recipes["y-ac-" .. item .. "2uc"].enabled)
    end
    locked(force, planet == "vulcanus" and "fulgora" or "vulcanus")
    -- Arrival before discovery must wait; discovery retries a physically present
    -- character after a force change without granting the other planet's gate.
    character.force = other
    player.force = other
    progression.arrive(player)
    assert(not other.technologies["quinityn-arrival-" .. planet].researched)
    discover(other, planet, player)
    assert(other.technologies["quinityn-arrival-" .. planet].researched)
    locked(other, planet)
    character.destroy()
  end
  log("QUINITYN CIMOTA SETUP PASSED")
end)
script.on_event(defines.events.on_tick, function()
  -- --benchmark is a genuine save reload; persisted visit and branch ownership
  -- must survive without a player being present to replay the landing.
  progression.reconcile()
  for planet, items in pairs(branches) do
    local force = game.forces["cimota-" .. planet]
    assert(force.technologies["quinityn-arrival-" .. planet].researched)
    for _, item in ipairs(items) do
      assert(force.recipes["y-ac-uc2" .. item].enabled)
    end
    locked(force, planet == "vulcanus" and "fulgora" or "vulcanus")
  end
  log("QUINITYN CIMOTA RELOAD PASSED")
end)
