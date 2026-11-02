-- The real Milestones mod logs the preset addons it loads; tools/test.py checks that.
-- Milestones tracks only forces with players, which the headless engine cannot create,
-- so this compares the addon with the loaded science item, Yuoki robots and Quinityn enemies.
local function check(ok, message)
  assert(ok, "MILESTONES TEST FAILED: " .. message)
end

local function key(group, kind, name, quantity, next_formula)
  return table.concat({ tostring(group), kind, name, tostring(quantity), tostring(next_formula) }, " ")
end

script.on_init(function()
  check(remote.interfaces["yuoki-quinityn"].offworld_crusher_tracked, "test functions registered")
  local addon = remote.call("yuoki-quinityn", "milestones_preset_addons")["Yuoki Industries: Quinityn"]
  check(addon and addon.required_mods[1] == "yuoki-quinityn", "preset addon requires Quinityn")

  local science = prototypes.item["quinityn-research-data"]
  check(science and science.type == "tool", "Quinityn research data is a science item")
  local expected = {
    [key("Science", "item", science.name, 1)] = true,
    [key("Science at scale", "item", science.name, 1000, "x10")] = true,
  }
  local robots, enemies = 0, 0
  for name, item in pairs(prototypes.item) do
    local placed = item.place_result
    -- The addon tracks every Yuoki robot; vanilla robots belong to the base presets.
    if
      placed
      and (placed.type == "construction-robot" or placed.type == "logistic-robot")
      and name ~= "construction-robot"
      and name ~= "logistic-robot"
    then
      expected[key("Progress", "item", name, 1)] = true
      robots = robots + 1
    end
  end
  for name, entity in pairs(prototypes.entity) do
    if
      (entity.type == "unit" and name:match("^quinityn%-%a+%-biter$"))
      or (entity.type == "spider-unit" and name:match("^quinityn%-%a+%-stomp%-a%-tron$"))
    then
      expected[key("Kills", "kill", name, 1)] = true
      enemies = enemies + 1
    end
  end
  check(robots > 0 and enemies > 0, "loaded Yuoki robots and Quinityn enemies")

  local group
  for _, milestone in ipairs(addon.milestones) do
    if milestone.type == "group" then
      group = milestone.name
    else
      local entry = key(group, milestone.type, milestone.name, milestone.quantity, milestone.next)
      check(expected[entry], "unexpected or duplicate milestone: " .. entry)
      expected[entry] = nil
    end
  end
  for entry in pairs(expected) do
    check(false, "missing milestone: " .. entry)
  end
  log("QUINITYN MILESTONES TESTS PASSED")
end)
