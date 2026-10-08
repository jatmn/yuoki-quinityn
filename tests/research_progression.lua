-- Native production/research with injected inputs and power, not a playthrough.
local progression=require("__yuoki-quinityn__/scripts/progression")
local function check(ok,message)
  assert(ok,"RESEARCH PROGRESSION TEST FAILED: "..message)
  log("QUINITYN RESEARCH PASS: "..message)
end
local withheld={
  ["quinityn-advanced-factories"]=true,["quinityn-p3-factory"]=true,
  ["quinityn-research-center"]=true,["quinityn-robotics"]=true,
  ["quinityn-robot-network-expansion"]=true,["quinityn-robot-production"]=true,
  ["quinityn-advanced-robotics"]=true
}
local function supply(machine,recipe)
  if not machine.get_inventory(defines.inventory.crafter_input).is_empty() then return false end
  for _,p in pairs(prototypes.recipe[recipe].ingredients) do
    assert(machine.insert{name=p.name,count=p.amount}==p.amount,"Fixture cannot supply "..p.name)
  end
  return true
end
script.on_init(function()
  local force=game.forces.player
  for name,t in pairs(force.technologies) do
    if not withheld[name] and not name:match("^quinityn%-bridge%-") then t.researched=true end
  end
  progression.reconcile()
  local surface=game.create_surface("research-fixture",{width=64,height=64})
  surface.request_to_generate_chunks({0,0},1);surface.force_generate_chunk_requests()
  local tiles={}
  for x=-20,20 do for y=-20,20 do tiles[#tiles+1]={name="landfill",position={x,y}} end end
  surface.set_tiles(tiles)
  storage.surface=surface.index
  game.create_force("research-other")
  force.technologies["quinityn-advanced-factories"].researched=true
  check(force.recipes.ye_fassembly2.enabled,"Y2 research unlocks Y2")
  check(not force.recipes.ye_fassembly_sp.enabled and not force.recipes.yie_science_blue_gen.enabled,
    "Y2 research leaves P3 and research center locked")
  storage.machine=surface.create_entity{name="y-atomic-quantum-composer",position={0,0},force=force}
  check(storage.machine.set_recipe("yi_radar"),"existing radar recipe supplies reputation")
  storage.phase="reputation";storage.funded=0;storage.signs=0
end)
script.on_event(defines.events.on_tick,function()
  if storage.finished then return end
  local force=game.forces.player
  local surface=game.surfaces[storage.surface]
  local machine=storage.machine
  if machine then machine.energy=100000000 end
  if storage.phase=="reputation" then
    if storage.funded<4 and supply(machine,"yi_radar") then storage.funded=storage.funded+1 end
    storage.signs=storage.signs+machine.get_output_inventory().remove{name="ye_science_blue",count=4}
    machine.get_output_inventory().clear()
    if storage.signs==4 then
      check(not force.technologies["quinityn-research-center"].researched,"four native byproduct signs before the center")
      machine.destroy()
      storage.machine=surface.create_entity{name="assembling-machine-3",position={0,0},force=force}
      storage.machine.set_recipe("ye_fassembly2")
      for _,p in pairs(prototypes.recipe.ye_fassembly2.ingredients) do
        storage.machine.insert{name=p.name,count=p.amount}
      end
      storage.signs=storage.signs-1;storage.phase="y2"
    end
  elseif storage.phase=="y2" or storage.phase=="p3" then
    if machine.products_finished==0 then return end
    check(not force.recipes.yie_science_blue_gen.enabled,"factory constructed before research center unlock")
    if storage.phase=="y2" then
      check(machine.get_output_inventory().get_item_count("ye_fassembly2")==1,"native Y2 manufacture")
      force.technologies["quinityn-p3-factory"].researched=true
      machine.get_output_inventory().clear();machine.set_recipe("ye_fassembly_sp")
      -- products_finished is cumulative, so use output inventory for the second recipe.
      for _,p in pairs(prototypes.recipe.ye_fassembly_sp.ingredients) do machine.insert{name=p.name,count=p.amount} end
      storage.signs=storage.signs-3;storage.phase="p3"
    elseif machine.get_output_inventory().get_item_count("ye_fassembly_sp")==1 then
      check(storage.signs==0,"native P3 manufacture uses the remaining byproduct signs")
      machine.destroy()
      force.technologies["quinityn-robotics"].researched=true
      progression.reconcile()
      check(force.recipes["yi_logistic-robot"].enabled and force.recipes["yi_construction-robot"].enabled
        and force.recipes.yi_roboport.enabled,"robotics unlocks basic bots and roboport")
      check(not force.recipes.j_yi_roboport1.enabled,"robotics leaves 8080 locked")
      force.technologies["quinityn-robot-network-expansion"].researched=true
      check(force.recipes.j_yi_roboport1.enabled,"separate research unlocks 8080")
      check(not force.add_research("quinityn-advanced-robotics"),"advanced robots cannot be researched before production")
      storage.machine=surface.create_entity{name="assembling-machine-3",position={0,0},force=force}
      storage.machine.set_recipe("yi_logistic-robot")
      -- Merely owning 500 robots must not satisfy a crafting trigger.
      local chest=surface.create_entity{name="steel-chest",position={5,0},force=force}
      chest.insert{name="yi_logistic-robot",count=500}
      storage.funded=0;storage.phase="robots"
    end
  elseif storage.phase=="robots" then
    machine.get_output_inventory().clear()
    if storage.funded<499 and supply(machine,"yi_logistic-robot") then storage.funded=storage.funded+1 end
    if machine.products_finished==499 then
      storage.paused=storage.paused or game.tick
      check(not force.technologies["quinityn-robot-production"].researched,"499 crafted robots leave milestone locked")
      if game.tick-storage.paused>=60 then
        check(not force.add_research("quinityn-advanced-robotics"),"499 robots cannot open advanced research")
        check(supply(machine,"yi_logistic-robot"),"supply final robot")
        storage.phase="last-robot"
      end
    end
  elseif storage.phase=="last-robot" then
    if not force.technologies["quinityn-robot-production"].researched then return end
    check(machine.products_finished==500,"500th native craft completes milestone")
    check(not game.forces["research-other"].technologies["quinityn-robot-production"].researched,"production is force-local")
    check(not force.recipes["j_logistic2-robot"].enabled and not force.recipes["j_construction2-robot"].enabled,
      "milestone alone does not unlock advanced bots")
    machine.destroy();storage.machine=nil
    check(force.add_research("quinityn-advanced-robotics"),"milestone enables separate lab research")
    storage.lab=surface.create_entity{name="lab",position={0,0},force=force}
    force.laboratory_speed_modifier=1000
    storage.started=game.tick;storage.phase="labs"
  elseif storage.phase=="labs" then
    storage.lab.energy=100000000
    for _,p in pairs(prototypes.technology["quinityn-advanced-robotics"].research_unit_ingredients) do
      if p.name~="chemical-science-pack" or game.tick-storage.started>=120 then
        storage.lab.insert{name=p.name,count=20}
      end
    end
    if game.tick-storage.started==119 then check(force.research_progress==0,"lab cannot research without chemical science") end
    if force.technologies["quinityn-advanced-robotics"].researched then
      check(force.recipes["j_logistic2-robot"].enabled and force.recipes["j_construction2-robot"].enabled,
        "science-funded research unlocks both advanced robots")
      -- Existing saves may have completed advanced robots before this milestone existed.
      force.technologies["quinityn-robot-production"].researched=false
      progression.reconcile()
      check(force.technologies["quinityn-advanced-robotics"].researched and force.recipes["j_logistic2-robot"].enabled,
        "reconciliation preserves previously completed advanced robot research")
      storage.lab.destroy();storage.finished=true
      log("QUINITYN RESEARCH PROGRESSION TESTS PASSED")
    end
  end
end)
