import {test,expect} from 'bun:test';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import M from '../../src/limits.bend';
import B from '../../src/byte_root.bend';
import F from '../../types/fulu_bytes.bend';
import {list,bytes,execute} from '../../tools/primitive_backend';
function cs(xs:number[][]) {return xs.reduceRight((tail,head)=>({$:'Con',head:list(head),tail}),{$:'Nil'} as any);}
function hash(a:number[],b:number[]){return [...createHash('sha256').update(Buffer.from([...a,...b])).digest()];}
function root(xs:number[][],limit:number) {
  let n=1;while(n<limit)n*=2;
  let level=xs.map(x=>[...x]);while(level.length<n)level.push(Array(32).fill(0));
  while(level.length>1){const next:number[][]=[];for(let i=0;i<level.length;i+=2)next.push(hash(level[i],level[i+1]));level=next;}
  return level[0];
}
function byteRoot(value:number[]) {
  const chunks:number[][]=[];
  for(let i=0;i<value.length;i+=32){const part=value.slice(i,i+32);chunks.push([...part,...Array(32-part.length).fill(0)]);}
  return root(chunks,chunks.length);
}
test('minimal depth and arbitrary-limit roots match independent power rounding',()=>{
  for(let limit=0;limit<=130;limit++) {
    let cap=1,depth=0;while(cap<limit){cap*=2;depth++;}
    expect(M.depth(BigInt(limit))).toBe(BigInt(depth));
    for(const count of [...new Set([0,Math.min(1,limit),Math.floor(limit/2),limit])]) {
      const chunks=Array.from({length:count},(_,i)=>Array.from({length:32},(_,j)=>(i*11+j*41)&255));
      expect(bytes(M.merkleize(BigInt(limit),cs(chunks)).value)).toEqual(root(chunks,limit));
      expect(bytes(M.merkleize_default(cs(chunks)).value)).toEqual(root(chunks,count));
    }
    expect(M.merkleize(BigInt(limit),cs(Array.from({length:limit+1},()=>Array(32).fill(0)))).$).toBe('None');
  }
  for(const limit of [3,5,7,9,17,33]) {
    let cap=1;while(cap<limit)cap*=2;
    expect(M.merkleize(BigInt(limit),cs(Array.from({length:cap},()=>Array(32).fill(0)))).$).toBe('None');
  }
});
test('large limits pad virtually and malformed chunks remain semantic rejection',()=>{
  let zero=Array(32).fill(0);
  for(let depth=0;depth<=40;depth++) {
    const limit=1n<<BigInt(depth);
    expect(M.depth(limit)).toBe(BigInt(depth));
    expect(bytes(M.merkleize(limit,cs([])).value)).toEqual(zero);
    if(depth>1)expect(M.depth(limit-1n)).toBe(BigInt(depth));
    expect(M.depth(limit+1n)).toBe(BigInt(depth+1));
    zero=hash(zero,zero);
  }
  for(const size of [0,1,31,33])expect(M.merkleize(5n,cs([Array(size).fill(0)])).$).toBe('None');
  for(const bad of [256,65536,0xffffffff]) {
    const chunk=Array(32).fill(0);chunk[31]=bad;
    expect(M.merkleize(5n,cs([chunk])).$).toBe('None');
    expect(M.merkleize_default(cs([chunk])).$).toBe('None');
  }
});
test('all frozen fixed-byte names have exact bounds, roots and invalid-value rejection',()=>{
  const schemas=JSON.parse(readFileSync(new URL('../../schemas/fulu_mainnet.json',import.meta.url),'utf8'));
  const seen=new Set<string>();
  for(const [name,s] of Object.entries(schemas) as [string,any][]) {
    if(s.kind!=='bytes')continue;
    const tag=F[`${name}.tag`](); seen.add(tag.$);
    expect(F[`${name}.length`]()).toBe(BigInt(s.length));
    const value=Array.from({length:s.length},(_,i)=>(i*19+7)&255);
    const result=F[`${name}.hash_tree_root`](list(value));
    expect(result.$).toBe('Some');expect(bytes(result.value)).toEqual(byteRoot(value));expect(bytes(result.value).length).toBe(32);
    expect(F[`${name}.hash_tree_root`](list(value.slice(1))).$).toBe('None');
    expect(F[`${name}.hash_tree_root`](list([...value,0])).$).toBe('None');
    value[value.length-1]=256;expect(F[`${name}.hash_tree_root`](list(value)).$).toBe('None');
  }
  expect(seen.size).toBe(24);
  expect(B.hash_tree_root(0n,list([])).$).toBe('None');
});
test('byte vector transport preserves raw domains and distinguishes infrastructure errors',()=>{
  expect(execute({type:'byte_vector',length:'3',action:'root',value:[1,2,3]})).toEqual({kind:'accepted',value:byteRoot([1,2,3])});
  expect(execute({type:'byte_vector',length:'3',action:'decode',bytes:[1,256,3]})).toEqual({kind:'rejected'});
  expect(()=>execute({type:'byte_vector',length:'-1',action:'decode',bytes:[]})).toThrow();
  expect(()=>execute({type:'byte_vector',length:'3',action:'decode',bytes:['1',2,3]})).toThrow();
});
