"""A constructive finite-stock budget for reaching the first Cimota Restructor.

Overprovisions the pre-Cimota science budget; reserves 500 coal for boilers,
smelting and the separator. Uses only native recipes plus emergency hand dressing.
Does not count incidental salvage, productivity, or distant deposits.
"""
import json,sys,math
from pathlib import Path
from collections import defaultdict
D=json.loads(Path(sys.argv[1]).read_text());R=D['recipe']; stock=defaultdict(float);used=defaultdict(float)
choice={
 'iron-ore':'quinityn-iron','copper-ore':'quinityn-copper','stone':'quinityn-stone',
 'coal':'quinityn-carbon','wood':'quinityn-timber','water':'quinityn-water',
 'y-crush-yres1':'y-crush-unicomp-raw','y-crush-yres2':'y-crush-fuel-raw',
 'y-refined-yres1':'y-smelt-crush-res1','y-refined-yres2':'y-smelt-crush-res2',
 'y_rwtechsign':'y-fuel-reactor', 'y-richdust':'y-mixing-rich'
}
def supply(name,amount,path=()):
 if stock[name]>=amount:stock[name]-=amount;return
 amount-=stock[name];stock[name]=0
 if name in {'y-res1','y-res2','y-liquid-uc2'}:used[name]+=amount;return
 assert name not in path, 'cycle '+str(path+(name,))
 r=R.get(choice.get(name,name));assert r,'No selected recipe for '+name
 output=next(p for p in r['results'] if p['name']==name)
 count=math.ceil(amount/output['amount'])
 for p in r.get('ingredients',[]):supply(p['name'],count*p['amount'],path+(name,))
 for p in r['results']:
  if p.get('independent_probability',1)==1:stock[p['name']]+=count*p.get('amount',0)
 stock[name]-=amount
# Reserve the original pre-Cimota research plus Circuit network for the first
# factory arithmetic combinator, with margin for basic automation technologies.
goals={'automation-science-pack':600,'logistic-science-pack':400,'quinityn-research-data':160,
 'stone-furnace':2,'boiler':1,'steam-engine':1,'offshore-pump':1,'small-electric-pole':10,
 'quinityn-burner-separator':1,'lab':2,'y-crusher':1,'y-heat-form-press':1,'y-atomic-constructor':1,
 'ye_fassembly1':1,'assembling-machine-1':2,'pipe':30,'coal':500,'burner-mining-drill':2,'burner-inserter':8}
for name,amount in goals.items():supply(name,amount)
for ore in ['y-res1','y-res2']:
 print(ore,math.ceil(used[ore]),'/ 125000 starting units')
 assert used[ore]<=125000,'Insufficient starter ore: '+ore
print('PASS: finite starting-stock budget reaches a powered Cimota without salvage, imported items or remote deposits')
