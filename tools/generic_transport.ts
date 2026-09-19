function tag(x:any):string{return x.$.split('.').at(-1);}
/** Representation conversion only: every SSZ operation runs in Bend. */
import API from '../src/ssz.bend';
import P from '../src/primitives.bend';
import Fulu from '../types/fulu.bend';
export function linked(xs:any[]):any{return xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});}
function array(xs:any):any[]{const out=[];while(xs.$==='Con'){out.push(xs.head);xs=xs.tail;}if(xs.$!=='Nil')throw Error('bad list');return out;}
function str(s:string):string{return s;}
function nat(n:any):bigint{if(!/^(0|[1-9][0-9]*)$/.test(String(n)))throw Error('invalid natural');const b=BigInt(n);if(b>=(1n<<48n))throw Error('schema Nat exceeds runtime');return b;}
function chain(xs:any[]):any{return xs.reduceRight((tail,head)=>API.chain(head,tail),API.end());}
export function schema(s:any):any {
 switch(s.kind){
  case 'bool':return API.boolean_type();
  case 'uint':if(![1,2,4,8,16,32].includes(s.size))throw Error('bad width');return API.unsigned_type(P[`width${s.size*8}`]());
  case 'bytes':return API.byte_vector_type(nat(s.length));
  case 'bytelist':return API.byte_list_type(nat(s.limit));
  case 'bits':return API.bit_vector_type(nat(s.length));
  case 'bitlist':return API.bit_list_type(nat(s.limit));
  case 'vector':return API.vector_type(schema(s.element),nat(s.length));
  case 'list':return API.list_type(schema(s.element),nat(s.limit));
  case 'container':return API.container_type(linked(s.fields.map((f:any)=>str(f[0]))),chain(s.fields.map((f:any)=>schema(f[1]))));
  case 'union':return API.union_type(chain(s.options.map(schema)));
  case 'none':return API.null_type();
  case 'progressive_list':return API.progressive_list_type(schema(s.element));
  case 'progressive_bits':return API.progressive_bits_type();
  case 'progressive_container':return API.progressive_container_type(linked(s.fields.map((f:any)=>str(f[0]))),chain(s.fields.map((f:any)=>schema(f[1]))),linked(s.active.map((b:any)=>{if(b!==0&&b!==1)throw Error('bad active bit');return !!b;})));
  case 'compatible_union':return API.compatible_union_type(linked(s.selectors.map((n:any)=>{if(!Number.isInteger(n)||n<0||n>0xffffffff)throw Error('selector transport');return n;})),chain(s.options.map(schema)));
  default:throw Error('unknown schema kind');
 }
}
function uint(n:any):any{if(typeof n!=='string'||!/^\d+$/.test(n))throw Error('uint transport');let b=BigInt(n);if(b<0n||b>=(1n<<256n))throw Error('uint transport overflow');const limbs=[];for(let i=0;i<8;i++){limbs.push(Number(b&0xffffffffn));b>>=32n;}return P.make_uint(...limbs);}
function decimal(v:any):string{let n=0n;for(const k of [...'abcdefgh'].reverse()){if(!Number.isInteger(v[k])||v[k]<0||v[k]>0xffffffff)throw Error('limb output');n=(n<<32n)+BigInt(v[k]);}return String(n);}
function items(xs:any[]):any{return xs.reduceRight((tail,head)=>API.items(head,tail),API.empty_items());}
function values(xs:any):any[]{const out=[];while(tag(xs)==='Items'){out.push(xs.head);xs=xs.tail;}if(tag(xs)!=='EmptyItems')throw Error('bad items');return out;}
function selected(s:any,n:number):any{if(s.kind==='union')return s.options[n];return s.options[s.selectors.indexOf(n)];}
export function value(s:any,v:any):any{
 switch(s.kind){
  case 'bool':if(typeof v!=='boolean')throw Error('boolean transport');return API.boolean_value(v);
  case 'uint':return API.unsigned_value(uint(v));
  case 'bytes':case 'bytelist':if(!Array.isArray(v)||!v.every(x=>Number.isInteger(x)&&x>=0&&x<=0xffffffff))throw Error('bytes transport');return API.bytes_value(linked(v));
  case 'bits':case 'bitlist':case 'progressive_bits':if(!Array.isArray(v)||!v.every(x=>typeof x==='boolean'))throw Error('bits transport');return API.bits_value(linked(v));
  case 'vector':case 'list':case 'progressive_list':if(!Array.isArray(v))throw Error('sequence transport');return API.sequence_value(items(v.map(x=>value(s.element,x))));
  case 'container':case 'progressive_container':if(!v||Array.isArray(v)||Object.keys(v).length!==s.fields.length||s.fields.some((f:any)=>!Object.hasOwn(v,f[0])))throw Error('container fields');return API.sequence_value(items(s.fields.map((f:any)=>value(f[1],v[f[0]]))));
  case 'none':if(v!==null)throw Error('null transport');return API.null_value();
  case 'union':case 'compatible_union':if(!v||!Number.isInteger(v.selector)||v.selector<0||v.selector>0xffffffff)throw Error('selector transport');const opt=selected(s,v.selector);if(!opt)throw Error('selected value has no type');return API.selected_value(v.selector,value(opt,v.value));
  default:throw Error('unknown value kind');
 }
}
export function output(s:any,v:any):any{
 switch(s.kind){
  case 'bool':if(tag(v)!=='BooleanValue')throw Error('bool output');return v.value;
  case 'uint':if(tag(v)!=='UnsignedValue')throw Error('uint output');return decimal(v.value);
  case 'bytes':case 'bytelist':if(tag(v)!=='BytesValue')throw Error('bytes output');return array(v.value);
  case 'bits':case 'bitlist':case 'progressive_bits':if(tag(v)!=='BitsValue')throw Error('bits output');return array(v.value);
  case 'vector':case 'list':case 'progressive_list':if(tag(v)!=='Sequence')throw Error('sequence output');return values(v.items).map(x=>output(s.element,x));
  case 'container':case 'progressive_container':if(tag(v)!=='Sequence')throw Error('container output');const vs=values(v.items);if(vs.length!==s.fields.length)throw Error('field count');return Object.fromEntries(s.fields.map((f:any,i:number)=>[f[0],output(f[1],vs[i])]));
  case 'none':if(tag(v)!=='NullValue')throw Error('null output');return null;
  case 'union':case 'compatible_union':if(tag(v)!=='Selected')throw Error('union output');const opt=selected(s,v.selector);if(!opt)throw Error('unknown returned selector');return {selector:v.selector,value:output(opt,v.value)};
 }
 throw Error('unknown output schema');
}
export function executeGeneric(req:any):any{
 const s=schema(req.schema);
 let r:any;
 if(req.action==='decode'){
  if(!Array.isArray(req.bytes)||!req.bytes.every((x:any)=>Number.isInteger(x)&&x>=0&&x<=0xffffffff))throw Error('byte input transport');
  if(req.name){
   if(typeof Fulu[req.name+'.deserialize']!=='function')throw Error('unknown named API');
   r=Fulu[req.name+'.deserialize'](linked(req.bytes));
   if(r.$==='Some')r={...r,value:Fulu[req.name+'.to_ssz'](r.value)};
  }else r=API.deserialize(s,linked(req.bytes));
 } else if(req.action==='serialize'||req.action==='root'){
  const v=value(req.schema,req.value);
  if(req.name){
   if(typeof Fulu[req.name+'.from_ssz']!=='function')throw Error('unknown named API');
   const typed=Fulu[req.name+'.from_ssz'](v);
   if(typed.$==='None')return {kind:'rejected'};
   if(typed.$!=='Some')throw Error('invalid named conversion');
   r=Fulu[req.name+(req.action==='serialize'?'.serialize':'.hash_tree_root')](typed.value);
  }else r=req.action==='serialize'?API.serialize(s,v):API.hash_tree_root(s,v);
 } else throw Error('unknown action');
 if(r.$==='None')return {kind:'rejected'};
 if(r.$!=='Some')throw Error('invalid result');
 if(req.action==='decode')return {kind:'accepted',value:output(req.schema,r.value)};
 const bs=array(r.value);if(!bs.every(x=>Number.isInteger(x)&&x>=0&&x<256))throw Error('non-byte output');
 return {kind:'accepted',value:bs};
}
