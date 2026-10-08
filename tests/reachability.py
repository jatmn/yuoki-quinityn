"""Conservative item/category/technology closure over Factorio's real prototype dump.

Models zero inventory after researched discovery and physical landing;
conservatively withholds all other pre-existing vanilla research; no trade imports,
recycling, other planets, or free electricity. This is a dependency proof, not a
throughput simulation. Runtime tests separately check operating machines and terrain.
"""
import json, sys
from pathlib import Path
D=json.loads(Path(sys.argv[1]).read_text())
R=D['recipe']; T=D['technology']
items={'y-res1','y-res2','quinityn-salvage','y-pol-waste'}
# Finite natural rock samples fund the first science; budget/runtime bound this stock.
mined={'y-res1','y-res2','quinityn-wreck','quinityn-big-rock','quinityn-huge-rock'}
fluids=set(); categories={'crafting','hand-crafting'}
techs={'planet-discovery-quinityn','quinityn-arrival'}
recipes={n for n,r in R.items() if r.get('enabled',True)}
crafted=set(); machines=set(); power=False
sources={n:'hand mining / salvage on Quinityn' for n in items}
produced=set()
entities={n:e for kind in ['assembling-machine','furnace','rocket-silo','offshore-pump','boiler','generator','solar-panel','lab'] for n,e in D.get(kind,{}).items()}
allitems={n:v for kind in ['item','tool','item-with-entity-data','ammo','capsule','module','armor','gun'] for n,v in D.get(kind,{}).items()}

def available(p):
 return p['name'] in (fluids if p.get('type')=='fluid' else items)

def researchable(n,t):
 if t.get('max_level')=='infinite' or any(x not in techs for x in t.get('prerequisites',[])):return False
 if t.get('unit'):
  return power and 'lab' in items and all(i[0] in items for i in t['unit']['ingredients'])
 tr=t.get('research_trigger',{});kind=tr.get('type')
 if kind=='craft-item':
  item=tr['item'];return (item if isinstance(item,str) else item['name']) in crafted
 if kind=='craft-fluid':return tr['fluid'] in fluids
 if kind=='mine-entity':return bool(set(tr['entities'])&mined)
 if kind=='scripted':return n.startswith('quinityn-bridge-')
 return False

for iteration in range(200):
 before=(len(items),len(fluids),len(techs),len(recipes),len(machines),power)
 for n in list(techs):
  recipes.update(e['recipe'] for e in T[n].get('effects',[]) if e['type']=='unlock-recipe')
 if 'quinityn-oil-processing' in techs:techs.add('oil-processing')
 for n in list(items):
  entity=allitems.get(n,{}).get('place_result',n)
  e=entities.get(entity)
  if not e:continue
  energy=e.get('energy_source',{}).get('type','void')
  if energy=='electric' and not power:continue
  if energy=='burner' and 'coal' not in items:continue
  if energy=='fluid' and e.get('energy_source',{}).get('fluid_box',{}).get('filter') not in fluids:continue
  machines.add(entity)
  categories.update(e.get('crafting_categories',[]))
 if 'offshore-pump' in machines:fluids.add('y-liquid-uc2')
 if 'quinityn-burner-separator' in machines and 'y-liquid-uc2' in fluids and 'quinityn-water' in recipes:fluids.add('water')
 if {'boiler','steam-engine','small-electric-pole'}<=items and 'water' in fluids and 'coal' in items:
  power=True;fluids.add('steam')
 for n in sorted(recipes):
  r=R[n]
  # Imports intentionally excluded: a local rocket must not depend on offworld purchases.
  if 'recycling' in r.get('categories',[]) or r.get('hidden') or r.get('subgroup','').startswith(('yie_trades','y-stargate')):continue
  if not set(r.get('categories',['crafting']))&categories:continue
  if not all(available(p) for p in r.get('ingredients',[])):continue
  conditions=r.get('surface_conditions',[])
  props={'pressure':1600,'gravity':10,'magnetic-field':60,'quinityn-industry':1}
  if any(not c.get('min',-float('inf'))<=props.get(c['property'],0)<=c.get('max',float('inf')) for c in conditions):continue
  produced.add(n)
  for p in r.get('results',[]):
   if p.get('independent_probability',1)<=0:continue
   if p.get('type','item')=='fluid':fluids.add(p['name'])
   else:
    if p['name'] not in items:
     sources[p['name']]=n
     if p['name']=='quinityn-research-data':
      assert 'quinityn-industrial-science' in techs and 'quinityn-power' not in techs, 'First science depends on science-gated Power'
      assert 'ye_fassembly1' in machines, 'First science lacks its local factory'
      print('PASS: first Quinityn science producible after rock discovery and factory construction, before Power')
    items.add(p['name']);crafted.add(p['name'])
 for n,t in T.items():
  if n not in techs and researchable(n,t):techs.add(n)
 after=(len(items),len(fluids),len(techs),len(recipes),len(machines),power)
 if before==after:break
required={'rocket-silo','rocket-fuel','low-density-structure','processing-unit','quinityn-research-data','quinityn-burner-separator','y-atomic-constructor','quinityn-foundation'}
missing=required-items
print('Closure:',len(items),'items;',len(techs),'technologies;',len(machines),'machines;',iteration+1,'iterations')
for n in sorted(required):print(n,':',sources.get(n,'UNREACHABLE'))
if missing:
 print('Missing:',sorted(missing))
 print('Quinityn technologies:',sorted(n for n in techs if n.startswith('quinityn-') and not n.startswith('quinityn-bridge-')))
 for n in sorted(recipes):
  r=R[n]
  if n.startswith('quinityn') or any(p['name'] in missing for p in r.get('results',[])):
   print('BLOCKED?',n,'ingredients',[p['name'] for p in r.get('ingredients',[]) if not available(p)],'categories',r.get('categories',['crafting']))
 sys.exit(1)
finite={n for n,t in T.items() if n.startswith('quinityn-') and not n.startswith('quinityn-bridge-')
        and t.get('max_level')!='infinite'}
# These specific upgrades require orbital science, directly or through speed 2
# for P3. Keep the empty-inventory rocket proof and every other finite unlock local.
space_gated={'quinityn-'+n for n in ['advanced-modules','advanced-efficiency-module',
 'advanced-productivity-module','quantum-modules','combined-module','ultimate-efficiency-module',
 'science-module','quality-module','p3-factory','research-center']}
assert finite-techs==space_gated, 'Unexpected nonlocal research: '+str(sorted((finite-techs)^space_gated))
for name in space_gated-{'quinityn-p3-factory'}:
 assert {i[0] for i in T[name]['unit']['ingredients'] if i[0] not in items}=={'space-science-pack'},name
assert 'ye_fassembly2' in machines
assert sources['ye_science_blue'] in {'yi_radar','y-quantrinum','y_quantrinum_infusion'}
print('PASS: Y2 and reputation byproducts are local; eight advanced modules, P3 and research center await orbital science')
assert 'rocket-building' in categories, 'Rocket silo category inaccessible'
assert all(p['name'] in items for p in R['rocket-part']['ingredients'])
assert 'rocket-part' in recipes
for n in ['quinityn-mining-productivity','quinityn-plasma-damage']:
 t=T[n]
 assert t['max_level']=='infinite'
 assert 'quinityn-research-data' in items, 'Local endgame science inaccessible: '+n
 assert ['quinityn-research-data',2] in t['unit']['ingredients']
print('PASS: local empty-inventory post-discovery rocket and infinite-research science dependency closure')

assert {'y-rmvpol','j-airfilter_dirty','j-airfilter_cleaning','y-waste-condense','y_mixedfuel2rocketfuel'}<=produced
assert {'y-electric-air-heater','y-emotor-s','y-dirtwasher'}<=machines
print('PASS: renewable unfiltered/filtered flyash and alternate rocket fuel are locally producible')
