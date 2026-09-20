import Fulu from '../types/fulu.bend';
import {readFileSync} from 'node:fs';
const input=readFileSync(process.argv[2]);
let xs:any={$:'Nil'};
for(let i=input.length-1;i>=0;i--)xs={$:'Con',head:input[i],tail:xs};
const start=performance.now();
const result=Fulu['BeaconState.deserialize'](xs);
if(result.$!=='Some')throw Error('full typed decode rejected');
(globalThis as any).__memory_sink=result;
const measurement={elapsed_ms:performance.now()-start,max_rss_kib:process.resourceUsage().maxRSS,...process.memoryUsage()};
// Correctness is checked AFTER recording peak; it cannot precompute the decode.
const encoded=Fulu['BeaconState.serialize'](result.value);
if(encoded.$!=='Some')throw Error('serialize rejected decoded state');
let t=encoded.value,i=0;
while(t.$==='Con'){if(i>=input.length||t.head!==input[i++])throw Error('roundtrip mismatch');t=t.tail;}
if(t.$!=='Nil'||i!==input.length)throw Error('roundtrip length mismatch');
console.log(JSON.stringify({...measurement,verified:true}));
