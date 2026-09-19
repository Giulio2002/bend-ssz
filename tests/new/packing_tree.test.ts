import {test, expect} from 'bun:test';
import {createHash} from 'node:crypto';
import P from '../../src/packing.bend';
import T from '../../src/tree.bend';
import {list, bytes} from '../../tools/primitive_backend';

function chunks(value: any): number[][] {
  const result: number[][]=[];
  while(value.$==='Con') { result.push(bytes(value.head)); value=value.tail; }
  if(value.$!=='Nil') throw Error('malformed chunk list');
  return result;
}
function chunkList(value: number[][]) {
  return value.reduceRight((tail, head)=>({$:'Con',head:list(head),tail}),{$:'Nil'} as any);
}
function hash(a: number[],b: number[]): number[] {
  return [...createHash('sha256').update(Buffer.from([...a,...b])).digest()];
}
function materializedTree(value: number[][],depth: number): number[] {
  let level=[...value];
  while(level.length < 2**depth) level.push(Array(32).fill(0));
  while(level.length>1) {
    const next:number[][]=[];
    for(let i=0;i<level.length;i+=2) next.push(hash(level[i],level[i+1]));
    level=next;
  }
  return level[0];
}

test('general packing independently partitions and pads all boundary lengths',()=>{
  for(const n of [...Array.from({length:100},(_,i)=>i),127,128,129,2047,2048,2049,131072]) {
    const value=Array.from({length:n},(_,i)=>(i*57+21)&255);
    const expected:number[][]=[];
    for(let i=0;i<n;i+=32) {
      const part=value.slice(i,i+32);
      expected.push([...part,...Array(32-part.length).fill(0)]);
    }
    const result=P.pack(list(value));
    expect(result.$).toBe('Some');
    const actual=chunks(result.value);
    expect(actual).toEqual(expected);
    expect(actual.every(c=>c.length===32)).toBe(true);
  }
  for(const bad of [256,65536,0xffffffff]) {
    for(const index of [0,31,32,63,64,2047]) {
      const value=Array(2048).fill(0);value[index]=bad;
      expect(P.pack(list(value)).$).toBe('None');
    }
  }
});

test('depth trees match materialized independent trees and reject capacity overflow',()=>{
  for(let depth=0;depth<=7;depth++) {
    const capacity=2**depth;
    for(const count of [...new Set([0,1,Math.floor(capacity/2),capacity-1,capacity])]) {
      const value=Array.from({length:count},(_,i)=>Array.from({length:32},(_,j)=>(i*37+j*13)&255));
      const result=T.merkleize_at_depth(BigInt(depth),chunkList(value));
      expect(result.$).toBe('Some');
      expect(bytes(result.value)).toEqual(materializedTree(value,depth));
      expect(bytes(result.value).length).toBe(32);
    }
    const overflow=Array.from({length:capacity+1},()=>Array(32).fill(0));
    expect(T.merkleize_at_depth(BigInt(depth),chunkList(overflow)).$).toBe('None');
  }
});

test('trees reject malformed chunks, including residual malformed inputs',()=>{
  for(const size of [0,1,31,33,64]) {
    expect(T.merkleize_at_depth(3n,chunkList([Array(size).fill(0)])).$).toBe('None');
  }
  for(const bad of [256,65536,0xffffffff]) {
    for(const index of [0,15,31]) {
      const value=Array(32).fill(0);value[index]=bad;
      expect(T.merkleize_at_depth(0n,chunkList([Array(32).fill(0),value])).$).toBe('None');
      expect(T.merkleize_at_depth(3n,chunkList([value])).$).toBe('None');
    }
  }
});

test('virtual padding handles depth 64 and full Blob-size packing',()=>{
  const leaf=Array.from({length:32},(_,i)=>i);
  let expected=leaf,zero=Array(32).fill(0);
  for(let depth=0;depth<=64;depth++) {
    expect(bytes(T.merkleize_at_depth(BigInt(depth),chunkList([leaf])).value)).toEqual(expected);
    expect(bytes(T.merkleize_at_depth(BigInt(depth),chunkList([])).value)).toEqual(zero);
    expected=hash(expected,zero);zero=hash(zero,zero);
  }
  const value=Array.from({length:131072},(_,i)=>(i*17+3)&255);
  const packed=P.pack(list(value)).value;
  expect(bytes(T.merkleize_at_depth(12n,packed).value)).toEqual(materializedTree(chunks(packed),12));
});
