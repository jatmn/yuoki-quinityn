#!/usr/bin/env python3
"""Produce deterministic installable zips; source and dependency assets stay separate."""
import argparse, hashlib, json, zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def pack(root,out,addon=False):
 info=json.loads((root/'info.json').read_text());name=f'{info["name"]}_{info["version"]}';target=out/(name+'.zip')
 with zipfile.ZipFile(target,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
  for p in sorted(root.rglob('*')):
   rel=p.relative_to(root)
   if not p.is_file() or any(x.startswith('.') or x in {'build','__pycache__'} for x in rel.parts):continue
   if addon and rel.parts[0] in {'tests','tools','docs','AGENTS.md','CONTRIBUTING.md'}:continue
   zi=zipfile.ZipInfo(name+'/'+rel.as_posix(),date_time=(2026,10,6,0,0,0));zi.compress_type=zipfile.ZIP_DEFLATED
   zi.external_attr=0o644<<16;z.writestr(zi,p.read_bytes())
 print(target)
 return target
p=argparse.ArgumentParser();p.add_argument('--dependencies',type=Path);p.add_argument('--output',type=Path,default=ROOT/'build/dist');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
files=[pack(ROOT,a.output,True)]
if a.dependencies:
 for name in ['Yuoki','yi_engines']:files.append(pack(a.dependencies/name,a.output))
(a.output/'SHA256SUMS').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in files))
