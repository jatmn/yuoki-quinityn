-- The real Milestones mod logs the preset addons it loads; tools/test.py checks that.
-- Milestones tracks only forces with players, which the headless engine cannot create,
-- so this checks every entry resolves to the intended item or Quinityn enemy instead.
local function check(ok, message)
  assert(ok, "MILESTONES TEST FAILED: " .. message)
end

script.on_init(function()
  check(remote.interfaces["yuoki-quinityn"].offworld_crusher_tracked, "test functions registered")
  local addon = remote.call("yuoki-quinityn", "milestones_preset_addons")["Yuoki Industries: Quinityn"]
  check(addon and addon.required_mods[1] == "yuoki-quinityn", "preset addon requires Quinityn")
  for _, milestone in ipairs(addon.milestones) do
    if milestone.type == "item" then
      check(prototypes.item[milestone.name], "item " .. milestone.name)
    elseif milestone.type == "kill" then
      local entity = prototypes.entity[milestone.name]
      check(entity and (entity.type == "unit" or entity.type == "spider-unit"), "enemy " .. milestone.name)
      check(milestone.name:match("^quinityn%-"), "native enemy " .. milestone.name)
    else
      check(milestone.type == "group", "milestone type " .. milestone.type)
    end
  end
  log("QUINITYN MILESTONES TESTS PASSED")
end)
