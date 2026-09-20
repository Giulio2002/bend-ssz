"""Generate proofs/root_complete.bend: completeness of actual roots against the
independent relation (relation => the actual function returns exactly those
roots). Constructor enumeration only; no protocol inputs or fixtures."""
from pathlib import Path
import importlib.util, sys
spec = importlib.util.spec_from_file_location("gs", str(Path(__file__).with_name("generate_root_sound.py")))
gs = importlib.util.module_from_spec(spec); spec.loader.exec_module(gs)
SCHEMAS, VALUES, WIDTHS, FORESTS = gs.SCHEMAS, gs.VALUES, gs.WIDTHS, gs.FORESTS
NAMED, PROG_REST, pat, absurd, union_forest_absurd, pick = gs.NAMED, gs.PROG_REST, gs.pat, gs.absurd, gs.union_forest_absurd, gs.pick

HEADER = gs.HEADER.replace("Every successful actual recursive root result satisfies the independent\n# relational root semantics spec/root_relation.bend, for every value and every\n# cache size, under actual schema validation.",
  "Completeness: whenever the independent relational root semantics holds, the\n# actual recursive root function (every cache size) returns exactly those roots.").replace(
  "import ./root_steps.bend as G\n", "import ./root_steps.bend as G\nimport ../src/primitives.bend as IP\nimport ./root_complete_steps.bend as C\nimport ./root_sound.bend as RS\nimport ./byte_root.bend as PBV\nimport ./byte_list.bend as PBL\nimport ./bit_root.bend as PB\nimport ./bit_list_root.bend as PBLR\nimport ./integer_encoding.bend as IntegerRoot\nimport ./root_domain_steps.bend as Steps\n")


def main():
    out = [HEADER]
    out.append('''
def complete_goal(value: T.Value, schema: T.Schema, acc: +List<+List<U32>>, size: Nat, outs: +List<+List<U32>>) -> Type:
  match schema:
    case T.Chain{h, t}: {IR.roots_go(value, T.Chain{h, t}, acc, Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
    case T.End{}: {IR.roots_go(value, T.End{}, acc, Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
    case T.Repeat{e}: {IR.roots_go(value, T.Repeat{e}, acc, Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}
    case _: {IR.roots_go(value, schema, acc, Cache.zeros(size)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}
''')

    def view(name, statement, cases):
        out.append(statement)
        out.append("def %s:" % name)
        out.append("  match schema:")
        out.extend(cases)

    single_goal = lambda p: "{IR.roots_go(value, %s, [], Cache.zeros(size)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}" % p
    cases = []
    for n, k in SCHEMAS:
        p = pat(n, k, "s")
        cases.append("    case %s: %s" % (p, absurd(single_goal(p)) if n in FORESTS else "known"))
    view("head_view(schema, value, size, outs, legal, known)", '''
law head_view:
  for +schema: T.Schema
  for +value: T.Value
  for +size: Nat
  for +outs: +List<+List<U32>>
  for legal: {IS.valid_go(schema, False{}) == True{} : Bool}
  for known: complete_goal(value, schema, [], size, outs)
  {IR.roots_go(value, schema, [], Cache.zeros(size)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}''', cases)
    view("option_view(schema, value, size, outs, legal, known)", '''
law option_view:
  for +schema: T.Schema
  for +value: T.Value
  for +size: Nat
  for +outs: +List<+List<U32>>
  for legal: {DG.option_ok(schema) == True{} : Bool}
  for known: complete_goal(value, schema, [], size, outs)
  {IR.roots_go(value, schema, [], Cache.zeros(size)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}''', cases)
    fgoal = lambda p: "{IR.roots_go(value, %s, acc, Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}" % p
    cases = []
    for n, k in SCHEMAS:
        p = pat(n, k, "s") if n != "Union" else "T.Union{u0}"
        if n in ("Chain", "End"):
            cases.append("    case %s: known" % p)
        elif n == "Union":
            cases.append("    case %s:" % p)
            cases.append(union_forest_absurd(fgoal))
        else:
            cases.append("    case %s: %s" % (p, absurd(fgoal(p))))
    view("forest_view(schema, value, acc, size, outs, legal, known)", '''
law forest_view:
  for +schema: T.Schema
  for +value: T.Value
  for +acc: +List<+List<U32>>
  for +size: Nat
  for +outs: +List<+List<U32>>
  for legal: {IS.valid_go(schema, True{}) == True{} : Bool}
  for known: complete_goal(value, schema, acc, size, outs)
  {IR.roots_go(value, schema, acc, Cache.zeros(size)) == Some{List.reverse.go(&2, +List<U32>, acc, outs)} : Maybe<&2, +List<+List<U32>>>}''', cases)

    out.append('''
law complete:
  for +value: T.Value
  for +schema: T.Schema
  for +acc: +List<+List<U32>>
  for +size: Nat
  for +legal: {F.ok(schema) == True{} : Bool}
  for +outs: +List<+List<U32>>
  for rel: R.roots(value, schema, outs)
  complete_goal(value, schema, acc, size, outs)
def complete(value, schema, acc, size, legal, outs, rel):
  match value:''')
    CU = ["Nat.is_lt(0n, IS.count(s1))", "Nat.is_eq(Lists.length(U32, s0), IS.count(s1))", "IS.selectors_valid(s0, [])",
          "IS.valid_go(s1, True{})", "IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(s1)), 1, s1, s1)"]
    TABLE = "Cache.zeros(size)"
    for vn, vk in VALUES:
        out.append("    case %s:" % pat(vn, vk, "v"))
        out.append("      match schema:")
        for sn, sk in SCHEMAS:
            p = pat(sn, sk, "s")
            lines = None
            proof = None
            if vn == "BooleanValue" and sn == "Boolean":
                proof = "C.boolean_complete(v0, outs, rel)"
            elif vn == "UnsignedValue" and sn == "Unsigned":
                proof = "C.single_complete(IP.uint_root(s0, v0), SP.uint_hash_tree_root(s0, v0), outs, IntegerRoot.uint_hash_tree_root_correct(s0, v0), rel)"
            elif vn == "BytesValue" and sn == "ByteVector":
                lines = ["(+depth, (minimal, single)) = rel", "C.single_complete(IByteRoot.merkle_root(s0, v0), R.bytevector_at_depth(s0, depth, v0), outs, Steps.bytevector_root_correct(s0, v0, depth, minimal), single)"]
            elif vn == "BytesValue" and sn == "ByteList":
                lines = ["(+depth, (minimal, single)) = rel", "C.single_complete(IByteList.merkle_root(s0, v0), R.bytelist_at_depth(s0, depth, v0), outs, Steps.bytelist_root_correct(s0, depth, v0, minimal), single)"]
            elif vn == "BitsValue" and sn == "BitVector":
                lines = ["(+depth, (minimal, single)) = rel", "C.single_complete(IBits.bitvector_hash_tree_root(s0, v0), SBits.bitvector_at_depth(s0, depth, v0), outs, PB.bitvector_hash_tree_root_correct(s0, v0, depth, minimal), single)"]
            elif vn == "BitsValue" and sn == "BitList":
                lines = ["(+depth, (minimal, single)) = rel", "C.single_complete(IBits.bitlist_hash_tree_root(s0, v0), SBits.bitlist_at_depth(s0, depth, v0), outs, PBLR.bitlist_root_correct(s0, depth, v0, minimal), single)"]
            elif vn == "BitsValue" and sn == "ProgressiveBits":
                proof = "C.progressive_bits_complete(v0, size, outs, rel)"
            elif vn == "NullValue" and sn == "Null":
                proof = "C.null_complete(outs, rel)"
            elif vn == "EmptyItems" and sn in ("End", "Repeat"):
                proof = "C.empty_complete(acc, outs, rel)"
            elif vn == "Items" and sn == "Chain":
                vs = "V.and_left(IS.valid_go(s0, False{}), IS.valid_go(s1, True{}), legal)"
                vr = "V.and_right(IS.valid_go(s0, False{}), IS.valid_go(s1, True{}), legal)"
                proof = ("C.chain_complete(v0, v1, s0, s1, acc, size, outs, "
                         "head => rh => head_view(s0, v0, size, head, %s, complete(v0, s0, [], size, Shape.ok_single(s0, %s), head, rh)), "
                         "prior => tail => rt => forest_view(s1, v1, prior, size, tail, %s, complete(v1, s1, prior, size, Shape.ok_forest(s1, %s), tail, rt)), rel)" % (vs, vs, vr, vr))
            elif vn == "Items" and sn == "Repeat":
                proof = ("C.repeat_complete(v0, v1, s0, acc, size, outs, "
                         "head => rh => head_view(s0, v0, size, head, legal, complete(v0, s0, [], size, Shape.ok_single(s0, legal), head, rh)), "
                         "prior => tail => rt => complete(v1, T.Repeat{s0}, prior, size, legal, tail, rt), rel)")
            elif vn == "Sequence" and sn in ("Vector", "ListOf", "ProgressiveList"):
                if sn == "Vector":
                    ve = "V.and_right(Nat.is_lt(0n, s1), IS.valid_go(s0, False{}), legal)"
                    schema_expr = "T.Vector{s0, s1}"; limit = "s1"; prog = "False{}"; length = "None{}"; ilength = None
                elif sn == "ListOf":
                    ve = "legal"; schema_expr = "T.ListOf{s0, s1}"; limit = "s1"; prog = "False{}"; length = "Some{SC.count(v0)}"; ilength = "Some{IC.count(v0)}"
                else:
                    ve = "legal"; schema_expr = "T.ProgressiveList{s0}"; limit = "0n"; prog = "True{}"; length = "Some{SC.count(v0)}"; ilength = "Some{IC.count(v0)}"
                enc = "u => IR.basic_bytes(v0, s0)"
                comp = "u => IR.roots_go(v0, T.Repeat{s0}, [], %s)" % TABLE
                enc_eq = "Steps.basic_bytes_correct(v0, s0)"
                comp_ok = "chunks => rc => complete(v0, T.Repeat{s0}, [], size, %s, chunks, rc)" % ve
                seq = ("C.sequence_complete(R.basic_size(s0), %s, %s, R.basic_bytes(v0, s0), chunks => R.roots(v0, T.Repeat{s0}, chunks), %s, %s, %s, size, %s, %s, outs, rel)"
                       % (enc, comp, limit, prog, length, enc_eq, comp_ok))
                ilimit = "0n" if sn == "ProgressiveList" else "IR.count_limit(_, %s)" % limit
                if ilength is None:
                    gt = "{IR.single(IR.merkle(IR.choose_chunks(_, %s, %s), %s, %s, %s)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}" % (enc, comp, ilimit, prog, TABLE)
                else:
                    gt = "{IR.single(IR.length_mix(IR.merkle(IR.choose_chunks(_, %s, %s), %s, %s, %s), %s)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}" % (enc, comp, ilimit, prog, TABLE, ilength)
                lines = ["%%Equal.sym(Maybe<&2, Nat>, IS.basic_size(s0), R.basic_size(s0), RS.basic_size_correct(s0)) : %s" % gt]
                if ilength is not None:
                    il2 = "0n" if sn == "ProgressiveList" else "IR.count_limit(R.basic_size(s0), %s)" % limit
                    g2 = "{IR.single(IR.length_mix(IR.merkle(IR.choose_chunks(R.basic_size(s0), %s, %s), %s, %s, %s), Some{_})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}" % (enc, comp, il2, prog, TABLE)
                    lines.append("%%Equal.sym(Nat, IC.count(v0), SC.count(v0), Counts.count_correct(v0)) : %s" % g2)
                if sn == "ProgressiveList":
                    g3 = "{IR.single(IR.length_mix(IR.merkle(IR.choose_chunks(R.basic_size(s0), %s, %s), _, %s, %s), Some{SC.count(v0)})) == Some{outs} : Maybe<&2, +List<+List<U32>>>}" % (enc, comp, prog, TABLE)
                    lines.append("%%RS.zero_limit(R.basic_size(s0)) : %s" % g3)
                lines.append(seq)
            elif vn == "Sequence" and sn == "Container":
                vf = "V.and_right(%s, IS.valid_go(s1, True{}), legal)" % NAMED
                proof = ("C.container_complete(s0, v0, s1, size, RS.count_correct(s1), outs, "
                         "chunks => rc => forest_view(s1, v0, [], size, chunks, %s, complete(v0, s1, [], size, Shape.ok_forest(s1, %s), chunks, rc)), rel)" % (vf, vf))
            elif vn == "Sequence" and sn == "ProgressiveContainer":
                rest = "Bool.and(IS.valid_go(s1, True{}), %s)" % PROG_REST
                vf = "V.and_left(IS.valid_go(s1, True{}), %s, V.and_right(%s, %s, legal))" % (PROG_REST, NAMED, rest)
                tail = "V.and_right(IS.valid_go(s1, True{}), %s, V.and_right(%s, %s, legal))" % (PROG_REST, NAMED, rest)
                AR = ["Nat.is_le(Lists.length(Bool, s2), 256n)", "IS.ends_active(s2, False{})", "Nat.is_eq(IS.active_count(s2, 0n), IS.count(s1))"]
                bound = "ValidatorSound.active_length(s2, %s)" % pick(AR, 0, tail)
                proof = ("C.active_complete(s0, v0, s1, s2, size, %s, outs, "
                         "chunks => rc => forest_view(s1, v0, [], size, chunks, %s, complete(v0, s1, [], size, Shape.ok_forest(s1, %s), chunks, rc)), rel)" % (bound, vf, vf))
            elif vn == "Selected" and sn in ("Union", "CompatibleUnion"):
                if sn == "Union":
                    found = "SS.option(s0, U32.to_nat(v0))"; impl = "IS.get(s0, U32.to_nat(v0))"; corr = "Sch.option_correct(s0, U32.to_nat(v0))"
                    okfn = "RS.index_ok(U32.to_nat(v0), 128n, %s, Lookups.union_lookup(s0, U32.to_nat(v0), legal), s, same)" % found
                else:
                    found = "SS.compatible_option(s0, s1, v0)"; impl = "IC.selected_schema(s0, s1, v0)"; corr = "Helpers.selected_schema_correct(s0, s1, v0)"
                    facts = "Lookups.compatible_lookup(s0, s1, v0, [], %s, %s)" % (pick(CU, 2, "legal"), pick(CU, 3, "legal"))
                    okfn = "RS.selection_ok(v0, %s, %s, s, same)" % (found, facts)
                g = "{IR.with_schema(_, s => IR.selector_mix(IR.unwrap(IR.roots_go(v1, s, [], %s)), v0)) == Some{outs} : Maybe<&2, +List<+List<U32>>>}" % TABLE
                lines = ["%%Equal.sym(Maybe<&2, T.Schema>, %s, %s, %s) : %s" % (impl, found, corr, g),
                         "C.union_complete(v1, v0, %s, size, outs, s => same => root => rc => option_view(s, v1, size, [root], %s, complete(v1, s, [], size, Lookups.ok_of_option(s, %s), [root], rc)), rel)" % (found, okfn, okfn)]
            if lines is not None:
                out.append("        case %s:" % p)
                for l in lines:
                    out.append("          " + l)
                continue
            if proof is None:
                out.append("        case %s:" % p)
                out.append("          match rel:")
                continue
            out.append("        case %s: %s" % (p, proof))
    text = "\n".join(out) + "\n"
    text = text.replace("import ./root_steps.bend as G\n", "import ./root_steps.bend as G\n", 1)
    Path("proofs/root_complete.bend").write_text(text)


if __name__ == "__main__":
    main()
