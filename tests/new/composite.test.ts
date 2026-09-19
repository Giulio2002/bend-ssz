import {test,expect} from 'bun:test';
import {createHash} from 'node:crypto';
import {executeGeneric as run,schema} from '../../tools/generic_transport';
import API from '../../src/ssz.bend';
import Spec from '../../spec/layout.bend';
import Layout from '../../src/layout.bend';
const u=(size:number)=>({kind:'uint',size});
const list=(element:any,limit:number)=>({kind:'list',element,limit});
const container=(fields:any[])=>({kind:'container',fields});
const enc=(s:any,value:any)=>run({schema:s,value,action:'serialize'});
const dec=(s:any,bytes:number[])=>run({schema:s,bytes,action:'decode'});
const root=(s:any,value:any)=>run({schema:s,value,action:'root'});
const yes=(value:any)=>({kind:'accepted',value});
const no={kind:'rejected'};
const zero=Array(32).fill(0);
const hash=(a:number[],b:number[])=>[...createHash('sha256').update(Buffer.from([...a,...b])).digest()];
test('nested fixed and variable layout and canonical boundaries',()=>{
 const s=container([['a',u(2)],['b',list(u(1),4)],['c',list(u(2),2)]]);
 const v={a:'258',b:['7','8'],c:[]};const bs=[2,1,10,0,0,0,12,0,0,0,7,8];
 expect(enc(s,v)).toEqual(yes(bs));expect(dec(s,bs)).toEqual(yes(v));
 for(const i of [0,9,11,13,255]){const bad=[...bs];bad[2]=i;expect(dec(s,bad)).toEqual(no);}
 const backwards=[...bs];backwards[6]=9;expect(dec(s,backwards)).toEqual(no);
 expect(dec(s,[...bs,1])).toEqual(no);
 expect(enc(s,{...v,b:['1','2','3','4','5']})).toEqual(no);
});
test('variable element offset table accepts empty members and rejects gaps',()=>{
 const s=list(list(u(1),3),3); const bs=[12,0,0,0,12,0,0,0,13,0,0,0,9];
 expect(enc(s,[[],['9'],[]])).toEqual(yes(bs));expect(dec(s,bs)).toEqual(yes([[],['9'],[]]));
 for(const bs of [[0,0,0,0],[3,0,0,0],[8,0,0,0],[4,0,0,0,1,2,3,4]])expect(dec(s,bs)).toEqual(no);
 expect(dec(s,[])).toEqual(yes([]));
});
test('unions selectors, null payloads and exact root composition',()=>{
 const s={kind:'union',options:[{kind:'none'},u(2)]};
 expect(enc(s,{selector:0,value:null})).toEqual(yes([0]));expect(dec(s,[0,0])).toEqual(no);
 expect(dec(s,[2])).toEqual(no);expect(dec(s,[])).toEqual(no);
 expect(root(s,{selector:0,value:null})).toEqual(yes(hash(zero,zero)));
 expect(root(s,{selector:1,value:'258'})).toEqual(yes(hash([2,1,...zero.slice(2)],[1,...zero.slice(1)])));
});
test('progressive empty and single chunk roots follow independent SHA composition',()=>{
 const s={kind:'progressive_list',element:u(1)};
 expect(root(s,[])).toEqual(yes(hash(zero,zero)));
 const chunk=[7,...zero.slice(1)];
 expect(root(s,['7'])).toEqual(yes(hash(hash(zero,chunk),[1,...zero.slice(1)])));
});
test('compatible progressive schemas preserve shared field positions',()=>{
 const p=(active:number[])=>({kind:'progressive_container',fields:[['x',u(1)]],active});
 const s={kind:'compatible_union',selectors:[1,2],options:[p([1]),p([0,1])]};
 expect(API.type_valid(schema(s))).toBe(false);
 expect(API.type_valid(schema({kind:'compatible_union',selectors:[1,2],options:[{kind:'bytes',length:2},{kind:'vector',element:u(1),length:2}]}))).toBe(true);
});
test('ordinary unions do not inherit compatibility of distinct progressive types',()=>{
 const p=(fields:any[],active:number[])=>({kind:'progressive_container',fields,active});
 const a=p([['x',u(1)]],[1]);
 const b=p([['x',u(1)],['y',u(1)]],[1,1]);
 expect(API.type_valid(schema({kind:'compatible_union',selectors:[1,2],options:[a,b]}))).toBe(true);
 expect(API.type_valid(schema({kind:'compatible_union',selectors:[1,2],options:[{kind:'union',options:[a]},{kind:'union',options:[b]}]}))).toBe(false);
});
test('65536-element vectors serialize and decode without recursive stack growth',()=>{
 const s={kind:'vector',element:u(1),length:65536};
 const value=Array(65536).fill('0'),bytes=Array(65536).fill(0);
 expect(enc(s,value)).toEqual(yes(bytes));expect(dec(s,bytes)).toEqual(yes(value));
});
