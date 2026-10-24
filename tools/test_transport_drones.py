#!/usr/bin/env python3
"""Native Transport Drones ownership, save-upgrade and delivery regression."""
import argparse
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATEGORIES = {'transport-drone-request', 'transport-fluid-request', 'fuel-depot'}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--factorio', type=Path, required=True)
    parser.add_argument('--dependencies', type=Path, required=True)
    parser.add_argument('--transport-drones', type=Path, required=True)
    parser.add_argument('--output', type=Path, default=ROOT / 'build/transport-drones')
    args = parser.parse_args()
    engine = args.factorio.resolve()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    # Keep concurrent runs and interrupted legacy fixtures in separate directories.
    output = Path(tempfile.mkdtemp(prefix='run-', dir=output))
    print('Run directory:', output, flush=True)

    # The control retains Quinityn's items, so even their generated requests are
    # compared. Only its final rewrite is absent; dependency sources are intact.
    control = output / 'control-addon'
    shutil.copytree(ROOT, control,
                    ignore=shutil.ignore_patterns('.git', 'build', '__pycache__'))
    (control / 'data-final-fixes.lua').unlink()

    def environment(name, addon, fuel):
        folder = output / name
        mods = folder / 'mods'
        mods.mkdir(parents=True, exist_ok=True)
        for mod, target in [('Yuoki', args.dependencies / 'Yuoki'),
                            ('yi_engines', args.dependencies / 'yi_engines'),
                            ('Transport_Drones', args.transport_drones),
                            ('yuoki-quinityn', addon)]:
            link = mods / mod
            if not link.exists():
                link.symlink_to(target.resolve(), target_is_directory=True)
        harness = mods / 'quinityn-tests'
        harness.mkdir(exist_ok=True)
        (harness / 'info.json').write_text(json.dumps({
            'name': 'quinityn-tests', 'version': '0.1.0', 'factorio_version': '2.1',
            'title': 'Drone integration tests', 'author': 'jatmn',
            'dependencies': ['yuoki-quinityn', 'Transport_Drones']}))
        (harness / 'settings-updates.lua').write_text(
            'data.raw["string-setting"]["fuel-fluid"].forced_value=' + json.dumps(fuel) + '\n')
        (mods / 'mod-list.json').write_text(json.dumps({'mods': [
            {'name': mod, 'enabled': True} for mod in ['base', 'space-age', 'quality',
            'elevated-rails', 'Yuoki', 'yi_engines', 'Transport_Drones', 'yuoki-quinityn', 'quinityn-tests']]}))
        config = folder / 'config.ini'
        config.write_text(f'[path]\nread-data={engine.parents[2] / "data"}\nwrite-data={folder / "write"}\n')
        return folder, harness, [str(engine), '--config', str(config), '--mod-directory', str(mods)]

    def run(env, name, options, marker='Factorio initialised'):
        result = subprocess.run(env[2] + options, capture_output=True, text=True, timeout=180)
        text = result.stdout + result.stderr
        (env[0] / (name + '.log')).write_text(text)
        assert result.returncode == 0 and marker in text, name + ':\n' + text[-6000:]
        print('PASS', env[0].name, name, flush=True)

    def helpers(dump):
        return {name: recipe for name, recipe in dump['recipe'].items()
                if CATEGORIES.intersection(recipe.get('categories', [recipe.get('category')]))}

    for fuel in ['petroleum-gas', 'y_hydrogen']:
        before = environment('control-' + fuel, control, fuel)
        after = environment('candidate-' + fuel, ROOT, fuel)
        run(before, 'dump', ['--dump-data'])
        run(after, 'dump', ['--dump-data'])
        baseline = json.loads((before[0] / 'write/script-output/data-raw-dump.json').read_text())
        candidate = json.loads((after[0] / 'write/script-output/data-raw-dump.json').read_text())
        expected, actual = helpers(baseline), helpers(candidate)
        assert expected and actual.keys() == expected.keys(), 'generated helper set changed'
        for name in expected:
            assert actual[name] == expected[name], 'Quinityn mutated helper: ' + name
        def helper_unlocks(dump):
            return sorted((name, e['recipe']) for name, tech in dump['technology'].items()
                          for e in tech.get('effects', []) if e.get('recipe') in actual)
        assert helper_unlocks(candidate) == helper_unlocks(baseline), 'upstream helper unlocks changed'
        for name, tech in candidate['technology'].items():
            if name.startswith('quinityn-'):
                assert not any(e.get('recipe') in actual for e in tech.get('effects', [])), name
        # Real manufacturing stays behind its original production tier.
        assert not candidate['recipe']['y-pink-module-2']['enabled']
        owners = [name for name, tech in candidate['technology'].items()
                  if any(e.get('recipe') == 'y-pink-module-2' for e in tech.get('effects', []))]
        assert owners == ['quinityn-advanced-productivity-module'], owners
        print('PASS complete helper equality and zero Quinityn effects:', len(actual), fuel, flush=True)
        harness = after[1]
        (harness / 'control.lua').write_text('require("__yuoki-quinityn__/tests/transport_drones")\n')
        (harness / 'parameters.lua').write_text('return {legacy=false}\n')
        run(after, 'fresh-create', ['--create', str(after[0] / 'fresh.zip')], 'DRONE FRESH SETUP')
        run(after, 'fresh-delivery', ['--benchmark', str(after[0] / 'fresh.zip'),
            '--benchmark-ticks', '12001', '--benchmark-runs', '1'], 'DRONE DELIVERY PASSED')
        # Reconstruct the old ownership defect for every generated helper. This
        # intentionally exceeds the 409 observed cases and never patches a dependency.
        legacy = harness / 'data-final-fixes.lua'
        legacy.write_text('local categories={["transport-drone-request"]=true,["transport-fluid-request"]=true,["fuel-depot"]=true}\n'
            'for name,r in pairs(data.raw.recipe) do for _,c in pairs(r.categories or {}) do if categories[c] then\n'
            ' r.enabled=false; table.insert(data.raw.technology["quinityn-trade"].effects,{type="unlock-recipe",recipe=name}); break\n'
            'end end end\n')
        (harness / 'parameters.lua').write_text('return {legacy=true}\n')
        try:
            run(after, 'legacy-create', ['--create', str(after[0] / 'legacy.zip')], 'DRONE LEGACY SETUP')
        finally:
            legacy.unlink()
            (harness / 'parameters.lua').write_text('return {legacy=false}\n')
        run(after, 'upgrade-delivery', ['--benchmark', str(after[0] / 'legacy.zip'),
            '--benchmark-ticks', '12001', '--benchmark-runs', '1'], 'DRONE UPGRADE DELIVERY PASSED')


if __name__ == '__main__':
    main()
