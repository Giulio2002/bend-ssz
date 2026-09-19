import {test,expect} from 'bun:test';
import Actual from '../../src/schema.bend';
import Spec from '../../spec/compatibility.bend';
import {schema} from '../../tools/generic_transport';
const leaf=()=>({$:'Leaf'});
const step=(child:any)=>({$:'Step',child});
const fork=(left:any,right:any)=>({$:'Fork',left,right});
const pair={$:'Pair'};
const u={kind:'uint',size:1};
const pc=(names:string[],active:number[])=>({kind:'progressive_container',fields:names.map(n=>[n,u]),active});
const derives=(d:any,a:any,b:any)=>Spec.derives(d,pair,schema(a),schema(b));

test('independent compatibility derivations require shared names to retain slots',()=>{
 const a=pc(['x'],[1]),extension=pc(['x','y'],[1,1]);
 const overlap=step(fork(leaf(),leaf()));
 expect(derives(overlap,a,extension)).toBe(true);
 expect(derives(overlap,extension,a)).toBe(true);
 // Skipping an absent slot cannot justify moving the same field name.
 expect(derives(step(step(leaf())),a,pc(['x'],[0,1]))).toBe(false);
 expect(derives(step(step(leaf())),a,pc(['y'],[0,1]))).toBe(true);
 expect(derives(leaf(),a,extension)).toBe(false);
});

test('compatible-union derivations compare every cross-option pair',()=>{
 const a=pc(['x'],[1]),b=pc(['x','y'],[1,1]);
 const overlap=step(fork(leaf(),leaf()));
 const left={kind:'compatible_union',selectors:[1,2],options:[a,b]};
 const right={kind:'compatible_union',selectors:[7],options:[a]};
 const all=step(fork(fork(leaf(),leaf()),fork(fork(overlap,leaf()),leaf())));
 expect(derives(all,left,right)).toBe(true);
 expect(derives(all,left,{...right,options:[pc(['x'],[0,1])]})).toBe(false);
 expect(derives(step(leaf()),left,right)).toBe(false);
});

test('ordinary union identity and basic aliases have distinct compatibility rules',()=>{
 const a={kind:'union',options:[pc(['x'],[1])]},b={kind:'union',options:[pc(['x','y'],[1,1])]};
 expect(derives(leaf(),a,a)).toBe(true);
 expect(derives(leaf(),a,b)).toBe(false);
 expect(derives(step(step(fork(leaf(),leaf()))),a,b)).toBe(false);
 expect(derives(leaf(),{kind:'bytes',length:2},{kind:'vector',element:u,length:2})).toBe(true);
 expect(derives(leaf(),{kind:'bytes',length:2},{kind:'vector',element:{kind:'uint',size:2},length:2})).toBe(false);
});

test('identity compatibility keeps malformed public schemas rejected',()=>{
 const uint=schema(u);
 const named={$:'Named',name:'x',schema:uint};
 expect(Actual.identical(named,named)).toBe(true);
 expect(Actual.valid(named)).toBe(false);
 const malformed=schema({kind:'compatible_union',selectors:[1,2],options:[u,{kind:'uint',size:2}]});
 // The identity rule applies to structural comparison; public legality still
 // requires compatibility between all distinct options.
 expect(Actual.compatible(malformed,malformed)).toBe(true);
 expect(Actual.valid(malformed)).toBe(false);
 const legal=schema(pc(['x'],[1]));
 expect(Actual.compatible_go(1n,0,legal,legal)).toBe(true);
 expect(Actual.valid(legal)).toBe(true);
});
