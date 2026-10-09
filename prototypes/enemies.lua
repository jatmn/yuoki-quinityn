local copy = table.deepcopy

-- Royal violet (#7040B8) anchors the palette; native mask colors retain distinct
-- shades for each variant. Keep each layer's original brightness and opacity.
local royal_violet = { 112 / 255, 64 / 255, 184 / 255 }
local function violet_tint(tint)
  local strength = tint and 0.75 or 1
  tint = tint or { 1, 1, 1, 1 }
  local r, g, b = tint.r or tint[1], tint.g or tint[2], tint.b or tint[3]
  local brightness = math.max(r, g, b)
  local violet = brightness / royal_violet[3] * strength
  r = r * (1 - strength) + royal_violet[1] * violet
  g = g * (1 - strength) + royal_violet[2] * violet
  b = b * (1 - strength) + royal_violet[3] * violet
  local mixed_brightness = math.max(r, g, b)
  local scale = mixed_brightness > 0 and brightness / mixed_brightness or 1
  return {
    r * scale,
    g * scale,
    b * scale,
    tint.a or tint[4] or 1,
  }
end

-- Retain size shading and markings. Tint sprite layers and local
-- particle effects, never shared particle prototypes, shadows or sounds.
local function tint_visuals(value)
  if type(value) ~= "table" then
    return
  end
  if
    ((value.filename or value.filenames or value.stripes) and (value.width or value.size) and not value.draw_as_shadow)
    or value.type == "create-particle"
  then
    value.tint = violet_tint(value.tint)
  end
  for key, child in pairs(value) do
    if key ~= "tint" then
      tint_visuals(child)
    end
  end
end

local function clone(kind, name)
  local entity = copy(data.raw[kind][name])
  entity.name = "quinityn-" .. name
  entity.localised_name = { "entity-name.quinityn-enemy", { "entity-name." .. name } }
  entity.factoriopedia_simulation = nil
  entity.icons = { { icon = entity.icon, icon_size = entity.icon_size or 64, tint = violet_tint() } }
  tint_visuals(entity)
  data:extend({ entity })
  return entity
end

local function enemy(kind, name)
  local entity = clone(kind, name)
  entity.localised_description = { "entity-description.quinityn-enemy" }
  entity.resistances = entity.resistances or {}
  local laser
  for _, resistance in ipairs(entity.resistances) do
    if resistance.type == "laser" then
      laser = resistance
      break
    end
  end
  if not laser then
    laser = { type = "laser", percent = 0 }
    table.insert(entity.resistances, laser)
  end
  -- Five percent less damage than the source, including already resistant worms.
  laser.percent = 100 - (100 - (laser.percent or 0)) * 0.95
  for field, prototype in pairs({ corpse = "corpse", folded_state_corpse = "corpse", dying_explosion = "explosion" }) do
    if entity[field] then
      local remains = clone(prototype, entity[field])
      remains.localised_name = entity.localised_name
      entity[field] = remains.name
    end
  end
  if entity.autoplace then
    entity.autoplace.control = "quinityn_enemy_base"
    entity.autoplace.default_enabled = false
    -- Only Quinityn's map-gen override supplies a nonzero probability. Even a
    -- surface using default entity placement cannot generate these elsewhere.
    entity.autoplace.probability_expression = 0
  end
  return entity
end

for _, size in ipairs({ "small", "medium", "big", "behemoth" }) do
  for _, kind in ipairs({ "biter", "spitter" }) do
    local unit = enemy("unit", size .. "-" .. kind)
    for i, name in ipairs(unit.buildable_entities) do
      unit.buildable_entities[i] = "quinityn-" .. name
    end
  end
  enemy("turret", size .. "-worm-turret")
end
for _, kind in ipairs({ "biter", "spitter" }) do
  local spawner = enemy("unit-spawner", kind .. "-spawner")
  -- Capture rockets filter by prototype ID before firing at enemy nests.
  table.insert(data.raw.ammo["capture-robot-rocket"].ammo_type.target_filter, spawner.name)
  for _, result in ipairs(spawner.result_units) do
    result[1] = "quinityn-" .. result[1]
  end
end
