-- Native research and save reloads, with a test-only compatibility opt-out.
local progression=require("__yuoki-quinityn__/scripts/progression")
local hidden={"y-inserter-smart-long","y_inserter_diagonal"}
local retained={"y-inserter-smart","y_inserter_evade_shortL","y_inserter_evade_shortR",
  "y_inserter_smart_LL","y_inserter_smart_RR","y_inserter_smart_leftR2","y_inserter_smart_rightR2"}
local function check(force,researched)
  local disabled=settings.startup["quinityn-test-hide-inserters"].value
  for _,name in ipairs(hidden) do
    assert(prototypes.recipe[name].hidden==disabled,"Unexpected visibility: "..name)
    assert(force.recipes[name].enabled==(researched and not disabled),"Unexpected unlock: "..name)
    local owners=0
    for tech_name,tech in pairs(prototypes.technology) do
      for _,effect in pairs(tech.effects or {}) do
        if effect.type=="unlock-recipe" and effect.recipe==name then
          assert(not disabled,"Hidden inserter acquired a research unlock: "..name)
          assert(tech_name=="quinityn-advanced-logistics",name)
          owners=owners+1
        end
      end
    end
    assert(owners==(disabled and 0 or 1),"Unexpected research owners: "..name)
  end
  for _,name in ipairs(retained) do
    assert(not prototypes.recipe[name].hidden,"Visible variant hidden: "..name)
    assert(force.recipes[name].enabled==researched,"Visible variant unlock changed: "..name)
  end
  assert(force.recipes["y-inserter-fast"].enabled,"Basic inserter lost its unlock")
end
local function reconcile(force)
  -- Model stale enabled states from a save that previously unlocked the variants.
  for _,name in ipairs(hidden) do force.recipes[name].enabled=true end
  force.recipes["iron-gear-wheel"].enabled=false
  progression.reconcile()
  assert(not force.recipes["iron-gear-wheel"].enabled,"Unrelated recipe state changed")
  assert(force.technologies["quinityn-advanced-logistics"].researched,"Completed research lost")
  check(force,true)
end
script.on_init(function()
  local force=game.forces.player
  force.technologies["quinityn-logistics"].researched=true
  check(force,false)
  force.technologies["quinityn-advanced-logistics"].researched=true
  check(force,true)
  reconcile(force)
  log("QUINITYN INSERTER OPT-OUT TESTS PASSED")
end)
script.on_configuration_changed(function()
  local force=game.forces.player
  assert(force.technologies["quinityn-advanced-logistics"].researched,"Reload lost research")
  check(force,true)
  reconcile(force)
  log("QUINITYN INSERTER OPT-OUT RELOAD PASSED")
end)
