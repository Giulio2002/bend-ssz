import {test,expect} from 'bun:test';
import Fulu from '../../types/fulu.bend';
import {schema,executeGeneric} from '../../tools/generic_transport';
import frozen from '../../schemas/fulu_mainnet.json';

test('all 109 named schemas match frozen fields, order and bounds',()=>{
 expect(Object.keys(frozen).length).toBe(109);
 for(const [name,s] of Object.entries(frozen)){
  expect(Fulu[name+'.schema']()).toEqual(schema(s));
  for(const api of ['valid','serialize','deserialize','hash_tree_root','from_ssz','to_ssz'])expect(typeof Fulu[name+'.'+api]).toBe('function');
 }
});
test('named Fork requests invoke typed conversion, serialization and decoding',()=>{
 const value={previous_version:[1,2,3,4],current_version:[5,6,7,8],epoch:'42'};
 const bytes=[1,2,3,4,5,6,7,8,42,0,0,0,0,0,0,0];
 const req={type:'generic',name:'Fork',schema:frozen.Fork};
 expect(executeGeneric({...req,action:'serialize',value})).toEqual({kind:'accepted',value:bytes});
 expect(executeGeneric({...req,action:'decode',bytes})).toEqual({kind:'accepted',value});
 expect(executeGeneric({...req,action:'decode',bytes:bytes.slice(1)})).toEqual({kind:'rejected'});
});

test('closed name index is exactly the frozen inventory and dispatches to the same schemas',()=>{
 const fs=require('fs');
 const src=fs.readFileSync(new URL('../../types/fulu.bend',import.meta.url),'utf8');
 const decl=src.slice(src.indexOf('type Name is Data:'),src.indexOf('def Name.Value('));
 const ctors=[...decl.matchAll(/^  Name_(\w+)\{\}$/gm)].map(m=>m[1]);
 expect(ctors).toEqual(Object.keys(frozen));
 for(const [name,s] of Object.entries(frozen)){
  expect(Fulu['Name.schema']({$:'Name_'+name})).toEqual(schema(s));
  const aliases=['schema','to_ssz','from_ssz','valid','serialize','decode_result','deserialize','hash_tree_root'];
  for(const api of aliases)expect(src).toContain(`def ${name}.${api}(`);
  expect(src).toContain(`def ${name}.serialize(`);
  expect(src).toMatch(new RegExp(`def ${name}\\.serialize\\([^)]*\\)[^:]*: Name\\.serialize\\(Name_${name}\\{\\}, v\\)`));
  expect(src).toMatch(new RegExp(`def ${name}\\.deserialize\\([^)]*\\)[^:]*: Name\\.deserialize\\(Name_${name}\\{\\}, xs\\)`));
  expect(src).toMatch(new RegExp(`def ${name}\\.hash_tree_root\\([^)]*\\)[^:]*: Name\\.hash_tree_root\\(Name_${name}\\{\\}, v\\)`));
 }
});
