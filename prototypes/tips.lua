data:extend({ { type = "tips-and-tricks-item-category", name = "quinityn", order = "l[quinityn]" } })
local biology_simulations = require("prototypes.biology-simulations")
local tutorial_simulations = require("prototypes.tutorial-simulations")
local chapters = {
  { "briefing", "planet-discovery-quinityn", "[planet=quinityn]" },
  { "bootstrap", "quinityn-arrival", "[item=quinityn-salvage]" },
  { "unicomp", "quinityn-arrival", "[fluid=y-liquid-uc2]" },
  { "materials", "quinityn-materials", "[item=y-crusher]" },
  { "power", "quinityn-power", "[item=y-notfall-generator-s2]" },
  { "cimota", "quinityn-cimota", "[item=y-atomic-constructor]" },
  { "engines", "quinityn-engines", "[fluid=y-mechanical-force]" },
  { "refining", "quinityn-refining", "[item=y_catalyst_bp]" },
  { "foundation", "quinityn-foundation", "[item=quinityn-foundation]" },
  { "agriculture", "quinityn-agriculture", "[item=ye_farm]" },
  { "logistics", "quinityn-logistics", "[item=yi_roboport]" },
  { "defense", "quinityn-defense", "[item=y_turret_flame]" },
  { "quantum", "quinityn-quantum", "[item=y-quantrinum]" },
  { "trade", "quinityn-trade", "[item=y-stargate]" },
  { "mastery", "quinityn-mastery", "[item=y_rwtechsign]" },
  { "orbital", "quinityn-orbital", "[item=rocket-silo]" },
  { "endgame", "quinityn-mastery", "[item=quinityn-research-data]" },
}
for i, chapter in ipairs(chapters) do
  data:extend({
    {
      type = "tips-and-tricks-item",
      name = "quinityn-" .. chapter[1],
      category = "quinityn",
      tag = chapter[3],
      order = string.format("%02d", i),
      indent = i == 1 and 0 or 1,
      is_title = i == 1,
      trigger = { type = "research", technology = chapter[2] },
      localised_name = { "tips-and-tricks-item-name.quinityn-" .. chapter[1] },
      localised_description = { "tips-and-tricks-item-description.quinityn-" .. chapter[1] },
      simulation = biology_simulations[chapter[1]] or tutorial_simulations[chapter[1]],
    },
  })
end

-- Keep each research branch after its prerequisites, including new split
-- stages. Stable ties retain the chapter/tier order within a milestone.
local depths = {}
local function depth(name)
  if depths[name] then
    return depths[name]
  end
  local value = 0
  for _, parent in ipairs(data.raw.technology[name].prerequisites or {}) do
    value = math.max(value, depth(parent) + 1)
  end
  depths[name] = value
  return value
end
local function trigger_depth(trigger)
  if trigger.type == "research" then
    return depth(trigger.technology)
  end
  local value = trigger.type == "or" and math.huge or 0
  for _, child in ipairs(trigger.triggers or {}) do
    if trigger.type == "or" then
      value = math.min(value, trigger_depth(child))
    else
      value = math.max(value, trigger_depth(child))
    end
  end
  return value
end
for i, stage in ipairs({ "surplus", "oil-processing" }) do
  data:extend({
    {
      type = "tips-and-tricks-item",
      name = "quinityn-" .. stage,
      category = "quinityn",
      order = "19-" .. i,
      indent = 1,
      trigger = { type = "research", technology = "quinityn-" .. stage },
      localised_name = { "technology-name.quinityn-" .. stage },
      localised_description = { "technology-description.quinityn-" .. stage },
      simulation = tutorial_simulations[stage],
    },
  })
end

for i, tier in ipairs(require("prototypes.research-tiers")) do
  data:extend({
    {
      type = "tips-and-tricks-item",
      name = "quinityn-" .. tier.name,
      category = "quinityn",
      tag = "[item=" .. tier.icon .. "]",
      order = "20-" .. string.format("%02d", i),
      indent = 1,
      trigger = { type = "research", technology = "quinityn-" .. tier.name },
      localised_name = { "technology-name.quinityn-" .. tier.name },
      localised_description = { "technology-description.quinityn-" .. tier.name },
      simulation = biology_simulations[tier.name] or tutorial_simulations[tier.name],
    },
  })
end

-- Wait for equipment/material prerequisites in demonstrations whose recipes
-- are revealed before they can be used. This does not change research itself.
data:extend({
  {
    type = "tips-and-tricks-item",
    name = "quinityn-science-production",
    category = "quinityn",
    order = "19-3",
    indent = 1,
    trigger = { type = "research", technology = "quinityn-industrial-science" },
    localised_name = { "tips-and-tricks-item-name.quinityn-science-production" },
    localised_description = { "tips-and-tricks-item-description.quinityn-science-production" },
    simulation = tutorial_simulations["science-production"],
  },
})
for stage, definition in pairs(require("scripts.tutorial-processes")) do
  if definition.requires or definition.requires_any then
    local tip = assert(data.raw["tips-and-tricks-item"]["quinityn-" .. stage])
    local triggers = { tip.trigger }
    for _, technology in ipairs(definition.requires or {}) do
      triggers[#triggers + 1] = { type = "research", technology = technology }
    end
    if definition.requires_any then
      local alternatives = {}
      for _, technology in ipairs(definition.requires_any) do
        alternatives[#alternatives + 1] = { type = "research", technology = technology }
      end
      triggers[#triggers + 1] = { type = "or", triggers = alternatives }
    end
    tip.trigger = { type = "and", triggers = triggers }
  end
end
for _, tip in pairs(data.raw["tips-and-tricks-item"]) do
  if tip.category == "quinityn" then
    tip.order = string.format("%03d-%s", tip.is_title and 0 or trigger_depth(tip.trigger), tip.order)
  end
end
