import Base
import ../../src/buffer.bend as B
import ../../src/croot.bend as R
import ../../src/digest.bend as D
import ../../src/cschema.bend as CS
import ../../src/root.bend as Old
import ../../types/schema.bend as T
import ../../types/primitive.bend as P

# The indexed root against the existing list-based implementation that the
# current proofs are about. Same value, same schema, two representations: the
# roots must agree. Inputs are literals so the whole comparison is decided at
# compile time and no file reader is involved.

def keep(xs: +List<U32>, +sink: U32) -> +List<U32>: xs

def fast_bytes(pair: B.Buf & D.Digest) -> +List<U32>:
  (buf, d) = pair
  keep(D.bytes(d), B.drop(buf))

def old_bytes(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case None{}: []
    case Some{root}: root

def same(a: +List<U32>, b: +List<U32>) -> Bool:
  match a:
    case Nil{}:
      match b:
        case Nil{}: True{}
        case Con{h, t}: False{}
    case Con{+ha, ta}:
      match b:
        case Nil{}: False{}
        case Con{+hb, tb}: Bool.and(U32.is_eq(ha, hb), same(ta, tb))

def check(label: String, fast: +List<U32>, old: +List<U32>) -> String:
  label ++ "=" ++ Bool.show(same(fast, old))

def u64(+lo: U32, +hi: U32) -> P.UInt: P.UInt{lo, hi, 0, 0, 0, 0, 0, 0}

# uint64
def case_uint() -> String:
  check("uint64",
    fast_bytes(R.root(CS.CUint{8}, 8, B.of_list(8, [1, 0, 0, 0, 0, 0, 0, 0]))),
    old_bytes(Old.hash_tree_root(T.Unsigned{P.U64{}}, T.UnsignedValue{u64(1, 0)})))

# Bytes32
def bytes32_list() -> +List<U32>:
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]

def case_bytes32() -> String:
  check("bytes32",
    fast_bytes(R.root(CS.CBytes{32, 0}, 32, B.of_list(32, bytes32_list()))),
    old_bytes(Old.hash_tree_root(T.ByteVector{32n}, T.BytesValue{bytes32_list()})))

# Bytes48, two chunks with padding
def bytes48_list() -> +List<U32>:
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
   32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47]

def case_bytes48() -> String:
  check("bytes48",
    fast_bytes(R.root(CS.CBytes{48, 1}, 48, B.of_list(48, bytes48_list()))),
    old_bytes(Old.hash_tree_root(T.ByteVector{48n}, T.BytesValue{bytes48_list()})))

# Container{uint64, uint64}
def cont_fields() -> CS.CS:
  CS.CFNode{CS.CFLeaf{CS.CUint{8}, 0, 8, True{}}, CS.CFLeaf{CS.CUint{8}, 8, 8, True{}}, 1}

def case_container() -> String:
  check("container",
    fast_bytes(R.root(CS.CCont{cont_fields(), 2, 16, 16, True{}, 1, True{}}, 16,
      B.of_list(16, [1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0]))),
    old_bytes(Old.hash_tree_root(
      T.Container{["a", "b"], T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U64{}}, T.End{}}}},
      T.Sequence{T.Items{T.UnsignedValue{u64(1, 0)},
        T.Items{T.UnsignedValue{u64(2, 0)}, T.EmptyItems{}}}})))

# List[uint64, 4] with two elements: packed leaves plus a length mix
def case_list_basic() -> String:
  check("list_uint64",
    fast_bytes(R.root(CS.CList{CS.CUint{8}, 4, False{}, 8, 0, True{}, True{}}, 16,
      B.of_list(16, [1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0]))),
    old_bytes(Old.hash_tree_root(T.ListOf{T.Unsigned{P.U64{}}, 4n},
      T.Sequence{T.Items{T.UnsignedValue{u64(1, 0)},
        T.Items{T.UnsignedValue{u64(2, 0)}, T.EmptyItems{}}}})))

# Vector[Bytes32, 2]: two composite elements
def case_vector_composite() -> String:
  check("vector_bytes32",
    fast_bytes(R.root(CS.CVec{CS.CBytes{32, 0}, 2, 32, 1, False{}, True{}}, 64,
      B.of_list(64, List.append(&2, U32, bytes32_list(), bytes32_list())))),
    old_bytes(Old.hash_tree_root(T.Vector{T.ByteVector{32n}, 2n},
      T.Sequence{T.Items{T.BytesValue{bytes32_list()},
        T.Items{T.BytesValue{bytes32_list()}, T.EmptyItems{}}}})))

# BitVector[16]: bytes 0xab, 0xcd
def bits16() -> +List<Bool>:
  [True{}, True{}, False{}, True{}, False{}, True{}, False{}, True{},
   True{}, False{}, True{}, True{}, False{}, False{}, True{}, True{}]

def case_bitvector() -> String:
  check("bitvector16",
    fast_bytes(R.root(CS.CBitVec{16, 2, 0}, 2, B.of_list(2, [171, 205]))),
    old_bytes(Old.hash_tree_root(T.BitVector{16n}, T.BitsValue{bits16()})))

# Container{BitVector[16], Bytes32}
def sync_like_fields() -> CS.CS:
  CS.CFNode{CS.CFLeaf{CS.CBitVec{16, 2, 0}, 0, 2, True{}},
            CS.CFLeaf{CS.CBytes{32, 0}, 2, 32, True{}}, 1}

def case_bits_container() -> String:
  check("bits_container",
    fast_bytes(R.root(CS.CCont{sync_like_fields(), 2, 34, 34, True{}, 1, True{}}, 34,
      B.of_list(34, List.append(&2, U32, [171, 205], bytes32_list())))),
    old_bytes(Old.hash_tree_root(
      T.Container{["bits", "sig"], T.Chain{T.BitVector{16n}, T.Chain{T.ByteVector{32n}, T.End{}}}},
      T.Sequence{T.Items{T.BitsValue{bits16()},
        T.Items{T.BytesValue{bytes32_list()}, T.EmptyItems{}}}})))

def hex_nib(+x: U32) -> String:
  match x:
    case 0: "0"
    case 1: "1"
    case 2: "2"
    case 3: "3"
    case 4: "4"
    case 5: "5"
    case 6: "6"
    case 7: "7"
    case 8: "8"
    case 9: "9"
    case 10: "a"
    case 11: "b"
    case 12: "c"
    case 13: "d"
    case 14: "e"
    case _: "f"

def hex_bytes(xs: +List<U32>) -> String:
  match xs:
    case Nil{}: ""
    case Con{+h, t}: hex_nib(U32.shrn(h, 4n)) ++ hex_nib((h .&. 15 : U32)) ++ hex_bytes(t)

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(case_uint())
    IO.print(case_bytes32())
    IO.print(case_bytes48())
    IO.print(case_container())
    IO.print(case_list_basic())
    IO.print(case_vector_composite())
    IO.print(case_bitvector())
    IO.print(case_bits_container())
    IO.print("list_fast=" ++ hex_bytes(fast_bytes(R.root(CS.CList{CS.CUint{8}, 4, False{}, 8, 0, True{}, True{}}, 16,
      B.of_list(16, [1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0])))))
    IO.print("list_old=" ++ hex_bytes(old_bytes(Old.hash_tree_root(T.ListOf{T.Unsigned{P.U64{}}, 4n},
      T.Sequence{T.Items{T.UnsignedValue{u64(1, 0)},
        T.Items{T.UnsignedValue{u64(2, 0)}, T.EmptyItems{}}}}))))
