"""Draw only sensor dots, using stock Spidertron eye coordinates (no game pixels).

Usage: python3 tools/generate_stomp_sensors.py path/to/data-raw-dump.json
The dump must come from the pinned Factorio engine; see docs/development.md.
"""
import json
import math
from pathlib import Path
import struct
import sys
import zlib

ROOT = Path(__file__).resolve().parents[1]
graphics = json.loads(Path(sys.argv[1]).read_text())['spider-vehicle']['spidertron']['graphics_set']
source = graphics['animation']['layers'][0]
assert (source['width'], source['height'], source['direction_count'], source['scale']) == (132, 138, 64, .5)
eyes = graphics['light_positions']
assert len(eyes) == 11 and all(len(eye) == 64 for eye in eyes)
width, height = 132 * 8, 138 * 8
pixels = bytearray(width * height * 4)
for direction in range(64):
    for eye in eyes:
        # Eye coordinates are in tiles; the stock torso has a (0, -19px)
        # shift and renders each 132x138 source frame at scale 0.5.
        x, y = eye[direction]
        cx = (direction % 8) * 132 + 66 + x * 32 / .5
        cy = (direction // 8) * 138 + 69 + (y * 32 + 19) / .5
        for py in range(math.floor(cy - 3), math.ceil(cy + 3)):
            for px in range(math.floor(cx - 3), math.ceil(cx + 3)):
                alpha = round(255 * max(0, min(1, 2.5 - math.hypot(px + .5 - cx, py + .5 - cy))))
                offset = (py * width + px) * 4
                if alpha > pixels[offset + 3]:
                    pixels[offset:offset + 4] = bytes((255, 246, 38, alpha))

def chunk(kind, data):
    return struct.pack('!I', len(data)) + kind + data + struct.pack('!I', zlib.crc32(kind + data))

rows = b''.join(b'\0' + pixels[y*width*4:(y+1)*width*4] for y in range(height))
png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('!2I5B', width, height, 8, 6, 0, 0, 0))
png += chunk(b'IDAT', zlib.compress(rows, 9)) + chunk(b'IEND', b'')
destination = ROOT / 'graphics/stomp-a-tron-sensors.png'
destination.write_bytes(png)
print('Wrote', destination.relative_to(ROOT), len(png), 'bytes')
