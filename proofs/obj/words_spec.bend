import Base
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../../spec/packing.bend as Pack
import ../../spec/primitives.bend as SP
import ../compact/found_generated.bend as F
import ./mtree_defs.bend as MS
import ./mtree_run.bend as MR
import ./root_leaf_generated.bend as RL
import ./spec_fixed.bend as FX

# Packed words, specification side: the bytes of a word array, cut at the
# object's length, pack (spec/packing.bend `scan`) into exactly the chunks
# whose digests the runtime tree hashes (proofs/obj/mtree_run.bend `clist`),
# provided the bytes past the length up to the chunk boundary are zero.
#
# Everything is stated over a word LIST W (the slots of the array model) and
# symbolic counts, so a 131072-byte blob is never unfolded.

def btake(n: Nat, xs: +List<U32>) -> +List<U32>:
  match n:
    case 0n: []
    case 1n+p:
      match xs:
        case Nil{}: []
        case Con{h, t}: h <> btake(p, t)

def bdrop(n: Nat, xs: +List<U32>) -> +List<U32>:
  match n:
    case 0n: xs
    case 1n+p:
      match xs:
        case Nil{}: []
        case Con{h, t}: bdrop(p, t)

def wdrop(n: Nat, W: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: W
    case 1n+p:
      match W:
        case Nil{}: []
        case Con{h, t}: wdrop(p, t)

def e32(+x: Nat) -> Nat: Nat.double(Nat.double(O.e8(x)))

# The 32 bytes of chunk i: the limbs of words 8i .. 8i + 7.
def cb(+W: List<&2, U32>, +i: Nat) -> +List<U32>:
  FX.limbs([MR.wd(W, Nat.add(O.e8(i), 0n)), MR.wd(W, Nat.add(O.e8(i), 1n)), MR.wd(W, Nat.add(O.e8(i), 2n)), MR.wd(W, Nat.add(O.e8(i), 3n)),
            MR.wd(W, Nat.add(O.e8(i), 4n)), MR.wd(W, Nat.add(O.e8(i), 5n)), MR.wd(W, Nat.add(O.e8(i), 6n)), MR.wd(W, Nat.add(O.e8(i), 7n))])

# ---- word lists ----------------------------------------------------------------

# Below its length, a suffix of a word list is its word followed by the next suffix.
law wdrop_eta:
  for +j: Nat
  for +W: List<&2, U32>
  for +e: {Nat.is_lt(j, F.spec_common__length(U32, W)) == True{} : Bool}
  {wdrop(j, W) == Con{MR.wd(W, j), wdrop(1n+j, W)} : List<&2, U32>}
def wdrop_eta(j, W, e):
  match j:
    case 0n:
      match W:
        case Nil{}: Empty.absurd({wdrop(0n, Nil{}) == Con{MR.wd(Nil{}, 0n), wdrop(1n, Nil{})} : List<&2, U32>}, MS.false_true(e))
        case Con{+h, +t}:
          match t:
            case Nil{}: {==}
            case Con{+h2, +t2}: {==}
    case 1n+ +p:
      match W:
        case Nil{}: Empty.absurd({wdrop(1n+p, Nil{}) == Con{MR.wd(Nil{}, 1n+p), wdrop(2n+p, Nil{})} : List<&2, U32>}, MS.false_true(e))
        case Con{+h, +t}: wdrop_eta(p, t, e)

# The same at a position written b + k.
def eta_at(+b: Nat, +k: Nat, +W: List<&2, U32>, +e: {Nat.is_lt(Nat.add(b, k), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {wdrop(Nat.add(b, k), W) == Con{MR.wd(W, Nat.add(b, k)), wdrop(Nat.add(b, 1n+k), W)} : List<&2, U32>}:
  %Equal.sym(Nat, Nat.add(b, 1n+k), 1n+Nat.add(b, k), MR.add_succ(b, k)) : {wdrop(Nat.add(b, k), W) == Con{MR.wd(W, Nat.add(b, k)), wdrop(_, W)} : List<&2, U32>}
  wdrop_eta(Nat.add(b, k), W, e)

# b < j + 1 + b.
law lt_shift:
  for +b: Nat
  for +j: Nat
  {Nat.is_lt(b, Nat.add(1n+j, b)) == True{} : Bool}
def lt_shift(b, j):
  match b:
    case 0n: {==}
    case 1n+ +c:
      %Equal.sym(Nat, Nat.add(j, 1n+c), 1n+Nat.add(j, c), MR.add_succ(j, c)) : {Nat.is_lt(c, _) == True{} : Bool}
      lt_shift(c, j)

def bnd_k(+b: Nat, +k: Nat, +hk: {Nat.is_lt(k, 8n) == True{} : Bool}) -> {Nat.is_lt(Nat.add(k, b), Nat.add(8n, b)) == True{} : Bool}:
  match k:
    case 0n: lt_shift(b, 7n)
    case 1n+ +k1:
    match k1:
      case 0n: lt_shift(b, 6n)
      case 1n+ +k2:
      match k2:
        case 0n: lt_shift(b, 5n)
        case 1n+ +k3:
        match k3:
          case 0n: lt_shift(b, 4n)
          case 1n+ +k4:
          match k4:
            case 0n: lt_shift(b, 3n)
            case 1n+ +k5:
            match k5:
              case 0n: lt_shift(b, 2n)
              case 1n+ +k6:
              match k6:
                case 0n: lt_shift(b, 1n)
                case 1n+ +k7:
                match k7:
                  case 0n: lt_shift(b, 0n)
                  case 1n+ +k8:
                  Empty.absurd({Nat.is_lt(Nat.add(8n+k8, b), Nat.add(8n, b)) == True{} : Bool}, MS.false_true(Equal.trans(Bool, False{}, Nat.is_lt(k8, 0n), True{}, Equal.sym(Bool, Nat.is_lt(k8, 0n), False{}, F.nat__not_lt_zero(k8)), hk)))

# Word b + k (k < 8) lies below a length that holds words b .. b + 7.
def bnd(+b: Nat, +k: Nat, +len: Nat, +hk: {Nat.is_lt(k, 8n) == True{} : Bool}, +cap: {Nat.is_le(Nat.add(8n, b), len) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(b, k), len) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(b, k), Nat.add(k, b), F.lru_map_difference_order__add_commute(b, k)) : {Nat.is_lt(_, len) == True{} : Bool}
  F.nat__lt_le_trans(Nat.add(k, b), Nat.add(8n, b), len, bnd_k(b, k, hk), cap)

# The limbs of the words from 8i are the chunk bytes of chunk i, then the limbs
# of the words from 8(i + 1).
law limbs8:
  for +W: List<&2, U32>
  for +i: Nat
  for +cap: {Nat.is_le(Nat.add(8n, O.e8(i)), F.spec_common__length(U32, W)) == True{} : Bool}
  {FX.limbs(wdrop(O.e8(i), W)) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
def limbs8(W, i, cap):
  %MR.add_zero(O.e8(i)) : {FX.limbs(wdrop(_, W)) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 0n), W), Con{MR.wd(W, Nat.add(O.e8(i), 0n)), wdrop(Nat.add(O.e8(i), 1n), W)}, eta_at(O.e8(i), 0n, W, bnd(O.e8(i), 0n, F.spec_common__length(U32, W), {==}, cap))) :
    {FX.limbs(_) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 1n), W), Con{MR.wd(W, Nat.add(O.e8(i), 1n)), wdrop(Nat.add(O.e8(i), 2n), W)}, eta_at(O.e8(i), 1n, W, bnd(O.e8(i), 1n, F.spec_common__length(U32, W), {==}, cap))) :
    {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), FX.limbs(_)) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 2n), W), Con{MR.wd(W, Nat.add(O.e8(i), 2n)), wdrop(Nat.add(O.e8(i), 3n), W)}, eta_at(O.e8(i), 2n, W, bnd(O.e8(i), 2n, F.spec_common__length(U32, W), {==}, cap))) :
    {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 1n))), FX.limbs(_))) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 3n), W), Con{MR.wd(W, Nat.add(O.e8(i), 3n)), wdrop(Nat.add(O.e8(i), 4n), W)}, eta_at(O.e8(i), 3n, W, bnd(O.e8(i), 3n, F.spec_common__length(U32, W), {==}, cap))) :
    {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 1n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 2n))), FX.limbs(_)))) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 4n), W), Con{MR.wd(W, Nat.add(O.e8(i), 4n)), wdrop(Nat.add(O.e8(i), 5n), W)}, eta_at(O.e8(i), 4n, W, bnd(O.e8(i), 4n, F.spec_common__length(U32, W), {==}, cap))) :
    {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 1n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 2n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 3n))), FX.limbs(_))))) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 5n), W), Con{MR.wd(W, Nat.add(O.e8(i), 5n)), wdrop(Nat.add(O.e8(i), 6n), W)}, eta_at(O.e8(i), 5n, W, bnd(O.e8(i), 5n, F.spec_common__length(U32, W), {==}, cap))) :
    {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 1n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 2n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 3n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 4n))), FX.limbs(_)))))) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 6n), W), Con{MR.wd(W, Nat.add(O.e8(i), 6n)), wdrop(Nat.add(O.e8(i), 7n), W)}, eta_at(O.e8(i), 6n, W, bnd(O.e8(i), 6n, F.spec_common__length(U32, W), {==}, cap))) :
    {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 1n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 2n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 3n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 4n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 5n))), FX.limbs(_))))))) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(List<&2, U32>, wdrop(Nat.add(O.e8(i), 7n), W), Con{MR.wd(W, Nat.add(O.e8(i), 7n)), wdrop(Nat.add(O.e8(i), 8n), W)}, eta_at(O.e8(i), 7n, W, bnd(O.e8(i), 7n, F.spec_common__length(U32, W), {==}, cap))) :
    {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 1n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 2n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 3n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 4n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 5n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 6n))), FX.limbs(_)))))))) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  %Equal.sym(Nat, Nat.add(O.e8(i), 8n), Nat.add(8n, O.e8(i)), F.lru_map_difference_order__add_commute(O.e8(i), 8n)) : {List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 0n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 1n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 2n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 3n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 4n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 5n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 6n))), List.append(&2, U32, I.limb(MR.wd(W, Nat.add(O.e8(i), 7n))), FX.limbs(wdrop(_, W)))))))))) == List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))) : +List<U32>}
  {==}

# ---- chunks ----------------------------------------------------------------------

law bytes_cw:
  for +W: List<&2, U32>
  for +i: Nat
  {D.bytes(MR.cw(W, i)) == cb(W, i) : +List<U32>}
def bytes_cw(W, i): RL.bytes_8(MR.wd(W, Nat.add(O.e8(i), 0n)), MR.wd(W, Nat.add(O.e8(i), 1n)), MR.wd(W, Nat.add(O.e8(i), 2n)), MR.wd(W, Nat.add(O.e8(i), 3n)), MR.wd(W, Nat.add(O.e8(i), 4n)), MR.wd(W, Nat.add(O.e8(i), 5n)), MR.wd(W, Nat.add(O.e8(i), 6n)), MR.wd(W, Nat.add(O.e8(i), 7n)))

law app_snoc:
  for +acc: +List<+List<U32>>
  for +x: +List<U32>
  for +ys: +List<+List<U32>>
  {List.append(&2, +List<U32>, List.append(&2, +List<U32>, acc, [x]), ys) == List.append(&2, +List<U32>, acc, x <> ys) : +List<+List<U32>>}
def app_snoc(acc, x, ys):
  match acc:
    case Nil{}: {==}
    case Con{+a, +t}:
      %app_snoc(t, x, ys) : {a <> List.append(&2, +List<U32>, List.append(&2, +List<U32>, t, [x]), ys) == a <> _ : +List<+List<U32>>}
      {==}

law le_refl:
  for +n: Nat
  {Nat.is_le(n, n) == True{} : Bool}
def le_refl(n):
  match n:
    case 0n: {==}
    case 1n+ +p: le_refl(p)

law le_plus8:
  for +x: Nat
  {Nat.is_le(x, Nat.add(8n, x)) == True{} : Bool}
def le_plus8(x):
  match x:
    case 0n: {==}
    case 1n+ +y: le_plus8(y)

# Chunk i lies inside an array that holds chunks i .. i + q.
law e8_le:
  for +i: Nat
  for +q: Nat
  {Nat.is_le(Nat.add(8n, O.e8(i)), O.e8(Nat.add(1n+q, i))) == True{} : Bool}
def e8_le(i, q):
  match q:
    case 0n: le_refl(Nat.add(8n, O.e8(i)))
    case 1n+ +p:
      F.nat__le_trans(Nat.add(8n, O.e8(i)), O.e8(Nat.add(1n+p, i)), O.e8(Nat.add(2n+p, i)), e8_le(i, p), le_plus8(O.e8(Nat.add(1n+p, i))))

# The last chunk: its r bytes, zero padded to 32 (the slack is zero).
def chunk_last(+r: Nat, +W: List<&2, U32>, +i: Nat, +acc: +List<+List<U32>>,
    +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool},
    +slack: {bdrop(r, cb(W, Nat.add(0n, i))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>})
    -> {Pack.scan(btake(r, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [cb(W, i)]) : +List<+List<U32>>}:
  match r:
    case 0n: Empty.absurd({Pack.scan(btake(0n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [cb(W, i)]) : +List<+List<U32>>}, MS.false_true(h1))
    case 1n+ +r1:
    match r1:
      case 0n:
        %Equal.sym(+List<U32>, bdrop(1n, cb(W, i)), SP.zero_bytes(31n), slack) :
          {Pack.scan(btake(1n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(1n, cb(W, i)), _)]) : +List<+List<U32>>}
        {==}
      case 1n+ +r2:
      match r2:
        case 0n:
          %Equal.sym(+List<U32>, bdrop(2n, cb(W, i)), SP.zero_bytes(30n), slack) :
            {Pack.scan(btake(2n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(2n, cb(W, i)), _)]) : +List<+List<U32>>}
          {==}
        case 1n+ +r3:
        match r3:
          case 0n:
            %Equal.sym(+List<U32>, bdrop(3n, cb(W, i)), SP.zero_bytes(29n), slack) :
              {Pack.scan(btake(3n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(3n, cb(W, i)), _)]) : +List<+List<U32>>}
            {==}
          case 1n+ +r4:
          match r4:
            case 0n:
              %Equal.sym(+List<U32>, bdrop(4n, cb(W, i)), SP.zero_bytes(28n), slack) :
                {Pack.scan(btake(4n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(4n, cb(W, i)), _)]) : +List<+List<U32>>}
              {==}
            case 1n+ +r5:
            match r5:
              case 0n:
                %Equal.sym(+List<U32>, bdrop(5n, cb(W, i)), SP.zero_bytes(27n), slack) :
                  {Pack.scan(btake(5n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(5n, cb(W, i)), _)]) : +List<+List<U32>>}
                {==}
              case 1n+ +r6:
              match r6:
                case 0n:
                  %Equal.sym(+List<U32>, bdrop(6n, cb(W, i)), SP.zero_bytes(26n), slack) :
                    {Pack.scan(btake(6n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(6n, cb(W, i)), _)]) : +List<+List<U32>>}
                  {==}
                case 1n+ +r7:
                match r7:
                  case 0n:
                    %Equal.sym(+List<U32>, bdrop(7n, cb(W, i)), SP.zero_bytes(25n), slack) :
                      {Pack.scan(btake(7n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(7n, cb(W, i)), _)]) : +List<+List<U32>>}
                    {==}
                  case 1n+ +r8:
                  match r8:
                    case 0n:
                      %Equal.sym(+List<U32>, bdrop(8n, cb(W, i)), SP.zero_bytes(24n), slack) :
                        {Pack.scan(btake(8n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(8n, cb(W, i)), _)]) : +List<+List<U32>>}
                      {==}
                    case 1n+ +r9:
                    match r9:
                      case 0n:
                        %Equal.sym(+List<U32>, bdrop(9n, cb(W, i)), SP.zero_bytes(23n), slack) :
                          {Pack.scan(btake(9n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(9n, cb(W, i)), _)]) : +List<+List<U32>>}
                        {==}
                      case 1n+ +r10:
                      match r10:
                        case 0n:
                          %Equal.sym(+List<U32>, bdrop(10n, cb(W, i)), SP.zero_bytes(22n), slack) :
                            {Pack.scan(btake(10n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(10n, cb(W, i)), _)]) : +List<+List<U32>>}
                          {==}
                        case 1n+ +r11:
                        match r11:
                          case 0n:
                            %Equal.sym(+List<U32>, bdrop(11n, cb(W, i)), SP.zero_bytes(21n), slack) :
                              {Pack.scan(btake(11n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(11n, cb(W, i)), _)]) : +List<+List<U32>>}
                            {==}
                          case 1n+ +r12:
                          match r12:
                            case 0n:
                              %Equal.sym(+List<U32>, bdrop(12n, cb(W, i)), SP.zero_bytes(20n), slack) :
                                {Pack.scan(btake(12n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(12n, cb(W, i)), _)]) : +List<+List<U32>>}
                              {==}
                            case 1n+ +r13:
                            match r13:
                              case 0n:
                                %Equal.sym(+List<U32>, bdrop(13n, cb(W, i)), SP.zero_bytes(19n), slack) :
                                  {Pack.scan(btake(13n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(13n, cb(W, i)), _)]) : +List<+List<U32>>}
                                {==}
                              case 1n+ +r14:
                              match r14:
                                case 0n:
                                  %Equal.sym(+List<U32>, bdrop(14n, cb(W, i)), SP.zero_bytes(18n), slack) :
                                    {Pack.scan(btake(14n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(14n, cb(W, i)), _)]) : +List<+List<U32>>}
                                  {==}
                                case 1n+ +r15:
                                match r15:
                                  case 0n:
                                    %Equal.sym(+List<U32>, bdrop(15n, cb(W, i)), SP.zero_bytes(17n), slack) :
                                      {Pack.scan(btake(15n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(15n, cb(W, i)), _)]) : +List<+List<U32>>}
                                    {==}
                                  case 1n+ +r16:
                                  match r16:
                                    case 0n:
                                      %Equal.sym(+List<U32>, bdrop(16n, cb(W, i)), SP.zero_bytes(16n), slack) :
                                        {Pack.scan(btake(16n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(16n, cb(W, i)), _)]) : +List<+List<U32>>}
                                      {==}
                                    case 1n+ +r17:
                                    match r17:
                                      case 0n:
                                        %Equal.sym(+List<U32>, bdrop(17n, cb(W, i)), SP.zero_bytes(15n), slack) :
                                          {Pack.scan(btake(17n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(17n, cb(W, i)), _)]) : +List<+List<U32>>}
                                        {==}
                                      case 1n+ +r18:
                                      match r18:
                                        case 0n:
                                          %Equal.sym(+List<U32>, bdrop(18n, cb(W, i)), SP.zero_bytes(14n), slack) :
                                            {Pack.scan(btake(18n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(18n, cb(W, i)), _)]) : +List<+List<U32>>}
                                          {==}
                                        case 1n+ +r19:
                                        match r19:
                                          case 0n:
                                            %Equal.sym(+List<U32>, bdrop(19n, cb(W, i)), SP.zero_bytes(13n), slack) :
                                              {Pack.scan(btake(19n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(19n, cb(W, i)), _)]) : +List<+List<U32>>}
                                            {==}
                                          case 1n+ +r20:
                                          match r20:
                                            case 0n:
                                              %Equal.sym(+List<U32>, bdrop(20n, cb(W, i)), SP.zero_bytes(12n), slack) :
                                                {Pack.scan(btake(20n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(20n, cb(W, i)), _)]) : +List<+List<U32>>}
                                              {==}
                                            case 1n+ +r21:
                                            match r21:
                                              case 0n:
                                                %Equal.sym(+List<U32>, bdrop(21n, cb(W, i)), SP.zero_bytes(11n), slack) :
                                                  {Pack.scan(btake(21n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(21n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                {==}
                                              case 1n+ +r22:
                                              match r22:
                                                case 0n:
                                                  %Equal.sym(+List<U32>, bdrop(22n, cb(W, i)), SP.zero_bytes(10n), slack) :
                                                    {Pack.scan(btake(22n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(22n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                  {==}
                                                case 1n+ +r23:
                                                match r23:
                                                  case 0n:
                                                    %Equal.sym(+List<U32>, bdrop(23n, cb(W, i)), SP.zero_bytes(9n), slack) :
                                                      {Pack.scan(btake(23n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(23n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                    {==}
                                                  case 1n+ +r24:
                                                  match r24:
                                                    case 0n:
                                                      %Equal.sym(+List<U32>, bdrop(24n, cb(W, i)), SP.zero_bytes(8n), slack) :
                                                        {Pack.scan(btake(24n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(24n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                      {==}
                                                    case 1n+ +r25:
                                                    match r25:
                                                      case 0n:
                                                        %Equal.sym(+List<U32>, bdrop(25n, cb(W, i)), SP.zero_bytes(7n), slack) :
                                                          {Pack.scan(btake(25n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(25n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                        {==}
                                                      case 1n+ +r26:
                                                      match r26:
                                                        case 0n:
                                                          %Equal.sym(+List<U32>, bdrop(26n, cb(W, i)), SP.zero_bytes(6n), slack) :
                                                            {Pack.scan(btake(26n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(26n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                          {==}
                                                        case 1n+ +r27:
                                                        match r27:
                                                          case 0n:
                                                            %Equal.sym(+List<U32>, bdrop(27n, cb(W, i)), SP.zero_bytes(5n), slack) :
                                                              {Pack.scan(btake(27n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(27n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                            {==}
                                                          case 1n+ +r28:
                                                          match r28:
                                                            case 0n:
                                                              %Equal.sym(+List<U32>, bdrop(28n, cb(W, i)), SP.zero_bytes(4n), slack) :
                                                                {Pack.scan(btake(28n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(28n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                              {==}
                                                            case 1n+ +r29:
                                                            match r29:
                                                              case 0n:
                                                                %Equal.sym(+List<U32>, bdrop(29n, cb(W, i)), SP.zero_bytes(3n), slack) :
                                                                  {Pack.scan(btake(29n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(29n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                                {==}
                                                              case 1n+ +r30:
                                                              match r30:
                                                                case 0n:
                                                                  %Equal.sym(+List<U32>, bdrop(30n, cb(W, i)), SP.zero_bytes(2n), slack) :
                                                                    {Pack.scan(btake(30n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(30n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                                  {==}
                                                                case 1n+ +r31:
                                                                match r31:
                                                                  case 0n:
                                                                    %Equal.sym(+List<U32>, bdrop(31n, cb(W, i)), SP.zero_bytes(1n), slack) :
                                                                      {Pack.scan(btake(31n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(31n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                                    {==}
                                                                  case 1n+ +r32:
                                                                  match r32:
                                                                    case 0n:
                                                                      %Equal.sym(+List<U32>, bdrop(32n, cb(W, i)), SP.zero_bytes(0n), slack) :
                                                                        {Pack.scan(btake(32n, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [List.append(&2, U32, btake(32n, cb(W, i)), _)]) : +List<+List<U32>>}
                                                                      {==}
                                                                    case 1n+ +r33:
                                                                    Empty.absurd({Pack.scan(btake(33n+r33, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [cb(W, i)]) : +List<+List<U32>>}, MS.false_true(h32))

# Packing the bytes of the words from chunk i, cut after 32q + r bytes (the last
# chunk is r bytes long, the rest of it zero), gives the chunk digests' bytes.
law chunk_scan:
  for +q: Nat
  for +r: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +acc: +List<+List<U32>>
  for +h1: {Nat.is_lt(0n, r) == True{} : Bool}
  for +h32: {Nat.is_le(r, 32n) == True{} : Bool}
  for +cap: {Nat.is_le(O.e8(Nat.add(1n+q, i)), F.spec_common__length(U32, W)) == True{} : Bool}
  for +slack: {bdrop(r, cb(W, Nat.add(q, i))) == SP.zero_bytes(Nat.sub(32n, r)) : +List<U32>}
  {Pack.scan(btake(Nat.add(e32(q), r), FX.limbs(wdrop(O.e8(i), W))), 31n, [], acc) == List.append(&2, +List<U32>, acc, MS.bytes_list(MR.clist(1n+q, W, i))) : +List<+List<U32>>}
def chunk_scan(q, r, W, i, acc, h1, h32, cap, slack):
  match q:
    case 0n:
      %Equal.sym(+List<U32>, FX.limbs(wdrop(O.e8(i), W)), List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))), limbs8(W, i, cap)) :
        {Pack.scan(btake(r, _), 31n, [], acc) == List.append(&2, +List<U32>, acc, MS.bytes_list(MR.clist(1n, W, i))) : +List<+List<U32>>}
      %Equal.sym(+List<U32>, D.bytes(MR.cw(W, i)), cb(W, i), bytes_cw(W, i)) :
        {Pack.scan(btake(r, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, [_]) : +List<+List<U32>>}
      chunk_last(r, W, i, acc, h1, h32, slack)
    case 1n+ +p:
      %Equal.sym(+List<U32>, FX.limbs(wdrop(O.e8(i), W)), List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))), limbs8(W, i, F.nat__le_trans(Nat.add(8n, O.e8(i)), O.e8(Nat.add(2n+p, i)), F.spec_common__length(U32, W), e8_le(i, 1n+p), cap))) :
        {Pack.scan(btake(Nat.add(e32(1n+p), r), _), 31n, [], acc) == List.append(&2, +List<U32>, acc, MS.bytes_list(MR.clist(2n+p, W, i))) : +List<+List<U32>>}
      %Equal.sym(+List<U32>, D.bytes(MR.cw(W, i)), cb(W, i), bytes_cw(W, i)) :
        {Pack.scan(btake(Nat.add(e32(1n+p), r), List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == List.append(&2, +List<U32>, acc, _ <> MS.bytes_list(MR.clist(1n+p, W, 1n+i))) : +List<+List<U32>>}
      %app_snoc(acc, cb(W, i), MS.bytes_list(MR.clist(1n+p, W, 1n+i))) :
        {Pack.scan(btake(Nat.add(e32(1n+p), r), List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), 31n, [], acc) == _ : +List<+List<U32>>}
      chunk_scan(p, r, W, 1n+i, List.append(&2, +List<U32>, acc, [cb(W, i)]), h1, h32, Equal.trans(Bool, Nat.is_le(O.e8(Nat.add(1n+p, 1n+i)), F.spec_common__length(U32, W)), Nat.is_le(O.e8(Nat.add(2n+p, i)), F.spec_common__length(U32, W)), True{}, Equal.cong(Nat, Bool, x => Nat.is_le(O.e8(1n+x), F.spec_common__length(U32, W)), Nat.add(p, 1n+i), 1n+Nat.add(p, i), MR.add_succ(p, i)), cap), Equal.trans(+List<U32>, bdrop(r, cb(W, Nat.add(p, 1n+i))), bdrop(r, cb(W, Nat.add(1n+p, i))), SP.zero_bytes(Nat.sub(32n, r)), Equal.cong(Nat, +List<U32>, x => bdrop(r, cb(W, x)), Nat.add(p, 1n+i), 1n+Nat.add(p, i), MR.add_succ(p, i)), slack))

def and_left(+a: Bool, +b: Bool, +e: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case True{}: {==}
    case False{}: Empty.absurd({False{} == True{} : Bool}, MS.false_true(e))

def and_right(+a: Bool, +b: Bool, +e: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}:
  match a:
    case True{}: e
    case False{}: Empty.absurd({b == True{} : Bool}, MS.false_true(e))

law take_app_le:
  for +c: Nat
  for +m: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +ec: {Nat.is_le(c, m) == True{} : Bool}
  for +ex: {SP.byte_scope(m, xs) == True{} : Bool}
  {btake(c, List.append(&2, U32, xs, ys)) == btake(c, xs) : +List<U32>}
def take_app_le(c, m, xs, ys, ec, ex):
  match c:
    case 0n: {==}
    case 1n+ +p:
      match m:
        case 0n: Empty.absurd({btake(1n+p, List.append(&2, U32, xs, ys)) == btake(1n+p, xs) : +List<U32>}, MS.false_true(ec))
        case 1n+ +k:
          match xs:
            case Nil{}: Empty.absurd({btake(1n+p, List.append(&2, U32, Nil{}, ys)) == btake(1n+p, Nil{}) : +List<U32>}, MS.false_true(ex))
            case Con{+x, +t}:
              F.list__cons_cong(U32, x, btake(p, List.append(&2, U32, t, ys)), btake(p, t),
                take_app_le(p, k, t, ys, ec, and_right(U32.is_lt(x, 256), SP.byte_scope(k, t), ex)))

# A prefix of at most the first list's length stays inside it.
law take_app32:
  for +c: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +ec: {Nat.is_le(c, 32n) == True{} : Bool}
  for +ex: {SP.byte_scope(32n, xs) == True{} : Bool}
  {btake(c, List.append(&2, U32, xs, ys)) == btake(c, xs) : +List<U32>}
def take_app32(c, xs, ys, ec, ex): take_app_le(c, 32n, xs, ys, ec, ex)

# ---- byte scope ----------------------------------------------------------------

law scope_app:
  for +m: Nat
  for +n: Nat
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +ex: {SP.byte_scope(m, xs) == True{} : Bool}
  for +ey: {SP.byte_scope(n, ys) == True{} : Bool}
  {SP.byte_scope(Nat.add(m, n), List.append(&2, U32, xs, ys)) == True{} : Bool}
def scope_app(m, n, xs, ys, ex, ey):
  match m:
    case 0n:
      match xs:
        case Nil{}: ey
        case Con{x, t}: Empty.absurd({SP.byte_scope(Nat.add(0n, n), List.append(&2, U32, Con{x, t}, ys)) == True{} : Bool}, MS.false_true(ex))
    case 1n+ +p:
      match xs:
        case Nil{}: Empty.absurd({SP.byte_scope(Nat.add(1n+p, n), List.append(&2, U32, Nil{}, ys)) == True{} : Bool}, MS.false_true(ex))
        case Con{+x, +t}:
          %Equal.sym(Bool, U32.is_lt(x, 256), True{}, and_left(U32.is_lt(x, 256), SP.byte_scope(p, t), ex)) :
            {Bool.and(_, SP.byte_scope(Nat.add(p, n), List.append(&2, U32, t, ys))) == True{} : Bool}
          scope_app(p, n, t, ys, and_right(U32.is_lt(x, 256), SP.byte_scope(p, t), ex), ey)

law scope_prefix:
  for +c: Nat
  for +m: Nat
  for +xs: +List<U32>
  for +ec: {Nat.is_le(c, m) == True{} : Bool}
  for +ex: {SP.byte_scope(m, xs) == True{} : Bool}
  {SP.byte_scope(c, btake(c, xs)) == True{} : Bool}
def scope_prefix(c, m, xs, ec, ex):
  match c:
    case 0n: {==}
    case 1n+ +p:
      match m:
        case 0n: Empty.absurd({SP.byte_scope(1n+p, btake(1n+p, xs)) == True{} : Bool}, MS.false_true(ec))
        case 1n+ +k:
          match xs:
            case Nil{}: Empty.absurd({SP.byte_scope(1n+p, btake(1n+p, Nil{})) == True{} : Bool}, MS.false_true(ex))
            case Con{+x, +t}:
              %Equal.sym(Bool, U32.is_lt(x, 256), True{}, and_left(U32.is_lt(x, 256), SP.byte_scope(k, t), ex)) :
                {Bool.and(_, SP.byte_scope(p, btake(p, t))) == True{} : Bool}
              scope_prefix(p, k, t, ec, and_right(U32.is_lt(x, 256), SP.byte_scope(k, t), ex))

law scope_cb:
  for +W: List<&2, U32>
  for +i: Nat
  {SP.byte_scope(32n, cb(W, i)) == True{} : Bool}
def scope_cb(W, i): FX.scope_limbs([MR.wd(W, Nat.add(O.e8(i), 0n)), MR.wd(W, Nat.add(O.e8(i), 1n)), MR.wd(W, Nat.add(O.e8(i), 2n)), MR.wd(W, Nat.add(O.e8(i), 3n)), MR.wd(W, Nat.add(O.e8(i), 4n)), MR.wd(W, Nat.add(O.e8(i), 5n)), MR.wd(W, Nat.add(O.e8(i), 6n)), MR.wd(W, Nat.add(O.e8(i), 7n))])

# The first 32q + r bytes of the words from chunk i are 32q + r bytes.
law chunk_scope:
  for +q: Nat
  for +r: Nat
  for +W: List<&2, U32>
  for +i: Nat
  for +h32: {Nat.is_le(r, 32n) == True{} : Bool}
  for +cap: {Nat.is_le(O.e8(Nat.add(1n+q, i)), F.spec_common__length(U32, W)) == True{} : Bool}
  {SP.byte_scope(Nat.add(e32(q), r), btake(Nat.add(e32(q), r), FX.limbs(wdrop(O.e8(i), W)))) == True{} : Bool}
def chunk_scope(q, r, W, i, h32, cap):
  match q:
    case 0n:
      %Equal.sym(+List<U32>, FX.limbs(wdrop(O.e8(i), W)), List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))), limbs8(W, i, cap)) :
        {SP.byte_scope(r, btake(r, _)) == True{} : Bool}
      %Equal.sym(+List<U32>, btake(r, List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)))), btake(r, cb(W, i)), take_app32(r, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W)), h32, scope_cb(W, i))) :
        {SP.byte_scope(r, _) == True{} : Bool}
      scope_prefix(r, 32n, cb(W, i), h32, scope_cb(W, i))
    case 1n+ +p:
      %Equal.sym(+List<U32>, FX.limbs(wdrop(O.e8(i), W)), List.append(&2, U32, cb(W, i), FX.limbs(wdrop(O.e8(1n+i), W))), limbs8(W, i, F.nat__le_trans(Nat.add(8n, O.e8(i)), O.e8(Nat.add(2n+p, i)), F.spec_common__length(U32, W), e8_le(i, 1n+p), cap))) :
        {SP.byte_scope(Nat.add(e32(1n+p), r), btake(Nat.add(e32(1n+p), r), _)) == True{} : Bool}
      scope_app(32n, Nat.add(e32(p), r), cb(W, i), btake(Nat.add(e32(p), r), FX.limbs(wdrop(O.e8(1n+i), W))), scope_cb(W, i), chunk_scope(p, r, W, 1n+i, h32, Equal.trans(Bool, Nat.is_le(O.e8(Nat.add(1n+p, 1n+i)), F.spec_common__length(U32, W)), Nat.is_le(O.e8(Nat.add(2n+p, i)), F.spec_common__length(U32, W)), True{}, Equal.cong(Nat, Bool, x => Nat.is_le(O.e8(1n+x), F.spec_common__length(U32, W)), Nat.add(p, 1n+i), 1n+Nat.add(p, i), MR.add_succ(p, i)), cap)))

# ---- the chunk count -------------------------------------------------------------

law add_assoc:
  for +x: Nat
  for +y: Nat
  for +z: Nat
  {Nat.add(Nat.add(x, y), z) == Nat.add(x, Nat.add(y, z)) : Nat}
def add_assoc(x, y, z):
  match x:
    case 0n: {==}
    case 1n+ +p:
      %add_assoc(p, y, z) : {1n+Nat.add(Nat.add(p, y), z) == 1n+_ : Nat}
      {==}

# Division by 32 peels 32 per chunk.
law divmod_e32:
  for +q: Nat
  for +y: Nat
  for +d: Nat
  {Nat.divmod.go(Nat.add(e32(q), y), 31n, d, 0n) == Nat.divmod.go(y, 31n, Nat.add(q, d), 0n) : Nat & Nat}
def divmod_e32(q, y, d):
  match q:
    case 0n: {==}
    case 1n+ +p:
      %MR.add_succ(p, d) : {Nat.divmod.go(Nat.add(e32(p), y), 31n, 1n+d, 0n) == Nat.divmod.go(y, 31n, _, 0n) : Nat & Nat}
      divmod_e32(p, y, 1n+d)


def count_last(+q: Nat, +r: Nat, +h1: {Nat.is_lt(0n, r) == True{} : Bool}, +h32: {Nat.is_le(r, 32n) == True{} : Bool})
    -> {Pair.fst(Nat, Nat, Nat.divmod.go(Nat.add(r, 31n), 31n, q, 0n)) == 1n+q : Nat}:
  match r:
    case 0n: Empty.absurd({Pair.fst(Nat, Nat, Nat.divmod.go(Nat.add(0n, 31n), 31n, q, 0n)) == 1n+q : Nat}, MS.false_true(h1))
    case 1n+ +r1:
    match r1:
      case 0n: {==}
      case 1n+ +r2:
      match r2:
        case 0n: {==}
        case 1n+ +r3:
        match r3:
          case 0n: {==}
          case 1n+ +r4:
          match r4:
            case 0n: {==}
            case 1n+ +r5:
            match r5:
              case 0n: {==}
              case 1n+ +r6:
              match r6:
                case 0n: {==}
                case 1n+ +r7:
                match r7:
                  case 0n: {==}
                  case 1n+ +r8:
                  match r8:
                    case 0n: {==}
                    case 1n+ +r9:
                    match r9:
                      case 0n: {==}
                      case 1n+ +r10:
                      match r10:
                        case 0n: {==}
                        case 1n+ +r11:
                        match r11:
                          case 0n: {==}
                          case 1n+ +r12:
                          match r12:
                            case 0n: {==}
                            case 1n+ +r13:
                            match r13:
                              case 0n: {==}
                              case 1n+ +r14:
                              match r14:
                                case 0n: {==}
                                case 1n+ +r15:
                                match r15:
                                  case 0n: {==}
                                  case 1n+ +r16:
                                  match r16:
                                    case 0n: {==}
                                    case 1n+ +r17:
                                    match r17:
                                      case 0n: {==}
                                      case 1n+ +r18:
                                      match r18:
                                        case 0n: {==}
                                        case 1n+ +r19:
                                        match r19:
                                          case 0n: {==}
                                          case 1n+ +r20:
                                          match r20:
                                            case 0n: {==}
                                            case 1n+ +r21:
                                            match r21:
                                              case 0n: {==}
                                              case 1n+ +r22:
                                              match r22:
                                                case 0n: {==}
                                                case 1n+ +r23:
                                                match r23:
                                                  case 0n: {==}
                                                  case 1n+ +r24:
                                                  match r24:
                                                    case 0n: {==}
                                                    case 1n+ +r25:
                                                    match r25:
                                                      case 0n: {==}
                                                      case 1n+ +r26:
                                                      match r26:
                                                        case 0n: {==}
                                                        case 1n+ +r27:
                                                        match r27:
                                                          case 0n: {==}
                                                          case 1n+ +r28:
                                                          match r28:
                                                            case 0n: {==}
                                                            case 1n+ +r29:
                                                            match r29:
                                                              case 0n: {==}
                                                              case 1n+ +r30:
                                                              match r30:
                                                                case 0n: {==}
                                                                case 1n+ +r31:
                                                                match r31:
                                                                  case 0n: {==}
                                                                  case 1n+ +r32:
                                                                  match r32:
                                                                    case 0n: {==}
                                                                    case 1n+ +r33:
                                                                    Empty.absurd({Pair.fst(Nat, Nat, Nat.divmod.go(Nat.add(33n+r33, 31n), 31n, q, 0n)) == 1n+q : Nat}, MS.false_true(h32))
# 32q + r bytes (1 <= r <= 32) are q + 1 chunks.
law chunks_count:
  for +q: Nat
  for +r: Nat
  for +h1: {Nat.is_lt(0n, r) == True{} : Bool}
  for +h32: {Nat.is_le(r, 32n) == True{} : Bool}
  {Nat.div(Nat.add(Nat.add(e32(q), r), 31n), 32n) == 1n+q : Nat}
def chunks_count(q, r, h1, h32):
  %Equal.sym(Nat, Nat.add(Nat.add(e32(q), r), 31n), Nat.add(e32(q), Nat.add(r, 31n)), add_assoc(e32(q), r, 31n)) :
    {Nat.div(_, 32n) == 1n+q : Nat}
  %Equal.sym(Nat & Nat, Nat.divmod.go(Nat.add(e32(q), Nat.add(r, 31n)), 31n, 0n, 0n), Nat.divmod.go(Nat.add(r, 31n), 31n, Nat.add(q, 0n), 0n), divmod_e32(q, Nat.add(r, 31n), 0n)) :
    {Pair.fst(Nat, Nat, _) == 1n+q : Nat}
  %Equal.sym(Nat, Nat.add(q, 0n), q, MR.add_zero(q)) :
    {Pair.fst(Nat, Nat, Nat.divmod.go(Nat.add(r, 31n), 31n, _, 0n)) == 1n+q : Nat}
  count_last(q, r, h1, h32)

# A scoped byte list is in the byte domain and has exactly that length.
law scope_dom:
  for +k: Nat
  for +xs: +List<U32>
  for +e: {SP.byte_scope(k, xs) == True{} : Bool}
  {SP.bytes_domain(xs) == True{} : Bool}
def scope_dom(k, xs, e):
  match k:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{x, t}: Empty.absurd({SP.bytes_domain(Con{x, t}) == True{} : Bool}, MS.false_true(e))
    case 1n+ +p:
      match xs:
        case Nil{}: Empty.absurd({SP.bytes_domain(Nil{}) == True{} : Bool}, MS.false_true(e))
        case Con{+x, +t}:
          %Equal.sym(Bool, U32.is_lt(x, 256), True{}, and_left(U32.is_lt(x, 256), SP.byte_scope(p, t), e)) :
            {Bool.and(_, SP.bytes_domain(t)) == True{} : Bool}
          scope_dom(p, t, and_right(U32.is_lt(x, 256), SP.byte_scope(p, t), e))

law scope_len:
  for +k: Nat
  for +xs: +List<U32>
  for +e: {SP.byte_scope(k, xs) == True{} : Bool}
  {List.length(&2, U32, xs) == k : Nat}
def scope_len(k, xs, e):
  match k:
    case 0n:
      match xs:
        case Nil{}: {==}
        case Con{x, t}: Empty.absurd({List.length(&2, U32, Con{x, t}) == 0n : Nat}, MS.false_true(e))
    case 1n+ +p:
      match xs:
        case Nil{}: Empty.absurd({List.length(&2, U32, Nil{}) == 1n+p : Nat}, MS.false_true(e))
        case Con{+x, +t}:
          %scope_len(p, t, and_right(U32.is_lt(x, 256), SP.byte_scope(p, t), e)) : {1n+List.length(&2, U32, t) == 1n+_ : Nat}
          {==}

# A Nat equation from its Bool comparison. The checker evaluates `Nat.is_eq`
# iteratively, but compares Nat terms by recursion on their depth, so a size
# fact past ~2^14 is stated to the checker as a comparison and turned into an
# equation here, symbolically.
law nat_eq:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.is_eq(a, b) == True{} : Bool}
  {a == b : Nat}
def nat_eq(a, b, e):
  match a:
    case 0n:
      match b:
        case 0n: {==}
        case 1n+q: Empty.absurd({0n == 1n+q : Nat}, MS.false_true(e))
    case 1n+ +p:
      match b:
        case 0n: Empty.absurd({1n+p == 0n : Nat}, MS.false_true(e))
        case 1n+ +q:
          %Equal.sym(Nat, p, q, nat_eq(p, q, e)) : {1n+_ == 1n+q : Nat}
          {==}
