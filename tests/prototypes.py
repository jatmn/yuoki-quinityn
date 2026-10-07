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
assert len(tips)==59
# Localized rich-text links must point at actual prototypes.
text=(root/'locale/en/quinityn.cfg').read_text()
for kind,name in re.findall(r'\[(item|entity|fluid|recipe|technology|planet)=([^\]]+)\]',text):
 exists=name in D.get(kind,{})
 if kind=='item':exists=exists or name in D.get('tool',{})
 if kind=='entity':exists=any(name in group for group in D.values() if isinstance(group,dict))
 assert exists,f'Broken guide link: {kind}={name}'
for name in ['quinityn-basalt','quinityn-slag','quinityn-ruined-district','quinityn-unicomp-sea']:
 assert tiles[name]['absorptions_per_second']['pollution']==.000001
print(f'PASS: {len(owned)} named upstream recipe gates; technology DAG; 59 guide chapters; foundations; science sinks; pollution')
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
for name in ['materials','pressing','compacting','alloying','structures','electronics','fuel-processing','basic-factory','industrial-science']:
 t=T['quinityn-'+name]
 assert 'unit' not in t and t['research_trigger']['type']=='craft-item'
 assert len([e for e in t['effects'] if e['type']=='unlock-recipe'])<=4,(name,t['effects'])
 assert 'quinityn-research-data' not in [e.get('recipe') for e in t['effects']] or name=='industrial-science'
for early,later in [('y-crusher','y-heat-form-press'),('y-smelt-crush-res1','y-unicomp-raw'),
 ('y-unicomp-raw','y_structure_element'),('y-orange-stuff','y-chip-1'),
 ('y_structure_element','ye_fassembly1'),('y-chip-1','ye_fassembly1'),('ye_fassembly1','quinityn-research-data')]:
 assert unlocks[early][0] in ancestry(unlocks[later][0]),(early,later)
for name,t in T.items():
 if name.startswith('quinityn-') and t.get('unit'):
  assert 'quinityn-industrial-science' in ancestry(name),name
print('PASS: nine focused pre-science milestones, distinct factory/science unlocks and science-rooted lab research')

# Habitat is a surface-local generation override, never an enemy collision rule.
for name in ['biter-spawner','spitter-spawner','small-worm-turret','medium-worm-turret','big-worm-turret','behemoth-worm-turret']:
 key='entity:'+name+':probability'
 assert key in mg['property_expression_names']
 entity=D.get('unit-spawner',{}).get(name,D.get('turret',{}).get(name))
 assert 'quinityn' not in str(entity.get('collision_mask'))
 assert 'quinityn' not in str(entity['autoplace'])
 for planet in D['planet'].values():
  if planet['name']!='quinityn':
   assert 'quinityn' not in str(planet.get('map_gen_settings',{}).get('property_expression_names',{}).get(key,''))
print('PASS: machinery-only cliff masks and surface-local enemy generation habitat')
