import {test, expect} from 'bun:test';
import {createHash} from 'node:crypto';
import I from '../../src/mixing.bend';
import M from '../../src/merkle.bend';
import P from '../../src/primitives.bend';
import {list, bytes} from '../../tools/primitive_backend';

function uint(n: bigint) {
  const limbs = Array.from({length:8}, (_,i) => Number((n >> BigInt(32*i)) & 0xffffffffn));
  return P.make_uint(...limbs);
}
function hash(value: number[]) { return [...createHash('sha256').update(Buffer.from(value)).digest()]; }

test('length mixing uses all 256 bits and exact little-endian encoding', () => {
  const lengths = [0n, 1n, 255n, 256n, (1n<<32n)-1n, 1n<<32n,
    (1n<<64n)-1n, 1n<<64n, 1n<<128n, 1n<<255n, (1n<<256n)-1n];
  for (const salt of [0, 19, 255]) {
    const root = Array.from({length:32}, (_,i)=>(salt+i*37)&255);
    for (const n of lengths) {
      const lengthBytes = Array.from({length:32}, (_,i)=>Number((n>>BigInt(i*8))&255n));
      const actual = bytes(I.mix_in_length(list(root), uint(n)).value);
      expect(actual).toEqual(hash([...root,...lengthBytes]));
      expect(actual.length).toBe(32);
    }
  }
});

test('length mixing rejects malformed roots semantically', () => {
  for (const size of [0, 1, 31, 33, 64]) {
    expect(I.mix_in_length(list(Array(size).fill(0)), uint(0n)).$).toBe('None');
  }
  for (const bad of [256, 65536, 0xffffffff]) {
    for (const index of [0, 15, 31]) {
      const root=Array(32).fill(0); root[index]=bad;
      expect(I.mix_in_length(list(root),uint((1n<<256n)-1n)).$).toBe('None');
    }
  }
});

test('virtual zero subtrees agree with independently hashed levels', () => {
  let expected = Array(32).fill(0);
  // Depth 64 represents 2^64 leaves; no leaf allocation is performed.
  for(let depth=0; depth<=64; depth++) {
    const actual = bytes(M.zero_hash(BigInt(depth)));
    expect(actual).toEqual(expected);
    expect(actual.length).toBe(32);
    expected=hash([...expected,...expected]);
  }
});

test('selector mixing validates uint8 and uses a zero-padded selector chunk', () => {
  const root = Array.from({length:32}, (_,i)=>(i*37+19)&255);
  for (let selector=0; selector<256; selector++) {
    const result=I.mix_in_selector(list(root),selector);
    expect(result.$).toBe('Some');
    expect(bytes(result.value)).toEqual(hash([...root,selector,...Array(31).fill(0)]));
    expect(bytes(result.value).length).toBe(32);
  }
  for (const selector of [256,257,65535,0xffffffff]) {
    expect(I.mix_in_selector(list(root),selector).$).toBe('None');
  }
  for (const n of [0,1,31,33,64]) {
    expect(I.mix_in_selector(list(Array(n).fill(0)),1).$).toBe('None');
  }
  for (const i of [0,15,31]) {
    const malformed=[...root]; malformed[i]=256;
    expect(I.mix_in_selector(list(malformed),255).$).toBe('None');
  }
});

test('selector chunk convention matches pinned compatible-union fixture', async () => {
  // The pinned test-format defines this option as ProgressiveContainer([1])
  // with a single uint8 A field. Reconstruct ONLY its inner root independently;
  // the selector root itself must come from Bend.
  const dir='fixtures/tests/general/phase0/ssz_generic/compatible_unions/valid/CompatibleUnionA_max_selector_1_chaos_1/';
  const value=await Bun.file(dir+'value.yaml').text();
  const meta=await Bun.file(dir+'meta.yaml').text();
  const a=Number(value.match(/A: (\d+)/)![1]);
  const selector=Number(value.match(/selector: (\d+)/)![1]);
  const fieldRoot=[a,...Array(31).fill(0)];
  const inner=hash([...hash([...Array(32).fill(0),...fieldRoot]),1,...Array(31).fill(0)]);
  const actual=bytes(I.mix_in_selector(list(inner),selector).value);
  expect('0x'+Buffer.from(actual).toString('hex')).toBe(meta.match(/0x[0-9a-f]{64}/)![0]);
});
