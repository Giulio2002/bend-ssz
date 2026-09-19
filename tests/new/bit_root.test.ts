import {test,expect} from 'bun:test';
import {createHash} from 'node:crypto';
import I from '../../src/bit_root.bend';
import {bitList,bytes,execute} from '../../tools/primitive_backend';
function reference(bits:boolean[]) {
  const data=Array(Math.ceil(bits.length/8)).fill(0);
  bits.forEach((b,i)=>{if(b)data[i>>3]|=1<<(i%8);});
  const chunks:number[][]=[];
  for(let i=0;i<data.length;i+=32) chunks.push([...data.slice(i,i+32),...Array(Math.max(0,i+32-data.length)).fill(0)]);
  let count=1;while(count<Math.ceil(bits.length/256))count*=2;
  while(chunks.length<count)chunks.push(Array(32).fill(0));
  while(chunks.length>1) {
    const next:number[][]=[];
    for(let i=0;i<chunks.length;i+=2)next.push([...createHash('sha256').update(Buffer.from([...chunks[i],...chunks[i+1]])).digest()]);
    chunks.splice(0,chunks.length,...next);
  }
  return chunks[0];
}
test('bitvector roots match independent packing and Merkleization at capacity boundaries',()=>{
  for(const n of [1,7,8,9,255,256,257,511,512,513,767,768,769,1023,1024,1025,2048]) {
    expect(I.chunk_limit(BigInt(n))).toBe(BigInt(Math.ceil(n/256)));
    for(const pattern of [0,1,2]) {
      const bits=Array.from({length:n},(_,i)=>pattern===0 ? false : pattern===1 ? true : (i*17+3)%11<5);
      const result=I.bitvector_hash_tree_root(BigInt(n),bitList(bits));
      expect(result.$).toBe('Some');
      expect(bytes(result.value)).toEqual(reference(bits));
      expect(bytes(result.value).length).toBe(32);
    }
    expect(I.bitvector_hash_tree_root(BigInt(n),bitList(Array(n-1).fill(false))).$).toBe('None');
    expect(I.bitvector_hash_tree_root(BigInt(n),bitList(Array(n+1).fill(false))).$).toBe('None');
  }
  expect(I.chunk_limit(0n)).toBe(0n);
  expect(I.bitvector_hash_tree_root(0n,bitList([])).$).toBe('None');
});
test('bitvector transport uses actual APIs and preserves errors as infrastructure failures',()=>{
  expect(execute({type:'bitvector',length:'9',action:'decode',bytes:[1,1]})).toEqual({kind:'accepted',value:[true,false,false,false,false,false,false,false,true]});
  expect(execute({type:'bitvector',length:'9',action:'decode',bytes:[1,2]})).toEqual({kind:'rejected'});
  expect(execute({type:'bitvector',length:'1',action:'decode',bytes:[256]})).toEqual({kind:'rejected'});
  expect(execute({type:'bitvector',length:'1',action:'serialize',value:[true]})).toEqual({kind:'accepted',value:[1]});
  expect(execute({type:'bitvector',length:'1',action:'root',value:[true]})).toEqual({kind:'accepted',value:[1,...Array(31).fill(0)]});
  expect(()=>execute({type:'bitvector',length:'1',action:'root',value:[1]})).toThrow();
  expect(()=>execute({type:'bitvector',length:String(1n<<48n),action:'root',value:[]})).toThrow();
});

test('bitlist roots omit the delimiter and mix exact lengths independently',()=>{
  for(const capacity of [0,1,7,8,9,255,256,257,511,512,513,1024,2048]) {
    for(const n of [...new Set([0,Math.floor(capacity/2),capacity])]) {
      const bits=Array.from({length:n},(_,i)=>(i*13+7)%9<4);
      // Right padding data to capacity yields the same data tree, but the
      // mixed length must remain n rather than the padded vector length.
      const data=reference([...bits,...Array(capacity-n).fill(false)]);
      const length=Buffer.alloc(32);length.writeBigUInt64LE(BigInt(n));
      const expected=[...createHash('sha256').update(Buffer.from(data)).update(length).digest()];
      const result=I.bitlist_hash_tree_root(BigInt(capacity),bitList(bits));
      expect(result.$).toBe('Some');
      expect(bytes(result.value)).toEqual(expected);
      expect(execute({type:'bitlist',length:String(capacity),action:'root',value:bits})).toEqual({kind:'accepted',value:expected});
    }
    expect(I.bitlist_hash_tree_root(BigInt(capacity),bitList(Array(capacity+1).fill(false))).$).toBe('None');
  }
  expect(execute({type:'bitlist',length:'0',action:'serialize',value:[]})).toEqual({kind:'accepted',value:[1]});
  expect(execute({type:'bitlist',length:'0',action:'decode',bytes:[1]})).toEqual({kind:'accepted',value:[]});
  for(const xs of [[],[0],[0,0],[2],[256]])
    expect(execute({type:'bitlist',length:'0',action:'decode',bytes:xs})).toEqual({kind:'rejected'});
});
