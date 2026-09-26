import Base
import ../../spec/bit_packing.bend as Bp
import ../../spec/primitives.bend as SP
import ../../proofs/power_division.bend as PD
import ../../proofs/word_split.bend as WSp
import ../../proofs/integer_decoding.bend as ID
import ../compact/found.bend as F
import ./vspec.bend as VS
import ./vbyte.bend as VY
import ./dk.bend as DK

# Bit lists on byte lists (spec side): the bits of a byte string whose last
# byte v is non-zero, cut before v's highest set bit (the runtime's
# O.high_bit), pack with the delimiter back to the string (bl_pack), and every
# byte string the spec's delimiter encoding produces has that shape (inv).

def W8(+v: U32) -> Word(8n): WSp.take(8n, 32n, PD.bits(v))

def lastb(bs: +List<U32>) -> U32:
  match bs:
    case Nil{}: 0
    case Con{+v, t}:
      match t:
        case Nil{}: v
        case Con{+h, r}: lastb(Con{h, r})

def nthb(bs: +List<U32>, k: Nat) -> U32:
  match bs k:
    case Nil{} _: 0
    case Con{+h, t} 0n: h
    case Con{+h, t} 1n+p: nthb(t, p)

# The value bits: every byte's eight bits, the last one's cut at its high bit.
def bl(bs: +List<U32>) -> +List<Bool>:
  match bs:
    case Nil{}: []
    case Con{+v, t}:
      match t:
        case Nil{}: VY.btk(VY.hb(v), VY.bits8(v))
        case Con{+h, r}: List.append(&2, Bool, VY.bits8(v), bl(Con{h, r}))

def blen(bs: +List<U32>) -> Nat:
  match bs:
    case Nil{}: 0n
    case Con{+v, t}:
      match t:
        case Nil{}: VY.hb(v)
        case Con{+h, r}: 8n+blen(Con{h, r})

law appB_assoc:
  for +xs: +List<Bool>
  for +ys: +List<Bool>
  for +zs: +List<Bool>
  {List.append(&2, Bool, List.append(&2, Bool, xs, ys), zs) == List.append(&2, Bool, xs, List.append(&2, Bool, ys, zs)) : +List<Bool>}
def appB_assoc(xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}:
      %appB_assoc(t, ys, zs) : {h <> List.append(&2, Bool, List.append(&2, Bool, t, ys), zs) == h <> _ : +List<Bool>}
      {==}

law lenB_app:
  for +xs: +List<Bool>
  for +ys: +List<Bool>
  {List.length(&2, Bool, List.append(&2, Bool, xs, ys)) == Nat.add(List.length(&2, Bool, xs), List.length(&2, Bool, ys)) : Nat}
def lenB_app(xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}:
      %lenB_app(t, ys) : {1n+List.length(&2, Bool, List.append(&2, Bool, t, ys)) == 1n+_ : Nat}
      {==}

law len_b8:
  for +w: Word(8n)
  {List.length(&2, Bool, VY.b8(w)) == 8n : Nat}
def len_b8(w):
  match w:
    case WCon{+c0, WCon{+c1, WCon{+c2, WCon{+c3, WCon{+c4, WCon{+c5, WCon{+c6, WCon{+c7, WNil{}}}}}}}}}: {==}

def dom_h(+v: U32, +t: +List<U32>, +d: {SP.bytes_domain(v <> t) == True{} : Bool}) -> {U32.is_lt(v, 256) == True{} : Bool}:
  F.logic__and_left(U32.is_lt(v, 256), SP.bytes_domain(t), d)
def dom_t(+v: U32, +t: +List<U32>, +d: {SP.bytes_domain(v <> t) == True{} : Bool}) -> {SP.bytes_domain(t) == True{} : Bool}:
  F.logic__and_right(U32.is_lt(v, 256), SP.bytes_domain(t), d)

# A byte is the embedding of its eight bits.
def ebyte(+v: U32, +d: {U32.is_lt(v, 256) == True{} : Bool}) -> {PD.embed8(W8(v)) == v : U32}:
  Equal.sym(U32, v, PD.embed8(W8(v)), ID.byte_shape(v, d))

def nz_e(+v: U32, +d: {U32.is_lt(v, 256) == True{} : Bool}, +nz: {U32.is_eq(v, 0) == False{} : Bool})
    -> {U32.is_eq(PD.embed8(W8(v)), 0) == False{} : Bool}:
  %Equal.sym(U32, PD.embed8(W8(v)), v, ebyte(v, d)) : {U32.is_eq(_, 0) == False{} : Bool}
  nz

def last1(+v: U32, +d: {U32.is_lt(v, 256) == True{} : Bool}, +nz: {U32.is_eq(v, 0) == False{} : Bool})
    -> {Bp.pack(List.append(&2, Bool, VY.btk(VY.hb(v), VY.bits8(v)), [True{}])) == [v] : +List<U32>}:
  %ebyte(v, d) : {Bp.pack(List.append(&2, Bool, VY.btk(VY.hb(_), VY.b8(W8(v))), [True{}])) == [_] : +List<U32>}
  VY.last_pack(W8(v), nz_e(v, d, nz))

def len1(+v: U32, +d: {U32.is_lt(v, 256) == True{} : Bool}, +nz: {U32.is_eq(v, 0) == False{} : Bool})
    -> {List.length(&2, Bool, VY.btk(VY.hb(v), VY.bits8(v))) == VY.hb(v) : Nat}:
  %ebyte(v, d) : {List.length(&2, Bool, VY.btk(VY.hb(_), VY.b8(W8(v)))) == VY.hb(_) : Nat}
  VY.last_len(W8(v), nz_e(v, d, nz))

# The value bits and the delimiter pack back to the byte string.
law bl_pack:
  for +bs: +List<U32>
  for +d: {SP.bytes_domain(bs) == True{} : Bool}
  for +nz: {U32.is_eq(lastb(bs), 0) == False{} : Bool}
  {Bp.pack(List.append(&2, Bool, bl(bs), [True{}])) == bs : +List<U32>}
def bl_pack(bs, d, nz):
  match bs:
    case Nil{}: Empty.absurd({Bp.pack(List.append(&2, Bool, bl(Nil{}), [True{}])) == Nil{} : +List<U32>}, F.logic__true_false(nz))
    case Con{+v, +t}:
      match t:
        case Nil{}: last1(v, dom_h(v, [], d), nz)
        case Con{+h, +r}:
          +R = List.append(&2, Bool, bl(Con{h, r}), [True{}])
          %Equal.sym(+List<Bool>, List.append(&2, Bool, List.append(&2, Bool, VY.bits8(v), bl(Con{h, r})), [True{}]), List.append(&2, Bool, VY.bits8(v), R),
              appB_assoc(VY.bits8(v), bl(Con{h, r}), [True{}])) :
            {Bp.pack(_) == v <> h <> r : +List<U32>}
          %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, VY.b8(W8(v)), R)), PD.embed8(W8(v)) <> Bp.pack(R), VY.oct_pack(W8(v), R)) :
            {_ == v <> h <> r : +List<U32>}
          %Equal.sym(U32, PD.embed8(W8(v)), v, ebyte(v, dom_h(v, h <> r, d))) : {_ <> Bp.pack(R) == v <> h <> r : +List<U32>}
          %Equal.sym(+List<U32>, Bp.pack(R), h <> r, bl_pack(Con{h, r}, dom_t(v, h <> r, d), nz)) : {v <> _ == v <> h <> r : +List<U32>}
          {==}

law bl_len:
  for +bs: +List<U32>
  for +d: {SP.bytes_domain(bs) == True{} : Bool}
  for +nz: {U32.is_eq(lastb(bs), 0) == False{} : Bool}
  {List.length(&2, Bool, bl(bs)) == blen(bs) : Nat}
def bl_len(bs, d, nz):
  match bs:
    case Nil{}: {==}
    case Con{+v, +t}:
      match t:
        case Nil{}: len1(v, dom_h(v, [], d), nz)
        case Con{+h, +r}:
          %Equal.sym(Nat, List.length(&2, Bool, List.append(&2, Bool, VY.bits8(v), bl(Con{h, r}))), Nat.add(List.length(&2, Bool, VY.bits8(v)), List.length(&2, Bool, bl(Con{h, r}))), lenB_app(VY.bits8(v), bl(Con{h, r}))) : {_ == 8n+blen(Con{h, r}) : Nat}
          %Equal.sym(Nat, List.length(&2, Bool, VY.b8(W8(v))), 8n, len_b8(W8(v))) : {Nat.add(_, List.length(&2, Bool, bl(Con{h, r}))) == 8n+blen(Con{h, r}) : Nat}
          %Equal.sym(Nat, List.length(&2, Bool, bl(Con{h, r})), blen(Con{h, r}), bl_len(Con{h, r}, dom_t(v, h <> r, d), nz)) : {Nat.add(8n, _) == 8n+blen(Con{h, r}) : Nat}
          {==}

# ---- the last byte, by index ----------------------------------------------------------------

law lastb_nth:
  for +t: +List<U32>
  for +v: U32
  {lastb(v <> t) == nthb(v <> t, List.length(&2, U32, t)) : U32}
def lastb_nth(t, v):
  match t:
    case Nil{}: {==}
    case Con{+h, +r}: lastb_nth(r, h)

law blen_eq:
  for +t: +List<U32>
  for +v: U32
  {blen(v <> t) == Nat.add(VS.x8(List.length(&2, U32, t)), VY.hb(lastb(v <> t))) : Nat}
def blen_eq(t, v):
  match t:
    case Nil{}: {==}
    case Con{+h, +r}:
      %Equal.sym(Nat, blen(h <> r), Nat.add(VS.x8(List.length(&2, U32, r)), VY.hb(lastb(h <> r))), blen_eq(r, h)) : {8n+_ == Nat.add(VS.x8(List.length(&2, U32, h <> r)), VY.hb(lastb(h <> r))) : Nat}
      {==}

# ---- inversion: every delimiter encoding has the shape ---------------------------------------

def P(+bits: +List<Bool>) -> +List<U32>: Bp.pack(List.append(&2, Bool, bits, [True{}]))

def mcnt(bits: +List<Bool>) -> Nat:
  match bits:
    case Con{+b0, Con{+b1, Con{+b2, Con{+b3, Con{+b4, Con{+b5, Con{+b6, Con{+b7, rest}}}}}}}}: 1n+mcnt(rest)
    case _: 0n

def IA(+bits: +List<Bool>) -> Data: {List.length(&2, U32, P(bits)) == 1n+mcnt(bits) : Nat}
def IB(+bits: +List<Bool>) -> Data: {U32.is_eq(nthb(P(bits), mcnt(bits)), 0) == False{} : Bool}
def IC(+bits: +List<Bool>) -> Data: {List.length(&2, Bool, bits) == Nat.add(VS.x8(mcnt(bits)), VY.hb(nthb(P(bits), mcnt(bits)))) : Nat}
def IF(+bits: +List<Bool>) -> Data: DK.P2(IA(bits), DK.P2(IB(bits), IC(bits)))

def inv_step(+b0: Bool, +b1: Bool, +b2: Bool, +b3: Bool, +b4: Bool, +b5: Bool, +b6: Bool, +b7: Bool, +rest: +List<Bool>, +ih: IF(rest))
    -> IF(b0 <> b1 <> b2 <> b3 <> b4 <> b5 <> b6 <> b7 <> rest):
  (+l, +r1) = ih
  (+nz, +len) = r1
  (Equal.cong(Nat, Nat, z => 1n+z, List.length(&2, U32, P(rest)), 1n+mcnt(rest), l),
   (nz, Equal.cong(Nat, Nat, z => 8n+z, List.length(&2, Bool, rest), Nat.add(VS.x8(mcnt(rest)), VY.hb(nthb(P(rest), mcnt(rest)))), len)))

law inv:
  for +bits: +List<Bool>
  IF(bits)
def inv(bits):
  match bits:
    case Nil{}: ({==}, VY.inv0())
    case Con{+b0, +t0}:
      match t0:
        case Nil{}: ({==}, VY.inv1(b0))
        case Con{+b1, +t1}:
          match t1:
            case Nil{}: ({==}, VY.inv2(b0, b1))
            case Con{+b2, +t2}:
              match t2:
                case Nil{}: ({==}, VY.inv3(b0, b1, b2))
                case Con{+b3, +t3}:
                  match t3:
                    case Nil{}: ({==}, VY.inv4(b0, b1, b2, b3))
                    case Con{+b4, +t4}:
                      match t4:
                        case Nil{}: ({==}, VY.inv5(b0, b1, b2, b3, b4))
                        case Con{+b5, +t5}:
                          match t5:
                            case Nil{}: ({==}, VY.inv6(b0, b1, b2, b3, b4, b5))
                            case Con{+b6, +t6}:
                              match t6:
                                case Nil{}: ({==}, VY.inv7(b0, b1, b2, b3, b4, b5, b6))
                                case Con{+b7, +rest}: inv_step(b0, b1, b2, b3, b4, b5, b6, b7, rest, inv(rest))
