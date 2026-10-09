local copy = table.deepcopy

-- The approved family runs from pale N4 blue through lavender to royal violet.
local variants = {
  {
    size = "small",
    scale = 0.9,
    body = "#FFFFFF",
    flesh = "#9996CA",
    armor = "#8BA3BD",
    laser = 3,
    salvage = { 1, 2 },
    data = { "y-crystal2", 1, 5 },
  },
  {
    size = "medium",
    scale = 1.2,
    body = "#B4A6D2",
    flesh = "#8170B0",
    armor = "#777FAD",
    laser = 7,
    salvage = { 3, 4 },
    data = { "y-crystal2", 4, 7 },
  },
  {
    size = "big",
    scale = 1.6,
    body = "#9780BD",
    flesh = "#7040A8",
    armor = "#605588",
    laser = 11,
    salvage = { 6, 9 },
    data = { "y_crystal2_combined", 1, 1 },
  },
}
local util = require("util")

local function half_vector(vector)
  if vector.x then
    return { x = vector.x * 0.5, y = vector.y * 0.5 }
  end
  return { vector[1] * 0.5, vector[2] * 0.5 }
end

local function half_box(box)
  return { half_vector(box[1]), half_vector(box[2]) }
end

-- Scale spatial graphics metadata, including shadows/reflections and the
-- distances between leg sprites. Direction/frame counts and colors stay intact.
local function half_graphics(value)
  if type(value) ~= "table" then
    return
  end
  if value.filename or value.filenames or value.stripes then
    value.scale = (value.scale or 1) * 0.5
    if value.shift then
      value.shift = half_vector(value.shift)
    end
    return
  end
  for key, child in pairs(value) do
    if
      type(child) == "number"
      and (
        key == "middle_offset_from_top"
        or key == "middle_offset_from_bottom"
        or key == "top_end_length"
        or key == "bottom_end_length"
      )
    then
      value[key] = child * 0.5
    else
      half_graphics(child)
    end
  end
end

local function sprites(value, edit)
  if type(value) ~= "table" then
    return
  end
  if value.filename or value.filenames or value.stripes then
    if not value.draw_as_shadow then
      edit(value)
    end
    return
  end
  for _, child in pairs(value) do
    sprites(child, edit)
  end
end

local function tint(value, color)
  sprites(value, function(sprite)
    sprite.tint = util.color(color)
    sprite.tint_as_overlay = true
    sprite.apply_runtime_tint = false
    sprite.surface = nil
  end)
end

local function torso(variant)
  local graphics = {}
  local source = data.raw["spider-vehicle"].spidertron.graphics_set
  -- Only torso fields shared with spider-units; no vehicle autopilot visuals.
  for _, field in ipairs({ "base_animation", "animation", "shadow_base_animation", "shadow_animation" }) do
    graphics[field] = copy(source[field])
    local function scale(value)
      if type(value) ~= "table" then
        return
      end
      if value.filename then
        local factor = variant.scale * 1.5 * 0.5
        value.scale = (value.scale or 1) * factor
        if value.shift then
          value.shift = { value.shift[1] * factor, value.shift[2] * factor }
        end
        if not value.draw_as_shadow then
          value.apply_runtime_tint = false
          value.tint = util.color(variant.body)
        end
      else
        for _, child in pairs(value) do
          scale(child)
        end
      end
    end
    scale(graphics[field])
  end
  graphics.render_layer = "under-elevated"
  graphics.base_render_layer = "higher-object-above"
  -- Spider-units do not support the vehicle-only eye_light/light_positions.
  -- This original transparent overlay follows the stock 64 eye orientations.
  local factor = variant.scale * 1.5 * 0.5
  table.insert(graphics.animation.layers, {
    filename = "__yuoki-quinityn__/graphics/stomp-a-tron-sensors.png",
    width = 132,
    height = 138,
    line_length = 8,
    direction_count = 64,
    scale = 0.5 * factor,
    shift = util.by_pixel(0, -19 * factor),
    draw_as_glow = true,
  })
  return graphics
end

for _, variant in ipairs(variants) do
  local source_name = variant.size .. "-stomper-pentapod"
  local name = "quinityn-" .. variant.size .. "-stomp-a-tron"
  local unit = copy(data.raw["spider-unit"][source_name])
  unit.name = name
  unit.localised_name = { "entity-name." .. name }
  unit.localised_description = { "entity-description.quinityn-stomp-a-tron" }
  unit.factoriopedia_simulation = nil
  unit.icons = {
    { icon = unit.icon, icon_size = 64, tint = util.color(variant.flesh) },
    {
      icon = data.raw["spider-vehicle"].spidertron.icon,
      icon_size = 64,
      scale = 0.25,
      shift = { 8, 8 },
      tint = util.color(variant.body),
    },
  }
  unit.graphics_set = torso(variant)
  for _, field in ipairs({ "collision_box", "selection_box", "sticker_box" }) do
    unit[field] = half_box(unit[field])
  end
  unit.height = unit.height * 0.5
  unit.drawing_box_vertical_extension = unit.drawing_box_vertical_extension * 0.5
  unit.attack_parameters.range = unit.attack_parameters.range * 0.5
  unit.attack_parameters.min_attack_distance = unit.attack_parameters.min_attack_distance * 0.5
  for _, emission in ipairs(unit.attack_parameters.projectile_creation_parameters) do
    emission[2] = half_vector(emission[2])
  end
  unit.steering.move.radius = unit.steering.move.radius * 0.5
  unit.steering.stay.radius = unit.steering.stay.radius * 0.5
  local strafe = unit.ai_settings.strafe_settings
  strafe.max_distance = strafe.max_distance * 0.5
  strafe.ideal_distance = strafe.ideal_distance * 0.5
  unit.surface_conditions = { { property = "quinityn-industry", min = 1, max = 1 } }
  unit.autoplace = nil
  unit.minable = nil
  -- Neither death offspring/shells nor Gleba nest construction belong here.
  unit.dying_trigger_effect = nil
  unit.buildable_entities = {}
  unit.absorptions_to_join_attack = { pollution = 25 }
  unit.loot = {
    {
      type = "item",
      name = "quinityn-salvage",
      amount_min = variant.salvage[1],
      amount_max = variant.salvage[2],
      independent_probability = 1,
    },
    {
      type = "item",
      name = variant.data[1],
      amount_min = variant.data[2],
      amount_max = variant.data[3],
      independent_probability = 1,
    },
  }
  for _, resistance in ipairs(unit.resistances) do
    if resistance.type == "laser" then
      resistance.percent = variant.laser
      resistance.decrease = 0
    end
  end
  local leg = copy(data.raw["spider-leg"][source_name .. "-leg"])
  leg.name = name .. "-leg"
  leg.localised_name = unit.localised_name
  leg.resistances = copy(unit.resistances)
  leg.collision_box = half_box(leg.collision_box)
  leg.selection_box = half_box(leg.selection_box)
  for _, field in ipairs({
    "target_position_randomisation_distance",
    "minimal_step_size",
    "base_position_selection_distance",
    "movement_based_position_selection_distance",
    "knee_height",
    "ankle_height",
    "initial_movement_speed",
    "movement_acceleration",
  }) do
    leg[field] = leg[field] * 0.5
  end
  half_graphics(leg.graphics_set)
  tint(leg.graphics_set.upper_part, variant.flesh)
  tint(leg.graphics_set.lower_part, variant.armor)
  tint(leg.graphics_set.joint, variant.armor)
  tint(leg.graphics_set.foot, variant.armor)
  for _, mount in ipairs(unit.spider_engine.legs) do
    mount.leg = leg.name
    mount.mount_position = half_vector(mount.mount_position)
    mount.ground_position = half_vector(mount.ground_position)
    for _, effect in ipairs(mount.leg_hit_the_ground_when_attacking_trigger) do
      if effect.type == "nested-result" and effect.action.type == "area" then
        effect.action.radius = effect.action.radius * 0.5
      end
    end
  end
  local corpse = copy(data.raw.corpse[unit.corpse])
  corpse.name = name .. "-corpse"
  corpse.localised_name = unit.localised_name
  half_graphics(corpse.animation)
  half_graphics(corpse.decay_animation)
  half_graphics(corpse.water_reflection)
  corpse.collision_box = half_box(corpse.collision_box)
  corpse.selection_box = half_box(corpse.selection_box)
  tint(corpse.animation, variant.armor)
  tint(corpse.decay_animation, variant.armor)
  unit.corpse = corpse.name
  data:extend({ unit, leg, corpse })

  for _, kind in ipairs({ "biter", "spitter" }) do
    local nest = data.raw["unit-spawner"]["quinityn-" .. kind .. "-spawner"]
    for _, result in ipairs(copy(nest.result_units)) do
      if result[1] == "quinityn-" .. variant.size .. "-" .. kind then
        local points = copy(result[2])
        for _, point in ipairs(points) do
          point[2] = point[2] * 0.1
        end
        table.insert(nest.result_units, { name, points })
      end
    end
  end
end
