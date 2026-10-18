"""Validate gameplay contracts against the actual engine prototype dump."""
import colorsys,json,re,sys
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
assert len(tips)==78
# Localized rich-text links must point at actual prototypes.
text=(root/'locale/en/quinityn.cfg').read_text()
for kind,name in re.findall(r'\[(item|entity|fluid|recipe|technology|planet)=([^\]]+)\]',text):
 exists=name in D.get(kind,{})
 if kind=='item':exists=exists or name in D.get('tool',{})
 if kind=='entity':exists=any(name in group for group in D.values() if isinstance(group,dict))
 assert exists,f'Broken guide link: {kind}={name}'
for name in ['quinityn-basalt','quinityn-slag','quinityn-ruined-district','quinityn-unicomp-sea']:
 assert tiles[name]['absorptions_per_second']['pollution']==.000001
print(f'PASS: {len(owned)} named upstream recipe gates; technology DAG; 78 guide chapters; foundations; science sinks; pollution')
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
source=D['assembling-machine']['y-atomic-constructor']
def channels(tint):
 if tint is None: return [1, 1, 1, 1]
 if isinstance(tint, dict):
  return [tint.get('r', 0), tint.get('g', 0), tint.get('b', 0), tint.get('a', 1)]
 tint=list(tint)
 return tint if len(tint) == 4 else tint + [1]
def is_sprite(value):
 return isinstance(value,dict) and any(k in value for k in ['filename','filenames','stripes'])
def walk_sprites(value):
 if isinstance(value,dict):
  if is_sprite(value):
   yield value
   if value.get('draw_as_shadow') or value.get('draw_as_light') or value.get('draw_as_glow'): return
  for key,child in value.items():
   if key!='tint' and key!='stripes': yield from walk_sprites(child)
 elif isinstance(value,list):
  for child in value: yield from walk_sprites(child)
def without_tint(value):
 if isinstance(value,dict): return {k:without_tint(v) for k,v in value.items() if k!='tint'}
 if isinstance(value,list): return [without_tint(v) for v in value]
 return value
purple=[0.8,0.45,1]
def check_sprite(before, after):
 if before.get('draw_as_shadow') or before.get('draw_as_light') or before.get('draw_as_glow'):
  assert after==before
 else:
  assert without_tint(after)==without_tint(before)
  got=channels(after.get('tint'))
  for i,c in enumerate(purple): assert abs(got[i]-c)<1e-6
  assert abs(got[3]-1)<1e-6
  base=channels(before.get('tint'))
  assert not all(abs(base[i]-purple[i])<1e-6 for i in range(3))
def tinted(sprite, **nested):
 out=dict(sprite)
 out['tint']=[0.8,0.45,1]
 out.update(nested)
 return out
# A filename-only sprite is still a sprite. Ignoring it, or leaving it untinted, fails.
assert list(walk_sprites({'layers':[{'filename':'visible-only.png'}]}))==[{'filename':'visible-only.png'}]
try:
 check_sprite({'filename':'visible-only.png'}, {'filename':'visible-only.png'})
except AssertionError:
 pass
else:
 raise AssertionError('filename-only sprite left untinted was accepted')
stripe={'stripes':[{'filename':'frame.png','width_in_frames':4,'height_in_frames':1}],'hr_version':{'filename':'hr-only.png'}}
found=list(walk_sprites({'layers':[stripe, {'filename':'shadow.png','draw_as_shadow':True,'hr_version':{'filename':'shadow-hr.png'}}]}))
assert len(found)==3 and 'stripes' in found[0] and found[1]['filename']=='hr-only.png' and found[2]['filename']=='shadow.png'
assert all(s.get('filename') not in ('frame.png','shadow-hr.png') for s in found)
raw={'layers':[
 {'filename':'visible-only.png'},
 {'filenames':['a.png','b.png']},
 {'stripes':[{'filename':'frame.png','width_in_frames':4,'height_in_frames':1}]},
 {'filename':'shadow.png','draw_as_shadow':True,'hr_version':{'filename':'shadow-hr.png'}},
 {'filename':'light.png','draw_as_light':True},
 {'filename':'glow.png','draw_as_glow':True,'hr_version':{'filename':'glow-hr.png'}},
 {'filename':'visible.png','width':32,'hr_version':{'filename':'visible-hr.png'}},
]}
done={'layers':[
 tinted({'filename':'visible-only.png'}),
 tinted({'filenames':['a.png','b.png']}),
 tinted({'stripes':[{'filename':'frame.png','width_in_frames':4,'height_in_frames':1}]}),
 {'filename':'shadow.png','draw_as_shadow':True,'hr_version':{'filename':'shadow-hr.png'}},
 {'filename':'light.png','draw_as_light':True},
 {'filename':'glow.png','draw_as_glow':True,'hr_version':{'filename':'glow-hr.png'}},
 tinted({'filename':'visible.png','width':32}, hr_version=tinted({'filename':'visible-hr.png'})),
]}
left,right=list(walk_sprites(raw)),list(walk_sprites(done))
assert len(left)==len(right)==8
for before,after in zip(left,right): check_sprite(before, after)
prim=list(walk_sprites(separator['graphics_set']));orig=list(walk_sprites(source['graphics_set']))
assert len(prim)==len(orig) and len(prim)>=1
for before,after in zip(orig,prim): check_sprite(before, after)
assert separator['graphics_set']!=source['graphics_set']
assert separator['fluid_boxes']==source['fluid_boxes']
assert separator['circuit_connector']==D['assembling-machine']['chemical-plant']['circuit_connector']
item_tint=channels(I['quinityn-burner-separator']['icons'][0]['tint'])
for i,c in enumerate(purple): assert abs(item_tint[i]-c)<1e-6
assert R['quinityn-burner-separator']['icons']==I['quinityn-burner-separator']['icons']
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
tool=D['tool']
science=tool['quinityn-research-data']
assert R['quinityn-research-data']['subgroup']==science['subgroup']=='science-pack'
assert R['quinityn-research-data']['order']==science['order']=='z[quinityn]'
assert science['order']>I['promethium-science-pack']['order']
assert R['quinityn-foundation']['subgroup']==I['quinityn-foundation']['subgroup']=='terrain'
assert R['quinityn-foundation']['order']==I['quinityn-foundation']['order']=='c[landfill]-h[quinityn]'
assert R['quinityn-foundation']['order']>I['foundation']['order']=='c[landfill]-g[foundation]'
assert R['quinityn-low-density-structure']['subgroup']==I['low-density-structure']['subgroup']=='intermediate-product'
assert R['quinityn-low-density-structure']['order']==I['low-density-structure']['order']=='d[rocket-parts]-a[low-density-structure]'
assert R['quinityn-processing-unit']['subgroup']==I['processing-unit']['subgroup']=='intermediate-product'
assert R['quinityn-processing-unit']['order']==I['processing-unit']['order']=='b[circuits]-c[processing-unit]'
for name in ['quinityn-hand-sort','quinityn-iron','quinityn-copper','quinityn-carbon','quinityn-stone','quinityn-timber',
             'quinityn-burner-separator','quinityn-water','quinityn-technic-sign']:
 assert R[name]['subgroup']=='quinityn-fieldwork' and R[name]['order']==name
assert I['quinityn-salvage']['subgroup']==I['quinityn-burner-separator']['subgroup']=='quinityn-fieldwork'
assert R['quinityn-research-data']['categories']==['quinityn-science']
assert R['quinityn-foundation']['categories']==['yuoki-formpress']
assert R['quinityn-low-density-structure']['categories']==['crafting']
assert R['quinityn-processing-unit']['categories']==['crafting-with-fluid']
assert R['quinityn-technic-sign']['categories']==['quinityn-science']
for name in ['quinityn-research-data','quinityn-foundation','quinityn-low-density-structure','quinityn-processing-unit']:
 assert R[name]['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}] and R[name].get('enabled',True) is False
assert unlocks['quinityn-research-data']==['quinityn-industrial-science']
assert unlocks['quinityn-foundation']==['quinityn-foundation']
assert unlocks['quinityn-low-density-structure']==unlocks['quinityn-processing-unit']==['quinityn-orbital']
assert unlocks['quinityn-technic-sign']==['quinityn-industrial-science']
assert R['quinityn-research-data']['ingredients']==[{'type':'item','name':'y-unicomp-raw','amount':1},{'type':'item','name':'y-refined-yres2','amount':1},
 {'type':'item','name':'y_rwtechsign','amount':1},{'type':'item','name':'y-pol-waste','amount':5}]
assert R['quinityn-research-data']['results']==[{'type':'item','name':'quinityn-research-data','amount':5}]
assert R['quinityn-research-data']['energy_required']==5
assert R['quinityn-foundation']['ingredients']==[{'type':'item','name':'y_structure_element','amount':2},{'type':'item','name':'y_structure_vessel','amount':1},
 {'type':'item','name':'y-orange-stuff','amount':5},{'type':'item','name':'stone-brick','amount':10}]
assert R['quinityn-foundation']['results']==[{'type':'item','name':'quinityn-foundation','amount':4}]
assert R['quinityn-foundation']['energy_required']==8
assert R['quinityn-low-density-structure']['ingredients']==[{'type':'item','name':'y_structure_element','amount':2},{'type':'item','name':'y-unicomp-raw','amount':5},
 {'type':'item','name':'plastic-bar','amount':5}]
assert R['quinityn-low-density-structure']['results']==[{'type':'item','name':'low-density-structure','amount':1}]
assert R['quinityn-low-density-structure']['energy_required']==15
assert R['quinityn-processing-unit']['ingredients']==[{'type':'item','name':'y-chip-2','amount':2},{'type':'item','name':'y-conductive-wire-1','amount':4},
 {'type':'fluid','name':'sulfuric-acid','amount':5}]
assert R['quinityn-processing-unit']['results']==[{'type':'item','name':'processing-unit','amount':1}]
assert R['quinityn-processing-unit']['energy_required']==10
print('PASS: recipe family grouping for science, foundation and orbital products')

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
assert T['planet-discovery-quinityn']['effects']==[
 {'type':'unlock-space-location','space_location':'quinityn','use_icon_overlay_constant':True},
 {'type':'unlock-travel-to-space-platforms','modifier':True},
]
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
# graph. No vanilla unit or nest can introduce a Uni-touched enemy elsewhere.
def particle_effects(value):
 if isinstance(value,dict):
  if value.get('type')=='create-particle':yield value
  for child in value.values():yield from particle_effects(child)
 elif isinstance(value,list):
  for child in value:yield from particle_effects(child)

def royal_violet(tint):
 # The royal-violet base permits distinct blue-violet through grape variants.
 hue,saturation,brightness=colorsys.rgb_to_hsv(*tint[:3])
 assert 240<=hue*360<=295 and .3<=saturation<=.75 and brightness>0,tint

def sprite_layers(value):
 if isinstance(value,dict):
  if any(k in value for k in ['filename','filenames','stripes']) and ('width' in value or 'size' in value):yield value
  for child in value.values():yield from sprite_layers(child)
 elif isinstance(value,list):
  for child in value:yield from sprite_layers(child)

def check_enemy_visuals(native,variant):
 original=list(sprite_layers(native));modified=list(sprite_layers(variant))
 assert original and len(original)==len(modified)
 shade=None
 for before,after in zip(original,modified):
  if before.get('draw_as_shadow'):
   assert after==before
  else:
   assert {k:v for k,v in after.items() if k!='tint'}=={k:v for k,v in before.items() if k!='tint'}
   royal_violet(after['tint'])
   tint=before.get('tint',[1,1,1,1])
   if isinstance(tint,dict):tint=[tint.get(k,1 if k=='a' else 0) for k in ['r','g','b','a']]
   assert abs(max(after['tint'][:3])-max(tint[:3]))<1e-6
   assert after['tint'][3]==tint[3]
   if shade is None and 'tint' in before:
    shade=tuple(round(c,6) for c in colorsys.rgb_to_hsv(*after['tint'][:3])[:2])
 royal_violet(variant['icons'][0]['tint'])
 return shade

for kind,names in [('unit',[s+'-'+k for s in ['small','medium','big','behemoth'] for k in ['biter','spitter']]),
                   ('turret',[s+'-worm-turret' for s in ['small','medium','big','behemoth']]),
                   ('unit-spawner',['biter-spawner','spitter-spawner'])]:
 shades=set()
 for name in names:
  source=D[kind][name];enemy=D[kind]['quinityn-'+name]
  shade=check_enemy_visuals(source,enemy)
  assert shade is not None and shade not in shades,(name,'variant colors collapsed',shade)
  shades.add(shade)
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
   ordinary=[result for result in enemy['result_units'] if not result[0].endswith('-stomp-a-tron')]
   assert ordinary==[['quinityn-'+n,points] for n,points in source['result_units']]
   assert enemy['graphics_set']!=source['graphics_set']
  if kind=='turret':assert enemy['prepared_animation']!=source['prepared_animation']
  if 'autoplace' in enemy:
   assert enemy['autoplace']['probability_expression']==0
   assert enemy['autoplace']['default_enabled'] is False
   assert 'quinityn-'+name in mg['autoplace_settings']['entity']['settings']
   assert name not in mg['autoplace_settings']['entity']['settings']
  for field in ['corpse','folded_state_corpse','dying_explosion']:
   if field in source:assert enemy[field]=='quinityn-'+source[field]
  for field in ['corpse','folded_state_corpse']:
   if field in source:check_enemy_visuals(D['corpse'][source[field]],D['corpse'][enemy[field]])
  native_particles=list(particle_effects(D['explosion'][source['dying_explosion']]['created_effect']))
  tinted_particles=list(particle_effects(D['explosion'][enemy['dying_explosion']]['created_effect']))
  assert native_particles and len(tinted_particles)==len(native_particles),name
  for native,tinted in zip(native_particles,tinted_particles):
   assert {k:v for k,v in tinted.items() if k!='tint'}==native,(name,'death effect changed beyond tint')
   tint=tinted.get('tint')
   assert tint is not None,(name,'death particle lacks Uni-touched tint')
   royal_violet(tint)
   assert tint[3]==1,(name,tint)
for kind in ['unit','unit-spawner']:
 for name,entity in D[kind].items():
  if not name.startswith('quinityn-'):
   assert 'quinityn-' not in str(entity.get('buildable_entities',[])),name
   assert 'quinityn-' not in str(entity.get('result_units',[])),name
print('PASS: Uni-touched enemy identity, minor laser resistance, and isolated spawn/expansion graph')
print('PASS: all 14 Uni-touched death bursts have local particle tints and unchanged effect mechanics')
print('PASS: distinct violet variants preserve sprite geometry, shadows, brightness and opacity through live/remains/icon/particle visuals')

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

prim=D['assembling-machine']['quinityn-burner-separator']
assert prim['crafting_categories']==['quinityn-separation','quinityn-primitive-conversion']
full=D['assembling-machine']['y-atomic-constructor']
assert full['crafting_categories']==['yuoki-atomics'] and full['crafting_speed']==2 and full['energy_usage']=='1200kW'
assert 'quinityn-primitive-conversion' not in D['character']['character']['crafting_categories']
surplus_specs={
 'quinityn-stone-to-uc':([('stone',40)],[('y-unicomp-a2',1)]),
 'quinityn-wood-to-uc':([('wood',40)],[('y-unicomp-a2',1)]),
 'quinityn-uc-to-coal':([('y-unicomp-a2',1)],[('coal',10)]),
 'quinityn-uc-to-iron':([('y-unicomp-a2',1)],[('iron-ore',10)]),
 'quinityn-uc-to-copper':([('y-unicomp-a2',1)],[('copper-ore',10)]),
}
for name,(ing,res) in surplus_specs.items():
 r=R[name]
 assert r['categories']==['quinityn-primitive-conversion'] and r['energy_required']==8
 assert r.get('enabled',True) is False and r['subgroup']=='quinityn-fieldwork' and r['order']==name
 assert not r.get('allow_productivity',True) and r.get('auto_recycle') is False
 assert [(p['name'],p['amount']) for p in r['ingredients']]==ing
 assert [(p['name'],p['amount']) for p in r['results']]==res
 assert unlocks[name]==['quinityn-surplus']
surplus=T['quinityn-surplus']
assert surplus['prerequisites']==['quinityn-arrival'] and 'unit' not in surplus
assert surplus['research_trigger']=={'type':'craft-item','item':'quinityn-burner-separator','count':1}
assert 'quinityn-power' not in ancestry('quinityn-surplus')
assert 'quinityn-cimota' not in ancestry('quinityn-surplus')
for upstream in ['y-ac-stone2uc','y-ac-wood2uc','y-ac-uc2coal','y-ac-uc2iron-ore','y-ac-uc2copper-ore']:
 assert unlocks[upstream]==['quinityn-cimota']
prim_time=lambda r,s: r['energy_required']/s
prim_chain=prim_time(R['quinityn-wood-to-uc'],0.5)+prim_time(R['quinityn-uc-to-coal'],0.5)
full_chain=prim_time(R['y-ac-wood2uc'],2)+prim_time(R['y-ac-uc2coal'],2)
assert prim_chain>full_chain
def recipe_amount(recipe_name,field,item_name):
 recipe=R[recipe_name]
 parts=[p for p in (recipe.get(field) or []) if p.get('name')==item_name]
 assert len(parts)==1 and isinstance(parts[0].get('amount'),(int,float)) and parts[0]['amount']>0, recipe_name+' missing '+item_name+' in '+field
 return parts[0]['amount']
wood_in,coal_out=40,10
full_wood=recipe_amount('y-ac-wood2uc','ingredients','wood')
full_coal=recipe_amount('y-ac-uc2coal','results','coal')
assert wood_in/full_wood>coal_out/full_coal, 'Primitive wood-to-coal yield must stay below the loaded full Cimota recipes'
coal_fuel=I.get('coal',{}).get('fuel_value','4MJ')
if coal_fuel=='4MJ':
 assert int(I['wood']['fuel_value'][:-2])*wood_in>=int(coal_fuel[:-2])*coal_out, 'Primitive wood-to-coal must not multiply fuel energy'
assert unlocks['quinityn-water']==['quinityn-arrival']
assert len(tips)==78
refining_kept={
 'y-sulfuric-acid','y-water-gen','y-water-gen-fluid','y_catalyst_bp','y_catalyst_ft','y_coal2liquid','y_ft',
 'y_granulate_wood','y_rawsyngas1','y_rawsyngas2','y_refinehydrogen','y_regcatbp','y_regcatft'}
assert {e['recipe'] for e in T['quinityn-refining']['effects'] if e['type']=='unlock-recipe'}==refining_kept
assert set(T['quinityn-refining']['prerequisites'])=={'quinityn-engines','quinityn-advanced-components'}
thermal={
 'y_smelter','y_charger','y_block_heat','y_hps_purecopper','y_hps_pureiron','y_hps_steel'}
assert {e['recipe'] for e in T['quinityn-thermal-smelting']['effects'] if e['type']=='unlock-recipe'}==thermal
assert set(T['quinityn-thermal-smelting']['prerequisites'])=={'quinityn-refining'}
assert 'y_charger' not in {e['recipe'] for e in T['quinityn-quantum']['effects'] if e['type']=='unlock-recipe'}
adv_comp={e['recipe'] for e in T['quinityn-advanced-components']['effects'] if e['type']=='unlock-recipe'}
assert 'y_block_heat' not in adv_comp and 'y_block_cold' in adv_comp
assert 'quinityn-quantum' not in ancestry('quinityn-thermal-smelting')
bio={'ye_biofuel','ye_granulate_corn','ye_granulate_trifitan','ye_granulate_vuger'}
assert {e['recipe'] for e in T['quinityn-biological-feedstock']['effects'] if e['type']=='unlock-recipe'}==bio
assert set(T['quinityn-biological-feedstock']['prerequisites'])=={'quinityn-agriculture'}
assert {e['recipe'] for e in T['quinityn-slurry-syngas']['effects'] if e['type']=='unlock-recipe'}=={'ye_slurry2ethanol'}
assert set(T['quinityn-slurry-syngas']['prerequisites'])=={'quinityn-biological-feedstock','quinityn-husbandry'}
molten={'yi-molten-iron','yi-molten-copper'}
assert {e['recipe'] for e in T['quinityn-foundry-melting']['effects'] if e['type']=='unlock-recipe'}==molten
assert set(T['quinityn-foundry-melting']['prerequisites'])=={'quinityn-refining','foundry'}
assert 'foundry' in ancestry('quinityn-foundry-melting')
assert 'foundry' not in ancestry('quinityn-refining')
crush={'j_crushing_to_n4','j_crushing_to_f7'}
assert {e['recipe'] for e in T['quinityn-asteroid-crushing']['effects'] if e['type']=='unlock-recipe'}==crush
assert set(T['quinityn-asteroid-crushing']['prerequisites'])=={'quinityn-materials','quinityn-industrial-science','space-platform'}
assert 'space-platform' in ancestry('quinityn-asteroid-crushing')
assert 'quinityn-industrial-science' in ancestry('quinityn-asteroid-crushing')
for tech in ['quinityn-thermal-smelting','quinityn-biological-feedstock','quinityn-slurry-syngas',
 'quinityn-foundry-melting','quinityn-asteroid-crushing']:
 assert 'quinityn-arrival' in ancestry(tech),tech
assert R['y_hps_purecopper']['categories']==['yuoki_smelter_recipe']
assert R['y_hps_pureiron']['categories']==['yuoki_smelter_recipe']
assert R['y_hps_steel']['categories']==['yuoki_smelter_recipe']
assert R['y_block_heat']['categories']==['yuoki_charger_recipe']
assert R['yi-molten-iron']['categories']==['metallurgy']
assert R['yi-molten-copper']['categories']==['metallurgy']
assert R['j_crushing_to_n4']['categories']==['crushing']
assert R['j_crushing_to_f7']['categories']==['crushing']
print('PASS: primitive surplus conversions, gated full Cimota atomics unchanged, water bootstrap intact')
print('PASS: refining split by chemical, biological, thermal, foundry and asteroid processing')
science=R['quinityn-research-data']
assert science['allow_productivity'] is True
assert science['allow_quality'] is False
assert {p['name']:p['amount'] for p in science['ingredients']}=={'y-unicomp-raw':1,'y-refined-yres2':1,'y_rwtechsign':1,'y-pol-waste':5}
assert science['results']==[{'type':'item','name':'quinityn-research-data','amount':5}]
assert science['energy_required']==5
assert science['categories']==['quinityn-science']
assert science['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}]
for name in ['quinityn-hand-sort','quinityn-iron','quinityn-copper','quinityn-carbon','quinityn-stone','quinityn-timber',
 'quinityn-burner-separator','quinityn-water','quinityn-technic-sign','quinityn-low-density-structure',
 'quinityn-processing-unit','quinityn-foundation','quinityn-stone-to-uc','quinityn-wood-to-uc',
 'quinityn-uc-to-coal','quinityn-uc-to-iron','quinityn-uc-to-copper']:
 assert R[name].get('allow_productivity',False) is False,name
for name,slots in [('ye_fassembly1',3),('ye_fassembly2',3),('ye_fassembly_sp',2)]:
 machine=D['assembling-machine'][name]
 assert 'productivity' in machine['allowed_effects'],name
 assert 'quinityn-science' in machine['crafting_categories'],name
 assert machine['module_slots']==slots,name
print('PASS: industrial research data accepts productivity; other Quinityn recipes and factory slots unchanged')
