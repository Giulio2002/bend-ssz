import {test, expect} from 'bun:test';
import {createHash} from 'node:crypto';
import H from '../src/sha256.bend';
function list(xs: number[]): any {
  let value: any = {$: 'Nil'};
  for (let i = xs.length - 1; i >= 0; i--) value = {$: 'Con', head: xs[i], tail: value};
  return value;
}
function bytes(xs: any): number[] {
  const out: number[] = [];
  while (xs.$ === 'Con') { out.push(xs.head); xs = xs.tail; }
  if (xs.$ !== 'Nil') throw new Error('unexpected Bend list');
  return out;
}
test('actual SHA wrapper matches independent SHA for padding and chunk boundaries', () => {
  for (const size of [0, 1, 2, 31, 32, 55, 56, 63, 64, 65, 119, 120, 127, 128, 129, 1024]) {
    const input = Buffer.from(Array.from({length: size}, (_, i) => (i * 73 + 19) & 255));
    const actual = bytes(H.hash(list([...input])));
    expect(actual.length).toBe(32);
    expect(Buffer.from(actual).toString('hex')).toBe(createHash('sha256').update(input).digest('hex'));
  }
});
