import {test, expect} from 'bun:test';
import {createHash} from 'node:crypto';
import B from '../../src/bytes.bend';
import M from '../../src/merkle.bend';
import F from '../../types/fulu_bytes.bend';
import {list, bytes} from '../../tools/primitive_backend';
import {readFileSync} from 'node:fs';

test('every frozen fixed-byte alias preserves exact bytes and rejects malformed input', () => {
  const schemas = JSON.parse(readFileSync(new URL('../../schemas/fulu_mainnet.json', import.meta.url),'utf8'));
  for (const [name,schema] of Object.entries(schemas) as [string,any][]) {
    if (schema.kind !== 'bytes') continue;
    const n=schema.length;
    const value=Array.from({length:n},(_,i)=>(i*73+19)&255);
    const xs=list(value);
    expect(F[`${name}.valid`](xs)).toBe(true);
    expect(bytes(F[`${name}.serialize`](xs).value)).toEqual(value);
    expect(bytes(F[`${name}.deserialize`](xs).value)).toEqual(value);
    expect(F[`${name}.deserialize`](list(value.slice(1))).$).toBe('None');
    expect(F[`${name}.serialize`](list([...value,0])).$).toBe('None');
    value[n-1]=256;
    expect(F[`${name}.deserialize`](list(value)).$).toBe('None');
  }
  expect(B.vector_serialize(0n,list([])).$).toBe('None');
  expect(B.vector_deserialize(0n,list([])).$).toBe('None');
});

test('single-chunk pack appends zeros and rejects overflow or non-bytes', () => {
  for(let n=0;n<=32;n++) {
    const value=Array.from({length:n},(_,i)=>(i*41+7)&255);
    const result=B.pack_chunk(list(value));
    expect(bytes(result.value)).toEqual([...value,...Array(32-n).fill(0)]);
    expect(bytes(result.value).length).toBe(32);
  }
  expect(B.pack_chunk(list(Array(33).fill(0))).$).toBe('None');
  expect(B.pack_chunk(list(Array(131072).fill(0))).$).toBe('None');
  for(const bad of [256,65536,0xffffffff]) expect(B.pack_chunk(list([bad])).$).toBe('None');
});

test('binary Merkle node uses exact chunks and independent SHA-256', () => {
  for(const salt of [0,1,17,255]) {
    const left=Array.from({length:32},(_,i)=>(salt+i)&255);
    const right=Array.from({length:32},(_,i)=>(salt+3*i)&255);
    const actual=bytes(M.hash_pair(list(left),list(right)).value);
    const expected=createHash('sha256').update(Buffer.from([...left,...right])).digest();
    expect(Buffer.from(actual)).toEqual(expected);
    expect(actual.length).toBe(32);
  }
  for(const n of [0,1,31,33,64]) {
    expect(M.hash_pair(list(Array(n).fill(0)),list(Array(32).fill(0))).$).toBe('None');
    expect(M.hash_pair(list(Array(32).fill(0)),list(Array(n).fill(0))).$).toBe('None');
  }
  const bad=Array(32).fill(0);bad[31]=256;
  expect(M.hash_pair(list(bad),list(Array(32).fill(0))).$).toBe('None');
});

test('byte-vector serialized-size bound is strict uint32 without allocating enormous values',()=>{
  for(const n of [0n,1n,131072n,(1n<<32n)-1n]) expect(B.size_fits(n)).toBe(true);
  for(const n of [1n<<32n,(1n<<32n)+1n,(1n<<48n)-1n]) expect(B.size_fits(n)).toBe(false);
});
