#!/usr/bin/env python3
"""More laws that pin constants of the frozen spec no other law reaches (docs/MUTATION_PROOFS.md section 8): the spec is
never edited; each law states a spec function on witnesses in a small module that imports the spec file.

    python3 codegen/proofs/laws/spec_pins_more.py [--check]

  specpin_bit_root       chunk_limit(1n) == 1n, chunk_limit(257n) == 2n              (ceil(N / 256): the 255n)
  specpin_packing        pack of 33 bytes is two chunks, the first of 32 bytes        (the room 31n of scan)
  specpin_tree           capacity(0n) == 1n, capacity(3n) == 8n                       (a depth-0 tree holds one leaf)
  specpin_type_legality  inhabitants of type_legal for a union of 1 option behind Null, of 127 options behind Null and
                         of 127 options (a type error when the field-count bounds 0n / 127n move)
  specpin_fulu_schemas   Schema52() is Vector[Schema8(), SYNC_COMMITTEE_SIZE] (the value is read from codegen/fulu.yaml)
  specpin_root_relation  aggregate(True, a, ..) == aggregate(True, b, ..): the limit of a progressive sequence is unread (the 0n of
                         `sequence(.., 0n, True{}, ..)` is equivalent: no statement can depend on it)
  specpin_representation erase puts the placeholder length 0n in every erased type, whatever the length it replaces
                         (the placeholder is irrelevant to `shape`, proofs/representation_erasure.bend: shape(v, s) ==
                         shape(v, erase(s)); the pins make the chosen placeholder explicit)
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402

H = writer.header("spec_pins_more")


def mod(imports, body):
    return "import Base\n" + "".join(f"import ../../{p} as {a}\n" for a, p in imports) + H + "\n" + body


def law(name, params, stmt):
    return f"def {name}({params}) -> {{{stmt}}}:\n  {{==}}\n"


def legality():
    # ch(k): a chain of k booleans; pr(k): the inhabitant of legal(ch(k), True) =
    # {forest == True} & legal(Boolean, False) & legal(rest, True), right-nested pairs
    return (
        "def ch(+k: Nat) -> T.Schema:\n  match k:\n    case 0n: T.End{}\n    case 1n+p: T.Chain{T.Boolean{}, ch(p)}\n"
        "def pr(+k: Nat) -> S.legal(ch(k), True{}):\n  match k:\n    case 0n: {==}\n    case 1n+p: ({==}, ({==}, pr(p)))\n"
        # Union{Chain{Null, rest}}: {forest} & {0 < n} & {n <= 127} & legal(rest, True)
        "def union_null_1() -> S.type_legal(T.Union{T.Chain{T.Null{}, ch(1n)}}):\n  ({==}, ({==}, ({==}, pr(1n))))\n"
        "def union_null_127() -> S.type_legal(T.Union{T.Chain{T.Null{}, ch(127n)}}):\n  ({==}, ({==}, ({==}, pr(127n))))\n"
        # Union{Chain{head, rest}}: {forest} & {n <= 127} & legal(head, False) & legal(rest, True)
        "def bitvector_1() -> S.type_legal(T.BitVector{1n}):\n  ({==}, {==})\n"
        # CompatibleUnion{[1], Chain{Boolean, End}}: {forest} & {0 < n} & {len ids == n} & selectors(ids) & legal(options, True) &
        # mutually_compatible(options) (a derivation Fork{Fork{Leaf, Leaf}, Leaf} of All{} options options)
        "def compatible_union_1() -> S.type_legal(T.CompatibleUnion{[1], ch(1n)}):\n"
        "  ({==}, ({==}, ({==}, (({==}, ({==}, ({==}, Unit{}))), (pr(1n), (C.Fork{C.Fork{C.Leaf{}, C.Leaf{}}, C.Leaf{}}, {==}))))))\n"
        "def union_127() -> S.type_legal(T.Union{T.Chain{T.Boolean{}, ch(127n)}}):\n  ({==}, ({==}, ({==}, pr(127n))))\n")


def packing():
    xs = list(range(33))
    lit = lambda a: "[" + ", ".join(map(str, a)) + "]"   # noqa: E731
    return law("pack_33", "", f"Pack.pack({lit(xs)}) == Some{{[{lit(xs[:32])}, {lit(xs[32:] + [0] * 31)}]}} : Maybe<&2, +List<+List<U32>>>")


def representation():
    out = []
    for i, (c, args, res) in enumerate([("ByteVector", "n", "T.ByteVector{0n}"), ("ByteList", "n", "T.ByteVector{0n}"),
                                       ("BitVector", "n", "T.BitVector{0n}"), ("BitList", "n", "T.BitVector{0n}"),
                                       ("ProgressiveBits", "", "T.BitVector{0n}")]):
        p = "n: Nat" if args else ""
        out.append(law(f"erase_{c}", p, f"S.erase(T.{c}{{{args}}}) == {res} : T.Schema"))
    for c in ("Vector", "ListOf"):
        out.append(law(f"erase_{c}", "e: T.Schema, n: Nat", f"S.erase(T.{c}{{e, n}}) == T.Vector{{S.erase(e), 0n}} : T.Schema"))
    out.append(law("erase_ProgressiveList", "e: T.Schema", "S.erase(T.ProgressiveList{e}) == T.Vector{S.erase(e), 0n} : T.Schema"))
    return "".join(out)


def sync_size():
    y = (ROOT / "codegen/fulu.yaml").read_text()
    return int(re.search(r"^\s*SYNC_COMMITTEE_SIZE:\s*(\d+)", y, re.M).group(1))


def outputs():
    S = [("T", "types/schema.bend")]
    o = {
        "bit_root": mod([("K", "spec/bit_root.bend")],
                        law("chunk_limit_1", "", "K.chunk_limit(1n) == 1n : Nat") + law("chunk_limit_257", "", "K.chunk_limit(257n) == 2n : Nat")),
        "packing": mod([("Pack", "spec/packing.bend")], packing()),
        "tree": mod([("K", "spec/tree.bend"), ("P", "spec/primitives.bend")],
                    law("capacity_0", "", "K.capacity(0n) == 1n : Nat") + law("capacity_3", "", "K.capacity(3n) == 8n : Nat")
                    + law("tree_empty_0", "", "K.tree(0n, []) == P.zero_bytes(32n) : +List<U32>")),
        "type_legality": mod(S + [("S", "spec/type_legality.bend"), ("C", "spec/compatibility.bend")], legality()),
        "fulu_schemas": mod(S + [("F", "spec/fulu_schemas.bend")],
                            law("schema52", "", f"F.Schema52() == T.Vector{{F.Schema8(), {sync_size()}n}} : T.Schema")),
        "root_relation": mod([("R", "spec/root_relation.bend")],
                             law("aggregate_progressive_ignores_limit", "+a: Nat, +b: Nat, +c: +List<+List<U32>>, +l: Maybe<&2, Nat>, +o: +List<+List<U32>>",
                                 "R.aggregate(True{}, a, c, l, o) == R.aggregate(True{}, b, c, l, o) : Type")),
        "representation": mod(S + [("S", "spec/representation.bend")], representation()),
    }
    return {ROOT / f"proofs/obj/specpin_{k}.bend": v for k, v in o.items()}


def main():
    out = outputs()
    if "--check" in sys.argv:
        return writer.check(out, "stale spec pins: ", "spec pins are current")
    writer.write(out)
    print(f"{len(out)} modules")


if __name__ == "__main__":
    main()
