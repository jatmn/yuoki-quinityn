-- The headless engine cannot construct LuaPlayer objects. Only player membership
-- and player facades are substituted; force, character, technology and recipes
-- are native, and the actual research-finished handler performs every unlock.
local progression=require("__yuoki-quinityn__/scripts/progression")
local function check(ok,message)
  assert(ok,"DISCOVERY TEST FAILED: "..message)
  log("QUINITYN DISCOVERY PASS: "..message)
end
local function research(force,name,players)
  force.technologies[name].researched=true
  progression.research{research={name=name,force=setmetatable({players=players},
    {__index=function(_,key) return force[key] end})}}
end
return function(surface)
  local pending=game.create_force("discovery-pending")
  local character=surface.create_entity{name="character",position={8,4},force=game.forces.player}
  -- A character changes force while staying on an already-created planet.
  character.force=pending
  local player={valid=true,character=character,force=pending,physical_surface=surface}
  progression.arrive(player)
  check(not pending.technologies["quinityn-arrival"].researched,"force transfer before discovery stays gated")

  -- Make it eligible so discovery's guard cannot mask a wrong-force retry.
  pending.technologies["planet-discovery-quinityn"].researched=true
  local remote=game.create_force("discovery-remote")
  local remote_character=game.surfaces.nauvis.create_entity{name="character",position={0,0},force=remote}
  research(remote,"planet-discovery-quinityn",{
    {valid=true,character=remote_character,force=remote,physical_surface=game.surfaces.nauvis,surface=surface},
    {valid=true,force=remote,physical_surface=surface,physical_controller_type=defines.controllers.god}})
  check(not remote.technologies["quinityn-arrival"].researched and not remote.recipes["quinityn-hand-sort"].enabled,
    "discovery with remote view or characterless presence does not unlock survey")
  check(not pending.technologies["quinityn-arrival"].researched,"another force's discovery does not unlock the waiting force")

  research(pending,"planet-discovery-quinityn",{player})
  check(pending.technologies["quinityn-arrival"].researched and pending.recipes["quinityn-hand-sort"].enabled,
    "discovery completion unlocks a character already physically present")
  check(not pending.recipes["y-crusher"].enabled,"discovery retry does not bypass later crafting milestones")

  -- Completion must be idempotent: another delivery must not reapply unlocks.
  pending.recipes["quinityn-hand-sort"].enabled=false
  research(pending,"planet-discovery-quinityn",{player})
  check(not pending.recipes["quinityn-hand-sort"].enabled,"completed survey is not replayed by duplicate discovery events")

  check(remote_character.teleport({8,8},surface),"remote character physically travels to Quinityn")
  progression.arrive{valid=true,character=remote_character,force=remote,physical_surface=surface}
  check(remote.technologies["quinityn-arrival"].researched,"discovery before physical arrival remains supported")
  character.destroy();remote_character.destroy()
end
