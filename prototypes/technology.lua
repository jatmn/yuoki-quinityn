local icon = "__Yuoki__/graphics/icons/sign_tech_icon.png"
local function unlock(name) return {type="unlock-recipe",recipe=name} end
local discovery = table.deepcopy(data.raw.technology["planet-discovery-vulcanus"])
discovery.name = "planet-discovery-quinityn"
discovery.icon = "__space-age__/graphics/technology/fulgora.png"
discovery.effects = {{type="unlock-space-location",space_location="quinityn",use_icon_overlay_constant=true}}
discovery.localised_name = {"technology-name.planet-discovery-quinityn"}
discovery.localised_description = {"technology-description.planet-discovery-quinityn"}
local landing = {type="technology",name="quinityn-arrival",icon=icon,icon_size=64,
  effects={}, research_trigger={type="scripted",trigger_description={"quinityn.land-to-unlock"}},
  order="y-a", essential=true}
for _, name in ipairs({"hand-sort","iron","copper","carbon","stone","timber","burner-separator","water"}) do
  table.insert(landing.effects,unlock("quinityn-"..name))
end
data:extend({discovery,landing})
-- A single shared foundation followed by focused industrial disciplines.
local stages = {
  {"materials", "arrival", 30},
  {"power", "materials", 60},
  {"cimota", "power", 100},
  {"engines", "cimota", 120},
  {"refining", "engines", 150},
  {"agriculture", "refining", 180},
  {"logistics", "refining", 180},
  {"defense", "power", 100},
  {"quantum", "agriculture", 250},
  {"trade", "quantum", 300},
  {"mastery", "trade", 500},
  {"orbital", "quantum", 200}
}
for i, s in ipairs(stages) do
  local science = {{"automation-science-pack",1}}
  if s[1] ~= "materials" then table.insert(science,{"logistic-science-pack",1}) end
  if s[1] ~= "materials" and s[1] ~= "power" and s[1] ~= "defense" then
    table.insert(science,{"quinityn-research-data",1})
  end
  data:extend({{type="technology",name="quinityn-"..s[1],icon=icon,icon_size=64,
    effects={},prerequisites={"quinityn-"..s[2]},
    unit={count=s[3],time=20,ingredients=science},order="y-"..string.format("%02d",i)}})
end
table.insert(data.raw.technology["quinityn-materials"].effects,unlock("quinityn-research-data"))
data:extend({{type="technology",name="quinityn-oil-processing",
  icon="__base__/graphics/technology/oil-processing.png",icon_size=256,
  prerequisites={"quinityn-cimota","oil-gathering"},
  research_trigger={type="craft-fluid",fluid="crude-oil",amount=80},
  effects={{type="nothing",effect_description={"quinityn.oil-processing-effect"}}}}})
local orbital=data.raw.technology["quinityn-orbital"]
table.insert(orbital.prerequisites,"rocket-silo")
table.insert(orbital.effects,unlock("quinityn-low-density-structure"))
table.insert(orbital.effects,unlock("quinityn-processing-unit"))
