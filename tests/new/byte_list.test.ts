import {test,expect} from 'bun:test';
import {createHash} from 'node:crypto';
import I from '../../src/byte_list.bend';
import T from '../../types/fulu_transaction.bend';
import {bytes,list,execute} from '../../tools/primitive_backend';
const hash=(a:number[],b:number[])=>[...createHash('sha256').update(Buffer.from(a)).update(Buffer.from(b)).digest()];
function reference(capacity:number, data:number[]) {
  let nodes:number[][]=[];
  for(let i=0;i<data.length;i+=32) nodes.push([...data.slice(i,i+32),...Array(Math.max(0,i+32-data.length)).fill(0)]);
  let zero=Array(32).fill(0),depth=0,size=1;
  while(size<Math.ceil(capacity/32)){size*=2;depth++;}
  for(let d=0;d<depth;d++) {
    const next:number[][]=[];
    for(let i=0;i<nodes.length;i+=2)next.push(hash(nodes[i],nodes[i+1]??zero));
    nodes=next;zero=hash(zero,zero);
  }
  const length=Buffer.alloc(32);length.writeBigUInt64LE(BigInt(data.length));
  return hash(nodes[0]??zero,[...length]);
}
test('byte lists enforce capacity and canonical identity, with independent roots',()=>{
  for(const cap of [0,1,31,32,33,63,64,65,1024,1073741824]) {
    for(const n of [...new Set([0,Math.min(cap,1),Math.min(cap,31),Math.min(cap,32),Math.min(cap,33),Math.min(cap,130)])]) {
      const data=Array.from({length:n},(_,i)=>(i*61+29)%256),xs=list(data);
      expect(bytes(I.serialize(BigInt(cap),xs).value)).toEqual(data);
      expect(bytes(I.deserialize(BigInt(cap),xs).value)).toEqual(data);
      expect(bytes(I.hash_tree_root(BigInt(cap),xs).value)).toEqual(reference(cap,data));
      expect(execute({type:'byte_list',length:String(cap),action:'root',value:data})).toEqual({kind:'accepted',value:reference(cap,data)});
    }
    for(const invalid of [[256],[0,0xffffffff]]) {
      expect(I.serialize(BigInt(cap),list(invalid)).$).toBe('None');
      expect(I.deserialize(BigInt(cap),list(invalid)).$).toBe('None');
      expect(I.hash_tree_root(BigInt(cap),list(invalid)).$).toBe('None');
    }
    if(cap<2000) expect(I.deserialize(BigInt(cap),list(Array(cap+1).fill(0))).$).toBe('None');
  }
});
test('frozen Transaction wrapper uses exact mainnet capacity and actual codec/root',()=>{
  expect(T['Transaction.capacity']()).toBe(1073741824n);
  for(const data of [[],[0],[255,0,1],Array.from({length:100},(_,i)=>i)]) {
    expect(T['Transaction.valid'](list(data))).toBe(true);
    expect(bytes(T['Transaction.serialize'](list(data)).value)).toEqual(data);
    expect(bytes(T['Transaction.deserialize'](list(data)).value)).toEqual(data);
    expect(bytes(T['Transaction.hash_tree_root'](list(data)).value)).toEqual(reference(1073741824,data));
  }
  expect(T['Transaction.valid'](list([256]))).toBe(false);
  expect(T['Transaction.deserialize'](list([256])).$).toBe('None');
});
