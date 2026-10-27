"""Read PNGs to inventory provenance/alpha; never modify image pixels."""
import hashlib
import json
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def inspect(path):
    data = path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f'Not PNG: {path}')
    width, height, depth, color, compression, filtering, interlace = struct.unpack('>IIBBBBB', data[16:29])
    result = dict(file=path.relative_to(ROOT).as_posix(), width=width, height=height,
                  bytes=len(data), sha256=hashlib.sha256(data).hexdigest(),
                  bitDepth=depth, colorType=color)
    if depth != 8 or color not in (2, 6) or interlace:
        result['alphaInspection'] = 'Unsupported encoding; inspect separately'
        return result
    channels = 4 if color == 6 else 3
    pos, chunks = 8, []
    while pos < len(data):
        size = struct.unpack('>I', data[pos:pos + 4])[0]
        if data[pos + 4:pos + 8] == b'IDAT':
            chunks.append(data[pos + 8:pos + 8 + size])
        pos += size + 12
    raw = zlib.decompress(b''.join(chunks))
    stride = width * channels
    previous = bytearray(stride)
    cursor = transparent = translucent = opaque = 0
    minimum, maximum = 255, 0
    for _ in range(height):
        kind = raw[cursor]
        row = bytearray(raw[cursor + 1:cursor + 1 + stride])
        cursor += stride + 1
        for index in range(stride):
            left = row[index - channels] if index >= channels else 0
            up = previous[index]
            corner = previous[index - channels] if index >= channels else 0
            if kind == 1:
                predictor = left
            elif kind == 2:
                predictor = up
            elif kind == 3:
                predictor = (left + up) // 2
            elif kind == 4:
                p = left + up - corner
                a, b, c = abs(p-left), abs(p-up), abs(p-corner)
                predictor = left if a <= b and a <= c else up if b <= c else corner
            elif kind == 0:
                predictor = 0
            else:
                raise ValueError('Unsupported PNG filter')
            row[index] = (row[index] + predictor) & 255
        values = row[3::4] if channels == 4 else [255] * width
        minimum, maximum = min(minimum, min(values)), max(maximum, max(values))
        transparent += values.count(0)
        opaque += values.count(255)
        translucent += len(values) - values.count(0) - values.count(255)
        previous = row
    result['alpha'] = dict(minimum=minimum, maximum=maximum,
                           transparentPixels=transparent, translucentPixels=translucent,
                           opaquePixels=opaque)
    return result


if __name__ == '__main__':
    inventory = dict(prepared='2026-10-27', status='Proposed; owner fidelity approval pending',
                     method='Built-in image_gen; code-native HTML composition; no image pixel edits by this script',
                     files=[inspect(path) for path in sorted(ROOT.rglob('*.png'))
                            if 'screenshots' not in path.parts])
    (ROOT / 'asset-manifest.json').write_text(json.dumps(inventory, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(inventory, indent=2))
