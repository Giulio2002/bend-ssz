import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/bytelist_256_encode_ssz_generated.bend as BE
import ../../../../../types/bytelist_256_hashtreeroot_generated.bend as BH
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-2 probe: is the root of an object that X_valid accepts the specification's root when the storage is exactly the minimum that
# X_valid demands (ceil(n / 4) words rounded up to a power of two, which is what Array.new gives)? The API builds roomier storage
# (O.zeros_for: whole chunks plus one chunk), but the record constructor O.Words{ws, n} is public and X_valid only checks
# ceil(n / 4) <= size. SSZ_CASE: 1 tight n = 1, 2 roomy n = 1 (same byte), 3 tight n = 16, 4 roomy n = 16 (same bytes).

def pr_digest(label: String, valid: Bool, d: D.Digest) -> IO(Unit):
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}:
      IO.print(label ++ " valid=" ++ O.pick_str(valid) ++ " root=" ++ U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d1) ++ "," ++ U32.show(e) ++ "," ++ U32.show(f) ++ "," ++ U32.show(g) ++ "," ++ U32.show(h))

def root_fin(label: String, valid: Bool, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  pr_digest(label, valid, d)

def root_of(label: String, valid: Bool, o: O.Words) -> IO(Unit): root_fin(label, valid, BH.bl256_root(64n, O.hasher(), o, 0))

def probe(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  root_of(label, ok, o)

def one_byte(ws: Array<U32>) -> O.Words: O.Words{Array.set(U32, ws, 0, 65), 1}
def sixteen(ws: Array<U32>) -> O.Words:
  O.Words{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, ws, 0, 67305985), 1, 134678021), 2, 202050057), 3, 269422093), 16}

def case1() -> IO(Unit): probe("tight_1", BE.bl256_valid(one_byte(Array.new(U32, 0n, 0))))
def case2() -> IO(Unit): probe("roomy_1", BE.bl256_valid(one_byte(O.zeros_for(1))))
def case3() -> IO(Unit): probe("tight_16", BE.bl256_valid(sixteen(Array.new(U32, 2n, 0))))
def case4() -> IO(Unit): probe("roomy_16", BE.bl256_valid(sixteen(O.zeros_for(16))))

def dispatch(+c: U32) -> IO(Unit):
  match c:
    case 1: case1()
    case 2: case2()
    case 3: case3()
    case _: case4()

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(c)
