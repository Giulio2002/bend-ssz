import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/Fulu_list_bytevec_2048_4096_def_generated.bend as Cells
import ../../types/proglist_uint8_def_generated.bend as PlD
import ../../types/proglist_uint8_decode_ssz_generated.bend as PlR
import ../../types/proglist_uint8_encode_ssz_generated.bend as PlE
import ../../types/proglist_uint8_hashtreeroot_generated.bend as PlH
import ../../types/progbitlist_def_generated.bend as PbD
import ../../types/progbitlist_encode_ssz_generated.bend as PbE
import ../../types/progbitlist_hashtreeroot_generated.bend as PbH
import ../../types/Fulu_bitlist_2048_def_generated.bend as B2048
import ../../types/Fulu_list_uint64_128_def_generated.bend as L128
import ../../benchmarks/compact/objio.bend as IOx

# Crash-hunt probe A: objects built through the public constructors and the
# public setters/getters/encoders on extreme values. SSZ_CASE selects the case,
# SSZ_ARG is a case parameter. Each case prints one result line; a crash, a
# hang or an out-of-memory is the finding and is recorded by the runner.

def word_line(label: String, pair: O.Words & U32) -> IO(Unit):
  (w, +x) = pair
  IO.print(label ++ "=" ++ U32.show(x))

def first_word(pair: O.Words & Maybe<&1, O.Words>) -> IO(Unit):
  (o, m) = pair
  match m:
    case Some{w}: word_line("cell_w0", O.words_word(w, 0))
    case None{}: IO.print("cell=none")

def cell_after(pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  do IO<Unit>:
    IO.print("set_ok=" ++ O.pick_str(ok))
    first_word(Cells.l4096_b2048_get(o, 0))

def cells2() -> O.Words: O.Words{Array.new(U32, 10n, 0), 4096}

# 1: set a cell from an empty Words; 2: from an oversized Words at index 1; 3: from a short Words
def case1() -> IO(Unit): cell_after(Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 3n, 0), 0}))
def case2() -> IO(Unit): cell_after(Cells.l4096_b2048_set(cells2(), 1, O.Words{Array.new(U32, 10n, 4294967295), 4096}))
def case3() -> IO(Unit): cell_after(Cells.l4096_b2048_set(cells2(), 0, O.Words{Array.new(U32, 5n, 4294967295), 64}))
def case4() -> IO(Unit): cell_after(Cells.l4096_b2048_append(cells2(), O.Words{Array.new(U32, 3n, 0), 0}))

def enc_line(label: String, e: O.Encoded) -> IO(Unit):
  match e:
    case O.Encoded{ok, b}: IO.print(label ++ "_ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))

def ser_line(label: String, pair: O.Words & O.Encoded) -> IO(Unit):
  (o, e) = pair
  enc_line(label, e)

# 5: serialize an object made by the public constructor words_new(n) (huge n)
def case5(+n: U32) -> IO(Unit): ser_line("words_new_serialize", PlE.proglist_uint8_serialize(O.words_new(n)))

def root_line(label: String, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (w, d) = r
  IO.print(label ++ "=" ++ IOx.words(d))

# 6: hash_tree_root of a Words claiming n bytes with tiny storage
def case6(+n: U32) -> IO(Unit): root_line("root", PlH.proglist_uint8_hash_tree_root(O.hasher(), O.Words{Array.new(U32, 4n, 0), n}))

# 7: unchecked encode of a Words claiming n bytes
def enc7(pair: O.Words & B.Buf) -> IO(Unit):
  (o, b) = pair
  IO.print("encode_size=" ++ U32.show(Pair.snd(B.Buf, U32, B.size(b))))
def case7(+n: U32) -> IO(Unit): enc7(PlE.proglist_uint8_encode(O.Words{Array.new(U32, 4n, 0), n}))

# 8: progressive bit list at 2^32 - 1 bits, append
def bits_after(pair: O.Bits & Bool) -> IO(Unit):
  (b, ok) = pair
  match b:
    case O.Bits{ws, +k}:
      do IO<Unit>:
        IO.print("append_ok=" ++ O.pick_str(ok))
        IO.print("len_after=" ++ U32.show(k))
def case8() -> IO(Unit): bits_after(PbD.pbits_append(O.Bits{Array.new(U32, 27n, 0), 4294967295}, True{}))
# 9: Bitlist[2048] append on an object claiming 2^32 - 1 bits
def case9() -> IO(Unit): bits_after(B2048.bits2048_append(O.Bits{Array.new(U32, 1n, 0), 4294967295}, True{}))
# 10: Bitlist[2048] serialize / root on such an object
def bser(pair: O.Bits & O.Encoded) -> IO(Unit):
  (o, e) = pair
  enc_line("bits_serialize", e)
def case10() -> IO(Unit): bser(PbE.progbitlist_serialize(O.Bits{Array.new(U32, 1n, 0), 4294967295}))
def broot(pair: B.Buf & (O.Bits & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (w, d) = r
  IO.print("bits_root=" ++ IOx.words(d))
def case11(+n: U32) -> IO(Unit): broot(PbH.progbitlist_hash_tree_root(O.hasher(), O.Bits{Array.new(U32, 2n, 0), n}))
# 12: packed list of uint64 with a length that is not a multiple of 8 and tiny storage; get / set / append
def get_line(pair: O.Words & Maybe<&1, O.U64>) -> IO(Unit):
  (o, m) = pair
  match m:
    case Some{v}: IO.print("get=some")
    case None{}: IO.print("get=none")
def case12() -> IO(Unit): get_line(L128.l128_u64_get(O.Words{Array.new(U32, 1n, 0), 1016}, 127))
def app_line(pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  IO.print("append_ok=" ++ O.pick_str(ok))
def case13() -> IO(Unit): app_line(L128.l128_u64_append(O.Words{Array.new(U32, 1n, 0), 1016}, O.U64{1, 2}))
# 14: progressive byte list append at n bytes claimed
def case14(+n: U32) -> IO(Unit): app_line(PlD.pl_u8_append(O.Words{Array.new(U32, 4n, 0), n}, 7))

# 15: serialize a valid byte list of exactly 2^31 bytes (2 GiB) / 16: of 2^31 - 1 bytes (control)
def case15(+n: U32) -> IO(Unit): ser_line("serialize_big", PlE.proglist_uint8_serialize(O.Words{Array.new(U32, 29n, 0), n}))

def dispatch(+c: U32, +a: U32) -> IO(Unit):
  match c:
    case 1: case1()
    case 2: case2()
    case 3: case3()
    case 4: case4()
    case 5: case5(a)
    case 6: case6(a)
    case 7: case7(a)
    case 8: case8()
    case 9: case9()
    case 10: case10()
    case 11: case11(a)
    case 12: case12()
    case 13: case13()
    case 15: case15(a)
    case _: case14(a)

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +a : U32 <- IOx.env_u32("SSZ_ARG")
    dispatch(c, a)
