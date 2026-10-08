#!/usr/bin/env python3
"""Regressions for CI routing only; no game or dependency mods are loaded."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from ci_changes import classify

ROUTER = Path(__file__).with_name('ci_changes.py').resolve()


class RoutingTests(unittest.TestCase):
    def test_surface_selection(self):
        cases = [
            (['control.lua'], {'lua', 'package'}),
            (['prototypes/new/module.lua'], {'lua', 'package'}),
            (['tests/runtime.lua'], {'lua'}),
            (['tests/prototypes.py', 'tools/test.py'], {'python'}),
            (['tools/package.py', 'tools/validate_package.py'], {'python', 'package'}),
            (['info.json', 'locale/en/quinityn.cfg', 'graphics/new.png'], {'package'}),
            (['README.md', 'NOTICE', 'graphics/README.md'], {'package'}),
            (['docs/development.md', 'AGENTS.md', 'CONTRIBUTING.md'], set()),
            (['.gitignore', '.github/CODEOWNERS', 'build/generated.txt'], set()),
            (['.luacheckrc', '.stylua.toml'], {'lua'}),
            (['.github/workflows/lua.yml'], {'lua', 'workflows'}),
            (['.github/workflows/python.yml'], {'python', 'workflows'}),
            (['.github/workflows/package.yml'], {'package', 'workflows'}),
            (['.github/workflows/workflows.yml'], {'workflows'}),
            (['.github/workflows/ci.yml'], {'lua', 'python', 'package', 'workflows'}),
            (['tools/ci_changes.py'], {'lua', 'python', 'package', 'workflows'}),
            (['control.lua', 'tools/test.py'], {'lua', 'python', 'package'}),
            ([], set()),
        ]
        for paths, expected in cases:
            with self.subTest(paths=paths):
                self.assertEqual({name for name, enabled in classify(paths).items() if enabled}, expected)

    def test_complete_git_diff_and_path_changes(self):
        with tempfile.TemporaryDirectory(prefix='quinityn-ci-') as directory:
            root = Path(directory)

            def git(*args):
                return subprocess.check_output([
                    'git', '-c', 'user.name=CI test', '-c', 'user.email=ci@example.invalid', *args
                ], cwd=root, text=True).strip()

            def route(base):
                result = subprocess.check_output(
                    [sys.executable, str(ROUTER), '--base', base], cwd=root, text=True
                )
                return {line.split('=')[0] for line in result.splitlines() if line.endswith('=true')}

            git('init', '-q')
            git('commit', '--allow-empty', '-qm', 'base')
            base = git('rev-parse', 'HEAD')
            (root / 'docs').mkdir()
            for index in range(3500):
                (root / 'docs' / f'{index:04}.md').write_text('documentation\n')
            git('add', '.'); git('commit', '-qm', 'large docs-only change')
            self.assertEqual(route(base), set())
            (root / 'tests').mkdir()
            lua = root / 'tests/late file\nwith whitespace.lua'
            lua.write_text('return true\n')
            git('add', '.'); git('commit', '-qm', 'Lua beyond the filtered file-list cap')
            self.assertEqual(route(base), {'lua'})
            previous = git('rev-parse', 'HEAD')
            git('mv', str(lua.relative_to(root)), 'tools-renamed.py')
            git('commit', '-qm', 'cross-surface rename')
            self.assertEqual(route(previous), {'lua', 'python', 'package'})
            previous = git('rev-parse', 'HEAD')
            git('rm', 'tools-renamed.py'); git('commit', '-qm', 'delete')
            self.assertEqual(route(previous), {'python', 'package'})
            failed = subprocess.run([sys.executable, str(ROUTER), '--base', 'missing-revision'],
                                    cwd=root, capture_output=True, text=True)
            self.assertNotEqual(failed.returncode, 0)
            self.assertEqual(failed.stdout, '')


if __name__ == '__main__':
    unittest.main()
