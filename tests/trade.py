"""Trade capability ownership, measured from loaded production prototypes."""
import json,sys
from pathlib import Path
D=json.loads(Path(sys.argv[1]).read_text());R=D['recipe'];T=D['technology']
owners={}
for name,t in T.items():
 for e in t.get('effects',[]):
  if e['type']=='unlock-recipe':owners.setdefault(e['recipe'],[]).append(name)
def ancestry(name,seen=frozenset()):
 assert name not in seen,name
 return {name}.union(*(ancestry(p,seen|{name}) for p in T[name].get('prerequisites',[])))
expected={
 'reputation':['y-fame-gen','y-fame','y_fame_tech'],
 'mastery':['ypfw_trader_sign'],
 'chemical-science':['y_chemical_science'],
 'military-science':['y_military_science'],
 'production-science':['y_production_science'],
 'utility-science':['y_high-tech_science','ye_createbluesigns'],
 'space-science':['y_space_science'],
 'genetic-trade':['ye_export01','ye_export02','ye_export05'],
 'advanced-genetic-trade':['ye_export03','ye_export06'],
 'industrial-biology-trade':['ye_export04'],
 'trade':['y-stargate','ye_trade_node','ye_buechse_gelb_export','yie_import_sealing','yie_import_blech_blau'],
 'trade-biology':['ye_buechse_blau_export','ye_buechse_fleisch_export','ye_buechse_rosa_export',
                  'ye_buechse_weiss_export','ye_export_fish1','ye_export_fish2','ye_tradeblood',
                  'ye_trademeat1','ye_trademeat2','ye_dna_fish2','ye_futtermittel_a','ye_futtermittel_b'],
}
for stage,names in expected.items():
 for n in names:
  assert owners[n]==['quinityn-'+stage],(n,owners[n])
  if n+'-recycling' in R:
   bridge='quinityn-bridge-'+stage+'-recycling'
   assert set(owners[n+'-recycling'])=={bridge},n
   assert set(T[bridge]['prerequisites'])=={'quinityn-'+stage,'recycling'}
assert {'quinityn-reputation','quinityn-quantum-power','quinityn-packaging'}<=ancestry('quinityn-trade')
assert 'quinityn-mastery' not in ancestry('quinityn-trade')
assert 'quinityn-trade' not in ancestry('quinityn-reputation')
for recipe,machine in [('y-fame','y-fame-gen'),('y_fame_tech','y-fame-gen'),('ypfw_trader_sign','y_trade_ultimate')]:
 assert set(R[recipe]['categories'])&set(D['assembling-machine'][machine]['crafting_categories'])
 assert owners[machine][0] in ancestry(owners[recipe][0]),recipe
# A product tier must precede each biological export, while its production
# remains independent of Trade. Test actual ingredient producer ownership.
for export,producer in [
 ('ye_export01','ye_package_substratin'),('ye_export02','ye_package_omtrinit'),
 ('ye_export03','ye_package_verotin'),('ye_export04','ye_package_organic'),
 ('ye_export05','ye_package_spliced_cells'),('ye_export06','ye_package_carni'),
 ('ye_buechse_blau_export','ye_buechse_blau'),('ye_buechse_fleisch_export','ye_buechse_braun'),
 ('ye_buechse_rosa_export','ye_buechse_rosa'),('ye_buechse_weiss_export','ye_buechse_white'),
 ('ye_buechse_gelb_export','ye_buechse_gelb')]:
 assert {p['name'] for p in R[export]['ingredients']}&{p['name'] for p in R[producer]['results']}
 assert owners[producer][0] in ancestry(owners[export][0]),(export,producer)
 assert 'quinityn-trade' in ancestry(owners[export][0]),export
for stage in ['genetics','advanced-genetics','industrial-biology']:
 assert 'quinityn-trade' not in ancestry('quinityn-'+stage)
for recipe in ['y_chemical_science','y_military_science','y_production_science','y_high-tech_science','y_space_science']:
 assert R[recipe]['categories']==['yuoki-atomics']
 assert owners['y-atomic-constructor'][0] in ancestry(owners[recipe][0])
 for part in R[recipe]['ingredients']:
  if part['name'] in owners:
   producers=[n for n,r in R.items() if not n.endswith('-recycling')
              and any(p['name']==part['name'] for p in r.get('results',[]))]
   assert any(owner in ancestry(owners[recipe][0]) for n in producers for owner in owners.get(n,[])),(recipe,part['name'])
assert 'space-science-pack' in ancestry('quinityn-space-science')
assert {'chemical-science-pack','military-science-pack','production-science-pack','utility-science-pack'}<=ancestry('quinityn-utility-science')
assert 'quinityn-trade' not in ancestry('quinityn-chemical-science')
assert 'quinityn-reputation' not in ancestry('quinityn-orbital')
print('PASS: staged trade, real-machine manufacture, input ancestry, recycling bridges and independent rockets')
