/** Diagnostic only: exposes existing decoder phases without changing semantics. */
import Decode from '../src/decode.bend';
import Schema from '../src/schema.bend';
import Lists from '../src/lists.bend';
import Fulu from '../types/fulu.bend';
import {readFileSync} from 'node:fs';
const input=readFileSync(process.argv[2]);
const started=performance.now();
function point(phase:string){console.log(JSON.stringify({phase,elapsed_ms:performance.now()-started,...process.memoryUsage(),max_rss:process.resourceUsage().maxRSS}));}
point('raw_input');
let xs:any={$:'Nil'};
for(let i=input.length-1;i>=0;i--)xs={$:'Con',head:input[i],tail:xs};
point('linked_input');
const schema=Fulu['BeaconState.schema']();
const weight=Schema.weight(schema);
point('schema');
const fuel=(2n+weight)*(2n+BigInt(input.length));
const raw=Decode.decode_go(fuel,schema,xs,{$:'Nil'},{$:'EmptyItems'});
if(raw.$!=='Some')throw Error('raw decoder rejected');
point('generic_decode');
const checked=Decode.canonical(raw,schema,xs);
if(checked.$!=='Some')throw Error('canonical decoder rejected');
point('canonical_reencode');
const typed=Fulu['BeaconState.from_ssz'](checked.value);
if(typed.$!=='Some')throw Error('typed conversion rejected');
point('typed_conversion');
(globalThis as any).__memory_profile_sink={xs,raw,checked,typed};
