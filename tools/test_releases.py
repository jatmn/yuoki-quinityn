#!/usr/bin/env python3
"""Exercise real addon builds and release gates; portal HTTP responses are simulated."""
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import textwrap
import unittest
from unittest.mock import patch
import zipfile

import publish_mod
import validate_package

ROOT = Path(__file__).resolve().parents[1]


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='quinityn-release-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'source'
        shutil.copytree(ROOT, self.root, ignore=shutil.ignore_patterns('.git', 'build', '__pycache__'))
        subprocess.run(['git', 'init', '-q', str(self.root)], check=True)
        subprocess.run(['git', 'add', '.'], cwd=self.root, check=True)
        self.out = self.root / 'build/dist'
        self.version = json.loads((self.root / 'info.json').read_text())['version']
        self.tag = 'v' + self.version
        self.archive = self.out / f'yuoki-quinityn_{self.version}.zip'
        self.addCleanup(patch.stopall)
        patch.object(validate_package, 'ROOT', self.root).start()
        patch.object(publish_mod, 'ROOT', self.root).start()

    def build(self, *args):
        subprocess.run([sys.executable, 'tools/package.py', *args],
                       cwd=self.root, check=True, capture_output=True)

    def test_stable_and_nightly_are_installable_and_leave_sources_unchanged(self):
        originals = {name: (self.root / name).read_bytes()
                     for name in ['info.json', 'changelog.txt', '.github/release-please-manifest.json']}
        self.build()
        validate_package.validate(self.out, tag=self.tag)
        stable_hash = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        self.build()
        self.assertEqual(hashlib.sha256(self.archive.read_bytes()).hexdigest(), stable_hash)
        self.build('--nightly')
        validate_package.validate(self.out, nightly=True)
        major, minor, patch_number = map(int, self.version.split('.'))
        version = f'{major}.{minor}.{patch_number + 1}'
        root = f'yuoki-quinityn_{version}/'
        with zipfile.ZipFile(self.out / (root[:-1] + '.zip')) as archive:
            self.assertEqual(json.loads(archive.read(root + 'info.json'))['version'], version)
            notes = archive.read(root + 'changelog.txt')
            self.assertTrue(notes.startswith(('-' * 99 + '\nVersion: ' + version + '\n').encode()))
            self.assertTrue(notes.endswith(originals['changelog.txt']))
            self.assertNotIn(b'updated ci', notes.lower())
            self.assertTrue(all(name.startswith(root) for name in archive.namelist()))
            self.assertFalse(any('/.github/' in name or '/tools/' in name for name in archive.namelist()))
        for name, content in originals.items():
            self.assertEqual((self.root / name).read_bytes(), content)

    def test_wrong_tag_and_missing_manual_notes_block_a_release(self):
        self.build()
        with self.assertRaisesRegex(ValueError, 'Stable tag'):
            validate_package.validate(self.out, tag='v65535.0.0')
        notes = self.root / 'changelog.txt'
        notes.write_text(notes.read_text().replace('Version: ' + self.version, 'Version: 65535.0.0', 1))
        self.build()
        with self.assertRaisesRegex(ValueError, 'manually written'):
            validate_package.validate(self.out, tag=self.tag)

    def test_version_records_must_match(self):
        (self.root / '.github/version.txt').write_text('12.34.56\n')
        self.build()
        with self.assertRaisesRegex(ValueError, 'versions must match'):
            validate_package.validate(self.out)

    def test_factorio_changelog_grammar_rejects_bad_release_notes(self):
        good = '-' * 99 + '\nVersion: 0.1.1\n  Bugfixes:\n    - Fixed landing.\n'
        validate_package.validate_changelog(good, '0.1.1')
        cases = [
            good.replace('-' * 99, '-' * 98),
            good.replace('\nVersion', '\n\nVersion'),
            good.replace('0.1.1', '0.1.1.1'),
            good.replace('0.1.1', '0.1.1-nightly'),
            good.replace('0.1.1', '0.1.65536'),
            good.replace('0.1.1', '0.0.0'),
            good.replace('  Bugfixes:', '\tBugfixes:'),
            good.replace('landing.', 'landing. '),
            good.replace('  Bugfixes:\n', ''),
            good + good,
            good + '    - Fixed landing.\n',
        ]
        for text in cases:
            with self.subTest(text=text), self.assertRaises(ValueError):
                validate_package.validate_changelog(text, '0.1.1')

    def test_corrupt_zip_metadata_is_rejected_even_with_a_matching_checksum(self):
        self.build()
        with zipfile.ZipFile(self.archive) as archive:
            files = {name: archive.read(name) for name in archive.namelist()}
        files[f'yuoki-quinityn_{self.version}/info.json'] = b'{}'
        with zipfile.ZipFile(self.archive, 'w') as archive:
            for name, content in files.items():
                archive.writestr(name, content)
        checksum = hashlib.sha256(self.archive.read_bytes()).hexdigest()
        (self.out / 'SHA256SUMS').write_text(f'{checksum}  {self.archive.name}\n')
        with self.assertRaisesRegex(ValueError, 'differs from source'):
            validate_package.validate(self.out)

    def portal_release(self):
        return {'releases': [{
            'version': self.version, 'file_name': self.archive.name,
            'sha1': hashlib.sha1(self.archive.read_bytes()).hexdigest(),
        }]}

    def test_portal_upload_and_retry_use_the_exact_validated_zip(self):
        self.build()
        response = self.portal_release()
        with (patch.object(publish_mod, 'find_mod', side_effect=[{'releases': []}, response]),
              patch.object(publish_mod, 'request_json', side_effect=[
                    {'upload_url': 'https://uploads.example.invalid/upload'},
                    {'success': True},
                ]) as request):
            publish_mod.publish(self.out, self.tag, 'test-key', None)
            self.assertEqual(request.call_args_list[0].args[0],
                             'https://mods.factorio.com/api/v2/mods/releases/init_upload')
            self.assertEqual(request.call_args_list[1].kwargs, {'archive': self.archive})
        with (patch.object(publish_mod, 'find_mod', return_value=response),
              patch.object(publish_mod, 'request_json') as request):
            publish_mod.publish(self.out, self.tag, 'test-key', None)
            request.assert_not_called()
            response['releases'][0]['sha1'] = 'different'
            with self.assertRaisesRegex(ValueError, 'different ZIP'):
                publish_mod.publish(self.out, self.tag, 'test-key', None)
            request.assert_not_called()

    def test_first_portal_publication_requires_explicit_license(self):
        self.build()
        with (patch.object(publish_mod, 'find_mod', return_value=None),
              patch.object(publish_mod, 'request_json') as request):
            with self.assertRaisesRegex(ValueError, 'FACTORIO_LICENSE_ID'):
                publish_mod.publish(self.out, self.tag, 'test-key', None)
            request.assert_not_called()
        with (patch.object(publish_mod, 'find_mod', side_effect=[None, self.portal_release()]),
              patch.object(publish_mod, 'request_json', side_effect=[
                    {'upload_url': 'https://uploads.example.invalid/upload'},
                    {'success': True},
                ]) as request):
            publish_mod.publish(self.out, self.tag, 'test-key', 'custom_123')
            self.assertTrue(request.call_args_list[0].args[0].endswith('/init_publish'))
            self.assertEqual(request.call_args_list[1].args[1]['license'], 'custom_123')

    def test_failed_upload_is_not_reported_as_published(self):
        self.build()
        with (patch.object(publish_mod, 'find_mod', return_value={'releases': []}),
              patch.object(publish_mod, 'request_json', side_effect=[
                    {'upload_url': 'https://uploads.example.invalid/upload'},
                    {'success': False},
                ])):
            with self.assertRaisesRegex(ValueError, 'rejected'):
                publish_mod.publish(self.out, self.tag, 'test-key', None)

    def test_upload_request_contains_zip_bytes_without_forwarding_api_key(self):
        self.build()
        with patch.object(publish_mod.urllib.request, 'urlopen',
                          return_value=io.BytesIO(b'{"success":true}')) as opened:
            publish_mod.request_json('https://uploads.example.invalid/upload',
                                     {'license': 'custom_123'}, archive=self.archive)
        request = opened.call_args.args[0]
        self.assertIsNone(request.get_header('Authorization'))
        self.assertIn(b'name="file"; filename="' + self.archive.name.encode() + b'"', request.data)
        self.assertIn(self.archive.read_bytes(), request.data)
        self.assertIn(b'name="license"\r\n\r\ncustom_123\r\n', request.data)

    def test_manual_notes_pause_refresh_and_api_errors_fail_closed(self):
        workflow = (ROOT / '.github/workflows/release.yml').read_text()
        section = workflow.split('      - name: Preserve a release PR')[1].split('      - uses:')[0]
        script = textwrap.dedent(section.split('        run: |\n')[1])
        stub = self.root / 'fake-bin'
        stub.mkdir()
        gh = stub / 'gh'
        gh.write_text('#!/bin/sh\nif [ "$2" = list ]; then echo 42; '
                      'else printf "%s\\n" "$DIFF_FILES"; exit "$DIFF_EXIT"; fi\n')
        gh.chmod(0o755)
        for files, code, frozen in [('info.json\nchangelog.txt', '0', True),
                                    ('info.json', '0', False),
                                    ('', '1', False)]:
            with self.subTest(files=files, code=code):
                output = self.root / 'outputs'
                summary = self.root / 'summary'
                output.write_text('')
                env = {**os.environ, 'PATH': str(stub) + os.pathsep + os.environ['PATH'],
                       'DIFF_FILES': files, 'DIFF_EXIT': code,
                       'RUNNER_TEMP': str(self.root), 'GITHUB_OUTPUT': str(output),
                       'GITHUB_STEP_SUMMARY': str(summary)}
                result = subprocess.run(['bash', '-e', '-o', 'pipefail', '-c', script],
                                        cwd=self.root, env=env, capture_output=True)
                self.assertEqual(result.returncode, int(code))
                self.assertEqual(output.read_text(), 'prepared=true\n' if frozen else '')


if __name__ == '__main__':
    unittest.main()
