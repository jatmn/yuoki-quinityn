local stages = require("prototypes.recipe-stages")
local owned = {}
local names = {}
for name, r in pairs(data.raw.recipe) do
  if stages.owned(r) then owned[name]=true; table.insert(names,name) end
end
table.sort(names)
-- Remember existing progress gates (notably Space Age resource conversions).
local existing = {}
for name, tech in pairs(data.raw.technology) do
  if not name:match("^quinityn%-") then
    local keep = {}
    for _, effect in pairs(tech.effects or {}) do
      if effect.type=="unlock-recipe" and owned[effect.recipe] then
        existing[effect.recipe]=existing[effect.recipe] or {}
        table.insert(existing[effect.recipe],name)
      else table.insert(keep,effect) end
    end
    tech.effects=keep
  end
end
for _, name in ipairs(names) do
  local r=data.raw.recipe[name]
  r.enabled=false
  local tech="quinityn-"..stages.stage(r)
  local old=existing[name]
  if name=="y-heavyoil2uc" and not settings.startup["yuoki-uc-heavyoil"].value then
    -- Respect the upstream opt-out even after researching Cimota.
  elseif old and #old>0 then
    -- Preserve an OR between alternative old unlocks with one bridge per old technology.
    table.sort(old)
    for i, prerequisite in ipairs(old) do
      local bridge="quinityn-bridge-"..stages.stage(r).."-"..prerequisite
      if not data.raw.technology[bridge] then
        data:extend({{type="technology",name=bridge,
          localised_name={"technology-name."..tech},
          icons=table.deepcopy(data.raw.technology[tech].icons),
          prerequisites={tech,prerequisite},research_trigger={type="scripted",trigger_description={"quinityn.bridge"}},
          effects={},hidden=true}})
      end
      table.insert(data.raw.technology[bridge].effects,{type="unlock-recipe",recipe=name})
    end
  else
    table.insert(data.raw.technology[tech].effects,{type="unlock-recipe",recipe=name})
  end
end
-- Publish a deterministic audit to the Factorio log without maintaining a second recipe list.
log("Quinityn gated "..#names.." Yuoki / Engines recipes")
-- Native Nauvis placement is supplied by Yuoki: Quinityn is its source world in this addon.
-- Restrict only the two Yuoki ores, leaving other planets' terrain untouched.
for name, planet in pairs(data.raw.planet) do
  if name ~= "quinityn" and planet.map_gen_settings then
    local mg=planet.map_gen_settings
    for _, ore in ipairs({"y-res1","y-res2"}) do
      if mg.autoplace_controls then mg.autoplace_controls[ore]=nil end
      local entities=mg.autoplace_settings and mg.autoplace_settings.entity
      if entities and entities.settings then entities.settings[ore]=nil end
      -- Do not advertise a disabled slider. Explicitly suppress probability too,
      -- including surfaces whose entity placement uses default settings.
      mg.property_expression_names=mg.property_expression_names or {}
      mg.property_expression_names["entity:"..ore..":probability"]="0"
    end
  end
end
-- Match all normal foundation destinations, then add the unicomp sea exclusively.
local foundation=data.raw.item["quinityn-foundation"]
foundation.place_as_tile=table.deepcopy(data.raw.item.foundation.place_as_tile)
foundation.place_as_tile.result="quinityn-foundation"
table.insert(foundation.place_as_tile.tile_condition,"quinityn-unicomp-sea")
