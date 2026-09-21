"""Pure-Python decoder for the raw Snappy block format used by the official
consensus-spec fixtures (`serialized.ssz_snappy`).

benchmarks/run.py is executed by the operator's validation interpreter, which
does not have python-snappy; installing packages there is outside this
project's scope. This decoder is checked byte for byte against python-snappy on
every fixture by benchmarks/checks/snappy_check.py.
"""


def _varint(data, pos):
    value, shift = 0, 0
    while True:
        byte = data[pos]
        pos += 1
        value |= (byte & 0x7F) << shift
        if not byte & 0x80:
            return value, pos
        shift += 7


def decompress(data):
    length, pos = _varint(data, 0)
    out = bytearray()
    while pos < len(data):
        tag = data[pos]
        pos += 1
        kind = tag & 3
        if kind == 0:  # literal
            n = tag >> 2
            if n >= 60:
                extra = n - 59
                n = int.from_bytes(data[pos:pos + extra], 'little')
                pos += extra
            n += 1
            out += data[pos:pos + n]
            pos += n
            continue
        if kind == 1:  # copy, 1-byte offset
            n = ((tag >> 2) & 7) + 4
            offset = ((tag >> 5) << 8) | data[pos]
            pos += 1
        elif kind == 2:  # copy, 2-byte offset
            n = (tag >> 2) + 1
            offset = int.from_bytes(data[pos:pos + 2], 'little')
            pos += 2
        else:  # copy, 4-byte offset
            n = (tag >> 2) + 1
            offset = int.from_bytes(data[pos:pos + 4], 'little')
            pos += 4
        if offset == 0 or offset > len(out):
            raise ValueError('invalid snappy copy offset')
        start = len(out) - offset
        for i in range(n):  # copies may overlap their own output
            out.append(out[start + i])
    if len(out) != length:
        raise ValueError('snappy length mismatch')
    return bytes(out)
