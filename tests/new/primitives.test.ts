import {test, expect} from 'bun:test';
import P from '../../src/primitives.bend';
import F from '../../types/fulu_primitives.bend';
import {execute, list, integer, decimal, bytes} from '../../tools/primitive_backend';

const widths = [8,16,32,64,128,256];
const accepted = (value:any) => ({kind:'accepted', value});
const rejected = {kind:'rejected'};
function le(n:bigint, count:number): number[] {
  return Array.from({length:count}, (_,i)=>Number((n >> BigInt(8*i)) & 255n));
}
test('integer boundaries and every individual bit agree with independent arithmetic', () => {
  for (const bits of widths) {
    const values = [0n, 1n, (1n<<BigInt(bits))-1n,
      ...Array.from({length:bits}, (_,i)=>1n<<BigInt(i))];
    for (const n of values) {
      const input = {type:'uint', bits, value:n.toString()};
      expect(execute({...input, action:'serialize'})).toEqual(accepted(le(n,bits/8)));
      expect(execute({...input, action:'root'})).toEqual(accepted(le(n,32)));
      expect(execute({type:'uint', bits, action:'decode', bytes:le(n,bits/8)})).toEqual(accepted(n.toString()));
    }
    if (bits < 256) {
      const input = {type:'uint', bits, value:(1n<<BigInt(bits)).toString()};
      expect(execute({...input,action:'serialize'})).toEqual(rejected);
      expect(execute({...input,action:'root'})).toEqual(rejected);
    }
  }
});

test('decoders reject wrong lengths and non-byte U32 inputs at every position', () => {
  for (const bits of widths) {
    const decode = (bs:number[]) => execute({type:'uint',bits,action:'decode',bytes:bs});
    for (const length of [0,bits/8-1,bits/8+1,64]) expect(decode(Array(length).fill(0))).toEqual(rejected);
    for (let i=0; i<bits/8; i++) {
      for (const invalid of [256,65536,0xffffffff]) {
        const xs = Array(bits/8).fill(0); xs[i]=invalid;
        expect(decode(xs)).toEqual(rejected);
      }
    }
  }
});

test('boolean canonical values and full byte rejection domain', () => {
  for (const v of [false,true]) {
    expect(execute({type:'boolean',action:'serialize',value:v})).toEqual(accepted([+v]));
    expect(execute({type:'boolean',action:'root',value:v})).toEqual(accepted([+v,...Array(31).fill(0)]));
  }
  for (let b=0; b<258; b++) {
    expect(execute({type:'boolean',action:'decode',bytes:[b]})).toEqual(b<2 ? accepted(b===1) : rejected);
  }
  for (const xs of [[],[0,0],[1,0],[0xffffffff]]) expect(execute({type:'boolean',action:'decode',bytes:xs})).toEqual(rejected);
});

test('all named Fulu primitive entry points are usable and enforce their ranges', () => {
  const names: Record<string,number> = {
    uint8:8,uint32:32,uint64:64,uint256:256,Slot:64,Epoch:64,Gwei:64,
    CommitteeIndex:64,ValidatorIndex:64,NodeID:256,SubnetID:64,Ether:64,
    ParticipationFlags:8,WithdrawalIndex:64,BlobIndex:64,CellIndex:64,
    CommitmentIndex:64,RowIndex:64,ColumnIndex:64,CustodyIndex:64};
  for (const [name,bits] of Object.entries(names)) {
    const n=(1n<<BigInt(bits))-1n;
    const v=integer(n.toString());
    expect(F[`${name}.valid`](v)).toBe(true);
    expect(bytes(F[`${name}.serialize`](v).value)).toEqual(le(n,bits/8));
    expect(decimal(F[`${name}.deserialize`](list(le(n,bits/8))).value)).toBe(n.toString());
    expect(bytes(F[`${name}.hash_tree_root`](v).value)).toEqual(le(n,32));
    if (bits<256) expect(F[`${name}.valid`](integer((n+1n).toString()))).toBe(false);
  }
  expect(bytes(F['boolean.serialize'](true))).toEqual([1]);
});

test('Bend width constructor bridge preserves every width', () => {
  for (const bits of widths) expect(P.width(P[`width${bits}`]())).toBe(BigInt(bits/8));
});
