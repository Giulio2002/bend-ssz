import {test,expect} from 'bun:test';
import Spec from '../../spec/fulu_schemas.bend';
import {schema} from '../../tools/generic_transport';
import frozen from '../../schemas/fulu_mainnet.json';

test('independent schema constants preserve all frozen names, fields and capacities',()=>{
  const names=Object.keys(frozen);
  expect(names.length).toBe(109);
  for(const name of names) expect(Spec[name]()).toEqual(schema(frozen[name]));
});
