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
from release_notes import split_pending
import validate_package

ROOT = Path(__file__).resolve().parents[1]


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='quinityn-release-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'source'
        shutil.copytree(ROOT, self.root, ignore=shutil.ignore_patterns('.git', 'build', '__pycache__'))
        # Stable/upload tests need the last released state even when this suite
        # runs on an ordinary PR containing pending notes. The lifecycle test
        # explicitly adds contributions and exercises their real package path.
        notes = self.root / 'changelog.txt'
        notes.write_text(split_pending(notes.read_text())[1])
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

    def test_wrong_tag_and_changelog_version_block_a_release(self):
        self.build()
        with self.assertRaisesRegex(ValueError, 'Stable tag'):
            validate_package.validate(self.out, tag='v65535.0.0')
        notes = self.root / 'changelog.txt'
        notes.write_text(notes.read_text().replace('Version: ' + self.version, 'Version: 65535.0.0', 1))
        self.build()
        with self.assertRaisesRegex(ValueError, 'top section'):
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

    def test_per_pr_notes_survive_nightly_release_refresh_and_next_cycle(self):
        notes = self.root / 'changelog.txt'
        history = notes.read_text()
        pending = '-' * 99 + '\nVersion: Unreleased\n  Bugfixes:\n    - Fixed landing.\n'
        notes.write_text(pending + history)
        self.build('--nightly')
        validate_package.validate(self.out, nightly=True)
        major, minor, patch_number = map(int, self.version.split('.'))
        upcoming = f'{major}.{minor}.{patch_number + 1}'
        archive_path = self.out / f'yuoki-quinityn_{upcoming}.zip'
        with zipfile.ZipFile(archive_path) as archive:
            content = archive.read(f'yuoki-quinityn_{upcoming}/changelog.txt').decode()
            self.assertIn('Fixed landing.', content)
            self.assertNotIn('Unreleased', content)
            self.assertTrue(content.endswith(history))
        self.assertEqual(notes.read_text(), pending + history)
        # A regular development package is also loadable before the bot bumps info.json.
        self.build()
        validate_package.validate(self.out)
        with self.assertRaises(ValueError):
            validate_package.validate(self.out, tag='v' + upcoming)

        def set_version(version):
            info = self.root / 'info.json'
            data = json.loads(info.read_text())
            data['version'] = version
            info.write_text(json.dumps(data))
            (self.root / '.github/version.txt').write_text(version + '\n')
            (self.root / '.github/release-please-manifest.json').write_text(json.dumps({'.': version}))

        def prepare():
            subprocess.run([sys.executable, 'tools/release_notes.py', '--date', '2026-10-08'],
                           cwd=self.root, check=True, capture_output=True)

        set_version(upcoming)  # Release Please owns these version updates.
        prepare()
        first = notes.read_text()
        prepare()
        self.assertEqual(notes.read_text(), first)
        # Another normal PR lands; the bot rebuilds its branch from the updated main.
        pending += '    - Fixed a second issue.\n'
        notes.write_text(pending + history)
        prepare()
        released = notes.read_text()
        self.assertTrue(released.startswith('-' * 99 + f'\nVersion: {upcoming}\nDate: 2026-10-08\n'))
        self.assertIn('Fixed landing.', released)
        self.assertIn('Fixed a second issue.', released)
        self.assertTrue(released.endswith(history))
        self.build()
        validate_package.validate(self.out, tag='v' + upcoming)
        stable_bytes = archive_path.read_bytes()
        self.build()
        self.assertEqual(archive_path.read_bytes(), stable_bytes)
        # The next contribution opens a fresh pending section, preserving released history.
        notes.write_text('-' * 99 + '\nVersion: Unreleased\n  Changes:\n    - Next cycle.\n' + released)
        self.build('--nightly')
        validate_package.validate(self.out, nightly=True)
        following = f'{major}.{minor}.{patch_number + 2}'
        with zipfile.ZipFile(self.out / f'yuoki-quinityn_{following}.zip') as archive:
            content = archive.read(f'yuoki-quinityn_{following}/changelog.txt').decode()
            self.assertTrue(content.endswith(released))
            self.assertIn('Next cycle.', content)

    def test_development_only_release_gets_metadata_without_ci_prose(self):
        notes = self.root / 'changelog.txt'
        history = notes.read_text()
        info = self.root / 'info.json'
        data = json.loads(info.read_text())
        major, minor, patch_number = map(int, self.version.split('.'))
        data['version'] = f'{major}.{minor}.{patch_number + 1}'
        info.write_text(json.dumps(data))
        for day in ['2026-10-08', '2026-10-09']:
            subprocess.run([sys.executable, 'tools/release_notes.py', '--date', day],
                           cwd=self.root, check=True, capture_output=True)
        content = notes.read_text()
        validate_package.validate_changelog(content, data['version'])
        self.assertIn('Date: 2026-10-08\n', content)
        self.assertIn('No player-facing changes.', content)
        self.assertTrue(content.endswith(history))

    def test_workflow_finalizes_only_the_matching_repository_branch(self):
        def git(*args):
            return subprocess.check_output(['git', *args], cwd=self.root).decode().strip()

        git('config', 'user.name', 'Release test')
        git('config', 'user.email', 'release@example.invalid')
        git('commit', '-qm', 'feat: test contribution')
        foreign_head = git('rev-parse', 'HEAD')
        info = self.root / 'info.json'
        data = json.loads(info.read_text())
        major, minor, patch_number = map(int, self.version.split('.'))
        version = f'{major}.{minor}.{patch_number + 1}'
        data['version'] = version
        info.write_text(json.dumps(data))
        (self.root / '.github/version.txt').write_text(version + '\n')
        (self.root / '.github/release-please-manifest.json').write_text(json.dumps({'.': version}))
        git('add', '.')
        git('commit', '-qm', 'chore(main): release ' + version)
        trusted_head = git('rev-parse', 'HEAD')
        branch = 'release-please--branches--main'
        git('branch', branch)
        remote = Path(self.temp.name) / 'origin.git'
        subprocess.run(['git', 'init', '--bare', '-q', str(remote)], check=True)
        git('remote', 'add', 'origin', str(remote))
        git('push', '-q', 'origin', branch)
        # Only gh's read-only PR lookup is simulated; checkout, finalization,
        # package validation, commit and fast-forward push are the real workflow.
        fake_bin = Path(self.temp.name) / 'bin'
        fake_bin.mkdir()
        gh = fake_bin / 'gh'
        gh.write_text('#!/bin/sh\nprintf "%s\\n" "$TEST_PR_HEAD"\n')
        gh.chmod(0o755)
        workflow = (self.root / '.github/workflows/release.yml').read_text()
        section = workflow.split("      - name: Finalize the release PR's accumulated game notes\n")[1]
        script = textwrap.dedent(section.split('        run: |\n')[1].split('\n  publish:')[0])
        for head, succeeds in [(foreign_head, False), (trusted_head, True)]:
            result = subprocess.run(['bash', '-e', '-o', 'pipefail', '-c', script], cwd=self.root,
                                    env={**os.environ, 'PATH': str(fake_bin) + os.pathsep + os.environ['PATH'],
                                         'TEST_PR_HEAD': head}, capture_output=True)
            self.assertEqual(result.returncode == 0, succeeds, result.stderr.decode())
            if not succeeds:
                self.assertEqual(git('rev-parse', branch), trusted_head)
                self.assertFalse(self.out.exists())
        published_head = git('ls-remote', 'origin', 'refs/heads/' + branch).split()[0]
        self.assertEqual(published_head, git('rev-parse', 'HEAD'))
        self.assertNotEqual(published_head, trusted_head)
        validate_package.validate(self.out, tag='v' + version)


if __name__ == '__main__':
    unittest.main()
