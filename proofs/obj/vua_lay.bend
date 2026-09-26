import Base
import ../../types/schema.bend as S
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ../../src/primitives.bend as I
import ../compact/found.bend as F
import ../../proofs/decode_facts.bend as DF
import ./vspec.bend as VS
import ./vnest.bend as VN
import ./vdig.bend as VG
import ./vua_win.bend as UW
import ./vmv.bend as VMV

# The spec's container layout (spec/layout.bend) read part by part, for a part
# list of any shape: the offset word the fixed region holds for variable part i
# (lay_off, at FPOS; its value OFF threads the running offset exactly as
# Layout.fixed_parts does), the fixed region's length (lay_len), variable part
# i's payload (lay_pay), the total length (lay_end), the positions from the
# parts' widths alone (fpos_w, fs_w), and the fixed region as header words
# whose offset words hold the layout's offsets (hdr_fp).

def nthp(ps: +List<S.Part>, i: Nat) -> Maybe<&2, S.Part>:
  match ps i:
    case Nil{} _: None{}
    case Con{h, t} 0n: Some{h}
    case Con{h, t} 1n+q: nthp(t, q)

# The position of part i's slot in the fixed region.
def FPOS(ps: +List<S.Part>, i: Nat) -> Nat:
  match ps i:
    case Nil{} _: 0n
    case Con{h, t} 0n: 0n
    case Con{h, t} 1n+q: Nat.add(Layout.slot(h), FPOS(t, q))

# A list's length behind a name: Nat.add(<large literal>, List.length(&2, ..)) is not
# recognised as the same term by the big checker, which then unfolds the literal;
# Nat.add(<literal>, LN(..)) is.
def LN(+xs: +List<U32>) -> Nat: List.length(&2, U32, xs)

# The running offset after part h.
def NX(h: S.Part, +o: Nat) -> Nat:
  match h:
    case S.Fixed{xs}: o
    case S.Variable{xs}: Nat.add(o, LN(xs))

# The offset of part i when the payloads start at o.
def OFF(ps: +List<S.Part>, i: Nat, +o: Nat) -> Nat:
  match ps i:
    case Nil{} _: o
    case Con{h, t} 0n: o
    case Con{h, t} 1n+q: OFF(t, q, NX(h, o))

# The end of the payloads when they start at o.
def END(ps: +List<S.Part>, +o: Nat) -> Nat:
  match ps:
    case Nil{}: o
    case Con{h, t}: END(t, NX(h, o))

def isvp(p: S.Part) -> Bool:
  match p:
    case S.Fixed{xs}: False{}
    case S.Variable{xs}: True{}

def isv(m: Maybe<&2, S.Part>) -> Bool:
  match m:
    case None{}: False{}
    case Some{p}: isvp(p)

def vpp(p: S.Part) -> +List<U32>:
  match p:
    case S.Fixed{xs}: []
    case S.Variable{xs}: xs

def vpay(m: Maybe<&2, S.Part>) -> +List<U32>:
  match m:
    case None{}: []
    case Some{p}: vpp(p)

def fv(+a: +List<U32>, +b: +List<U32>, +e: {Some{S.Fixed{a}} == Some{S.Variable{b}} : Maybe<&2, S.Part>}) -> Empty:
  F.logic__false_true(Equal.cong(Maybe<&2, S.Part>, Bool, m => isv(m), Some{S.Fixed{a}}, Some{S.Variable{b}}, e))

def vinj(+a: +List<U32>, +b: +List<U32>, +e: {Some{S.Variable{a}} == Some{S.Variable{b}} : Maybe<&2, S.Part>}) -> {a == b : +List<U32>}:
  Equal.cong(Maybe<&2, S.Part>, +List<U32>, m => vpay(m), Some{S.Variable{a}}, Some{S.Variable{b}}, e)

def fpp(p: S.Part) -> +List<U32>:
  match p:
    case S.Fixed{xs}: xs
    case S.Variable{xs}: []

def fpay(m: Maybe<&2, S.Part>) -> +List<U32>:
  match m:
    case None{}: []
    case Some{p}: fpp(p)

def vf(+a: +List<U32>, +b: +List<U32>, +e: {Some{S.Variable{a}} == Some{S.Fixed{b}} : Maybe<&2, S.Part>}) -> Empty:
  F.logic__true_false(Equal.cong(Maybe<&2, S.Part>, Bool, m => isv(m), Some{S.Variable{a}}, Some{S.Fixed{b}}, e))

def mval(m: Maybe<&2, Nat>) -> Nat:
  match m:
    case None{}: 0n
    case Some{a}: a

def mnat(+a: Nat, +b: Nat, +e: {Some{a} == Some{b} : Maybe<&2, Nat>}) -> {a == b : Nat}:
  Equal.cong(Maybe<&2, Nat>, Nat, m => mval(m), Some{a}, Some{b}, e)

# ---- the offsets ----------------------------------------------------------------------------------

def off0(+h: S.Part, +t: +List<S.Part>, +o: Nat, +y: +List<U32>, +R: +List<U32>, +e: {Some{h} == Some{S.Variable{y}} : Maybe<&2, S.Part>})
    -> {VS.bt(4n, VS.bdr(0n, List.append(&2, U32, Layout.fixed_parts(Con{h, t}, o), R))) == N.digits(4n, o) : +List<U32>}:
  match h:
    case S.Fixed{+xs}: Empty.absurd({VS.bt(4n, VS.bdr(0n, List.append(&2, U32, Layout.fixed_parts(Con{S.Fixed{xs}, t}, o), R))) == N.digits(4n, o) : +List<U32>}, fv(xs, y, e))
    case S.Variable{+z}: {==}

def offs(+h: S.Part, +t: +List<S.Part>, +o: Nat, +q: Nat, +y: +List<U32>, +R: +List<U32>,
    ih: {VS.bt(4n, VS.bdr(FPOS(t, q), List.append(&2, U32, Layout.fixed_parts(t, NX(h, o)), R))) == N.digits(4n, OFF(t, q, NX(h, o))) : +List<U32>})
    -> {VS.bt(4n, VS.bdr(FPOS(Con{h, t}, 1n+q), List.append(&2, U32, Layout.fixed_parts(Con{h, t}, o), R))) == N.digits(4n, OFF(Con{h, t}, 1n+q, o)) : +List<U32>}:
  match h:
    case S.Fixed{+xs}:
      +FP = Layout.fixed_parts(t, o)
      +G = N.digits(4n, OFF(t, q, o))
      %Equal.sym(+List<U32>, VS.bdr(Nat.add(List.length(&2, U32, xs), FPOS(t, q)), List.append(&2, U32, List.append(&2, U32, xs, FP), R)),
          VS.bdr(FPOS(t, q), VS.bdr(List.length(&2, U32, xs), List.append(&2, U32, List.append(&2, U32, xs, FP), R))), VN.bdr_add(List.length(&2, U32, xs), FPOS(t, q), List.append(&2, U32, List.append(&2, U32, xs, FP), R))) :
        {VS.bt(4n, _) == G : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, FP), R), List.append(&2, U32, xs, List.append(&2, U32, FP, R)), VS.app_assoc(xs, FP, R)) :
        {VS.bt(4n, VS.bdr(FPOS(t, q), VS.bdr(List.length(&2, U32, xs), _))) == G : +List<U32>}
      %Equal.sym(+List<U32>, VS.bdr(List.length(&2, U32, xs), List.append(&2, U32, xs, List.append(&2, U32, FP, R))), List.append(&2, U32, FP, R), VS.bdr_app(xs, List.append(&2, U32, FP, R))) :
        {VS.bt(4n, VS.bdr(FPOS(t, q), _)) == G : +List<U32>}
      ih
    case S.Variable{+z}: ih

law lay_off:
  for +ps: +List<S.Part>
  for +o: Nat
  for +i: Nat
  for +y: +List<U32>
  for +R: +List<U32>
  for +e: {nthp(ps, i) == Some{S.Variable{y}} : Maybe<&2, S.Part>}
  {VS.bt(4n, VS.bdr(FPOS(ps, i), List.append(&2, U32, Layout.fixed_parts(ps, o), R))) == N.digits(4n, OFF(ps, i, o)) : +List<U32>}
def lay_off(ps, o, i, y, R, e):
  match ps i:
    case Nil{} _: Empty.absurd({VS.bt(4n, VS.bdr(0n, List.append(&2, U32, [], R))) == N.digits(4n, o) : +List<U32>}, F.logic__none_some(S.Part, S.Variable{y}, e))
    case Con{+h, +t} 0n: off0(h, t, o, y, R, e)
    case Con{+h, +t} 1n+ +q: offs(h, t, o, q, y, R, lay_off(t, NX(h, o), q, y, R, e))

# ---- the fixed parts -------------------------------------------------------------------------------

def fix0(+h: S.Part, +t: +List<S.Part>, +o: Nat, +xs: +List<U32>, +R: +List<U32>, +e: {Some{h} == Some{S.Fixed{xs}} : Maybe<&2, S.Part>})
    -> {VS.bt(List.length(&2, U32, xs), VS.bdr(0n, List.append(&2, U32, Layout.fixed_parts(Con{h, t}, o), R))) == xs : +List<U32>}:
  match h:
    case S.Fixed{+z}:
      %Equal.sym(+List<U32>, z, xs, Equal.cong(Maybe<&2, S.Part>, +List<U32>, m => fpay(m), Some{S.Fixed{z}}, Some{S.Fixed{xs}}, e)) :
        {VS.bt(List.length(&2, U32, xs), List.append(&2, U32, List.append(&2, U32, _, Layout.fixed_parts(t, o)), R)) == xs : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(t, o)), R), List.append(&2, U32, xs, List.append(&2, U32, Layout.fixed_parts(t, o), R)),
          VS.app_assoc(xs, Layout.fixed_parts(t, o), R)) :
        {VS.bt(List.length(&2, U32, xs), _) == xs : +List<U32>}
      Equal.trans(+List<U32>, VS.bt(List.length(&2, U32, xs), List.append(&2, U32, xs, List.append(&2, U32, Layout.fixed_parts(t, o), R))), VS.bt(List.length(&2, U32, xs), xs), xs,
        VN.bt_app(List.length(&2, U32, xs), xs, List.append(&2, U32, Layout.fixed_parts(t, o), R), F.nat__le_refl(List.length(&2, U32, xs))), UW.bt_self(xs))
    case S.Variable{+z}: Empty.absurd({VS.bt(List.length(&2, U32, xs), VS.bdr(0n, List.append(&2, U32, Layout.fixed_parts(Con{S.Variable{z}, t}, o), R))) == xs : +List<U32>}, vf(z, xs, e))

def fixs(+h: S.Part, +t: +List<S.Part>, +o: Nat, +q: Nat, +xs: +List<U32>, +R: +List<U32>,
    ih: {VS.bt(List.length(&2, U32, xs), VS.bdr(FPOS(t, q), List.append(&2, U32, Layout.fixed_parts(t, NX(h, o)), R))) == xs : +List<U32>})
    -> {VS.bt(List.length(&2, U32, xs), VS.bdr(FPOS(Con{h, t}, 1n+q), List.append(&2, U32, Layout.fixed_parts(Con{h, t}, o), R))) == xs : +List<U32>}:
  match h:
    case S.Fixed{+ys}:
      +FP = Layout.fixed_parts(t, o)
      %Equal.sym(+List<U32>, VS.bdr(Nat.add(List.length(&2, U32, ys), FPOS(t, q)), List.append(&2, U32, List.append(&2, U32, ys, FP), R)),
          VS.bdr(FPOS(t, q), VS.bdr(List.length(&2, U32, ys), List.append(&2, U32, List.append(&2, U32, ys, FP), R))), VN.bdr_add(List.length(&2, U32, ys), FPOS(t, q), List.append(&2, U32, List.append(&2, U32, ys, FP), R))) :
        {VS.bt(List.length(&2, U32, xs), _) == xs : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, ys, FP), R), List.append(&2, U32, ys, List.append(&2, U32, FP, R)), VS.app_assoc(ys, FP, R)) :
        {VS.bt(List.length(&2, U32, xs), VS.bdr(FPOS(t, q), VS.bdr(List.length(&2, U32, ys), _))) == xs : +List<U32>}
      %Equal.sym(+List<U32>, VS.bdr(List.length(&2, U32, ys), List.append(&2, U32, ys, List.append(&2, U32, FP, R))), List.append(&2, U32, FP, R), VS.bdr_app(ys, List.append(&2, U32, FP, R))) :
        {VS.bt(List.length(&2, U32, xs), VS.bdr(FPOS(t, q), _)) == xs : +List<U32>}
      ih
    case S.Variable{+z}: ih

# The bytes of fixed part i, at its position in the fixed region.
law lay_fix:
  for +ps: +List<S.Part>
  for +o: Nat
  for +i: Nat
  for +xs: +List<U32>
  for +R: +List<U32>
  for +e: {nthp(ps, i) == Some{S.Fixed{xs}} : Maybe<&2, S.Part>}
  {VS.bt(List.length(&2, U32, xs), VS.bdr(FPOS(ps, i), List.append(&2, U32, Layout.fixed_parts(ps, o), R))) == xs : +List<U32>}
def lay_fix(ps, o, i, xs, R, e):
  match ps i:
    case Nil{} _: Empty.absurd({VS.bt(List.length(&2, U32, xs), VS.bdr(0n, List.append(&2, U32, [], R))) == xs : +List<U32>}, F.logic__none_some(S.Part, S.Fixed{xs}, e))
    case Con{+h, +t} 0n: fix0(h, t, o, xs, R, e)
    case Con{+h, +t} 1n+ +q: fixs(h, t, o, q, xs, R, lay_fix(t, NX(h, o), q, xs, R, e))

# ---- the fixed region's length ------------------------------------------------------------------------

def lenh(+h: S.Part, +t: +List<S.Part>, +o: Nat, ih: {List.length(&2, U32, Layout.fixed_parts(t, NX(h, o))) == Layout.fixed_size(t) : Nat})
    -> {List.length(&2, U32, Layout.fixed_parts(Con{h, t}, o)) == Layout.fixed_size(Con{h, t}) : Nat}:
  match h:
    case S.Fixed{+xs}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(t, o))), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, Layout.fixed_parts(t, o))),
          VS.len_app(xs, Layout.fixed_parts(t, o))) :
        {_ == Nat.add(List.length(&2, U32, xs), Layout.fixed_size(t)) : Nat}
      Equal.cong(Nat, Nat, z => Nat.add(List.length(&2, U32, xs), z), List.length(&2, U32, Layout.fixed_parts(t, o)), Layout.fixed_size(t), ih)
    case S.Variable{+z}:
      Equal.cong(Nat, Nat, w => 4n+w, List.length(&2, U32, Layout.fixed_parts(t, Nat.add(o, List.length(&2, U32, z)))), Layout.fixed_size(t), ih)

law lay_len:
  for +ps: +List<S.Part>
  for +o: Nat
  {List.length(&2, U32, Layout.fixed_parts(ps, o)) == Layout.fixed_size(ps) : Nat}
def lay_len(ps, o):
  match ps:
    case Nil{}: {==}
    case Con{+h, +t}: lenh(h, t, o, lay_len(t, NX(h, o)))

# ---- the payloads -----------------------------------------------------------------------------------

def pay0(+h: S.Part, +t: +List<S.Part>, +y: +List<U32>, +o: Nat, +pre: +List<U32>, +hl: {List.length(&2, U32, pre) == o : Nat},
    +e: {Some{h} == Some{S.Variable{y}} : Maybe<&2, S.Part>})
    -> {VS.bt(List.length(&2, U32, y), VS.bdr(o, List.append(&2, U32, pre, Layout.payloads(Con{h, t})))) == y : +List<U32>}:
  match h:
    case S.Fixed{+xs}: Empty.absurd({VS.bt(List.length(&2, U32, y), VS.bdr(o, List.append(&2, U32, pre, Layout.payloads(Con{S.Fixed{xs}, t})))) == y : +List<U32>}, fv(xs, y, e))
    case S.Variable{+z}:
      %Equal.sym(+List<U32>, z, y, vinj(z, y, e)) : {VS.bt(List.length(&2, U32, y), VS.bdr(o, List.append(&2, U32, pre, List.append(&2, U32, _, Layout.payloads(t))))) == y : +List<U32>}
      %hl : {VS.bt(List.length(&2, U32, y), VS.bdr(_, List.append(&2, U32, pre, List.append(&2, U32, y, Layout.payloads(t))))) == y : +List<U32>}
      %Equal.sym(+List<U32>, VS.bdr(List.length(&2, U32, pre), List.append(&2, U32, pre, List.append(&2, U32, y, Layout.payloads(t)))), List.append(&2, U32, y, Layout.payloads(t)),
          VS.bdr_app(pre, List.append(&2, U32, y, Layout.payloads(t)))) :
        {VS.bt(List.length(&2, U32, y), _) == y : +List<U32>}
      Equal.trans(+List<U32>, VS.bt(List.length(&2, U32, y), List.append(&2, U32, y, Layout.payloads(t))), VS.bt(List.length(&2, U32, y), y), y,
        VN.bt_app(List.length(&2, U32, y), y, Layout.payloads(t), F.nat__le_refl(List.length(&2, U32, y))), UW.bt_self(y))

def pre2(+z: +List<U32>, +o: Nat, +pre: +List<U32>, +hl: {List.length(&2, U32, pre) == o : Nat})
    -> {List.length(&2, U32, List.append(&2, U32, pre, z)) == Nat.add(o, List.length(&2, U32, z)) : Nat}:
  %hl : {List.length(&2, U32, List.append(&2, U32, pre, z)) == Nat.add(_, List.length(&2, U32, z)) : Nat}
  VS.len_app(pre, z)

def pays(+h: S.Part, +t: +List<S.Part>, +q: Nat, +y: +List<U32>, +o: Nat, +pre: +List<U32>, +hl: {List.length(&2, U32, pre) == o : Nat},
    ihf: {VS.bt(List.length(&2, U32, y), VS.bdr(OFF(t, q, o), List.append(&2, U32, pre, Layout.payloads(t)))) == y : +List<U32>},
    ihv: @+z: +List<U32> -> {VS.bt(List.length(&2, U32, y), VS.bdr(OFF(t, q, Nat.add(o, List.length(&2, U32, z))), List.append(&2, U32, List.append(&2, U32, pre, z), Layout.payloads(t)))) == y : +List<U32>})
    -> {VS.bt(List.length(&2, U32, y), VS.bdr(OFF(Con{h, t}, 1n+q, o), List.append(&2, U32, pre, Layout.payloads(Con{h, t})))) == y : +List<U32>}:
  match h:
    case S.Fixed{+xs}: ihf
    case S.Variable{+z}:
      %VS.app_assoc(pre, z, Layout.payloads(t)) :
        {VS.bt(List.length(&2, U32, y), VS.bdr(OFF(t, q, Nat.add(o, List.length(&2, U32, z))), _)) == y : +List<U32>}
      ihv(z)

law lay_pay:
  for +ps: +List<S.Part>
  for +i: Nat
  for +y: +List<U32>
  for +o: Nat
  for +pre: +List<U32>
  for +hl: {List.length(&2, U32, pre) == o : Nat}
  for +e: {nthp(ps, i) == Some{S.Variable{y}} : Maybe<&2, S.Part>}
  {VS.bt(List.length(&2, U32, y), VS.bdr(OFF(ps, i, o), List.append(&2, U32, pre, Layout.payloads(ps)))) == y : +List<U32>}
def lay_pay(ps, i, y, o, pre, hl, e):
  match ps i:
    case Nil{} _: Empty.absurd({VS.bt(List.length(&2, U32, y), VS.bdr(o, List.append(&2, U32, pre, []))) == y : +List<U32>}, F.logic__none_some(S.Part, S.Variable{y}, e))
    case Con{+h, +t} 0n: pay0(h, t, y, o, pre, hl, e)
    case Con{+h, +t} 1n+ +q:
      pays(h, t, q, y, o, pre, hl, lay_pay(t, q, y, o, pre, hl, e),
        z => lay_pay(t, q, y, Nat.add(o, List.length(&2, U32, z)), List.append(&2, U32, pre, z), pre2(z, o, pre, hl), e))

# ---- the total length -----------------------------------------------------------------------------

def endh(+h: S.Part, +t: +List<S.Part>, +o: Nat, ih: {Nat.add(NX(h, o), LN(Layout.payloads(t))) == END(t, NX(h, o)) : Nat})
    -> {Nat.add(o, LN(Layout.payloads(Con{h, t}))) == END(Con{h, t}, o) : Nat}:
  match h:
    case S.Fixed{+xs}: ih
    case S.Variable{+z}:
      +PT = Layout.payloads(t)
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, z, PT)), Nat.add(List.length(&2, U32, z), List.length(&2, U32, PT)), VS.len_app(z, PT)) :
        {Nat.add(o, _) == END(t, Nat.add(o, List.length(&2, U32, z))) : Nat}
      %F.nat__add_assoc(o, List.length(&2, U32, z), List.length(&2, U32, PT)) : {_ == END(t, Nat.add(o, List.length(&2, U32, z))) : Nat}
      ih

law lay_end:
  for +ps: +List<S.Part>
  for +o: Nat
  {Nat.add(o, LN(Layout.payloads(ps))) == END(ps, o) : Nat}
def lay_end(ps, o):
  match ps:
    case Nil{}: F.nat__add_zero(o)
    case Con{+h, +t}: endh(h, t, o, lay_end(t, NX(h, o)))

def nx_ge(+h: S.Part, +o: Nat) -> {Nat.is_le(o, NX(h, o)) == True{} : Bool}:
  match h:
    case S.Fixed{+xs}: F.nat__le_refl(o)
    case S.Variable{+xs}: F.nat__le_add_right(o, List.length(&2, U32, xs))

# The payloads end at or after they start.
law end_ge:
  for +ps: +List<S.Part>
  for +o: Nat
  {Nat.is_le(o, END(ps, o)) == True{} : Bool}
def end_ge(ps, o):
  match ps:
    case Nil{}: F.nat__le_refl(o)
    case Con{+h, +t}: F.nat__le_trans(o, NX(h, o), END(t, NX(h, o)), nx_ge(h, o), end_ge(t, NX(h, o)))

# Every offset is at most the end.
law off_le:
  for +ps: +List<S.Part>
  for +i: Nat
  for +o: Nat
  {Nat.is_le(OFF(ps, i, o), END(ps, o)) == True{} : Bool}
def off_le(ps, i, o):
  match ps i:
    case Nil{} _: F.nat__le_refl(o)
    case Con{+h, +t} 0n: F.nat__le_trans(o, NX(h, o), END(t, NX(h, o)), nx_ge(h, o), end_ge(t, NX(h, o)))
    case Con{+h, +t} 1n+ +q: off_le(t, q, NX(h, o))

# ---- positions from the widths ------------------------------------------------------------------------

def WIDH(h: S.Part) -> Maybe<&2, Nat>:
  match h:
    case S.Fixed{xs}: Some{List.length(&2, U32, xs)}
    case S.Variable{xs}: None{}

def WID(ps: +List<S.Part>) -> +List<Maybe<&2, Nat>>:
  match ps:
    case Nil{}: []
    case Con{h, t}: WIDH(h) <> WID(t)

def WSL(w: Maybe<&2, Nat>) -> Nat:
  match w:
    case None{}: 4n
    case Some{a}: a

def WPOS(ws: +List<Maybe<&2, Nat>>, i: Nat) -> Nat:
  match ws i:
    case Nil{} _: 0n
    case Con{w, t} 0n: 0n
    case Con{w, t} 1n+q: Nat.add(WSL(w), WPOS(t, q))

def WFS(ws: +List<Maybe<&2, Nat>>) -> Nat:
  match ws:
    case Nil{}: 0n
    case Con{w, t}: Nat.add(WSL(w), WFS(t))

def slot_w(+h: S.Part) -> {Layout.slot(h) == WSL(WIDH(h)) : Nat}:
  match h:
    case S.Fixed{+xs}: {==}
    case S.Variable{+xs}: {==}

law fpos_w:
  for +ps: +List<S.Part>
  for +i: Nat
  {FPOS(ps, i) == WPOS(WID(ps), i) : Nat}
def fpos_w(ps, i):
  match ps i:
    case Nil{} _: {==}
    case Con{+h, +t} 0n: {==}
    case Con{+h, +t} 1n+ +q:
      %Equal.sym(Nat, Layout.slot(h), WSL(WIDH(h)), slot_w(h)) : {Nat.add(_, FPOS(t, q)) == Nat.add(WSL(WIDH(h)), WPOS(WID(t), q)) : Nat}
      Equal.cong(Nat, Nat, z => Nat.add(WSL(WIDH(h)), z), FPOS(t, q), WPOS(WID(t), q), fpos_w(t, q))

law fs_w:
  for +ps: +List<S.Part>
  {Layout.fixed_size(ps) == WFS(WID(ps)) : Nat}
def fs_w(ps):
  match ps:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, Layout.slot(h), WSL(WIDH(h)), slot_w(h)) : {Nat.add(_, Layout.fixed_size(t)) == Nat.add(WSL(WIDH(h)), WFS(WID(t))) : Nat}
      Equal.cong(Nat, Nat, z => Nat.add(WSL(WIDH(h)), z), Layout.fixed_size(t), WFS(WID(t)), fs_w(t))

# ---- the fixed region as header words -----------------------------------------------------------------

# The fixed parts' bytes, and the limbs of the words os in the variable parts' slots.
def HDRW(ps: +List<S.Part>, os: +List<U32>) -> +List<U32>:
  match ps:
    case Nil{}: []
    case Con{h, t}:
      match h:
        case S.Fixed{xs}: List.append(&2, U32, xs, HDRW(t, os))
        case S.Variable{xs}:
          match os:
            case Nil{}: HDRW(t, [])
            case Con{w, r}: List.append(&2, U32, I.limb(w), HDRW(t, r))

# The words os hold the layout's offsets (from o).
def OKO(ps: +List<S.Part>, +o: Nat, os: +List<U32>) -> Type:
  match ps:
    case Nil{}: Unit
    case Con{h, t}:
      match h:
        case S.Fixed{xs}: OKO(t, o, os)
        case S.Variable{+xs}:
          match os:
            case Nil{}: Empty
            case Con{w, r}: {U32.to_nat(w) == o : Nat} & OKO(t, Nat.add(o, LN(xs)), r)

law hdr_fp:
  for +ps: +List<S.Part>
  for +o: Nat
  for +os: +List<U32>
  for h: OKO(ps, o, os)
  {Layout.fixed_parts(ps, o) == HDRW(ps, os) : +List<U32>}
def hdr_fp(ps, o, os, h):
  match ps:
    case Nil{}: {==}
    case Con{+p, +t}:
      match p:
        case S.Fixed{+xs}:
          Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, xs, z), Layout.fixed_parts(t, o), HDRW(t, os), hdr_fp(t, o, os, h))
        case S.Variable{+z}:
          match os:
            case Nil{}: Empty.absurd({Layout.fixed_parts(Con{S.Variable{z}, t}, o) == HDRW(Con{S.Variable{z}, t}, []) : +List<U32>}, h)
            case Con{+w, +r}:
              (ea, hr) = h
              +FT = Layout.fixed_parts(t, Nat.add(o, List.length(&2, U32, z)))
              %ea : {List.append(&2, U32, N.digits(4n, _), FT) == List.append(&2, U32, I.limb(w), HDRW(t, r)) : +List<U32>}
              %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(w)), I.limb(w), VG.digits_limb(w)) :
                {List.append(&2, U32, _, FT) == List.append(&2, U32, I.limb(w), HDRW(t, r)) : +List<U32>}
              Equal.cong(+List<U32>, +List<U32>, q => List.append(&2, U32, I.limb(w), q), FT, HDRW(t, r), hdr_fp(t, Nat.add(o, List.length(&2, U32, z)), r, hr))

# ---- a variable list is one variable part ---------------------------------------------------------------

def lreq(+b: Bool, +m: Maybe<&2, +List<S.Part>>) -> DF.single_result(None{}, Codec.require(b, Codec.aggregate(m, None{}))):
  match b:
    case False{}: Unit{}
    case True{}: UW.vs_agg(m)

law lsingle:
  for +h: S.Value
  for +s: S.Schema
  for +n: Nat
  DF.single_result(None{}, Codec.parts(h, S.ListOf{s, n}))
def lsingle(h, s, n):
  match h:
    case S.Sequence{+items}: lreq(Nat.is_le(Codec.count(items), n), Codec.parts(items, S.Repeat{s}))
    case S.BooleanValue{+b0}: Unit{}
    case S.UnsignedValue{+u0}: Unit{}
    case S.BytesValue{+xs0}: Unit{}
    case S.BitsValue{+bs0}: Unit{}
    case S.Items{+hd0, +tl0}: Unit{}
    case S.EmptyItems{}: Unit{}
    case S.Selected{+sel0, +sv0}: Unit{}
    case S.NullValue{}: Unit{}

# Layout.encoding from its pieces, the size check stated through LN.
law enc_genL:
  for +ps: +List<S.Part>
  for +FS: Nat
  for +FP: +List<U32>
  for +PAY: +List<U32>
  for +hs: {Layout.fixed_size(ps) == FS : Nat}
  for +hf: {Layout.fixed_parts(ps, FS) == FP : +List<U32>}
  for +hp: {Layout.payloads(ps) == PAY : +List<U32>}
  for +hv: {Layout.bytes_valid(ps) == True{} : Bool}
  for +fit: {N.fits(4n, Nat.add(FS, LN(PAY))) == True{} : Bool}
  {Layout.encoding(ps) == Some{List.append(&2, U32, FP, PAY)} : Maybe<&2, +List<U32>>}
def enc_genL(ps, FS, FP, PAY, hs, hf, hp, hv, fit): VMV.enc_gen(ps, FS, FP, PAY, hs, hf, hp, hv, fit)
