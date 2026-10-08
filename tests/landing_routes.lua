-- Real terrain and enemy collision paths. No tiles/entities are cleared or built.
local copy=require("util").table.deepcopy
local function check(ok,message)
  assert(ok,"LANDING ROUTE TEST FAILED: "..message)
  log("QUINITYN ROUTE PASS: "..message)
end
script.on_init(function()
  storage.cases={}
  for _,seed in ipairs({1,42,8675309,4042551623,17,12345,314159,4294967295}) do
    storage.cases[#storage.cases+1]={seed=seed,water=1,frequency=1}
  end
  for _,seed in ipairs({1,42,8675309,4042551623}) do
    for _,water in ipairs({1/6,6}) do
      storage.cases[#storage.cases+1]={seed=seed,water=water,frequency=1}
    end
    storage.cases[#storage.cases+1]={seed=seed,water=2,frequency=6}
  end
  storage.case=0
  storage.requests={}
end)
local function request(surface,start,kind)
  local biter=prototypes.entity["behemoth-biter"]
  local id=surface.request_path{bounding_box=biter.collision_box,
    collision_mask=biter.collision_mask,start=start,goal={0,0},
    force=game.forces.enemy,radius=1,pathfind_flags={allow_destroy_friendly_entities=false}}
  storage.requests[id]={start=start,kind=kind}
end
local function next_case()
  if storage.surface then game.delete_surface(storage.surface) end
  storage.requests={}
  storage.case=storage.case+1
  local case=storage.cases[storage.case]
  if not case then
    storage.finished=true
    log("QUINITYN LANDING ROUTE TESTS PASSED")
    return
  end
  local settings=copy(game.planets.quinityn.prototype.map_gen_settings)
  settings.seed=case.seed
  settings.autoplace_controls.quinityn_water={frequency=case.frequency,size=case.water}
  local surface=game.create_surface("landing-route-"..storage.case,settings)
  storage.surface=surface.index
  surface.request_to_generate_chunks({0,0},32)
  surface.force_generate_chunk_requests()
  for _,cliff in pairs(surface.find_entities_filtered{type="cliff"}) do
    assert(surface.get_tile(cliff.position).name=="quinityn-ruined-district","Cliff origin outside machinery district on seed "..case.seed.." at "..helpers.table_to_json(cliff.position).." tile "..surface.get_tile(cliff.position).name)
  end
  -- Sample tile connectivity independently, then ask the native pathfinder to
  -- validate the selected exits with full entity collision (including cliffs).
  local frontier={{x=0,y=0}}
  local seen={["0:0"]=true}
  local exits={}
  local i=1
  while frontier[i] do
    local p=frontier[i];i=i+1
    if p.x==-640 then exits.west=exits.west or p end
    if p.x==640 then exits.east=exits.east or p end
    for _,d in ipairs({{-8,0},{8,0},{0,-8},{0,8}}) do
      local x,y=p.x+d[1],p.y+d[2]
      local key=x..":"..y
      if math.abs(x)<=672 and math.abs(y)<=672 and not seen[key] then
        seen[key]=true
        if surface.get_tile(x,y).name~="quinityn-unicomp-sea" then frontier[#frontier+1]={x=x,y=y} end
      end
    end
  end
  local label="seed="..case.seed.." water="..case.water.." frequency="..case.frequency
  check(exits.west and exits.east,label.." has dry connections to both distant edges")
  storage.success={};storage.pending=0;storage.started=game.tick
  for side,p in pairs(exits) do
    local start=surface.find_non_colliding_position("behemoth-biter",p,16,0.5)
    check(start~=nil,label.." has an open "..side.." exit")
    request(surface,start,side);storage.pending=storage.pending+1
  end
  -- Actual naturally generated nests, not test-placed enemies on an artificial road.
  local nests=surface.find_entities_filtered{type="unit-spawner"}
  if #nests==0 then
    -- Extreme sea coverage can place the nearest natural nest beyond 1,024 tiles.
    surface.request_to_generate_chunks({0,0},48)
    surface.force_generate_chunk_requests()
    nests=surface.find_entities_filtered{type="unit-spawner"}
  end
  for _,nest in pairs(nests) do
    assert(surface.get_tile(nest.position).name=="quinityn-slag","Natural nest outside slag on seed "..case.seed)
  end
  table.sort(nests,function(a,b) return a.position.x^2+a.position.y^2 < b.position.x^2+b.position.y^2 end)
  for j=1,math.min(#nests,24) do
    local start=surface.find_non_colliding_position("behemoth-biter",nests[j].position,12,0.5)
    if start then request(surface,start,"nest");storage.pending=storage.pending+1 end
  end
  check(#nests>0,label.." has natural nests")
  storage.label=label
end
script.on_event(defines.events.on_tick,function()
  if storage.finished then return end
  if storage.case==0 then next_case();return end
  if storage.pending==0 or (storage.success.west and storage.success.east and storage.success.nest) then
    check(storage.success.west and storage.success.east,storage.label.." has native walking paths from both exits")
    check(storage.success.nest,storage.label.." has a native nest-to-landing walking path")
    next_case()
  else
    assert(game.tick-storage.started<1000,"Native path requests timed out")
  end
end)
script.on_event(defines.events.on_script_path_request_finished,function(event)
  local r=storage.requests[event.id]
  if not r then return end
  storage.requests[event.id]=nil
  if event.try_again_later then
    request(game.surfaces[storage.surface],r.start,r.kind)
  else
    storage.pending=storage.pending-1
    if event.path then
      local finish=event.path[#event.path].position
      check(finish.x^2+finish.y^2<=4,"successful native path reaches landing")
      storage.success[r.kind]=true
    end
  end
end)
