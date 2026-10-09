-- Paired real-engine surfaces differ in one map control, never in their seed.
local copy = require("util").table.deepcopy
local function check(ok, message)
  assert(ok, "MAP CONTROL TEST FAILED: " .. message)
  log("QUINITYN CONTROL PASS: " .. message)
end
script.on_init(function()
  local template = game.planets.quinityn.prototype.map_gen_settings
  local area = { { -384, -384 }, { 384, 384 } }
  local function sample(name, edit)
    local settings = copy(template)
    settings.seed = 42
    edit(settings)
    local surface = game.create_surface("controls-" .. name, settings)
    surface.request_to_generate_chunks({ 0, 0 }, 12)
    surface.force_generate_chunk_requests()
    local sea = surface.count_tiles_filtered({ area = area, name = "quinityn-unicomp-sea" })
    local cliffs = surface.count_entities_filtered({ area = area, type = "cliff" })
    local trees = surface.count_entities_filtered({ area = area, type = "tree" })
    local coast = 0
    for _, cliff in pairs(surface.find_entities_filtered({ area = area, type = "cliff" })) do
      assert(cliff.name == "quinityn-cliff")
      assert(
        surface.get_tile(cliff.position).name == "quinityn-ruined-district",
        "Cliff origin outside machinery district: " .. name
      )
      local p = cliff.position
      if
        surface.count_tiles_filtered({
          area = { { p.x - 10, p.y - 10 }, { p.x + 10, p.y + 10 } },
          name = "quinityn-unicomp-sea",
        }) > 0
      then
        coast = coast + 1
      end
    end
    local bases = surface.count_entities_filtered({ area = area, type = "unit-spawner" })
    check(
      surface.count_entities_filtered({ area = { { -80, -80 }, { 80, 80 } }, type = "cliff" }) == 0,
      name .. " protects starter core from cliffs"
    )
    local signature = {}
    for _, e in pairs(surface.find_entities_filtered({ area = area, type = "unit-spawner" })) do
      assert(e.name:find("^quinityn%-"), "Natural nest is not contaminated")
      assert(surface.get_tile(e.position).name == "quinityn-slag", "Natural nest outside brown slag")
      signature[#signature + 1] = e.name .. ":" .. e.position.x .. ":" .. e.position.y
    end
    for _, worm in pairs(surface.find_entities_filtered({ area = area, type = "turret", force = "enemy" })) do
      assert(worm.name:find("^quinityn%-"), "Natural worm is not contaminated")
      assert(surface.get_tile(worm.position).name == "quinityn-slag", "Natural worm outside brown slag")
    end
    if name == "default" then
      for _, kind in ipairs({
        "quinityn-basalt",
        "quinityn-ash",
        "quinityn-slag",
        "quinityn-rubble",
        "quinityn-ruined-district",
        "quinityn-weathered-soil",
        "quinityn-dead-turf",
        "quinityn-ash-soil",
      }) do
        local placed = false
        for _, tile in pairs(surface.find_tiles_filtered({ area = area, name = kind })) do
          local spec = {
            name = "quinityn-biter-spawner",
            force = "enemy",
            position = { tile.position.x + 0.5, tile.position.y + 0.5 },
          }
          if surface.can_place_entity(spec) then
            local nest = surface.create_entity(spec)
            check(nest and nest.valid, "later colony placement remains allowed on " .. kind)
            nest.destroy()
            placed = true
            break
          end
        end
        check(placed, "walkable colony site exists on " .. kind)
      end
    end
    table.sort(signature)
    log(
      "CONTROL SAMPLE "
        .. name
        .. " sea="
        .. sea
        .. " cliffs="
        .. cliffs
        .. " bases="
        .. bases
        .. " trees="
        .. trees
        .. " coastal-cliffs="
        .. coast
    )
    game.delete_surface(surface)
    return {
      sea = sea,
      cliffs = cliffs,
      coast = coast,
      trees = trees,
      bases = bases,
      signature = table.concat(signature, ";"),
    }
  end
  local normal = sample("default", function(_) end)
  -- Same seed/area at f14a2ae had 806 coastal cliffs; PR #1 (2c7d5d3) had 445 trees.
  check(normal.coast > 0 and normal.coast < 806 * 0.65, "machinery-only cliffs retain reduced coastal coverage")
  check(normal.trees > 445 * 0.7 and normal.trees < 445 * 0.9, "default trees are modestly reduced from PR #1")
  check(
    normal.coast / normal.cliffs > 0.5 and normal.coast < normal.cliffs,
    "cliffs are mostly coastal with some inland"
  )
  check(normal.trees > 20 and normal.trees < 1000, "dead trees are present but sparse by default")
  local no_trees = sample("trees-off", function(s)
    s.autoplace_controls.quinityn_trees = { frequency = 0, size = 0 }
  end)
  check(no_trees.trees == 0, "tree checkbox suppresses all trees")
  local more_trees = sample("more-trees", function(s)
    s.autoplace_controls.quinityn_trees.size = 2
  end)
  check(more_trees.trees > normal.trees, "tree coverage slider increases groves")
  local scaled_trees = sample("tree-frequency", function(s)
    s.autoplace_controls.quinityn_trees.frequency = 4
  end)
  check(scaled_trees.trees > 0 and scaled_trees.trees ~= normal.trees, "tree frequency changes groves")
  local dry = sample("less-liquid", function(s)
    s.autoplace_controls.quinityn_water.size = 0.5
  end)
  local wet = sample("more-liquid", function(s)
    s.autoplace_controls.quinityn_water.size = 2
  end)
  check(dry.sea < normal.sea and normal.sea < wet.sea, "unicomp coverage changes land/liquid ratio monotonically")
  local scaled = sample("smaller-districts", function(s)
    s.autoplace_controls.quinityn_water.frequency = 4
  end)
  check(scaled.sea ~= normal.sea, "unicomp scale changes generated terrain")
  local no_cliffs = sample("no-cliffs", function(s)
    s.autoplace_controls.quinityn_cliff.frequency = 0
  end)
  check(normal.cliffs > 0 and no_cliffs.cliffs == 0, "cliffs generate by default and their slider disables them")
  local no_nauvis = sample("nauvis-enemies-off", function(s)
    s.autoplace_controls["enemy-base"] = { frequency = 0, size = 0 }
  end)
  check(
    normal.bases > 0 and no_nauvis.signature == normal.signature,
    "Nauvis enemy settings do not change Quinityn nests"
  )
  local more_bases = sample("more-enemies", function(s)
    s.autoplace_controls.quinityn_enemy_base = { frequency = 4, size = 2 }
  end)
  check(more_bases.bases > normal.bases, "Quinityn enemy slider increases native nests")
  local no_bases = sample("no-enemies", function(s)
    s.autoplace_controls.quinityn_enemy_base.frequency = 0
  end)
  check(no_bases.bases == 0, "zero Quinityn enemy frequency suppresses nests")
  for name, planet in pairs(game.planets) do
    if name ~= "quinityn" then
      local s = planet.create_surface()
      s.request_to_generate_chunks({ 0, 0 }, 4)
      s.force_generate_chunk_requests()
      check(s.count_entities_filtered({ name = { "y-res1", "y-res2" } }) == 0, name .. " has no Yuoki ores")
      check(
        s.count_entities_filtered({ name = { "quinityn-big-rock", "quinityn-huge-rock" } }) == 0,
        name .. " has no Quinityn flyash rocks"
      )
      for _, entity in pairs(s.find_entities_filtered({ type = { "unit", "unit-spawner", "turret" } })) do
        assert(not entity.name:find("^quinityn%-"), name .. " generated a contaminated enemy")
      end
    end
  end
  log("QUINITYN MAP CONTROL TESTS PASSED")
end)
