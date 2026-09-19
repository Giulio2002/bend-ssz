"""Generate structural successful-root scope proofs, never fixture evidence."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'proofs/root_scope.bend'
s=p.read_text().split('# Generated structural public scope composition.')[0]
extra='''import ../src/ssz.bend as API
import ../src/schema.bend as Schema
import ../src/codec.bend as Codec
import ../src/lists.bend as Lists
import ../src/byte_root.bend as ByteRoot
import ../src/byte_list.bend as ByteList
import ./byte_root.bend as ByteRootLaws
import ./byte_list.bend as ByteListLaws
import ./bit_root.bend as BitRootLaws
import ./bit_list_root.bend as BitListLaws
'''
if 'import ../src/schema.bend as Schema' not in s:s=s.replace('import Base\n','import Base\n'+extra,1)
s+='''# Generated structural public scope composition.
law boolean_scope:
  for +b: Bool
  {SP.byte_scope(32n, P.boolean_root(b)) == True{} : Bool}
def boolean_scope(b):
  match b:
    case False{}: {==}
    case True{}: {==}

law roots_go_scope:
  for +value: T.Value
  for +schema: T.Schema
  for +acc: +List<+List<U32>>
  for +size: Nat
  for valid: {Chunks.chunks_domain(acc) == True{} : Bool}
  roots_scope(I.roots_go(value, schema, acc, Cache.zeros(size)))
def roots_go_scope(value, schema, acc, size, valid):
  match value:
'''
ctors={'Boolean':0,'Unsigned':1,'ByteVector':1,'ByteList':1,'BitVector':1,'BitList':1,'Vector':2,'ListOf':2,'Container':2,'Union':1,'Null':0,'Chain':2,'End':0,'Repeat':1,'Named':2,'ProgressiveList':1,'ProgressiveBits':0,'ProgressiveContainer':3,'CompatibleUnion':2}
cache='Cache.zeros(size)'
def roots(v,ty,acc='[]'):return f'I.roots_go({v}, {ty}, {acc}, {cache})'
def single(expr,proof):return f'single_scope({expr}, {proof})'
def merkle(chunks,lim,prog='False{}'):return f'I.merkle({chunks}, {lim}, {prog}, {cache})'
def single_merkle(chunks,lim):return single(merkle(chunks,lim),f'merkle_scope({chunks}, {lim}, False{{}}, size)')
def length_mixed(expr,n):return single(f'I.length_mix({expr}, Some{{{n}}})', f'mix_scope({expr}, Length.encode(32n, {n}))')
def sequence_chunks(ty):return f'I.choose_chunks(Schema.basic_size(x0), u => Codec.unwrap(Codec.encode(T.Sequence{{items}}, {ty})), u => {roots("items","T.Repeat{x0}")})'
branches={
 'T.BooleanValue{b}':{'Boolean':'V.and_true(SP.byte_scope(32n, P.boolean_root(b)), True{}, boolean_scope(b), {==})'},
 'T.UnsignedValue{v}':{'Unsigned':single('P.uint_root(x0, v)','integer_scope(x0, v)')},
 'T.BytesValue{xs}':{'ByteVector':single('ByteRoot.hash_tree_root(x0, xs)','ByteRootLaws.hash_tree_root_scope(x0, xs)'), 'ByteList':single('ByteList.hash_tree_root(x0, xs)','ByteListLaws.root_scope(x0, xs)')},
 'T.BitsValue{bits}':{'BitVector':single('Bits.bitvector_hash_tree_root(x0, bits)','BitRootLaws.bitvector_root_scope(x0, bits)'), 'BitList':single('Bits.bitlist_hash_tree_root(x0, bits)','BitListLaws.bitlist_root_scope(x0, bits)'), 'ProgressiveBits':length_mixed(f'Cache.progressive(Bits.chunks(bits), {cache})','Lists.length(Bool, bits)')},
 'T.NullValue{}':{'Null':'V.and_true(SP.byte_scope(32n, P.pad(32n, [])), True{}, padded_scope([], {==}), {==})'},
 'T.EmptyItems{}':{k:'reverse_scope(acc, [], valid, {==})' for k in ['End','Repeat']},
 'T.Items{h, t}':{},
 'T.Sequence{items}':{},
 'T.Selected{selector, v}':{},
}
for ctor,tail in [('Chain','x1'),('Repeat','T.Repeat{x0}')]:
 branches['T.Items{h, t}'][ctor]=f'accumulate_scope({roots("h","x0")}, acc, next => {roots("t",tail,"next")}, roots_go_scope(h, x0, [], size, {{==}}), valid, next => scope => roots_go_scope(t, {tail}, next, size, scope))'
branches['T.Sequence{items}']['Vector']=single_merkle(sequence_chunks('T.Vector{x0, x1}'),'I.count_limit(Schema.basic_size(x0), x1)')
branches['T.Sequence{items}']['ListOf']=length_mixed(merkle(sequence_chunks('T.ListOf{x0, x1}'),'I.count_limit(Schema.basic_size(x0), x1)'),'Codec.count(items)')
branches['T.Sequence{items}']['ProgressiveList']=length_mixed(merkle(sequence_chunks('T.ProgressiveList{x0}'),'0n','True{}'),'Codec.count(items)')
branches['T.Sequence{items}']['Container']=single_merkle(roots('items','x1'),'Schema.count(x1)')
branches['T.Sequence{items}']['ProgressiveContainer']=f'active_scope({roots("items","x1")}, x2, {cache})'
for ctor,option in [('Union','Schema.get(x0, U32.to_nat(selector))'),('CompatibleUnion','Codec.selected_schema(x0, x1, selector)')]:
 expr=f'I.unwrap({roots("v","s")})'
 branches['T.Selected{selector, v}'][ctor]=f'option_scope({option}, s => I.selector_mix({expr}, selector), s => selector_scope({expr}, selector))'
for value,cases in branches.items():
 s+=f'    case {value}:\n      match schema:\n'
 for ctor,n in ctors.items():s+='        case T.'+ctor+'{'+', '.join('x'+str(i) for i in range(n))+'}: '+cases.get(ctor,'Unit{}')+'\n'
s+='''
law roots_public_scope:
  for +schema: T.Schema
  for +value: T.Value
  roots_scope(I.roots(value, schema))
def roots_public_scope(schema, value):
  roots_go_scope(value, schema, [], Bool.pick(Nat, Nat.is_lt(Schema.weight(schema), 24n), Schema.weight(schema), 24n), {==})

law root_gate_scope:
  for +ok: Bool
  for +schema: T.Schema
  for +value: T.Value
  Tree.result_scope(I.gate(ok, u => I.unwrap(I.roots(value, schema))))
def root_gate_scope(ok, schema, value):
  match ok:
    case False{}: Unit{}
    case True{}: unwrap_scope(I.roots(value, schema), roots_public_scope(schema, value))

law hash_tree_root_scope:
  for +schema: T.Schema
  for +value: T.Value
  Tree.result_scope(I.hash_tree_root(schema, value))
def hash_tree_root_scope(schema, value): root_gate_scope(Codec.valid(schema, value), schema, value)

law accepted_root_scope:
  for +schema: T.Schema
  for +value: T.Value
  for +root: +List<U32>
  for accepted: {I.hash_tree_root(schema, value) == Some{root} : Maybe<&2, +List<U32>>}
  {SP.byte_scope(32n, root) == True{} : Bool}
def accepted_root_scope(schema, value, root, accepted):
  %accepted : Tree.result_scope(_)
  hash_tree_root_scope(schema, value)
'''
s+='''
# The exported standalone API is definitionally the root implementation above.
law public_root_scope:
  for +schema: T.Schema
  for +value: T.Value
  Tree.result_scope(API.hash_tree_root(schema, value))
def public_root_scope(schema, value): hash_tree_root_scope(schema, value)

law public_root_length:
  for +schema: T.Schema
  for +value: T.Value
  {Basic.lengths(API.hash_tree_root(schema, value)) == Basic.expected_root_length(API.hash_tree_root(schema, value)) : Maybe<&2, Nat>}
def public_root_length(schema, value):
  Tree.result_length(API.hash_tree_root(schema, value), public_root_scope(schema, value))
'''
if 'import ../src/ssz.bend as API' not in s:s=s.replace('import Base\n','import Base\nimport ../src/ssz.bend as API\n',1)
p.write_text(s)
