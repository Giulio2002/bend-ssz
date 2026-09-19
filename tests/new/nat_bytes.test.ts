import {test,expect} from 'bun:test';
import I from '../../src/nat_bytes.bend';
import {bytes} from '../../tools/primitive_backend';
test('exact-width natural encoding never narrows through U32 and rejects overflow',()=>{
  for(const width of [0,1,2,3,4,5,6,7,8,32]) {
    for(const n of [0n,1n,255n,256n,65535n,65536n,(1n<<32n)-1n,1n<<32n,(1n<<40n)+257n,(1n<<48n)-1n]) {
      const encoded=I.encode(BigInt(width),n);
      if(n >= (1n<<BigInt(width*8))) expect(encoded.$).toBe('None');
      else {
        expect(encoded.$).toBe('Some');
        const expected=Array.from({length:width},(_,i)=>Number((n>>BigInt(i*8))&255n));
        expect(bytes(encoded.value)).toEqual(expected);
      }
    }
  }
});
