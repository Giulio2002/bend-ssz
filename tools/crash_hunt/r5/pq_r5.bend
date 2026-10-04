import Base
import ../../../src/buffer.bend as B
import ../../../src/digest.bend as D
import ../../../src/obj.bend as O
import ../../../types/proglist_uint8_def_generated.bend as P8
import ../../../types/proglist_uint8_encode_ssz_generated.bend as P8E
import ../../../types/proglist_uint16_def_generated.bend as L16
import ../../../types/proglist_uint16_encode_ssz_generated.bend as L16E
import ../../../types/bitlist_33_def_generated.bend as B33
import ../../../types/bitlist_33_encode_ssz_generated.bend as B33E
import ../../../types/progbitlist_def_generated.bend as PB
import ../../../types/progbitlist_encode_ssz_generated.bend as PBE
import ../../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 5, probe Q: `_append` into a VALID object whose storage past its length is not zero (a hand-built O.Words / O.Bits,
# the R2-02 (b) / CH-11 class of objects: `_valid` is 1, the root takes the clean copy). SSZ_CASE:
#  1 proglist_uint8 n = 4 bytes in 4 words of 0xA5A5A5A5 (D = 1: the same data in zero storage), append 7
#  2 proglist_uint16 n = 4 bytes, the same storage, append 7
#  3 bitlist_33 k = 31 bits (word 0 = 0x7FFFFFFF, words 1..3 = 0xFFFFFFFF), append True
#  4 progbitlist the same
# Prints valid before, the append flag, valid after, and the checked serialize answer (ok, size) after.

def fillw(+d: U32) -> U32: O.pick(U32.is_eq(d, 1), 0, 2779096485)
def wsx(+d: U32) -> Array<U32>: Array.set(U32, Array.new(U32, 2n, fillw(d)), 0, 2779096485)
def bsx(+d: U32) -> Array<U32>: Array.set(U32, Array.new(U32, 2n, O.pick(U32.is_eq(d, 1), 0, 4294967295)), 0, 2147483647)

def ser_sz(ok: Bool, pair: B.Buf & U32) -> String:
  (b, +m) = pair
  " ser_ok=" ++ O.pick_str(ok) ++ " ser_size=" ++ U32.show(m)
def ser_line(e: O.Encoded) -> String:
  match e:
    case O.Encoded{ok, b}: ser_sz(ok, B.size(b))

def w_ser(pair: O.Words & O.Encoded) -> String:
  (o, e) = pair
  ser_line(e)
def b_ser(pair: O.Bits & O.Encoded) -> String:
  (o, e) = pair
  ser_line(e)

def c1v(pair: O.Words & Bool, +v0: U32, +fl: U32) -> IO(Unit):
  (o, ok) = pair
  IO.print("valid0=" ++ U32.show(v0) ++ " append=" ++ U32.show(fl) ++ " valid1=" ++ O.pick_str(ok) ++ w_ser(P8E.proglist_uint8_serialize(o)))
def c1a(+v0: U32, pair: O.Words & Bool) -> IO(Unit):
  (o, fl) = pair
  c1v(P8E.pl_u8_valid(o), v0, O.pick(fl, 1, 0))
def c1(pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  c1a(O.pick(ok, 1, 0), P8.pl_u8_append(o, 7))

def c2v(pair: O.Words & Bool, +v0: U32, +fl: U32) -> IO(Unit):
  (o, ok) = pair
  IO.print("valid0=" ++ U32.show(v0) ++ " append=" ++ U32.show(fl) ++ " valid1=" ++ O.pick_str(ok) ++ w_ser(L16E.proglist_uint16_serialize(o)))
def c2a(+v0: U32, pair: O.Words & Bool) -> IO(Unit):
  (o, fl) = pair
  c2v(L16E.pl_u16_valid(o), v0, O.pick(fl, 1, 0))
def c2(pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  c2a(O.pick(ok, 1, 0), L16.pl_u16_append(o, 7))

def c3v(pair: O.Bits & Bool, +v0: U32, +fl: U32) -> IO(Unit):
  (o, ok) = pair
  IO.print("valid0=" ++ U32.show(v0) ++ " append=" ++ U32.show(fl) ++ " valid1=" ++ O.pick_str(ok) ++ b_ser(B33E.bitlist_33_serialize(o)))
def c3a(+v0: U32, pair: O.Bits & Bool) -> IO(Unit):
  (o, fl) = pair
  c3v(B33E.bits33_valid(o), v0, O.pick(fl, 1, 0))
def c3(pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  c3a(O.pick(ok, 1, 0), B33.bits33_append(o, True{}))

def c4v(pair: O.Bits & Bool, +v0: U32, +fl: U32) -> IO(Unit):
  (o, ok) = pair
  IO.print("valid0=" ++ U32.show(v0) ++ " append=" ++ U32.show(fl) ++ " valid1=" ++ O.pick_str(ok) ++ b_ser(PBE.progbitlist_serialize(o)))
def c4a(+v0: U32, pair: O.Bits & Bool) -> IO(Unit):
  (o, fl) = pair
  c4v(PBE.pbits_valid(o), v0, O.pick(fl, 1, 0))
def c4(pair: O.Bits & Bool) -> IO(Unit):
  (o, ok) = pair
  c4a(O.pick(ok, 1, 0), PB.pbits_append(o, True{}))

def go(+c: U32, +d: U32) -> IO(Unit):
  match c:
    case 1: c1(P8E.pl_u8_valid(O.Words{wsx(d), 4}))
    case 2: c2(L16E.pl_u16_valid(O.Words{wsx(d), 4}))
    case 3: c3(B33E.bits33_valid(O.Bits{bsx(d), 31}))
    case _: c4(PBE.pbits_valid(O.Bits{bsx(d), 31}))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +d : U32 <- IOx.env_u32("SSZ_D")
    go(c, d)
