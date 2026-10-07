local copy = table.deepcopy
local sea = copy(data.raw.tile["water"])
sea.name = "quinityn-unicomp-sea"
sea.localised_name = {"tile-name.quinityn-unicomp-sea"}
sea.fluid = "y-liquid-uc2"
sea.destroys_dropped_items = true
sea.default_destroyed_dropped_item_trigger = copy(data.raw.tile.lava.default_destroyed_dropped_item_trigger)
sea.absorptions_per_second = {pollution=0.000001}
sea.map_color = {0.32, 0.07, 0.42}
sea.effect_color = {0.38, 0.08, 0.48}
sea.effect_color_secondary = {0.17, 0.02, 0.26}
sea.tint = {0.66, 0.30, 0.85}
sea.autoplace = {probability_expression = "1000 * (quinityn_elevation < 0)"}
sea.allowed_neighbors = nil
sea.transition_merges_with_tile = nil
sea.ambient_sounds_group = "water"
sea.ambient_sounds = nil
sea.default_cover_tile = "quinityn-foundation"
sea.localised_description = {"tile-description.quinityn-unicomp-sea"}
local land = copy(data.raw.tile["volcanic-ash-dark"])
land.name = "quinityn-basalt"
land.autoplace = {probability_expression = "1000 * (quinityn_elevation >= 0)"}
land.absorptions_per_second = {pollution=0.000001}
land.map_color = {0.22, 0.19, 0.24}
land.tint = {0.82, 0.77, 0.91}
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
planet.icons = {{icon = planet.icon, icon_size = 64, tint = {0.75, 0.4, 1}}}
planet.starmap_icon = "__space-age__/graphics/icons/starmap-planet-fulgora.png"
planet.starmap_icon_size = 512
planet.distance = 23
planet.orientation = 0.18
planet.order = "d[quinityn]"
planet.subgroup = "planets"
planet.map_seed_offset = 420151201
planet.solar_power_in_space = 180
planet.surface_render_parameters = copy(data.raw.planet.vulcanus.surface_render_parameters)
planet.surface_render_parameters.fog.color1 = {0.52,0.42,0.49}
planet.surface_render_parameters.fog.color2 = {0.33,0.29,0.37}
planet.surface_render_parameters.day_night_cycle_color_lookup = copy(data.raw.planet.fulgora.surface_render_parameters.day_night_cycle_color_lookup)
planet.persistent_ambient_sounds = copy(data.raw.planet.vulcanus.persistent_ambient_sounds)
planet.surface_properties = {
  ["day-night-cycle"] = 12 * 60 * 60,
  ["solar-power"] = 70,
  ["pressure"] = 1600,
  ["gravity"] = 10,
  ["magnetic-field"] = 60,
  ["quinityn-industry"] = 1
}
planet.asteroid_spawn_definitions = copy(data.raw.planet.vulcanus.asteroid_spawn_definitions)
planet.map_gen_settings = {
  water = 1,
  starting_area = 1.5,
  property_expression_names = {
    elevation = "quinityn_elevation", moisture = "0", aux = "0",
    cliff_elevation = "quinityn_cliff_elevation", cliffiness = "quinityn_cliffiness",
    enemy_base_radius = "quinityn_enemy_base_radius",
    enemy_base_frequency = "quinityn_enemy_base_frequency"
  },
  cliff_settings = {name = "cliff", control = "quinityn_cliff",
    cliff_elevation_interval = 24, cliff_elevation_0 = 12, richness = 0.7},
  autoplace_controls = {
    ["y-res1"] = {frequency = 0.5, size = 0.5, richness = 0.5},
    ["y-res2"] = {frequency = 0.5, size = 0.5, richness = 0.5},
    ["quinityn_enemy_base"] = {frequency = 1, size = 1},
    ["quinityn_water"] = {frequency = 1, size = 1},
    ["quinityn_cliff"] = {}
  },
  autoplace_settings = {
    tile = {treat_missing_as_default = false, settings = {[sea.name] = {}, [land.name] = {}}},
    decorative = {treat_missing_as_default = false, settings = {}},
    entity = {treat_missing_as_default = false, settings = {
      ["y-res1"] = {}, ["y-res2"] = {},
      ["biter-spawner"] = {}, ["spitter-spawner"] = {},
      ["small-worm-turret"] = {}, ["medium-worm-turret"] = {},
      ["big-worm-turret"] = {}, ["behemoth-worm-turret"] = {}
    }}
  }
}
local connection = copy(data.raw["space-connection"]["nauvis-vulcanus"])
connection.name = "nauvis-quinityn"
connection.to = "quinityn"
connection.length = 15000
connection.order = "d"
data:extend({
  {type = "surface-property", name = "quinityn-industry", default_value = 0},
  {type="autoplace-control",name="quinityn_water",category="terrain",order="c-z-e",can_be_disabled=false,
    localised_description={"autoplace-control-descriptions.quinityn_water"}},
  {type="autoplace-control",name="quinityn_cliff",category="cliff",order="c-z-e",
    localised_description={"autoplace-control-descriptions.quinityn_cliff"}},
  {type="autoplace-control",name="quinityn_enemy_base",category="enemy",order="z-q",
    richness=false,can_be_disabled=false,related_to_fight_achievements=true,
    localised_description={"autoplace-control-descriptions.quinityn_enemy_base"}},
  {type="noise-expression",name="quinityn_enemy_base_radius",
    expression="sqrt(control:quinityn_enemy_base:size) * (15 + 4 * enemy_base_intensity)"},
  {type="noise-expression",name="quinityn_enemy_base_frequency",
    expression="(0.00001 + 0.000003 * enemy_base_intensity) * control:quinityn_enemy_base:frequency"},
  {type="noise-expression",name="quinityn_cliff_elevation",expression="4 * quinityn_elevation"},
  {type="noise-expression",name="quinityn_cliffiness",
    expression="cliffiness_basic * (distance > 125) * (quinityn_elevation > 2)"},
  -- Domain warping breaks up smooth coastlines; broad ridges keep districts joined.
  {type="noise-expression",name="quinityn_warp_x",expression=[[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=811,octaves=3,
      persistence=0.55,input_scale=0.009,output_scale=38}
  ]]},
  {type="noise-expression",name="quinityn_warp_y",expression=[[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=812,octaves=3,
      persistence=0.55,input_scale=0.009,output_scale=38}
  ]]},
  {type="noise-expression",name="quinityn_continents",expression=[[
    multioctave_noise{x=x+quinityn_warp_x,y=y+quinityn_warp_y,
      seed0=map_seed,seed1=912,octaves=4,persistence=0.55,input_scale=0.007 * sqrt(control:quinityn_water:frequency),output_scale=1}
  ]]},
  {type="noise-expression",name="quinityn_elevation",expression=[[
    max(110-sqrt((x+18*sin(quinityn_warp_x/20))^2+(y+18*sin(quinityn_warp_y/20))^2),
      28*(0.33 / max(0.1,control:quinityn_water:size)-abs(quinityn_continents)))
  ]]},
  {type="noise-expression",name="quinityn_stockpile_noise",expression=[[
    multioctave_noise{x=x,y=y,seed0=map_seed,seed1=2171,octaves=3,
      persistence=0.6,input_scale=0.009,output_scale=1}
  ]]},
  -- Fulgora-style layered density: sparse districts containing dense wreck clusters.
  {type="noise-expression",name="quinityn_stockpile_probability",expression=[[
    (quinityn_elevation > 0) * (distance > 80) * 0.06 * clamp(
      max(quinityn_stockpile_noise-1.1,
        1-((x+18*sin(quinityn_warp_x/20)-88)^2+(y+18*sin(quinityn_warp_y/20)-20)^2)/900,
        1-((x+18*sin(quinityn_warp_x/20)+82)^2+(y+18*sin(quinityn_warp_y/20)+30)^2)/900) * 5,0,1)
  ]]},
  sea, land, planet, connection
})
-- Suppress native large starter patches on this surface only; finite hand-placed
-- deposits contain 125k–150k units per ore. Distant deposits remain configurable.
for _, ore in ipairs({"y-res1", "y-res2"}) do
  local expression="quinityn_"..ore:gsub("-","_").."_probability"
  data:extend({{type="noise-expression",name=expression,
    expression="("..data.raw.resource[ore].autoplace.probability_expression..") * (distance > 200)"}})
  planet.map_gen_settings.property_expression_names["entity:"..ore..":probability"]=expression
end

-- Ruined industrial districts interrupt the basalt with slag and buried machinery.
data:extend({{type="noise-expression",name="quinityn_industrial_noise",expression=[[
  multioctave_noise{x=x,y=y,seed0=map_seed,seed1=1717,octaves=3,
    persistence=0.5,input_scale=0.025,output_scale=1}
]]}})
for i, spec in ipairs({
  {name="quinityn-slag",source="volcanic-ash-cracks",threshold="quinityn_industrial_noise > 0.15"},
  {name="quinityn-ruined-district",source="fulgoran-machinery",threshold="quinityn_industrial_noise > 0.45"},
  {name="quinityn-ash",source="volcanic-ash-light",threshold="quinityn_industrial_noise < -0.20"},
  {name="quinityn-rubble",source="fulgoran-walls",threshold="quinityn_industrial_noise < -0.45"}
}) do
  local tile=copy(data.raw.tile[spec.source])
  tile.name=spec.name
  tile.allowed_neighbors=nil
  tile.transition_merges_with_tile=nil
  tile.autoplace={probability_expression=(2000+i).." * (quinityn_elevation >= 0) * (distance > 12) * ("..spec.threshold..")"}
  tile.absorptions_per_second={pollution=0.000001}
  tile.tint={0.75,0.65,0.8}
  for _, tr in pairs(tile.transitions or {}) do
    if tr.to_tiles then table.insert(tr.to_tiles,"quinityn-unicomp-sea") end
  end
  data:extend({tile})
  planet.map_gen_settings.autoplace_settings.tile.settings[spec.name]={}
end

-- Surface-local decorative clones use this world's masks, not another planet's noise.
for _, spec in ipairs({
  {"tiny-volcanic-rock",0.12}, {"small-volcanic-rock",0.025},
  {"vulcanus-crack-decal",0.035}, {"pumice-relief-decal",0.018},
  {"fulgoran-ruin-tiny",0.055}
}) do
  local decorative=copy(data.raw["optimized-decorative"][spec[1]])
  decorative.name="quinityn-"..spec[1]
  decorative.localised_name={"decorative-name."..decorative.name}
  decorative.collision_mask={layers={water_tile=true},colliding_with_tiles_only=true}
  decorative.autoplace={probability_expression=spec[2]..
    " * (quinityn_elevation > 0) * clamp(0.5 + quinityn_industrial_noise,0.15,1)"}
  data:extend({decorative})
  planet.map_gen_settings.autoplace_settings.decorative.settings[decorative.name]={}
end
