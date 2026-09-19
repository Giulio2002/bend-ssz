import Fulu from '../types/fulu.bend';
import {readFileSync} from 'node:fs';
const [file, expectedHex, repetitions] = process.argv.slice(2);
const input = readFileSync(file);
const count=Number(repetitions);
function linked(xs:Uint8Array):any {let t:any={$:'Nil'};for(let i=xs.length-1;i>=0;i--)t={$:'Con',head:xs[i],tail:t};return t;}
function unwrap(x:any):any {if(x.$!=='Some')throw Error('Bend rejected');return x.value;}
function bytes(xs:any):Buffer {const a:number[]=[];while(xs.$==='Con'){if(!Number.isInteger(xs.head)||xs.head<0||xs.head>255)throw Error('bad byte');a.push(xs.head);xs=xs.tail;}if(xs.$!=='Nil')throw Error('bad list');return Buffer.from(a);}
const encoded=linked(input);
const state=unwrap(Fulu['BeaconState.deserialize'](encoded));
if(!bytes(unwrap(Fulu['BeaconState.serialize'](state))).equals(input))throw Error('bytes mismatch');
if(bytes(unwrap(Fulu['BeaconState.hash_tree_root'](state))).toString('hex')!==expectedHex)throw Error('root mismatch');
const ops={deserialize:()=>Fulu['BeaconState.deserialize'](encoded),serialize:()=>Fulu['BeaconState.serialize'](state),hash_tree_root:()=>Fulu['BeaconState.hash_tree_root'](state)};
const operations:any={};
for(const [name,fn]of Object.entries(ops)){
 unwrap(fn()); // explicit untimed warmup, in addition to correctness checks
 const samples=[];
 for(let i=0;i<count;i++){const start=performance.now();const out=fn();samples.push((performance.now()-start)*1e6);unwrap(out);(globalThis as any).__benchmark_sink=out;}
 operations[name]={ns_per_op:samples,iterations:samples.map(()=>1)};
 console.error(`${name}: ${samples.map(n=>(n/1e6).toFixed(2)).join(', ')} ms`);
}
console.log(JSON.stringify({implementation:'bend/compiled-js/bun',bytes:input.length,verified:true,operations,bun:Bun.version}));
