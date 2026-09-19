import {test, expect} from 'bun:test';
import Bits from '../../src/bit_packing.bend';
import I from '../../src/bitfields.bend';
import {bytes} from '../../tools/primitive_backend';

function bitsList(xs: boolean[]): any {
  let r: any={$:'Nil'};
  for(let i=xs.length-1;i>=0;i--) r={$:'Con',head:xs[i],tail:r};
  return r;
}
function reference(xs: boolean[], delimiter=false) {
  const bits=delimiter ? [...xs,true] : xs;
  const result=Array(Math.ceil(bits.length/8)).fill(0);
  bits.forEach((bit,i)=>{if(bit)result[Math.floor(i/8)] += 2**(i%8)});
  return result;
}

test('bit packing agrees with positional arithmetic for every octet and partial octet',()=>{
  for(let x=0;x<256;x++) {
    for(let n=0;n<=8;n++) {
      const bits=Array.from({length:n},(_,i)=>Boolean(x&(1<<i)));
      expect(bytes(Bits.pack(bitsList(bits)))).toEqual(reference(bits));
    }
  }
});

test('bit serializers preserve ordering, delimiter and capacity at byte/chunk boundaries',()=>{
  for(const n of [0,1,7,8,9,15,16,17,255,256,257,511,512,513,2048]) {
    for(const pattern of [0,1,2]) {
      const bits=Array.from({length:n},(_,i)=>pattern===0 ? false : pattern===1 ? true : (i*13%17)<8);
      const v=I.bitvector_serialize(BigInt(n),bitsList(bits));
      if(n===0) expect(v.$).toBe('None');
      else {
        expect(bytes(v.value)).toEqual(reference(bits));
        expect(bytes(v.value).length).toBe(Math.ceil(n/8));
      }
      for(const cap of [n,n+1,n+256]) {
        const l=I.bitlist_serialize(BigInt(cap),bitsList(bits));
        expect(bytes(l.value)).toEqual(reference(bits,true));
        expect(bytes(l.value).length).toBe(Math.floor(n/8)+1);
      }
      expect(I.bitvector_serialize(BigInt(n+1),bitsList(bits)).$).toBe('None');
      if(n>0) {
        expect(I.bitvector_serialize(BigInt(n-1),bitsList(bits)).$).toBe('None');
        expect(I.bitlist_serialize(BigInt(n-1),bitsList(bits)).$).toBe('None');
      }
    }
  }
});

function raw(xs: number[]): any {
  let r: any={$:'Nil'};
  for(let i=xs.length-1;i>=0;i--) r={$:'Con',head:xs[i],tail:r};
  return r;
}
function unpack(r: any): boolean[] {
  const out: boolean[]=[];
  while(r.$==='Con') {out.push(r.head);r=r.tail;}
  return out;
}

test('bitvector decoding rejects every noncanonical one-octet unused-bit pattern',()=>{
  for(let n=1;n<=8;n++) {
    for(let x=0;x<256;x++) {
      const actual=I.bitvector_deserialize(BigInt(n),raw([x]));
      if(x>=2**n) expect(actual.$).toBe('None');
      else {
        expect(unpack(actual.value)).toEqual(Array.from({length:n},(_,i)=>Boolean(x&(1<<i))));
        expect(bytes(I.bitvector_serialize(BigInt(n),actual.value).value)).toEqual([x]);
      }
    }
  }
  for(const n of [0,1,7,8,9,255,256,257]) {
    const length=Math.ceil(n/8);
    for(const count of [length+1,Math.max(0,length-1)]) {
      expect(I.bitvector_deserialize(BigInt(n),raw(Array(count).fill(0))).$).toBe('None');
    }
    for(const invalid of [256,65536,0xffffffff]) {
      expect(I.bitvector_deserialize(BigInt(n),raw(Array(Math.max(1,length)).fill(invalid))).$).toBe('None');
    }
  }
});

test('bitlist delimiter decoding covers all final octets and capacities',()=>{
  for(let x=0;x<256;x++) {
    for(let capacity=0;capacity<=8;capacity++) {
      const actual=I.bitlist_deserialize(BigInt(capacity),raw([x]));
      const length=x===0 ? -1 : Math.floor(Math.log2(x));
      if(length<0 || length>capacity) expect(actual.$).toBe('None');
      else {
        expect(unpack(actual.value)).toEqual(Array.from({length},(_,i)=>Boolean(x&(1<<i))));
        expect(bytes(I.bitlist_serialize(BigInt(capacity),actual.value).value)).toEqual([x]);
      }
    }
  }
  for(const xs of [[],[0],[1,0],[255,0],[0,0],[256],[0xffffffff],[256,1]]) {
    expect(I.bitlist_deserialize(4096n,raw(xs)).$).toBe('None');
  }
  expect(unpack(I.bitlist_deserialize(0n,raw([1])).value)).toEqual([]);
  expect(I.bitlist_deserialize(0n,raw([2])).$).toBe('None');
});

test('bit decoders preserve values and canonical bytes across byte and chunk boundaries',()=>{
  for(const n of [1,7,8,9,15,16,17,255,256,257,511,512,513,2048]) {
    const bits=Array.from({length:n},(_,i)=>(i*13%17)<8);
    const vector=reference(bits);
    const list=reference(bits,true);
    const v=I.bitvector_deserialize(BigInt(n),raw(vector));
    const l=I.bitlist_deserialize(BigInt(n+9),raw(list));
    expect(unpack(v.value)).toEqual(bits);
    expect(unpack(l.value)).toEqual(bits);
    expect(bytes(I.bitvector_serialize(BigInt(n),v.value).value)).toEqual(vector);
    expect(bytes(I.bitlist_serialize(BigInt(n+9),l.value).value)).toEqual(list);
    expect(I.bitlist_deserialize(BigInt(n-1),raw(list)).$).toBe('None');
    expect(I.bitlist_deserialize(BigInt(n+9),raw([...list,0])).$).toBe('None');
  }
});
