#!/usr/bin/env python3
"""Fetch the exact 2.1 dependency sources; never modify upstream branches."""
import argparse, subprocess
from pathlib import Path
LOCK={
 'Yuoki':{'url':'https://github.com/jatmn/Yuoki-Factorio-2.x.git','commit':'2372d6c1e933bd95e4437fa1f3003b9d53b69eea'},
 'yi_engines':{'url':'https://github.com/jatmn/Yuoki-Engines-Factorio-2.x.git','commit':'3fc8761858e6d8d592ec1978ca51f7a57d44e882'},
}
def main():
 p=argparse.ArgumentParser();p.add_argument('--directory',type=Path,default=Path('build/dependencies'));a=p.parse_args()
 for name,source in LOCK.items():
  path=a.directory/name
  if not path.exists():
   subprocess.run(['git','clone','--no-checkout',source['url'],str(path)],check=True)
   subprocess.run(['git','-C',str(path),'checkout','--detach',source['commit']],check=True)
  actual=subprocess.check_output(['git','-C',str(path),'rev-parse','HEAD'],text=True).strip()
  if actual!=source['commit']:raise SystemExit(f'{path}: expected {source["commit"]}, found {actual}; use an empty directory')
  if subprocess.check_output(['git','-C',str(path),'status','--porcelain'],text=True).strip():raise SystemExit(f'{path}: modified; will not overwrite')
  print(name,actual)
if __name__=='__main__':main()
