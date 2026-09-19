import {executeGeneric} from './generic_transport';
import ByteList from '../src/byte_list.bend';
/** Transport only. Codec/root work is performed by the actual Bend APIs. */
import P from '../src/primitives.bend';
import B from '../src/bytes.bend';
import Root from '../src/byte_root.bend';
import BitFields from '../src/bitfields.bend';
import BitRoot from '../src/bit_root.bend';
import {readFileSync} from 'node:fs';
const widths: Record<number, string> = {8:'U8',16:'U16',32:'U32Width',64:'U64',128:'U128',256:'U256'};
export function list(xs: number[]): any {
  return xs.reduceRight((tail, head) => ({$: 'Con', head, tail}), {$:'Nil'} as any);
}
export function bytes(xs: any): number[] {
  const result: number[] = [];
  while (xs.$ === 'Con') {
    if (!Number.isInteger(xs.head) || xs.head < 0 || xs.head > 255) throw Error('non-byte output');
    result.push(xs.head); xs = xs.tail;
  }
  if (xs.$ !== 'Nil') throw Error('bad list output');
  return result;
}
export function integer(v: string): any {
  let n = BigInt(v);
  if (n < 0n || n >= (1n << 256n)) throw Error('integer transport out of range');
  const out: any = {$:'UInt'};
  for (const k of 'abcdefgh') { out[k] = Number(n & 0xffffffffn); n >>= 32n; }
  return P.make_uint(...[...'abcdefgh'].map(k => out[k]));
}
export function decimal(v: any): string {
  if (v.$ !== 'UInt') throw Error('bad integer output');
  let n = 0n;
  for (const k of [...'abcdefgh'].reverse()) {
    if (!Number.isInteger(v[k]) || v[k] < 0 || v[k] > 0xffffffff) throw Error('bad limb');
    n = (n << 32n) + BigInt(v[k]);
  }
  return n.toString();
}
function optional(v: any, convert: (x:any)=>any): any {
  if (v.$ === 'None') return {kind:'rejected'};
  if (v.$ !== 'Some') throw Error('bad optional output');
  return {kind:'accepted', value:convert(v.value)};
}
export function bitList(xs: boolean[]): any {
  return xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'} as any);
}
export function bitValues(xs: any): boolean[] {
  const result: boolean[]=[];
  while(xs.$==='Con') {
    if(typeof xs.head!=='boolean') throw Error('bad bit output');
    result.push(xs.head);xs=xs.tail;
  }
  if(xs.$!=='Nil') throw Error('bad bit list output');
  return result;
}
export function execute(req: any): any {
  if(req.type==='generic') return executeGeneric(req);
  if(req.type==='bitvector' || req.type==='bitlist') {
    if(!['decode','serialize','root'].includes(req.action)) throw Error('unknown action');
    if(typeof req.length!=='string' || !/^(0|[1-9][0-9]*)$/.test(req.length)) throw Error('bad bitvector length transport');
    const n=BigInt(req.length);
    if(n >= (1n<<48n)) throw Error('bitvector length exceeds runtime Nat transport range');
    if(req.action==='decode') {
      if(!Array.isArray(req.bytes) || !req.bytes.every((x:any)=>Number.isInteger(x) && x>=0 && x<=0xffffffff)) throw Error('bad byte transport');
      return optional((req.type==='bitvector' ? BitFields.bitvector_deserialize(n,list(req.bytes)) : BitFields.bitlist_deserialize(n,list(req.bytes))),bitValues);
    }
    if(!Array.isArray(req.value) || !req.value.every((x:any)=>typeof x==='boolean')) throw Error('bad bitvector value transport');
    const bits=bitList(req.value);
    const vector=req.type==='bitvector';
    return optional(req.action==='serialize' ? (vector ? BitFields.bitvector_serialize(n,bits) : BitFields.bitlist_serialize(n,bits)) : (vector ? BitRoot.bitvector_hash_tree_root(n,bits) : BitRoot.bitlist_hash_tree_root(n,bits)),bytes);
  }
  if (req.type === 'byte_vector' || req.type === 'byte_list') {
    if (!['decode','serialize','root'].includes(req.action)) throw Error('unknown action');
    if (typeof req.length !== 'string' || !/^(0|[1-9][0-9]*)$/.test(req.length)) throw Error('bad vector length transport');
    const n=BigInt(req.length);
    if (n >= (1n<<48n)) throw Error('vector length exceeds runtime Nat transport range');
    const input=req.action==='decode' ? req.bytes : req.value;
    if (!Array.isArray(input) || !input.every((x:any)=>Number.isInteger(x) && x>=0 && x<=0xffffffff)) throw Error('bad vector transport');
    const xs=list(input);
    if(req.type==='byte_list') return optional(req.action==='decode' ? ByteList.deserialize(n,xs) : req.action==='serialize' ? ByteList.serialize(n,xs) : ByteList.hash_tree_root(n,xs),bytes);
    return optional(req.action==='decode' ? B.vector_deserialize(n,xs) :
      req.action==='serialize' ? B.vector_serialize(n,xs) : Root.hash_tree_root(n,xs),bytes);
  }
  const bool = req.type === 'boolean';
  const name = widths[req.bits];
  if (!bool && !name) throw Error('unsupported primitive');
  const w = bool ? null : P[`width${req.bits}`]();
  if (req.action === 'decode') {
    if (!Array.isArray(req.bytes) || !req.bytes.every((x:any)=>Number.isInteger(x) && x >= 0 && x <= 0xffffffff)) throw Error('bad byte transport');
    const xs = list(req.bytes);
    return bool ? optional(P.boolean_deserialize(xs), v => {
      if (typeof v !== 'boolean') throw Error('bad boolean');
      return v;
    }) : optional(P.uint_deserialize(w, xs), decimal);
  }
  if (!['serialize','root'].includes(req.action)) throw Error('unknown action');
  if (bool) {
    if (typeof req.value !== 'boolean') throw Error('bad boolean transport');
    const v = req.value;
    return {kind:'accepted', value:bytes(req.action === 'root' ? P.boolean_root(v) : P.boolean_serialize(v))};
  }
  const v = integer(req.value);
  return optional(req.action === 'root' ? P.uint_root(w,v) : P.uint_serialize(w,v), bytes);
}
if (import.meta.main) {
  const requests = JSON.parse(readFileSync(0, 'utf8'));
  const results = requests.map((req:any) => {
    try { return execute(req); }
    catch (error) { return {kind:'backend_error', error:String(error)}; }
  });
  process.stdout.write(JSON.stringify(results));
}
