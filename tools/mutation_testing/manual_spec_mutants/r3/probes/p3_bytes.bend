import Base
import ../../../../../src/buffer.bend as B
import ../../../../../src/obj.bend as O
import ../../../../../src/digest.bend as D
import ../../../../../types/bytelist_256_def_generated.bend as BD
import ../../../../../types/bytelist_256_encode_ssz_generated.bend as BE
import ../../../../../types/bytelist_256_hashtreeroot_generated.bend as BH
import ../../../../../benchmarks/compact/objio.bend as IOx

# Round-3 probe (public record constructor O.Words{ws, n} + X_valid + X_hash_tree_root of bytelist_256): the root of a VALID object
# whose storage holds junk past its length inside its last chunk, and of valid objects with tight storage.
# SSZ_CASE c >= 100: m = c / 100 selects n (1: 40, 2: 58, 3: 36, 4: 100, 5: 5, 6: 1), j = c mod 100 the word that holds junk
# (the junk lies past the data: valid stays 1, the root must equal the root of the clean object).
# SSZ_CASE c < 100: 1 clean n=40; 2 clean n=58; 3 tight n=5 (2 words); 4 tight n=9 (4 words); 5 tight n=1 (1 word); 6 clean n=5; 7 clean n=9;
# 8 clean n=1; 9 clean n=100; 10 tight n=33 (16 words); 11 clean n=33.

def pr_digest(label: String, valid: Bool, d: D.Digest) -> IO(Unit):
  match d:
    case D.D{+a, +b1, +c, +d1, +e, +f, +g, +h}:
      IO.print(label ++ " valid=" ++ O.pick_str(valid) ++ " root=" ++ U32.show(a) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d1) ++ "," ++ U32.show(e) ++ "," ++ U32.show(f) ++ "," ++ U32.show(g) ++ "," ++ U32.show(h))

def root_fin(label: String, valid: Bool, pair: B.Buf & (O.Words & D.Digest)) -> IO(Unit):
  (b, r) = pair
  (o, d) = r
  pr_digest(label, valid, d)

def probe(label: String, pair: O.Words & Bool) -> IO(Unit):
  (o, ok) = pair
  root_fin(label, ok, BH.bl256_root(64n, O.hasher(), o, 0))

def data(+k: Nat, +i: U32, ws: Array<U32>) -> Array<U32>:
  match k:
    case 0n: ws
    case 1n+q: data(q, (i + 1 : U32), Array.set(U32, ws, i, (16909060 + i : U32)))

def mk(+n: U32, ws: Array<U32>) -> O.Words:
  O.Words{O.mask_last(n, data(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), 0, ws)), n}

def junk(+j: U32, w: O.Words) -> O.Words: O.words_setw(w, j, 3735928559)

def nof(+m: U32) -> U32:
  match m:
    case 1: 40
    case 2: 58
    case 3: 36
    case 4: 100
    case 5: 5
    case _: 1

def jk(+n: U32, +j: U32) -> IO(Unit):
  probe("n" ++ U32.show(n) ++ "_junk" ++ U32.show(j), BE.bl256_valid(junk(j, mk(n, O.zeros_for(n)))))

def clean(+n: U32) -> IO(Unit): probe("n" ++ U32.show(n) ++ "_clean", BE.bl256_valid(mk(n, O.zeros_for(n))))

def tight(+n: U32, +d: Nat) -> IO(Unit): probe("n" ++ U32.show(n) ++ "_tight", BE.bl256_valid(mk(n, Array.new(U32, d, 0))))

def small(+c: U32) -> IO(Unit):
  match c:
    case 1: clean(40)
    case 2: clean(58)
    case 3: tight(5, 1n)
    case 4: tight(9, 2n)
    case 5: tight(1, 0n)
    case 6: clean(5)
    case 7: clean(9)
    case 8: clean(1)
    case 9: clean(100)
    case 10: tight(33, 4n)
    case _: clean(33)

def dispatch(small_case: Bool, +c: U32) -> IO(Unit):
  match small_case:
    case True{}: small(c)
    case False{}: jk(nof(U32.div(c, 100)), U32.mod(c, 100))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    dispatch(U32.is_lt(c, 100), c)
