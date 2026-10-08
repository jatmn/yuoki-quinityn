#!/usr/bin/env python3
"""Upload a validated stable addon ZIP, or verify an identical prior upload."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import urllib.error
import urllib.parse
import urllib.request
import uuid

from validate_package import ROOT, validate

PORTAL = 'https://mods.factorio.com'


def request_json(url, fields=None, archive=None, token=None):
    headers = {}
    data = None
    if fields is not None:
        boundary = uuid.uuid4().hex
        parts = []
        for key, value in fields.items():
            parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{key}"\r\n\r\n{value}\r\n'.encode())
        if archive:
            parts.append(
                f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{archive.name}"\r\n'
                'Content-Type: application/zip\r\n\r\n'.encode()
            )
            parts.extend([archive.read_bytes(), b'\r\n'])
        parts.append(f'--{boundary}--\r\n'.encode())
        data = b''.join(parts)
        headers['Content-Type'] = f'multipart/form-data; boundary={boundary}'
    if token:
        headers['Authorization'] = f'Bearer {token}'
    request = urllib.request.Request(url, data=data, headers=headers)
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def find_mod(name):
    try:
        return request_json(PORTAL + '/api/mods/' + urllib.parse.quote(name, safe=''))
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise


def already_uploaded(mod, info, archive):
    for release in (mod or {}).get('releases', []):
        if release['version'] == info['version']:
            if (release['file_name'] != archive.name or
                    release['sha1'] != hashlib.sha1(archive.read_bytes()).hexdigest()):
                raise ValueError('Portal version already exists with different ZIP bytes')
            return True
    return False


def publish(output, tag, token, license_id):
    validate(output, tag=tag)
    if not token:
        raise ValueError('FACTORIO_API_KEY is required')
    info = json.loads((ROOT / 'info.json').read_text())
    archive = output / f'{info["name"]}_{info["version"]}.zip'
    mod = find_mod(info['name'])
    if already_uploaded(mod, info, archive):
        print('Portal already has this exact release')
        return
    if mod and any(tuple(map(int, item['version'].split('.'))) >
                   tuple(map(int, info['version'].split('.'))) for item in mod['releases']):
        raise ValueError('Refusing to publish an older version after a newer portal release')
    fields = {}
    endpoint = '/api/v2/mods/releases/init_upload'
    if mod is None:
        if not license_id or not license_id.startswith('custom_'):
            raise ValueError('First publication requires FACTORIO_LICENSE_ID for the project custom license')
        endpoint = '/api/v2/mods/init_publish'
        fields = {
            'description': info['description'] + '\n\nSee the source repository for installation and license notices.',
            'category': 'content',
            'license': license_id,
            'source_url': 'https://github.com/jatmn/yuoki-quinityn',
        }
    initialized = request_json(PORTAL + endpoint, {'mod': info['name']}, token=token)
    upload_url = initialized.get('upload_url', '')
    if initialized.get('error') or urllib.parse.urlparse(upload_url).scheme != 'https':
        raise ValueError('Portal did not return an HTTPS upload URL')
    # The returned URL is an upload capability; do not log it or forward the API key.
    result = request_json(upload_url, fields, archive=archive)
    if result.get('success') is not True:
        raise ValueError('Portal rejected the upload; verify its listing before retrying')
    if not already_uploaded(find_mod(info['name']), info, archive):
        raise ValueError('Upload returned success but portal verification is pending; retry this tag')
    print(f'Published {archive.name} to Factorio')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / 'build/dist')
    parser.add_argument('--tag', required=True)
    args = parser.parse_args()
    try:
        publish(args.output, args.tag, os.environ.get('FACTORIO_API_KEY'),
                os.environ.get('FACTORIO_LICENSE_ID'))
    except urllib.error.HTTPError as error:
        # Do not print URLs or response bodies that may contain upload capabilities.
        raise SystemExit(f'Factorio API HTTP {error.code}; check key permissions and retry the same tag') from None
    except urllib.error.URLError:
        raise SystemExit('Factorio API network failure; verify portal state and retry the same tag') from None
