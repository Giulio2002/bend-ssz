import Base
import 0xe4067e0d858024083f36a7abe7281e89/spec/crypto/sha.bend as PF
import 0xe4067e0d858024083f36a7abe7281e89/src/crypto/sha/state.bend as PS
import 0xe4067e0d858024083f36a7abe7281e89/spec/crypto/sha.bend as VF
import 0xe4067e0d858024083f36a7abe7281e89/src/crypto/sha/state.bend as VS

# The SHA-256 bridge between the two copies of FIPS 180-4 that were in play.
# Since both now come from bend-collections (spec/crypto/sha.bend), PF and VF
# are the same module and these laws hold trivially; they are kept so the
# proofs built on them keep their statements. The original rationale:
#
# The pinned BendHub package proves its packed runtime equal to its packed
# specification (package LAWS `sha256_array_correct`), and that specification
# hashes with the PACKAGE's copy of fips.bend (PF). The SSZ specification
# (spec/merkle.bend) hashes byte lists with the VENDORED copy
# (vendor/bend_sha256/fips.bend, VF). The two files are byte-identical text but
# distinct modules with distinct `State` types, so nothing identifies them for
# free. These laws do, function by function: one computation step for the
# non-recursive functions, induction for the list recursions. Nothing here
# normalizes a whole symbolic compression.

def conv(s: PS.State) -> VS.State:
  match s:
    case PS.H{+a, +b, +c, +d, +e, +f, +g, +h}: VS.H{a, b, c, d, e, f, g, h}

law constants_eq:
  {PF.constants() == VF.constants() : List<&2, U32>}
def constants_eq(): {==}

law initial_eq:
  {conv(PF.initial()) == VF.initial() : VS.State}
def initial_eq(): {==}

law step_eq:
  for +s: PS.State
  for +k: U32
  for +w: U32
  {conv(PF.step(s, k, w)) == VF.step(conv(s), k, w) : VS.State}
def step_eq(s, k, w):
  match s:
    case PS.H{+a, +b, +c, +d, +e, +f, +g, +h}: {==}

law rounds_eq:
  for +ks: List<&2, U32>
  for +ws: List<&2, U32>
  for +s: PS.State
  {conv(PF.rounds(ks, ws)(s)) == VF.rounds(ks, ws)(conv(s)) : VS.State}
def rounds_eq(ks, ws, s):
  match ks ws:
    case Nil{} _: {==}
    case k <> kt Nil{}: {==}
    case k <> kt w <> wt:
      Equal.trans(VS.State, conv(PF.rounds(kt, wt)(PF.step(s, k, w))), VF.rounds(kt, wt)(conv(PF.step(s, k, w))),
        VF.rounds(kt, wt)(VF.step(conv(s), k, w)),
        rounds_eq(kt, wt, PF.step(s, k, w)),
        Equal.cong(VS.State, VS.State, x => VF.rounds(kt, wt)(x), conv(PF.step(s, k, w)), VF.step(conv(s), k, w), step_eq(s, k, w)))

law feedforward_eq:
  for +x: PS.State
  for +y: PS.State
  {conv(PF.feedforward(x, y)) == VF.feedforward(conv(x), conv(y)) : VS.State}
def feedforward_eq(x, y):
  match x:
    case PS.H{+a, +b, +c, +d, +e, +f, +g, +h}:
      match y:
        case PS.H{+i, +j, +k, +l, +m, +n, +o, +p}: {==}

law compress_eq:
  for +ws: List<&2, U32>
  for +ks: List<&2, U32>
  for +s: PS.State
  {conv(PF.compress(ws, ks, s)) == VF.compress(ws, ks, conv(s)) : VS.State}
def compress_eq(ws, ks, s):
  Equal.trans(VS.State, conv(PF.feedforward(s, PF.rounds(ks, ws)(s))),
    VF.feedforward(conv(s), conv(PF.rounds(ks, ws)(s))),
    VF.feedforward(conv(s), VF.rounds(ks, ws)(conv(s))),
    feedforward_eq(s, PF.rounds(ks, ws)(s)),
    Equal.cong(VS.State, VS.State, x => VF.feedforward(conv(s), x), conv(PF.rounds(ks, ws)(s)), VF.rounds(ks, ws)(conv(s)), rounds_eq(ks, ws, s)))

law digest_eq:
  for +s: PS.State
  {VF.digest(conv(s)) == PF.digest(s) : List<&2, U32>}
def digest_eq(s):
  match s:
    case PS.H{+a, +b, +c, +d, +e, +f, +g, +h}: {==}

# ---- the message schedule ----------------------------------------------------

law nth_eq:
  for +h: List<&2, U32>
  for +i: Nat
  {PF.nth(h, i) == VF.nth(h, i) : U32}
def nth_eq(h, i):
  match h i:
    case Nil{} _: {==}
    case w <> rest 0n: {==}
    case w <> rest 1n+p: nth_eq(rest, p)

# The recurrence with its four schedule reads as arguments.
def rec4(+a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  (VF.sigma1(a) + b + VF.sigma0(c) + d : U32)

law recurrence_eq:
  for +h: List<&2, U32>
  {PF.recurrence(h) == VF.recurrence(h) : U32}
def recurrence_eq(h):
  %Equal.sym(U32, PF.nth(h, 1n), VF.nth(h, 1n), nth_eq(h, 1n)) :
    {rec4(_, PF.nth(h, 6n), PF.nth(h, 14n), PF.nth(h, 15n)) == VF.recurrence(h) : U32}
  %Equal.sym(U32, PF.nth(h, 6n), VF.nth(h, 6n), nth_eq(h, 6n)) :
    {rec4(VF.nth(h, 1n), _, PF.nth(h, 14n), PF.nth(h, 15n)) == VF.recurrence(h) : U32}
  %Equal.sym(U32, PF.nth(h, 14n), VF.nth(h, 14n), nth_eq(h, 14n)) :
    {rec4(VF.nth(h, 1n), VF.nth(h, 6n), _, PF.nth(h, 15n)) == VF.recurrence(h) : U32}
  %Equal.sym(U32, PF.nth(h, 15n), VF.nth(h, 15n), nth_eq(h, 15n)) :
    {rec4(VF.nth(h, 1n), VF.nth(h, 6n), VF.nth(h, 14n), _) == VF.recurrence(h) : U32}
  {==}

def ext_head(+x: U32, +p: Nat, +h: List<&2, U32>) -> List<&2, U32>:
  x <> PF.extension(p, x <> h)

law extension_eq:
  for +rounds: Nat
  for +h: List<&2, U32>
  {PF.extension(rounds, h) == VF.extension(rounds, h) : List<&2, U32>}
def extension_eq(rounds, h):
  match rounds:
    case 0n: {==}
    case 1n+p:
      Equal.trans(List<&2, U32>, ext_head(PF.recurrence(h), p, h), ext_head(VF.recurrence(h), p, h),
        VF.extension(1n+p, h),
        Equal.cong(U32, List<&2, U32>, x => ext_head(x, p, h), PF.recurrence(h), VF.recurrence(h), recurrence_eq(h)),
        Equal.cong(List<&2, U32>, List<&2, U32>, t => VF.recurrence(h) <> t,
          PF.extension(p, VF.recurrence(h) <> h), VF.extension(p, VF.recurrence(h) <> h),
          extension_eq(p, VF.recurrence(h) <> h)))

law schedule_eq:
  for +extra: Nat
  for +block: List<&2, U32>
  {PF.schedule(extra, block) == VF.schedule(extra, block) : List<&2, U32>}
def schedule_eq(extra, block):
  Equal.cong(List<&2, U32>, List<&2, U32>, t => List.append(&2, U32, block, t),
    PF.extension(extra, List.reverse(&2, U32, block)), VF.extension(extra, List.reverse(&2, U32, block)),
    extension_eq(extra, List.reverse(&2, U32, block)))
