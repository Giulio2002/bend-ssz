import {test, expect} from 'bun:test';
import Layout from '../../src/layout.bend';
import Normative from '../../spec/layout_decoding.bend';

const list = (xs: any[]): any => xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$: 'Nil'});
const widths = (xs: (number|null)[]) => list(xs.map(n => n === null ? {$: 'None'} : {$: 'Some', value: BigInt(n)}));
const decoded = (result: any): number[][]|null => {
  if (result.$ === 'None') return null;
  expect(result.$).toBe('Some');
  const out: number[][] = [];
  let items = result.value;
  for (; items.$ === 'Con'; items = items.tail) {
    const bytes: number[] = [];
    let xs = items.head;
    for (; xs.$ === 'Con'; xs = xs.tail) bytes.push(xs.head);
    expect(xs.$).toBe('Nil');
    out.push(bytes);
  }
  expect(items.$).toBe('Nil');
  return out;
};
const offset = (n: number) => [n & 255, (n >>> 8) & 255, (n >>> 16) & 255, (n >>> 24) & 255];

test('layout decoder and independent semantics preserve field order and empty extents', () => {
  // Expected slices are chosen before constructing wire offsets, so a shared
  // decoder error cannot establish agreement by round trip.
  for (let mask = 0; mask < 8; mask++) {
    for (let a = 0; a < 3; a++) for (let b = 0; b < 3; b++) for (let c = 0; c < 3; c++) {
      const fields = [a,b,c].map((n, i) => Array.from({length: n}, (_, j) => 70 * i + j));
      const ws = fields.map((xs, i) => mask & (1 << i) ? null : xs.length);
      let position = ws.reduce<number>((n, w) => n + (w === null ? 4 : w), 0);
      const header: number[] = [], payload: number[] = [];
      fields.forEach((xs, i) => {
        if (ws[i] === null) { header.push(...offset(position)); payload.push(...xs); position += xs.length; }
        else header.push(...xs);
      });
      const wire = [...header, ...payload];
      expect(decoded(Layout.decode(widths(ws), list(wire)))).toEqual(fields);
      expect(decoded(Normative.decoding(widths(ws), list(wire)))).toEqual(fields);
    }
  }
});

test('layout rejects non-byte words, header gaps, backwards and out-of-range offsets', () => {
  const ws = [1, null, 1, null];
  const valid = [11, ...offset(10), 22, ...offset(12), 33, 44];
  const cases: number[][] = [];
  for (const first of [0, 9, 11, 13, 256, 65536, 16777216, 0xffffffff]) {
    const xs = [...valid]; xs.splice(1, 4, ...offset(first)); cases.push(xs);
  }
  for (const second of [0, 9, 13, 0xffffffff]) {
    const xs = [...valid]; xs.splice(6, 4, ...offset(second)); cases.push(xs);
  }
  for (let i = 0; i < valid.length; i++) { const xs = [...valid]; xs[i] = 256; cases.push(xs); }
  for (let n = 0; n < 10; n++) cases.push(valid.slice(0,n));
  for (const xs of cases) {
    expect(decoded(Layout.decode(widths(ws), list(xs)))).toBeNull();
    expect(decoded(Normative.decoding(widths(ws), list(xs)))).toBeNull();
  }
  expect(decoded(Layout.decode(widths([1]), list([1,2])))).toBeNull();
  expect(decoded(Normative.decoding(widths([1]), list([1,2])))).toBeNull();
});
