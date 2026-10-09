local copy = table.deepcopy
-- Restrict this planet's cliff placement with native tile collision, including
-- map previews. Other cliffs and the source planet's tiles remain untouched.
local cliff_blocker = "quinityn-cliff-blocker"
local cliff = copy(data.raw.cliff["cliff-fulgora"])
cliff.name = "quinityn-cliff"
cliff.localised_name = { "entity-name.quinityn-cliff" }
cliff.collision_mask.layers[cliff_blocker] = true
data:extend({ { type = "collision-layer", name = cliff_blocker }, cliff })
local sea = copy(data.raw.tile["water"])
sea.name = "quinityn-unicomp-sea"
sea.collision_mask.layers[cliff_blocker] = true
sea.localised_name = { "tile-name.quinityn-unicomp-sea" }
sea.fluid = "y-liquid-uc2"
sea.destroys_dropped_items = true
sea.default_destroyed_dropped_item_trigger = copy(data.raw.tile.lava.default_destroyed_dropped_item_trigger)
sea.absorptions_per_second = { pollution = 0.000001 }
sea.map_color = { 0.32, 0.07, 0.42 }
sea.effect_color = { 0.38, 0.08, 0.48 }
sea.effect_color_secondary = { 0.17, 0.02, 0.26 }
sea.tint = { 0.66, 0.30, 0.85 }
sea.autoplace = { probability_expression = "1000 * (quinityn_elevation < 0)" }
sea.allowed_neighbors = nil
sea.transition_merges_with_tile = nil
sea.ambient_sounds_group = "water"
sea.ambient_sounds = nil
sea.default_cover_tile = "quinityn-foundation"
sea.localised_description = { "tile-description.quinityn-unicomp-sea" }
local land = copy(data.raw.tile["volcanic-ash-dark"])
land.name = "quinityn-basalt"
land.collision_mask.layers[cliff_blocker] = true
land.autoplace = { probability_expression = "1000 * (quinityn_elevation >= 0)" }
land.absorptions_per_second = { pollution = 0.000001 }
land.map_color = { 0.22, 0.19, 0.24 }
land.tint = { 0.82, 0.77, 0.91 }
land.allowed_neighbors = nil
land.transition_merges_with_tile = nil
-- Reuse the native water transition sprites; include our sea in every land-water boundary.
for _, tr in pairs(land.transitions or {}) do
  if tr.to_tiles then
    for _, name in pairs(tr.to_tiles) do
      if name == "water" or name == "lava" then
        table.insert(tr.to_tiles, sea.name)
        break
      end
    end
  end
end
local planet = copy(data.raw.planet.nauvis)
planet.name = "quinityn"
planet.icon = "__space-age__/graphics/icons/fulgora.png"
planet.icons = { { icon = planet.icon, icon_size = 64, tint = { 0.75, 0.4, 1 } } }
planet.starmap_icon = "__space-age__/graphics/icons/starmap-planet-fulgora.png"
planet.starmap_icon_size = 512
planet.distance = 23
planet.orientation = 0.18
planet.order = "d[quinityn]"
planet.subgroup = "planets"
planet.map_seed_offset = 420151201
planet.solar_power_in_space = 180
planet.surface_render_parameters = copy(data.raw.planet.vulcanus.surface_render_parameters)
planet.surface_render_parameters.fog.color1 = { 0.52, 0.42, 0.49 }
planet.surface_render_parameters.fog.color2 = { 0.33, 0.29, 0.37 }
planet.surface_render_parameters.day_night_cycle_color_lookup =
  copy(data.raw.planet.fulgora.surface_render_parameters.day_night_cycle_color_lookup)
planet.persistent_ambient_sounds = copy(data.raw.planet.vulcanus.persistent_ambient_sounds)
planet.surface_properties = {
  ["day-night-cycle"] = 12 * 60 * 60,
  ["solar-power"] = 70,
  ["pressure"] = 1600,
  ["gravity"] = 10,
  ["magnetic-field"] = 60,
  ["quinityn-industry"] = 1,
}
planet.asteroid_spawn_definitions = copy(data.raw.planet.vulcanus.asteroid_spawn_definitions)
planet.map_gen_settings = {
  water = 1,
  starting_area = 1.5,
  property_expression_names = {
    elevation = "quinityn_elevation",
    moisture = "0",
    aux = "0",
    cliff_elevation = "quinityn_cliff_elevation",
    cliffiness = "quinityn_cliffiness",
    enemy_base_radius = "quinityn_enemy_base_radius",
    enemy_base_frequency = "quinityn_enemy_base_frequency",
  },
  cliff_settings = {
    name = cliff.name,
    control = "quinityn_cliff",
    cliff_elevation_interval = 40,
    cliff_elevation_0 = 80,
    cliff_smoothing = 0,
    richness = 0.85,
  },
  autoplace_controls = {
    ["y-res1"] = { frequency = 0.5, size = 0.5, richness = 0.5 },
    ["y-res2"] = { frequency = 0.5, size = 0.5, richness = 0.5 },
    ["quinityn_enemy_base"] = { frequency = 1, size = 1 },
    ["quinityn_water"] = { frequency = 1, size = 1 },
    ["quinityn_cliff"] = {},
    ["quinityn_trees"] = { frequency = 1.25, size = 1 },
  },
  autoplace_settings = {
    tile = { treat_missing_as_default = false, settings = { [sea.name] = {}, [land.name] = {} } },
    decorative = { treat_missing_as_default = false, settings = {} },
    entity = {
      treat_missing_as_default = false,
      settings = {
        ["y-res1"] = {},
        ["y-res2"] = {},
        ["quinityn-biter-spawner"] = {},
        ["quinityn-spitter-spawner"] = {},
        ["quinityn-small-worm-turret"] = {},
        ["quinityn-medium-worm-turret"] = {},
        ["quinityn-big-worm-turret"] = {},
        ["quinityn-behemoth-worm-turret"] = {},
      },
    },
  },
}
local connection = copy(data.raw["space-connection"]["nauvis-vulcanus"])
connection.name = "nauvis-quinityn"
connection.to = "quinityn"
connection.length = 15000
connection.order = "d"
data:extend({
  { type = "surface-property", name = "quinityn-industry", default_value = 0 },
  {
    type = "autoplace-control",
    name = "quinityn_water",
    category = "terrain",
    order = "c-z-e",
    can_be_disabled = false,
    localised_description = { "autoplace-control-descriptions.quinityn_water" },
  },
  {
    type = "autoplace-control",
    name = "quinityn_cliff",
    category = "cliff",
    order = "c-z-e",
    localised_description = { "autoplace-control-descriptions.quinityn_cliff" },
  },
  {
    type = "autoplace-control",
    name = "quinityn_trees",
    category = "terrain",
    order = "c-z-f",
    can_be_disabled = true,
    richness = false,
    localised_description = { "autoplace-control-descriptions.quinityn_trees" },
  },
  {
    type = "autoplace-control",
    name = "quinityn_enemy_base",
    category = "enemy",
    order = "z-q",
    richness = false,
    can_be_disabled = false,
    related_to_fight_achievements = true,
    localised_description = { "autoplace-control-descriptions.quinityn_enemy_base" },
  },
  {
    type = "noise-expression",
    name = "quinityn_enemy_base_radius",
    expression = "sqrt(control:quinityn_enemy_base:size) * (15 + 4 * enemy_base_intensity)",
  },
  {
    type = "noise-expression",
    name = "quinityn_enemy_base_frequency",
    -- Slag occupies only part of the dry land; retain opportunities for nearby bases.
    expression = "4 * (0.00001 + 0.000003 * enemy_base_intensity) * control:quinityn_enemy_base:frequency",
  },
  -- Like Fulgora, step across the first cliff level at the coast and disable
  -- smoothing. Higher contours leave a few inland escarpments.
  {
    type = "noise-expression",
    name = "quinityn_cliff_elevation",
    expression = "40 + 50 * (quinityn_elevation > 4) + clamp(2 * (quinityn_elevation - 4),0,70)",
  },
  {
    type = "noise-expression",
    name = "quinityn_cliffiness",
    -- Keep the generation grid inside district interiors; native end caps are
    -- offset from the grid points where cliffiness is sampled.
    expression = "cliffiness_basic * (quinityn_industrial_noise > 0.7) * (distance > 125) * (quinityn_passage_distance > 18) * (4 * (quinityn_elevation < 6) * (quinityn_coastal_breaks > 0.1) + 0.25 * (quinityn_elevation >= 6) * (quinityn_industrial_noise > 0.7))",
  },
  -- Coherent breaks remove about half the coastal wall and open usable shore.
  {
    type = "noise-expression",
    name = "quinityn_coastal_breaks",
    expression = [[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=5321,octaves=2,
      persistence=0.5,input_scale=0.035,output_scale=1}
  ]],
  },
  -- Domain warping breaks up smooth coastlines; broad ridges keep districts joined.
  {
    type = "noise-expression",
    name = "quinityn_warp_x",
    expression = [[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=811,octaves=3,
      persistence=0.55,input_scale=0.009,output_scale=38}
  ]],
  },
  {
    type = "noise-expression",
    name = "quinityn_warp_y",
    expression = [[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=812,octaves=3,
      persistence=0.55,input_scale=0.009,output_scale=38}
  ]],
  },
  {
    type = "noise-expression",
    name = "quinityn_continents",
    expression = [[
    multioctave_noise{x=x+quinityn_warp_x,y=y+quinityn_warp_y,
      seed0=map_seed,seed1=912,octaves=4,persistence=0.55,input_scale=0.007 * sqrt(control:quinityn_water:frequency),output_scale=1}
  ]],
  },
  -- A continuous meandering spine joins the landing district to the wider
  -- world for every seed and liquid setting. Sampling one-dimensional noise
  -- (and subtracting its origin) anchors it at landing without a circular island.
  -- Keep its inner strip clear of cliffs/trees so connected land is walkable.
  {
    type = "noise-expression",
    name = "quinityn_passage_distance",
    expression = [[
    abs(y - multioctave_noise{x=x,y=0,seed0=map_seed,seed1=915,octaves=3,
      persistence=0.5,input_scale=0.004,output_scale=100}
      + multioctave_noise{x=0,y=0,seed0=map_seed,seed1=915,octaves=3,
      persistence=0.5,input_scale=0.004,output_scale=100})
  ]],
  },
  {
    type = "noise-expression",
    name = "quinityn_elevation",
    expression = [[
    max(36 + 10*sin(quinityn_warp_x/20) - quinityn_passage_distance,
      110-sqrt((x+18*sin(quinityn_warp_x/20))^2+(y+18*sin(quinityn_warp_y/20))^2),
      28*(0.33 / max(0.1,control:quinityn_water:size)-abs(quinityn_continents)))
  ]],
  },
  {
    type = "noise-expression",
    name = "quinityn_stockpile_noise",
    expression = [[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=2171,octaves=3,
      persistence=0.6,input_scale=0.009,output_scale=1}
  ]],
  },
  -- Fulgora-style layered density: sparse districts containing dense wreck clusters.
  {
    type = "noise-expression",
    name = "quinityn_stockpile_probability",
    expression = [[
    (quinityn_elevation > 0) * (distance > 80) * (quinityn_passage_distance > 12) * 0.06 * clamp(
      max(quinityn_stockpile_noise-1.1,
        1-((x+18*sin(quinityn_warp_x/20)-88)^2+(y+18*sin(quinityn_warp_y/20)-20)^2)/900,
        1-((x+18*sin(quinityn_warp_x/20)+82)^2+(y+18*sin(quinityn_warp_y/20)+30)^2)/900) * 5,0,1)
  ]],
  },
  sea,
  land,
  planet,
  connection,
})
-- Suppress native large starter patches on this surface only; finite hand-placed
-- deposits contain 125k–150k units per ore. Distant deposits remain configurable.
for _, ore in ipairs({ "y-res1", "y-res2" }) do
  local expression = "quinityn_" .. ore:gsub("-", "_") .. "_probability"
  data:extend({
    {
      type = "noise-expression",
      name = expression,
      expression = "(" .. data.raw.resource[ore].autoplace.probability_expression .. ") * (distance > 200)",
    },
  })
  planet.map_gen_settings.property_expression_names["entity:" .. ore .. ":probability"] = expression
end

-- Native generation only: Uni-touched colonies originate on brown slag.
-- Their unit build lists retain expansion onto other walkable terrain.
for _, name in ipairs({
  "biter-spawner",
  "spitter-spawner",
  "small-worm-turret",
  "medium-worm-turret",
  "big-worm-turret",
  "behemoth-worm-turret",
}) do
  local entity = data.raw["unit-spawner"][name] or data.raw.turret[name]
  local expression = "quinityn_" .. name:gsub("-", "_") .. "_probability"
  data:extend({
    {
      type = "noise-expression",
      name = expression,
      localised_name = { "entity-name." .. name },
      expression = "("
        .. entity.autoplace.probability_expression
        .. ") * (quinityn_elevation >= 0)"
        .. " * (quinityn_industrial_noise > 0.15) * (quinityn_industrial_noise <= 0.45)",
    },
  })
  planet.map_gen_settings.property_expression_names["entity:quinityn-" .. name .. ":probability"] = expression
end

-- Remnants of the old soil weave between the industrial districts. Keep their
-- mask outside slag/machinery so native nest and cliff habitats remain intact.
data:extend({
  {
    type = "noise-expression",
    name = "quinityn_industrial_noise",
    expression = [[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=1717,octaves=3,
      persistence=0.5,input_scale=0.025,output_scale=1}
  ]],
  },
  {
    type = "noise-expression",
    name = "quinityn_soil_patches",
    expression = [[
    multioctave_noise{x=x+quinityn_warp_x,y=y+quinityn_warp_y,
      seed0=map_seed,seed1=2719,octaves=3,persistence=0.55,input_scale=0.012,output_scale=1}
  ]],
  },
  -- Distance in noise space to either edge of the natural-ground mask. A mixed
  -- ash/earth fringe grades into the old ground before reaching solid soil/turf.
  {
    type = "noise-expression",
    name = "quinityn_soil_edge",
    expression = [[
    min(0.15 - quinityn_industrial_noise, 0.5 * (quinityn_soil_patches + 0.65))
  ]],
  },
  {
    type = "noise-expression",
    name = "quinityn_turf_detail",
    expression = [[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=2720,octaves=2,
      persistence=0.5,input_scale=0.12,output_scale=0.12}
  ]],
  },
  {
    type = "noise-expression",
    name = "quinityn_groundcover",
    expression = [[
    clamp(multioctave_noise{x=x,y=y,seed0=map_seed,seed1=3121,octaves=2,
      persistence=0.5,input_scale=0.045,output_scale=1} + 0.25,0,1)
  ]],
  },
})
for i, spec in ipairs({
  { name = "quinityn-slag", source = "volcanic-ash-cracks", threshold = "quinityn_industrial_noise > 0.15" },
  { name = "quinityn-ruined-district", source = "fulgoran-machinery", threshold = "quinityn_industrial_noise > 0.45" },
  { name = "quinityn-ash", source = "volcanic-ash-light", threshold = "quinityn_industrial_noise < -0.20" },
  { name = "quinityn-rubble", source = "fulgoran-walls", threshold = "quinityn_industrial_noise < -0.45" },
  {
    name = "quinityn-weathered-soil",
    source = "dirt-6",
    layer = 55,
    tint = { 0.68, 0.74, 0.82 },
    map_color = { 0.25, 0.23, 0.23 },
    threshold = "(quinityn_industrial_noise <= 0.15) * (quinityn_soil_patches > -0.65)",
  },
  {
    name = "quinityn-dead-turf",
    source = "grass-4",
    layer = 56,
    tint = { 0.76, 0.74, 0.82 },
    map_color = { 0.24, 0.22, 0.24 },
    threshold = "(quinityn_industrial_noise <= 0.15) * (quinityn_soil_patches > -0.65) * (quinityn_soil_patches + quinityn_turf_detail > 0.4)",
  },
  {
    name = "quinityn-ash-soil",
    source = "volcanic-ash-soil",
    layer = 57,
    tint = { 0.80, 0.75, 0.84 },
    map_color = { 0.23, 0.21, 0.23 },
    threshold = "(quinityn_soil_edge > 0) * (quinityn_soil_edge < 0.18)",
  },
}) do
  local tile = copy(data.raw.tile[spec.source])
  tile.name = spec.name
  tile.factoriopedia_alternative = nil
  if spec.name ~= "quinityn-ruined-district" then
    tile.collision_mask.layers[cliff_blocker] = true
  end
  tile.allowed_neighbors = nil
  tile.transition_merges_with_tile = nil
  tile.autoplace = {
    probability_expression = (2000 + i)
      .. " * (quinityn_elevation >= 0) * (distance > 12) * ("
      .. spec.threshold
      .. ")",
  }
  tile.absorptions_per_second = { pollution = 0.000001 }
  tile.tint = spec.tint or { 0.75, 0.65, 0.8 }
  -- Match the ash layer family above slag; lower Nauvis layers let native tile
  -- correction replace narrow slag margins underneath map-generated nests.
  if spec.layer then
    tile.layer = spec.layer
  end
  if spec.map_color then
    tile.map_color = spec.map_color
  end
  if spec.layer then
    tile.vehicle_friction_modifier = land.vehicle_friction_modifier
  end
  for _, tr in pairs(tile.transitions or {}) do
    for _, name in pairs(tr.to_tiles or {}) do
      if name == "water" then
        table.insert(tr.to_tiles, sea.name)
        break
      end
    end
  end
  data:extend({ tile })
  planet.map_gen_settings.autoplace_settings.tile.settings[spec.name] = {}
end

-- Non-mineable ground detail follows the terrain: dry, poisoned plants and
-- ordinary stones on old soil; volcanic fragments and wreckage in scarred areas.
local soils = { "quinityn-weathered-soil", "quinityn-dead-turf", "quinityn-ash-soil" }
local rocky_ground = { "quinityn-basalt", "quinityn-slag", "quinityn-ash" }
for _, spec in ipairs({
  { "tiny-volcanic-rock", 0.12, tiles = rocky_ground },
  { "small-volcanic-rock", 0.025, tiles = rocky_ground },
  { "vulcanus-crack-decal", 0.035, tiles = { "quinityn-basalt", "quinityn-slag" } },
  { "pumice-relief-decal", 0.018, tiles = { "quinityn-basalt", "quinityn-ash" } },
  { "fulgoran-ruin-tiny", 0.055, tiles = { "quinityn-ruined-district", "quinityn-rubble" } },
  { "tiny-rock", 0.09, tiles = soils, tint = { 0.85, 0.78, 0.88 } },
  { "small-rock", 0.018, tiles = soils, tint = { 0.85, 0.78, 0.88 } },
  { "brown-asterisk", 0.035, name = "quinityn-dead-shrub", tiles = soils, tint = { 0.84, 0.64, 0.9 }, plant = true },
  { "brown-fluff-dry", 0.06, name = "quinityn-dry-tuft", tiles = soils, tint = { 0.86, 0.72, 0.9 }, plant = true },
  {
    "brown-hairy-grass",
    0.045,
    name = "quinityn-dead-grass",
    tiles = soils,
    tint = { 0.82, 0.69, 0.86 },
    plant = true,
  },
  {
    "brown-carpet-grass",
    0.018,
    name = "quinityn-dead-groundcover",
    tiles = soils,
    tint = { 0.82, 0.69, 0.86 },
    plant = true,
  },
}) do
  local decorative = copy(data.raw["optimized-decorative"][spec[1]])
  decorative.name = spec.name or "quinityn-" .. spec[1]
  decorative.localised_name = { "decorative-name." .. decorative.name }
  decorative.collision_mask = { layers = { water_tile = true }, colliding_with_tiles_only = true }
  if spec.tint then
    for _, sprite in pairs(decorative.pictures) do
      sprite.tint = spec.tint
    end
  end
  -- Equal autoplace orders compete, suppressing every type except the most
  -- probable one. Independent groups let stones, shrubs and grass coexist.
  decorative.autoplace = {
    order = decorative.name,
    tile_restriction = spec.tiles,
    probability_expression = spec[2]
      .. " * (quinityn_elevation > 0)"
      .. (
        spec.plant and " * quinityn_groundcover"
        or (spec.tiles == soils and "" or " * clamp(0.5 + quinityn_industrial_noise,0.15,1)")
      ),
  }
  data:extend({ decorative })
  planet.map_gen_settings.autoplace_settings.decorative.settings[decorative.name] = {}
end

-- Ordinary Nauvis boulders stained by unicomp and coated with settled flyash.
-- Small finite samples introduce the item; Fatmice supplies sustained research.
for _, name in ipairs({ "big-rock", "huge-rock", "big-sand-rock" }) do
  planet.map_gen_settings.property_expression_names["entity:" .. name .. ":probability"] = "0"
end
for _, spec in ipairs({ { "big-rock", 0.0015, 2 }, { "huge-rock", 0.0004, 4 } }) do
  local rock = copy(data.raw["simple-entity"][spec[1]])
  rock.name = "quinityn-" .. spec[1]
  rock.localised_name = { "entity-name." .. rock.name }
  rock.localised_description = { "entity-description.quinityn-flyash-rock" }
  rock.factoriopedia_alternative = nil
  local tint = { 0.76, 0.64, 0.82 }
  rock.icons = { { icon = rock.icon, icon_size = rock.icon_size or 64, tint = tint } }
  for _, sprite in pairs(rock.pictures) do
    sprite.tint = tint
  end
  rock.map_color = { 0.43, 0.37, 0.46 }
  if rock.minable.result then
    rock.minable.results = { { type = "item", name = rock.minable.result, amount = rock.minable.count or 1 } }
    rock.minable.result = nil
    rock.minable.count = nil
  end
  table.insert(rock.minable.results, { type = "item", name = "y-pol-waste", amount = spec[3] })
  -- Place after existing habitats so rocks cannot displace native trees or nests.
  rock.autoplace = {
    order = "z[quinityn-rock]-" .. spec[1],
    probability_expression = spec[2] .. [[
    * (quinityn_elevation > 1) * (distance > 24) * (quinityn_passage_distance > 12)
    * clamp(quinityn_soil_patches + 0.8,0.3,1)
  ]],
  }
  data:extend({ rock })
  planet.map_gen_settings.autoplace_settings.entity.settings[rock.name] = {}
end

-- Poisoned, leafless native trees: sparse groves rather than a living forest.
data:extend({
  {
    type = "noise-expression",
    name = "quinityn_tree_patches",
    expression = [[
  multioctave_noise{x=x,y=y,seed0=map_seed,seed1=3117,octaves=3,
    persistence=0.6,input_scale=0.012 * sqrt(control:quinityn_trees:frequency),output_scale=1}
]],
  },
})
for _, source in ipairs({ "dry-tree", "dead-dry-hairy-tree" }) do
  local tree = copy(data.raw.tree[source])
  tree.name = "quinityn-" .. source
  tree.localised_name = { "entity-name." .. tree.name }
  tree.localised_description = { "entity-description.quinityn-dead-tree" }
  tree.factoriopedia_alternative = nil
  tree.deconstruction_alternative = nil
  tree.icons = { { icon = tree.icon, icon_size = tree.icon_size or 64, tint = { 0.95, 0.68, 1 } } }
  tree.map_color = { 0.55, 0.36, 0.62 }
  for _, sprite in pairs(tree.pictures) do
    sprite.tint = { 0.95, 0.68, 1 }
  end
  tree.autoplace = {
    control = "quinityn_trees",
    order = "a[tree]-z[quinityn]",
    probability_expression = [[
    0.0112 * (control:quinityn_trees:frequency > 0) * (control:quinityn_trees:size > 0)
      * (distance > 85) * (quinityn_elevation > 1) * (quinityn_passage_distance > 12)
      * clamp((quinityn_tree_patches + 0.35 * log2(max(0.01,control:quinityn_trees:size)) - 0.48)*3,0,1)
  ]],
  }
  data:extend({ tree })
  planet.map_gen_settings.autoplace_settings.entity.settings[tree.name] = {}
end
