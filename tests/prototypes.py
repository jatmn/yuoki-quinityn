"""Validate gameplay contracts against the actual engine prototype dump."""
import json,re,sys
from pathlib import Path
D=json.loads(Path(sys.argv[1]).read_text());root=Path(__file__).resolve().parents[1]
R=D['recipe'];T=D['technology'];I=D['item'];tiles=D['tile']
assert tiles['quinityn-unicomp-sea']['fluid']=='y-liquid-uc2'
assert tiles['quinityn-unicomp-sea']['destroys_dropped_items']
assert tiles['quinityn-unicomp-sea']['default_cover_tile']=='quinityn-foundation'
normal=set(I['foundation']['place_as_tile']['tile_condition']);alt=set(I['quinityn-foundation']['place_as_tile']['tile_condition'])
assert normal<=alt and alt-normal=={'quinityn-unicomp-sea'}
for name,item in I.items():
 if name!='quinityn-foundation':assert 'quinityn-unicomp-sea' not in item.get('place_as_tile',{}).get('tile_condition',[]),name
assert tiles['quinityn-foundation']['minable']['result']=='quinityn-foundation'
assert tiles['quinityn-foundation']['frozen_variant']=='quinityn-frozen-foundation'
assert tiles['quinityn-frozen-foundation']['thawed_variant']=='quinityn-foundation'
assert R['quinityn-foundation']['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}]
for n in ['iron','copper','stone','carbon','timber','hand-sort']:
 assert R['quinityn-'+n]['categories']==['hand-crafting']
assert R['quinityn-research-data']['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}]
# Every directly named upstream recipe must be gated, including hidden recycling.
owned={n for n in R if re.match(r'^(y[-_]|yi[-_]|ye[-_]|yie[-_]|ypfw[-_])',n)}
unlocks={}
for n,t in T.items():
 for e in t.get('effects',[]):
  if e['type']=='unlock-recipe':unlocks.setdefault(e['recipe'],[]).append(n)
for n in owned:
 assert R[n].get('enabled',True) is False, 'Enabled before visit: '+n
 if n=='y-heavyoil2uc' and R[n].get('hidden'):
  assert not unlocks.get(n), 'Disabled upstream option acquired an unlock'
 else:assert unlocks.get(n) and all(t.startswith('quinityn-') for t in unlocks[n]),'Ungated unlock: '+n
# Every generated Yuoki technology depends transitively on arrival; discovery stays separate.
def ancestry(n,seen=None):
 seen=set() if seen is None else seen
 assert n not in seen,'technology cycle: '+n
 result={n}
 for p in T[n].get('prerequisites',[]):result|=ancestry(p,seen|{n})
 return result
for n in T:
 if n.startswith('quinityn-'):assert 'quinityn-arrival' in ancestry(n),n
for n in ['quinityn-mining-productivity','quinityn-plasma-damage']:
 assert T[n]['max_level']=='infinite'
 assert ['quinityn-research-data',2] in T[n]['unit']['ingredients']
 assert T[n]['unit']['count_formula']=='1000*1.5^(L-1)'
tips=[n for n in D['tips-and-tricks-item'] if n.startswith('quinityn-')]
assert len(tips)==73
# Localized rich-text links must point at actual prototypes.
text=(root/'locale/en/quinityn.cfg').read_text()
for kind,name in re.findall(r'\[(item|entity|fluid|recipe|technology|planet)=([^\]]+)\]',text):
 exists=name in D.get(kind,{})
 if kind=='item':exists=exists or name in D.get('tool',{})
 if kind=='entity':exists=any(name in group for group in D.values() if isinstance(group,dict))
 assert exists,f'Broken guide link: {kind}={name}'
for name in ['quinityn-basalt','quinityn-slag','quinityn-ruined-district','quinityn-unicomp-sea']:
 assert tiles[name]['absorptions_per_second']['pollution']==.000001
print(f'PASS: {len(owned)} named upstream recipe gates; technology DAG; 73 guide chapters; foundations; science sinks; pollution')
# A compact reviewable manifest is generated from the engine, not a parallel source of truth.
manifest={n:[e['recipe'] for e in t.get('effects',[]) if e['type']=='unlock-recipe'] for n,t in T.items() if n.startswith('quinityn-')}
(root/'docs/recipe-unlocks.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')

# Exclusive factory manufacture and early factory access prevent a science deadlock.
factories={'ye_fassembly1','ye_fassembly2','ye_fassembly_sp'}
for name, machine in D['assembling-machine'].items():
 assert ('quinityn-science' in machine.get('crafting_categories',[])) == (name in factories), name
assert 'quinityn-science' not in D['character']['character']['crafting_categories']
assert R['quinityn-research-data']['categories']==['quinityn-science']
assert R['quinityn-technic-sign']['categories']==['quinityn-science']
assert R['quinityn-technic-sign']['results']==[{'type':'item','name':'y_rwtechsign','amount':1}]
assert R['quinityn-technic-sign']['energy_required']>=30
assert unlocks['ye_fassembly1']==['quinityn-basic-factory']
assert 'unit' not in T['quinityn-materials']
assert unlocks['quinityn-research-data']==['quinityn-industrial-science']
separator=D['assembling-machine']['quinityn-burner-separator']
assert separator['graphics_set']==D['assembling-machine']['y-atomic-constructor']['graphics_set']
assert separator['crafting_speed']==0.5 and separator['energy_usage']=='180kW'
assert separator['energy_source']['emissions_per_minute']['pollution']==6
assert separator['module_slots']==0 and not separator['quality_affects_module_slots']
assert I['y-res2']['fuel_value']=='1MJ' and I['wood']['fuel_value']=='2MJ'
assert 'chemical' in I['y-res2']['fuel_categories']
assert len(D['planet']['quinityn']['map_gen_settings']['autoplace_settings']['decorative']['settings'])>=5
assert 'quinityn-unicomp-sea' not in I['landfill']['place_as_tile']['tile_condition']
# PNG alpha, dimensions and prototype paths are checked independently of headless graphics loading.
import struct
for name,group in [('quinityn-salvage',I),('quinityn-research-data',D['tool'])]:
 p=group[name];path=root/p['icon'].removeprefix('__yuoki-quinityn__/')
 image=path.read_bytes();assert image[:8]==b'\x89PNG\r\n\x1a\n'
 width,height,depth,color=struct.unpack('>IIBB',image[16:26])
 assert width==height==p['icon_size']==256 and depth==8 and color==6
print('PASS: factory-only science/signs, early factory, primitive Cimota/F7 fuel, decorative coverage and RGBA icons')

# UI planet badges are derived from control membership, not nonzero settings.
for name,planet in D['planet'].items():
 mg=planet.get('map_gen_settings',{})
 for ore in ['y-res1','y-res2']:
  assert (ore in mg.get('autoplace_controls',{})) == (name=='quinityn'), (name,ore)
mg=D['planet']['quinityn']['map_gen_settings']
assert 'enemy-base' not in mg['autoplace_controls']
for control,category in [('quinityn_water','terrain'),('quinityn_cliff','cliff'),('quinityn_enemy_base','enemy'),('quinityn_trees','terrain')]:
 assert control in mg['autoplace_controls'] and D['autoplace-control'][control]['category']==category
sort=R['quinityn-hand-sort']
assert sort['icons']==[{'icon':I['quinityn-salvage']['icon'],'icon_size':I['quinityn-salvage']['icon_size']}]
assert not sort.get('hidden',False) and not sort.get('hide_from_player_crafting',False)
assert sort['ingredients']==[{'type':'item','name':'quinityn-salvage','amount':1}]
assert {p['name']:p['amount'] for p in sort['results']}=={'y-res1':2,'y-res2':2,'stone':2,'wood':1}
assert unlocks['quinityn-hand-sort']==['quinityn-arrival']
assert 'hand-crafting' in D['character']['character']['crafting_categories']
print('PASS: planet-specific map control membership and visible salvage sorting identity/unlock')

# Research is anchored beyond space travel; native milestones bootstrap local science.
assert T['quinityn-arrival']['prerequisites']==['planet-discovery-quinityn']
assert 'space-science-pack' in [i[0] for i in T['planet-discovery-quinityn']['unit']['ingredients']]
for name,t in T.items():
 if not name.startswith('quinityn-'):continue
 assert 'planet-discovery-quinityn' in ancestry(name),name
 if t.get('unit'):
  assert 'quinityn-research-data' in [i[0] for i in t['unit']['ingredients']],name
 assert 'sign_tech_icon' not in str(t.get('icons',t.get('icon',''))),name
for first,upgrade in [('y-crush-unicomp-raw','y-crush-blue_whead'),('y-crush-fuel-raw','y-crush-green_whead'),
 ('y-digfdirt','y-digfdirt2'),('y-pure-iron','y_pure_iron_wtool'),('y-pure-copper','y_pure_copper_wtool'),
 ('y-water-gen','y-water-gen-e'),('y-crusher','y_crusher2'),('y-heat-form-press','y_formpress2'),('y-mining-drill','y-mining-drill-e2'),
 ('y-accumulator-m','y-accumulator-m-t2'),('y-accumulator-b','y-accumulator-b-t2'),
 ('y-accumulator-b-t2','y-accumulator-b-tx'),('ye_fassembly1','ye_fassembly2'),
 ('y_turret_gun1f12','y_turret_gun2f12'),('yi_armor_gray','yi_armor_red'),('yi_armor_red','yi_armor_gold'),
 ('yi_armor_gold','yi_walker_a'),('yi_walker_a','yi_walker_c'),
 ('y-pink-module-1','y-pink-module-2'),('y-pink-module-2','y-pink-module-3'),
 ('y-speed-module-1','y-speed-module-2'),('y-green-module-1','y-green-module-2'),
 ('ye_dna_animal2','ye_dna_animal3'),('ye_dna_animal3','ye_dna_animal4'),
 ('yi_construction-robot','j_construction2-robot'),('yi_logistic-robot','j_logistic2-robot')]:
 a,b=unlocks[first][0],unlocks[upgrade][0]
 assert a!=b and a in ancestry(b),(first,upgrade,a,b)
print('PASS: discovery ancestry, mandatory post-milestone science, representative icons and ordered production tiers')

# Factory upgrades and free reputation generation must be distinct research steps.
y2,p3,center=(unlocks[n][0] for n in ['ye_fassembly2','ye_fassembly_sp','yie_science_blue_gen'])
assert len({y2,p3,center})==3
assert {e['recipe'] for e in T[y2]['effects'] if e['type']=='unlock-recipe'}=={'ye_fassembly2'}
assert y2 in ancestry(p3) and p3 in ancestry(center)
assert 'quinityn-advanced-modules' in ancestry(p3) and 'quinityn-mastery' in ancestry(center)
assert T[p3]['unit']['count']>=1000 and T[center]['unit']['count']>=5000
assert T[center]['unit']['time']==40
assert {i[0] for i in T[center]['unit']['ingredients']}=={
 'automation-science-pack','logistic-science-pack','military-science-pack','chemical-science-pack',
 'production-science-pack','utility-science-pack','space-science-pack','quinityn-research-data'}
assert unlocks['ye_science_blue']==[center]
# Existing reputation byproducts remain available before the free generator.
for name in ['yi_radar','y-quantrinum']:
 assert all(center not in ancestry(t) for t in unlocks[name])
 assert any(p['name']=='ye_science_blue' for p in R[name]['results'])

robotics=unlocks['yi_logistic-robot'][0]
assert {e['recipe'] for e in T[robotics]['effects'] if e['type']=='unlock-recipe'}=={
 'yi_roboport','yi_logistic-robot','yi_construction-robot'}
network=unlocks['j_yi_roboport1'][0]
assert network!=robotics and robotics in ancestry(network)
advanced=unlocks['j_logistic2-robot'][0]
milestones=[n for n in ancestry(advanced) if T[n].get('research_trigger')==
 {'type':'craft-item','item':'yi_logistic-robot','count':500}]
assert len(milestones)==1 and robotics in ancestry(milestones[0])
assert not T[milestones[0]].get('unit') and not T[milestones[0]].get('effects')
assert T[advanced]['unit']['count']>240 and 'research_trigger' not in T[advanced]
for n in [robotics,network,advanced]:
 assert {'logistic-science-pack','chemical-science-pack'}<={i[0] for i in T[n]['unit']['ingredients']}
 assert 'chemical-science-pack' in ancestry(n)
print('PASS: separate Y2/P3/research center, endgame science/costs and robot manufacturing plus lab gates')

# Every active Yuoki module has its own research, including ultimate products
# outside the ordinary module crafting subgroup. Recipe inputs establish lineage.
modules={n for n in D['module'] if n.startswith('y')}
assert len(modules)==11
module_owners={}
for name in modules:
 owners=unlocks[name]
 assert len(owners)==1,(name,owners)
 owner=owners[0];module_owners[name]=owner
 assert [e['recipe'] for e in T[owner]['effects'] if e['type']=='unlock-recipe']==[name], \
  'Module still shares a research unlock: '+name
for name,owner in module_owners.items():
 for ingredient in R[name]['ingredients']:
  if ingredient['name'] in modules:
   assert module_owners[ingredient['name']] in ancestry(owner),(name,ingredient['name'])
assert module_owners['y-green-module-2'] in ancestry(module_owners['y_modul_green_op'])
assert module_owners['y-pink-module-3'] in ancestry(module_owners['y_modul_science'])
assert 'quinityn-mastery' in ancestry(module_owners['y_modul_green_op'])
assert 'quinityn-mastery' in ancestry(module_owners['y_modul_science'])
assert 'quality-module-2' in ancestry(module_owners['y-quality-module-1'])
allowed_packs={'automation-science-pack','logistic-science-pack','military-science-pack',
 'chemical-science-pack','production-science-pack','utility-science-pack','space-science-pack','quinityn-research-data'}
for owner in module_owners.values():
 for parent in ancestry(owner)|{owner}:
  assert {i[0] for i in T[parent].get('unit',{}).get('ingredients',[])}<=allowed_packs,(owner,parent)
# Compare ordinary tiers to the installed vanilla units, with local science added.
for family,vanilla in [('speed','speed'),('green','efficiency'),('pink','productivity')]:
 for tier in [1,2]:
  name=f'y-{family}-module-{tier}'
  unit=T[module_owners[name]]['unit']
  base=T[f'{vanilla}-module'+('' if tier==1 else '-2')]['unit']
  assert unit['count']==base['count'] and unit['time']==base['time']
  assert dict(unit['ingredients'])==dict(base['ingredients'])|{'quinityn-research-data':1}
 first=module_owners[f'y-{family}-module-1']
 assert not (set(module_owners.values())-{first})&ancestry(first),family
late_packs={'automation-science-pack','logistic-science-pack','chemical-science-pack',
 'production-science-pack','space-science-pack','quinityn-research-data'}
for name,count in [('y-pink-module-3',300),('y_modul_red2',1000),('y_modul_green_op',5000),
 ('y_modul_science',5000),('y-quality-module-1',5000)]:
 unit=T[module_owners[name]]['unit']
 expected=late_packs if name=='y-pink-module-3' else late_packs|{'utility-science-pack'}
 assert dict(unit['ingredients'])==dict.fromkeys(expected,1),name
 assert unit['count']==count and unit['time']==60,name
print('PASS: eleven individual modules, ingredient ancestry, vanilla tier 1/2 costs and Nauvis/space-only advanced science')

assert mg['cliff_settings']['name']=='quinityn-cliff'
assert D['cliff']['quinityn-cliff']['orientations']==D['cliff']['cliff-fulgora']['orientations']
assert 'quinityn-cliff-blocker' not in D['cliff']['cliff-fulgora']['collision_mask']['layers']
for name in mg['autoplace_settings']['tile']['settings']:
 assert bool(tiles[name]['collision_mask']['layers'].get('quinityn-cliff-blocker')) == (name!='quinityn-ruined-district')
assert D['autoplace-control']['quinityn_trees']['can_be_disabled']
for name in ['quinityn-dry-tree','quinityn-dead-dry-hairy-tree']:
 tree=D['tree'][name]
 assert name in mg['autoplace_settings']['entity']['settings']
 assert tree['minable']['result']=='wood'
 for sprite in tree['pictures']:
  assert sprite['tint'][0]>sprite['tint'][1] and sprite['tint'][2]>sprite['tint'][1]
print('PASS: Fulgora cliffs and controllable purple dead-tree sprites')

# Each bootstrap stage is a native crafting milestone, with its trigger producible
# from earlier unlocks. Cheap red-only research must not recreate the starter tier.
for name in ['materials','pressing','compacting','alloying','structures','electronics','fuel-processing','basic-factory']:
 t=T['quinityn-'+name]
 assert 'unit' not in t and t['research_trigger']['type']=='craft-item'
 assert len([e for e in t['effects'] if e['type']=='unlock-recipe'])<=4,(name,t['effects'])
 assert 'quinityn-research-data' not in [e.get('recipe') for e in t['effects']] or name=='industrial-science'
for early,later in [('y-crusher','y-heat-form-press'),('y-smelt-crush-res1','y-unicomp-raw'),
 ('y-unicomp-raw','y_structure_element'),('y-orange-stuff','y-chip-1'),
 ('y_structure_element','ye_fassembly1'),('y-chip-1','ye_fassembly1')]:
 assert unlocks[early][0] in ancestry(unlocks[later][0]),(early,later)
for name,t in T.items():
 if name.startswith('quinityn-') and t.get('unit'):
  assert 'quinityn-industrial-science' in ancestry(name),name
print('PASS: eight crafting milestones, separate rock discovery and factory unlocks and science-rooted lab research')

# Habitat is a surface-local generation override, never an enemy collision rule.
for name in ['biter-spawner','spitter-spawner','small-worm-turret','medium-worm-turret','big-worm-turret','behemoth-worm-turret']:
 key='entity:quinityn-'+name+':probability'
 assert key in mg['property_expression_names']
 entity=D.get('unit-spawner',{}).get(name,D.get('turret',{}).get(name))
 assert 'quinityn' not in str(entity.get('collision_mask'))
 assert 'quinityn' not in str(entity['autoplace'])
 for planet in D['planet'].values():
  if planet['name']!='quinityn':
   assert 'quinityn' not in str(planet.get('map_gen_settings',{}).get('property_expression_names',{}).get(key,''))
print('PASS: machinery-only cliff masks and surface-local enemy generation habitat')

# Every size retains its combat/collision identity and stays in a closed colony
# graph. No vanilla unit or nest can introduce a contaminated enemy elsewhere.
def particle_effects(value):
 if isinstance(value,dict):
  if value.get('type')=='create-particle':yield value
  for child in value.values():yield from particle_effects(child)
 elif isinstance(value,list):
  for child in value:yield from particle_effects(child)

for kind,names in [('unit',[s+'-'+k for s in ['small','medium','big','behemoth'] for k in ['biter','spitter']]),
                   ('turret',[s+'-worm-turret' for s in ['small','medium','big','behemoth']]),
                   ('unit-spawner',['biter-spawner','spitter-spawner'])]:
 for name in names:
  source=D[kind][name];enemy=D[kind]['quinityn-'+name]
  for key in ['max_health','collision_box','movement_speed','spawning_cooldown']:
   assert enemy.get(key)==source.get(key),(name,key)
  original={r['type']:r for r in source.get('resistances',[])}
  modified={r['type']:r for r in enemy['resistances']}
  laser=modified.pop('laser');native=original.pop('laser',{})
  assert modified==original,name
  assert abs((100-laser['percent'])-(100-native.get('percent',0))*.95)<1e-8,name
  assert laser.get('decrease',0)==native.get('decrease',0),name
  if kind=='unit':
   assert enemy['buildable_entities']==['quinityn-'+n for n in source['buildable_entities']]
   assert enemy['run_animation']!=source['run_animation']
  if kind=='unit-spawner':
   assert enemy['result_units']==[['quinityn-'+n,points] for n,points in source['result_units']]
   assert enemy['graphics_set']!=source['graphics_set']
  if kind=='turret':assert enemy['prepared_animation']!=source['prepared_animation']
  if 'autoplace' in enemy:
   assert enemy['autoplace']['probability_expression']==0
   assert enemy['autoplace']['default_enabled'] is False
   assert 'quinityn-'+name in mg['autoplace_settings']['entity']['settings']
   assert name not in mg['autoplace_settings']['entity']['settings']
  for field in ['corpse','folded_state_corpse','dying_explosion']:
   if field in source:assert enemy[field]=='quinityn-'+source[field]
  native_particles=list(particle_effects(D['explosion'][source['dying_explosion']]['created_effect']))
  tinted_particles=list(particle_effects(D['explosion'][enemy['dying_explosion']]['created_effect']))
  assert native_particles and len(tinted_particles)==len(native_particles),name
  for native,tinted in zip(native_particles,tinted_particles):
   assert {k:v for k,v in tinted.items() if k!='tint'}==native,(name,'death effect changed beyond tint')
   tint=tinted.get('tint')
   assert tint is not None,(name,'death particle lacks contamination tint')
   # The loaded effect must carry a subtle purple wash without changing opacity.
   assert 0.8<tint[1]<tint[0]<=tint[2]<=1 and tint[3]==1,(name,tint)
for kind in ['unit','unit-spawner']:
 for name,entity in D[kind].items():
  if not name.startswith('quinityn-'):
   assert 'quinityn-' not in str(entity.get('buildable_entities',[])),name
   assert 'quinityn-' not in str(entity.get('result_units',[])),name
print('PASS: contaminated enemy identity, minor laser resistance, and isolated spawn/expansion graph')
print('PASS: all 14 contaminated death bursts have local particle tints and unchanged effect mechanics')

# The new natural remnants stay cosmetic and planet-local, with water shorelines
# rather than lava/void edges. Native source prototypes remain available unchanged.
for name,source in [('quinityn-weathered-soil','dirt-6'),('quinityn-dead-turf','grass-4'),
                    ('quinityn-ash-soil','volcanic-ash-soil')]:
 tile=tiles[name]
 assert tile['absorptions_per_second']['pollution']==.000001
 assert tile['variants']==tiles[source]['variants']
 assert tile['tint']!=tiles[source].get('tint')
 shore=[t for t in tile['transitions'] if 'quinityn-unicomp-sea' in t.get('to_tiles',[])]
 assert len(shore)==1 and 'water' in shore[0]['to_tiles']
 assert all('quinityn-unicomp-sea' not in t.get('to_tiles',[]) for t in tiles[source]['transitions'])
for name in ['quinityn-dead-shrub','quinityn-dry-tuft','quinityn-dead-grass','quinityn-dead-groundcover',
             'quinityn-tiny-rock','quinityn-small-rock']:
 assert name in D['optimized-decorative'] and name in mg['autoplace_settings']['decorative']['settings']
 assert name not in mg['autoplace_settings']['entity']['settings']
 assert 'minable' not in D['optimized-decorative'][name]
for name,planet in D['planet'].items():
 if name!='quinityn':
  assert 'quinityn-weathered-soil' not in planet.get('map_gen_settings',{}).get('autoplace_settings',{}).get('tile',{}).get('settings',{})
print('PASS: decayed soil/turf, native water transitions and non-mineable plant/stone decoratives')

# Discovery and added loot belong exclusively to the Quinityn rock clones.
rocks={'quinityn-big-rock','quinityn-huge-rock'}
science=T['quinityn-industrial-science']
assert science['research_trigger']=={'type':'mine-entity','entities':['quinityn-big-rock','quinityn-huge-rock']}
assert science['prerequisites']==['quinityn-arrival']
assert next(p['amount'] for p in R['quinityn-research-data']['ingredients'] if p['name']=='y-pol-waste')==5
for source,ash in [('big-rock',2),('huge-rock',4)]:
 native=D['simple-entity'][source];rock=D['simple-entity']['quinityn-'+source]
 assert all(p['name']!='y-pol-waste' for p in native['minable'].get('results',[]))
 expected=native['minable'].get('results',[{'type':'item','name':native['minable'].get('result'),'amount':native['minable'].get('count',1)}])
 assert rock['minable']['results']==expected+[{'type':'item','name':'y-pol-waste','amount':ash}]
 assert len(rock['pictures'])==len(native['pictures'])>=16
 assert [p['filename'] for p in rock['pictures']]==[p['filename'] for p in native['pictures']]
 for sprite in rock['pictures']:
  assert sprite['tint'][0]>sprite['tint'][1] and sprite['tint'][2]>sprite['tint'][1]
for name,planet in D['planet'].items():
 mg=planet.get('map_gen_settings',{})
 for rock in rocks:
  assert (rock in mg.get('autoplace_settings',{}).get('entity',{}).get('settings',{})) == (name=='quinityn')
  if name!='quinityn' and mg:assert mg['property_expression_names']['entity:'+rock+':probability']=='0'
for name in ['big-rock','huge-rock','big-sand-rock']:
 assert D['planet']['quinityn']['map_gen_settings']['property_expression_names']['entity:'+name+':probability']=='0'
assert unlocks['y-electric-air-heater']==unlocks['y-rmvpol']==['quinityn-air-scrubbing']
assert not R['y-rmvpol'].get('hidden',False)
for name in ['j-airfilter','j-airfilter_dirty','j-airfilter_cleaning']:
 assert unlocks[name]==['quinityn-air-filters'] and not R[name].get('enabled',True)
assert {'quinityn-air-scrubbing','quinityn-washing','quinityn-engines'}<=ancestry('quinityn-air-filters')
assert next(p['amount'] for p in R['j-airfilter_dirty']['ingredients'] if p['name']=='j-airfilter')==1
assert {p['name']:p['amount'] for p in R['j-airfilter_cleaning']['results']}=={'j-airfilter':1,'y-pol-waste':6}
assert R['j-airfilter_dirty']['emissions_multiplier']==2*R['y-rmvpol'].get('emissions_multiplier',1)
assert 6/R['j-airfilter_dirty']['energy_required']>1/R['y-rmvpol']['energy_required']
assert unlocks['y-waste-condense']==unlocks['y_mixedfuel2rocketfuel']==['quinityn-engines']
print('PASS: Quinityn-only rock discovery/loot, dedicated Fatmice, later reusable filters and flyash rocket fuel')
