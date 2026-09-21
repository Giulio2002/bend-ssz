"""Generate the container half of proofs/compact/sound_cont.bend: tag 0 on
containers and the walks at tags 8, 9, 13, 15 and 16.

Every case follows the same pattern (unfold one machine step, rewrite the
read it made with the reads.bend law, split the computed Booleans through a
helper, apply the induction hypothesis at the next tag, lift by level
monotonicity), and each lemma's statement repeats long machine expressions;
generating them from one table of abbreviations keeps the text consistent.
Bend checks every generated term.

    python3 tools/generate_compact_walk.py
"""
import re
P='proofs/compact/sound_cont.bend'
MARK='# ---- tag 0 on a container' 
T='+t: F.array__Tree<U32>, +d: Nat, +n: U32'
TD='t, d, n'
FCP='+fields: S.CS, +i: U32, +cnt: U32, +base: Nat, +endp: Nat, +fp: Nat, +pend: S.CS, +start: Nat, +has: U32, +up: C.Frame'
FCA='fields, i, cnt, base, endp, fp, pend, start, has, up'
BF='D.bf(t, n)'
sub = {
 '@BF@': BF,
 '@HP@': 'C.hpos(base, S.field(fields, i))',
 '@HE@': 'Nat.add(C.hpos(base, S.field(fields, i)), U32.to_nat(C.f_hsize(S.field(fields, i))))',
 '@FS@': 'C.f_schema(S.field(fields, i))',
 '@V8@': 'V.r32(t, d, C.hpos(base, S.field(fields, i)))',
 '@VA@': 'V.var_at(t, d, base, S.field(fields, i))',
 '@FR1@': 'C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}',
 '@W8N@': 'V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has}',
 '@SHE@': 'S.shallow(pend, Nat.sub(endp, start))',
 '@CH@': 'Nat.add(base, U32.to_nat(v))',
 '@B8N@': 'V.b8(t, d, C.check_byte(base, S.field(fields, (i + 1 : U32))))',
 '@R15@': 'V.r32(t, d, C.hpos(base, S.field(fields, (i + 1 : U32))))',
 '@FPN@': 'U32.to_nat(fp)',
}
code = r'''
# ---- tag 0 on a container -----------------------------------------------------------

def cont_lift(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +fr: C.Frame, -W: Type, pr: W & D.FD(t, d, p, fr)) -> W & D.FD(t, d, 1n+p, fr):
  (x, f) = pr
  (x, DM.fd_mono(t, d, p, fr, f))

# The walk the container starts, by its flags, with the first value read.
def cont_fixed(@T@, +p: Nat, +sch: S.CS, +fr: C.Frame, +checks: S.CS, +nchecks: U32, +fp: U32, +a: Nat, +b: Nat, +c: U32,
    ih: D.IH(t, d, n, p), plain: Bool, simple: Bool,
    h: {C.run(p, C.usel(plain, 5, C.usel(simple, 16, 8)), sch, C.fsel(plain, fr, @FC0@), a, b, c, (@BF@, @B8C@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(plain, Unit, V.If(simple, @W16T@, @W8T@)) & D.FD(t, d, 1n+p, fr):
  match plain simple:
    case True{} True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, b, c, @B8C@, h)))
    case True{} False{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, b, c, @B8C@, h)))
    case False{} True{}: cont_lift(t, d, p, fr, @W16T@, ih(D.T16{}, sch, @FC0@, a, b, c, @B8C@, h))
    case False{} False{}: cont_lift(t, d, p, fr, @W8T@, ih(D.T8{}, sch, @FC0@, a, b, c, @B8C@, h))

def cont_var(@T@, +p: Nat, +sch: S.CS, +fr: C.Frame, +checks: S.CS, +nchecks: U32, +fp: U32, +a: Nat, +b: Nat, +c: U32,
    ih: D.IH(t, d, n, p), plain: Bool, simple: Bool,
    h: {C.run(p, C.usel(plain, 5, C.usel(simple, 15, 8)), sch, C.fsel(plain, fr, @FC0@), a, b, c, (@BF@, @R32C@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(plain, Unit, V.If(simple, @W15T@, @W8T@)) & D.FD(t, d, 1n+p, fr):
  match plain simple:
    case True{} True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, b, c, @R32C@, h)))
    case True{} False{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, b, c, @R32C@, h)))
    case False{} True{}: cont_lift(t, d, p, fr, @W15T@, ih(D.T15{}, sch, @FC0@, a, b, c, @R32C@, h))
    case False{} False{}: cont_lift(t, d, p, fr, @W8T@, ih(D.T8{}, sch, @FC0@, a, b, c, @R32C@, h))

def cont_flags(@T@, @HDPF@, +p: Nat, +sch: S.CS, +fr: C.Frame, +checks: S.CS, +nchecks: U32, +fp: U32, +a: Nat, +b: Nat, +c: U32,
    ih: D.IH(t, d, n, p), fixed: Bool, +plain: Bool, +simple: Bool,
    h: {C.run(p, C.usel(plain, 5, C.usel(simple, C.usel(fixed, 16, 15), 8)), sch, C.fsel(plain, fr, @FC0@), a, b, c,
          C.first_read(fixed, S.field(checks, 0), a, @BF@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(plain, Unit, V.If(simple, V.If(fixed, @W16T@, @W15T@), @W8T@)) & D.FD(t, d, 1n+p, fr):
  match fixed:
    case True{}: cont_fixed(t, d, n, p, sch, fr, checks, nchecks, fp, a, b, c, ih, plain, simple,
      F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(plain, 5, C.usel(simple, 16, 8)), sch, C.fsel(plain, fr, @FC0@), a, b, c, z) == (@BF@, True{}) : B.Buf & Bool},
        C.rd8(@BF@, C.check_byte(a, S.field(checks, 0))), (@BF@, @B8C@), Rd.byte_any(d, t, n, U32.from_nat(C.check_byte(a, S.field(checks, 0))), hd, pf), h))
    case False{}: cont_var(t, d, n, p, sch, fr, checks, nchecks, fp, a, b, c, ih, plain, simple,
      F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(plain, 5, C.usel(simple, 15, 8)), sch, C.fsel(plain, fr, @FC0@), a, b, c, z) == (@BF@, True{}) : B.Buf & Bool},
        C.rd32(@BF@, C.hpos(a, S.field(checks, 0))), (@BF@, @R32C@), Rd.read32_any(d, t, n, U32.from_nat(C.hpos(a, S.field(checks, 0))), hd, pf), h))

def cont_len(@T@, @HDPF@, +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +depth: U32, +plain: Bool, +checks: S.CS, +nchecks: U32, +simple: Bool,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, ih: D.IH(t, d, n, p), ok: Bool, e: {@LENOK@ == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(plain, 5, C.usel(simple, C.usel(fixed, 16, 15), 8)), 6), @CC@,
          C.fsel(plain, fr, @FC0@), a, b, c, C.first_read(fixed, S.field(checks, 0), a, @BF@)) == (@BF@, True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, @CC@, fr, a, b, c, 0):
  match ok:
    case True{}:
      L.reassoc(V.Is(@LENOK@), V.If(plain, Unit, V.If(simple, V.If(fixed, @W16T@, @W15T@), @W8T@)), D.FD(t, d, 1n+p, fr), e,
        cont_flags(t, d, n, hd, pf, p, @CC@, fr, checks, nchecks, fp, a, b, c, ih, fixed, plain, simple, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, @CC@, fr, a, b, c, 0),
      L.no_run6(t, n, p, @CC@, C.fsel(plain, fr, @FC0@), a, b, c, C.first_read(fixed, S.field(checks, 0), a, @BF@), h))

def t0_cont(@T@, @HDPF@, +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +depth: U32, +plain: Bool, +checks: S.CS, +nchecks: U32, +simple: Bool,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T0{}, @CC@, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, @CC@, fr, a, b, c, v):
  cont_len(t, d, n, hd, pf, p, fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple, fr, a, b, c, ih, @LENOK@, {==}, h)

# ---- tag 0 on a progressive container --------------------------------------------------

def pcont_plain(@T@, +p: Nat, +sch: S.CS, +fp: U32, plain: Bool, +checks: S.CS, +nchecks: U32,
    +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, ih: D.IH(t, d, n, p),
    h: {C.run(p, C.usel(plain, 5, 8), sch, C.fsel(plain, fr, @FC0@), a, b, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(plain, Unit, @W8T@) & D.FD(t, d, 1n+p, fr):
  match plain:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, fr, ih(D.T5{}, sch, fr, a, b, c, 0, h)))
    case False{}: cont_lift(t, d, p, fr, @W8T@, ih(D.T8{}, sch, @FC0@, a, b, c, 0, h))

def pcont_len(@T@, +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +plain: Bool, +checks: S.CS, +nchecks: U32,
    +slots: S.CS, +nslots: U32, +active: U32, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, ih: D.IH(t, d, n, p),
    ok: Bool, e: {@LENOK@ == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(plain, 5, 8), 6), @PC@, C.fsel(plain, fr, @FC0@), a, b, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool})
    -> D.Den(t, d, 1n+p, D.T0{}, @PC@, fr, a, b, c, 0):
  match ok:
    case True{}:
      L.reassoc(V.Is(@LENOK@), V.If(plain, Unit, @W8T@), D.FD(t, d, 1n+p, fr), e,
        pcont_plain(t, d, n, p, @PC@, fp, plain, checks, nchecks, fr, a, b, c, ih, h))
    case False{}: Empty.absurd(D.Den(t, d, 1n+p, D.T0{}, @PC@, fr, a, b, c, 0),
      L.no_run6(t, n, p, @PC@, C.fsel(plain, fr, @FC0@), a, b, c, (@BF@, 0), h))

def t0_pcont(@T@, +p: Nat, +fields: S.CS, +cnt: U32, +fp: U32, +size: U32, +fixed: Bool, +plain: Bool, +checks: S.CS, +nchecks: U32,
    +slots: S.CS, +nslots: U32, +active: U32, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    h: D.Ok(t, n, 1n+p, D.T0{}, @PC@, fr, a, b, c, v))
    -> D.Den(t, d, 1n+p, D.T0{}, @PC@, fr, a, b, c, v):
  pcont_len(t, d, n, p, fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active, fr, a, b, c, ih, @LENOK@, {==}, h)

# ---- shared helpers for the walks ---------------------------------------------------

def shal0(-A: Type, +r: U32, eq: {r == 0 : U32}, x: A) -> V.Shallow(r, A):
  F.logic__subst(U32, z => V.Shallow(z, A), 0, r, Equal.sym(U32, r, 0, eq), x)

def shal1(-A: Type, +r: U32, eq: {r == 1 : U32}) -> V.Shallow(r, A):
  F.logic__subst(U32, z => V.Shallow(z, A), 1, r, Equal.sym(U32, r, 1, eq), Unit{})

def both_true(x: Bool, y: Bool, e: {C.bsel(x, y, False{}) == True{} : Bool}) -> V.Is(x) & V.Is(y):
  match x:
    case True{}: ({==}, e)
    case False{}: Empty.absurd(V.Is(False{}) & V.Is(y), F.logic__false_true(e))

def pack3(-A: Type, -B: Type, -Cc: Type, -Fd: Type, ab: A & B, pr: Cc & Fd) -> (A & B & Cc) & Fd:
  (x, y) = ab
  (z, f) = pr
  ((x, (y, z)), f)

def lift_right(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +up: C.Frame, -A: Type, -B: Type,
    pr: A & (B & D.FD(t, d, p, up))) -> (A & B) & D.FD(t, d, 1n+p, up):
  (x, r) = pr
  (y, f) = r
  ((x, y), DM.fd_mono(t, d, p, up, f))

def lift_m2(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +up: C.Frame, +j: V.Job,
    pr: V.M(t, d, p, j) & D.FD(t, d, p, up)) -> V.M(t, d, 1n+p, j) & D.FD(t, d, 1n+p, up):
  (x, f) = pr
  (G.m_mono(t, d, p, j, x), DM.fd_mono(t, d, p, up, f))

# ---- tag 13 -------------------------------------------------------------------------

def sound_t13(@T@, +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T13{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T13{}, s, fr, a, b, c, v):
  match s:
    case S.CUnion{+options, +nsel}:
      opt_ok(t, d, n, p, options, nsel, fr, a, b, c, v, ih, C.bsel(U32.is_lt(v, nsel), C.is_leaf(S.field(options, v)), False{}), {==}, h)
@ABSURD13@

# ---- tag 16: a fixed simple container's check bytes ------------------------------------

def t16_last(@T@, +p: Nat, +s: S.CS, @FCP@, +a: Nat, +b: Nat, +c: U32, ih: D.IH(t, d, n, p), last: Bool,
    h: {C.run(p, C.usel(last, 5, 16), s, C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, (@BF@, @B8N@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, @B8N@})) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, s, up, a, b, c, @B8N@, h)))
    case False{}: cont_lift(t, d, p, up, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, @B8N@}),
      ih(D.T16{}, s, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}, a, b, c, @B8N@, h))

def t16_ok(@T@, +p: Nat, +s: S.CS, @FCP@, +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), +last: Bool,
    ok: Bool, e: {C.byte_ok(C.f_schema(S.field(fields, i)), v) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(last, 5, 16), 6), s, C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, (@BF@, @B8N@)) == (@BF@, True{}) : B.Buf & Bool})
    -> (V.Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)) & V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, @B8N@}))) & D.FD(t, d, 1n+p, up):
  match ok:
    case True{}: L.reassoc(V.Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)), V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, @B8N@})), D.FD(t, d, 1n+p, up), e,
      t16_last(t, d, n, p, s, @FCA@, a, b, c, ih, last, h))
    case False{}: Empty.absurd((V.Is(C.byte_ok(C.f_schema(S.field(fields, i)), v)) & V.If(last, Unit, V.M(t, d, p, V.W16{fields, (i + 1 : U32), cnt, base, @B8N@}))) & D.FD(t, d, 1n+p, up),
      ih(D.T6{}, s, C.fsel(last, up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, @B8N@, h))

def sound_t16(@T@, @HDPF@, +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T16{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T16{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{@FCPAT@}:
      t16_ok(t, d, n, p, s, @FCA@, a, b, c, v, ih, U32.is_eq((i + 1 : U32), cnt), C.byte_ok(C.f_schema(S.field(fields, i)), v), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(C.byte_ok(C.f_schema(S.field(fields, i)), v), C.usel(U32.is_eq((i + 1 : U32), cnt), 5, 16), 6), s,
            C.fsel(U32.is_eq((i + 1 : U32), cnt), up, C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, pend, start, has, up}), a, b, c, z) == (@BF@, True{}) : B.Buf & Bool},
          C.rd8(@BF@, C.check_byte(base, S.field(fields, (i + 1 : U32)))), (@BF@, @B8N@),
          Rd.byte_any(d, t, n, U32.from_nat(C.check_byte(base, S.field(fields, (i + 1 : U32)))), hd, pf), h))
@ABSURDFR16@

# ---- tag 15: a simple container's offsets --------------------------------------------

def t15_end(@T@, +p: Nat, +s: S.CS, +fields: S.CS, +i: U32, +endp: Nat, +base: Nat, +v: U32, +up: C.Frame, +a: Nat, +b: Nat, +c: U32, +r: U32, ih: D.IH(t, d, n, p),
    en: Bool, e: {@ENDOK@ == en : Bool},
    h: {C.run(p, C.usel(en, 5, 6), s, up, a, b, c, (@BF@, r)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.Is(@ENDOK@) & D.FD(t, d, 1n+p, up):
  match en:
    case True{}: (e, DM.fd_mono(t, d, p, up, ih(D.T5{}, s, up, a, b, c, r, h)))
    case False{}: Empty.absurd(V.Is(@ENDOK@) & D.FD(t, d, 1n+p, up), ih(D.T6{}, s, up, a, b, c, r, h))

def t15_last(@T@, +p: Nat, +s: S.CS, @FCP@, +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), last: Bool,
    h: {C.run(p, C.usel(last, C.usel(@ENDOK@, 5, 6), 15), s,
          C.fsel(last, up, @FCN15@), a, b, c, (@BF@, @R15@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(last, V.Is(@ENDOK@), V.M(t, d, p, @W15N@)) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: t15_end(t, d, n, p, s, fields, i, endp, base, v, up, a, b, c, @R15@, ih, @ENDOK@, {==}, h)
    case False{}: cont_lift(t, d, p, up, V.M(t, d, p, @W15N@), ih(D.T15{}, s, @FCN15@, a, b, c, @R15@, h))

def t15_ok(@T@, +p: Nat, +s: S.CS, @FCP@, +a: Nat, +b: Nat, +c: U32, +v: U32, ih: D.IH(t, d, n, p), +last: Bool,
    ok: Bool, e: {C.bsel(@OFF@, @PREV@, False{}) == ok : Bool},
    h: {C.run(p, C.usel(ok, C.usel(last, C.usel(@ENDOK@, 5, 6), 15), 6), s,
          C.fsel(last, up, @FCN15@), a, b, c, (@BF@, @R15@)) == (@BF@, True{}) : B.Buf & Bool})
    -> (V.Is(@OFF@) & V.Is(@PREV@) & V.If(last, V.Is(@ENDOK@), V.M(t, d, p, @W15N@))) & D.FD(t, d, 1n+p, up):
  match ok:
    case True{}: pack3(V.Is(@OFF@), V.Is(@PREV@), V.If(last, V.Is(@ENDOK@), V.M(t, d, p, @W15N@)), D.FD(t, d, 1n+p, up),
      both_true(@OFF@, @PREV@, e), t15_last(t, d, n, p, s, @FCA@, a, b, c, v, ih, last, h))
    case False{}: Empty.absurd((V.Is(@OFF@) & V.Is(@PREV@) & V.If(last, V.Is(@ENDOK@), V.M(t, d, p, @W15N@))) & D.FD(t, d, 1n+p, up),
      ih(D.T6{}, s, C.fsel(last, up, @FCN15@), a, b, c, @R15@, h))

def sound_t15(@T@, @HDPF@, +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T15{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T15{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{@FCPAT@}:
      t15_ok(t, d, n, p, s, @FCA@, a, b, c, v, ih, U32.is_eq((i + 1 : U32), cnt), C.bsel(@OFF@, @PREV@, False{}), {==},
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(C.bsel(@OFF@, @PREV@, False{}), C.usel(U32.is_eq((i + 1 : U32), cnt), C.usel(@ENDOK@, 5, 6), 15), 6), s,
            C.fsel(U32.is_eq((i + 1 : U32), cnt), up, @FCN15@), a, b, c, z) == (@BF@, True{}) : B.Buf & Bool},
          C.rd32(@BF@, C.hpos(base, S.field(fields, (i + 1 : U32)))), (@BF@, @R15@),
          Rd.read32_any(d, t, n, U32.from_nat(C.hpos(base, S.field(fields, (i + 1 : U32)))), hd, pf), h))
@ABSURDFR15@

# ---- tag 9: a general container's variable-field offset ---------------------------------
# `s` is the schema of the variable field whose offset v was read.

def t9_sh0(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, @FCP@, +s: S.CS, +v: U32, +r: U32, eq: {r == 0 : U32},
    pr: V.M(t, d, p, V.Node{pend, start, @CH@}) & (V.M(t, d, p, @W8N9@) & D.FD(t, d, p, up)))
    -> V.Shallow(r, V.M(t, d, 1n+p, V.Node{pend, start, @CH@})) & @TAIL9@:
  (x, rest) = pr
  (shal0(V.M(t, d, 1n+p, V.Node{pend, start, @CH@}), r, eq, G.m_mono(t, d, p, V.Node{pend, start, @CH@}, x)), lift_m2(t, d, p, up, @W8N9@, rest))

def t9_k(@T@, +p: Nat, @FCP@, +s: S.CS, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    k: Sh, +eq: {@SH9@ == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(@SH9@, 0, 8), pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.Shallow(@SH9@, V.M(t, d, 1n+p, V.Node{pend, start, @CH@})) & @TAIL9@:
  match k:
    case Sh0{}: t9_sh0(t, d, p, @FCA@, s, v, @SH9@, eq,
      ih(D.T0{}, pend, @FCN9@, start, @CH@, c, 0,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 8), pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool}, @SH9@, 0, eq, h)))
    case Sh1{}: (shal1(V.M(t, d, 1n+p, V.Node{pend, start, @CH@}), @SH9@, eq),
      lift_m2(t, d, p, up, @W8N9@, ih(D.T8{}, pend, @FCN9@, start, @CH@, c, 0,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 8), pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool}, @SH9@, 1, eq, h))))
    case Sh2{}: Empty.absurd(V.Shallow(@SH9@, V.M(t, d, 1n+p, V.Node{pend, start, @CH@})) & @TAIL9@,
      ih(D.T6{}, pend, @FCN9@, start, @CH@, c, 0,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 8), pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool}, @SH9@, 2, eq, h)))

def t9_sh(@T@, +p: Nat, @FCP@, +s: S.CS, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    pr: &k: Sh -> {@SH9@ == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(@SH9@, 0, 8), pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.Shallow(@SH9@, V.M(t, d, 1n+p, V.Node{pend, start, @CH@})) & @TAIL9@:
  match pr:
    case (k, eq): t9_k(t, d, n, p, @FCA@, s, c, v, ih, k, eq, h)

def t9_grow(@T@, +p: Nat, @FCP@, +s: S.CS, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    g: Bool, e: {@GROW@ == g : Bool},
    h: {C.run(p, C.usel(g, C.shallow_tag(@SH9@, 0, 8), 6), pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool})
    -> (V.Is(@GROW@) & V.Shallow(@SH9@, V.M(t, d, 1n+p, V.Node{pend, start, @CH@}))) & @TAIL9@:
  match g:
    case True{}: L.reassoc(V.Is(@GROW@), V.Shallow(@SH9@, V.M(t, d, 1n+p, V.Node{pend, start, @CH@})), @TAIL9@, e,
      t9_sh(t, d, n, p, @FCA@, s, c, v, ih, shallow_is(pend, Nat.sub(@CH@, start)), h))
    case False{}: Empty.absurd((V.Is(@GROW@) & V.Shallow(@SH9@, V.M(t, d, 1n+p, V.Node{pend, start, @CH@}))) & @TAIL9@,
      ih(D.T6{}, pend, @FCN9@, start, @CH@, c, 0, h))

def t9_first(@T@, +p: Nat, @FCP@, +s: S.CS, +c: U32, +v: U32, ih: D.IH(t, d, n, p),
    ok: Bool, e: {Nat.is_eq(U32.to_nat(v), fp) == ok : Bool},
    h: {C.run(p, C.usel(ok, 8, 6), pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.Is(Nat.is_eq(U32.to_nat(v), fp)) & @TAIL9@:
  match ok:
    case True{}: (e, lift_m2(t, d, p, up, @W8N9@, ih(D.T8{}, pend, @FCN9@, start, @CH@, c, 0, h)))
    case False{}: Empty.absurd(V.Is(Nat.is_eq(U32.to_nat(v), fp)) & @TAIL9@, ih(D.T6{}, pend, @FCN9@, start, @CH@, c, 0, h))

def t9_pend(@T@, +p: Nat, @FCP@, +s: S.CS, +c: U32, +v: U32, ih: D.IH(t, d, n, p), pending: Bool,
    h: {C.run(p, C.usel(pending, C.usel(@GROW@, C.shallow_tag(@SH9@, 0, 8), 6), C.usel(Nat.is_eq(U32.to_nat(v), fp), 8, 6)),
          pend, @FCN9@, start, @CH@, c, (@BF@, 0)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(pending, V.Is(@GROW@) & V.Shallow(@SH9@, V.M(t, d, 1n+p, V.Node{pend, start, @CH@})), V.Is(Nat.is_eq(U32.to_nat(v), fp))) & @TAIL9@:
  match pending:
    case True{}: t9_grow(t, d, n, p, @FCA@, s, c, v, ih, @GROW@, {==}, h)
    case False{}: t9_first(t, d, n, p, @FCA@, s, c, v, ih, Nat.is_eq(U32.to_nat(v), fp), {==}, h)

def sound_t9(@T@, +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T9{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T9{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{@FCPAT@}: t9_pend(t, d, n, p, @FCA@, s, c, v, ih, U32.is_eq(has, 1), h)
@ABSURDFR9@

# ---- tag 8: a general container's walk ------------------------------------------------

def t8_sh0(+t: F.array__Tree<U32>, +d: Nat, +p: Nat, +pend: S.CS, +start: Nat, +endp: Nat, +up: C.Frame, +r: U32, eq: {r == 0 : U32},
    pr: V.M(t, d, p, V.Node{pend, start, endp}) & D.FD(t, d, p, up)) -> V.Shallow(r, V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up):
  (x, f) = pr
  (shal0(V.M(t, d, p, V.Node{pend, start, endp}), r, eq, x), DM.fd_mono(t, d, p, up, f))

def t8_k(@T@, +p: Nat, @FCP@, +c: U32, +r: U32, ih: D.IH(t, d, n, p),
    k: Sh, +eq: {@SHE@ == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(@SHE@, 0, 5), pend, up, start, endp, c, (@BF@, r)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.Shallow(@SHE@, V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up):
  match k:
    case Sh0{}: t8_sh0(t, d, p, pend, start, endp, up, @SHE@, eq,
      ih(D.T0{}, pend, up, start, endp, c, r,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 5), pend, up, start, endp, c, (@BF@, r)) == (@BF@, True{}) : B.Buf & Bool}, @SHE@, 0, eq, h)))
    case Sh1{}: (shal1(V.M(t, d, p, V.Node{pend, start, endp}), @SHE@, eq),
      DM.fd_mono(t, d, p, up, ih(D.T5{}, pend, up, start, endp, c, r,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 5), pend, up, start, endp, c, (@BF@, r)) == (@BF@, True{}) : B.Buf & Bool}, @SHE@, 1, eq, h))))
    case Sh2{}: Empty.absurd(V.Shallow(@SHE@, V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up),
      ih(D.T6{}, pend, up, start, endp, c, r,
        F.logic__subst(U32, z => {C.run(p, C.shallow_tag(z, 0, 5), pend, up, start, endp, c, (@BF@, r)) == (@BF@, True{}) : B.Buf & Bool}, @SHE@, 2, eq, h)))

def t8_sh(@T@, +p: Nat, @FCP@, +c: U32, +r: U32, ih: D.IH(t, d, n, p),
    pr: &k: Sh -> {@SHE@ == sh_lit(k) : U32},
    h: {C.run(p, C.shallow_tag(@SHE@, 0, 5), pend, up, start, endp, c, (@BF@, r)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.Shallow(@SHE@, V.M(t, d, p, V.Node{pend, start, endp})) & D.FD(t, d, 1n+p, up):
  match pr:
    case (k, eq): t8_k(t, d, n, p, @FCA@, c, r, ih, k, eq, h)

def t8_end(@T@, +p: Nat, @FCP@, +c: U32, +r: U32, ih: D.IH(t, d, n, p), pending: Bool,
    h: {C.run(p, C.usel(pending, C.shallow_tag(@SHE@, 0, 5), 5), pend, up, start, endp, c, (@BF@, r)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(pending, V.Shallow(@SHE@, V.M(t, d, p, V.Node{pend, start, endp})), Unit) & D.FD(t, d, 1n+p, up):
  match pending:
    case True{}: t8_sh(t, d, n, p, @FCA@, c, r, ih, shallow_is(pend, Nat.sub(endp, start)), h)
    case False{}: (Unit{}, DM.fd_mono(t, d, p, up, ih(D.T5{}, pend, up, start, endp, c, r, h)))

def t8_plain(@T@, +p: Nat, @FCP@, +c: U32, ih: D.IH(t, d, n, p), plain: Bool,
    h: {C.run(p, C.usel(plain, 8, 0), @FS@, @FR1@, @HP@, @HE@, c, (@BF@, @V8@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(plain, V.M(t, d, p, @W8N@), V.M(t, d, p, V.Node{@FS@, @HP@, @HE@}) & V.M(t, d, p, @W8N@)) & D.FD(t, d, 1n+p, up):
  match plain:
    case True{}: cont_lift(t, d, p, up, V.M(t, d, p, @W8N@), ih(D.T8{}, @FS@, @FR1@, @HP@, @HE@, c, @V8@, h))
    case False{}: lift_right(t, d, p, up, V.M(t, d, p, V.Node{@FS@, @HP@, @HE@}), V.M(t, d, p, @W8N@), ih(D.T0{}, @FS@, @FR1@, @HP@, @HE@, c, @V8@, h))

def t8_fixed(@T@, +p: Nat, @FCP@, +c: U32, ih: D.IH(t, d, n, p), fixed: Bool, +plain: Bool,
    h: {C.run(p, C.usel(fixed, C.usel(plain, 8, 0), 9), @FS@, @FR1@, @HP@, @HE@, c, (@BF@, @V8@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(fixed, V.If(plain, V.M(t, d, p, @W8N@), V.M(t, d, p, V.Node{@FS@, @HP@, @HE@}) & V.M(t, d, p, @W8N@)), @VARPART@ & V.M(t, d, p, @W8V@)) & D.FD(t, d, 1n+p, up):
  match fixed:
    case True{}: t8_plain(t, d, n, p, @FCA@, c, ih, plain, h)
    case False{}: lift_right(t, d, p, up, @VARPART@, V.M(t, d, p, @W8V@), ih(D.T9{}, @FS@, @FR1@, @HP@, @HE@, c, @V8@, h))

def t8_last(@T@, +p: Nat, @FCP@, +c: U32, ih: D.IH(t, d, n, p), last: Bool, +fixed: Bool, +plain: Bool,
    h: {C.run(p, C.usel(last, C.usel(U32.is_eq(has, 1), C.shallow_tag(@SHE@, 0, 5), 5), C.usel(fixed, C.usel(plain, 8, 0), 9)),
          C.ssel(last, pend, @FS@), C.fsel(last, up, @FR1@), C.natsel(last, start, @HP@), C.natsel(last, endp, @HE@), c, (@BF@, @V8@)) == (@BF@, True{}) : B.Buf & Bool})
    -> V.If(last, V.If(U32.is_eq(has, 1), V.Shallow(@SHE@, V.M(t, d, p, V.Node{pend, start, endp})), Unit),
         V.If(fixed, V.If(plain, V.M(t, d, p, @W8N@), V.M(t, d, p, V.Node{@FS@, @HP@, @HE@}) & V.M(t, d, p, @W8N@)), @VARPART@ & V.M(t, d, p, @W8V@))) & D.FD(t, d, 1n+p, up):
  match last:
    case True{}: t8_end(t, d, n, p, @FCA@, c, @V8@, ih, U32.is_eq(has, 1), h)
    case False{}: t8_fixed(t, d, n, p, @FCA@, c, ih, fixed, plain, h)

def sound_t8(@T@, @HDPF@, +p: Nat, +s: S.CS, +fr: C.Frame, +a: Nat, +b: Nat, +c: U32, +v: U32,
    ih: D.IH(t, d, n, p), h: D.Ok(t, n, 1n+p, D.T8{}, s, fr, a, b, c, v)) -> D.Den(t, d, 1n+p, D.T8{}, s, fr, a, b, c, v):
  match fr:
    case C.FCont{@FCPAT@}:
      t8_last(t, d, n, p, @FCA@, c, ih, U32.is_eq(i, cnt), C.f_fixed(S.field(fields, i)), S.is_plain(@FS@),
        F.logic__subst(B.Buf & U32, z => {C.run(p, C.usel(U32.is_eq(i, cnt), C.usel(U32.is_eq(has, 1), C.shallow_tag(@SHE@, 0, 5), 5),
              C.usel(C.f_fixed(S.field(fields, i)), C.usel(S.is_plain(@FS@), 8, 0), 9)),
            C.ssel(U32.is_eq(i, cnt), pend, @FS@), C.fsel(U32.is_eq(i, cnt), up, @FR1@),
            C.natsel(U32.is_eq(i, cnt), start, @HP@), C.natsel(U32.is_eq(i, cnt), endp, @HE@), c, z) == (@BF@, True{}) : B.Buf & Bool},
          C.rd32(@BF@, @HP@), (@BF@, @V8@), Rd.read32_any(d, t, n, U32.from_nat(@HP@), hd, pf), h))
@ABSURDFR8@
'''

sub2 = {
 '@T@': T, '@FCPAT@': '+fields, +i, +cnt, +base, +endp, +fp, +pend, +start, +has, +up', '@FCP@': FCP, '@FCA@': FCA,
 '@HDPF@': '+hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool}',
 '@CC@': 'S.CCont{fields, cnt, fp, size, fixed, depth, plain, checks, nchecks, simple}',
 '@PC@': 'S.CPCont{fields, cnt, fp, size, fixed, plain, checks, nchecks, slots, nslots, active}',
 '@LENOK@': 'C.bsel(fixed, Nat.is_eq(Nat.sub(b, a), @FPN@), Nat.is_le(@FPN@, Nat.sub(b, a)))',
 '@FC0@': 'C.FCont{checks, 0, nchecks, a, b, @FPN@, S.CFNone{}, 0n, 0, fr}',
 '@B8C@': 'V.b8(t, d, C.check_byte(a, S.field(checks, 0)))',
 '@R32C@': 'V.r32(t, d, C.hpos(a, S.field(checks, 0)))',
 '@W16T@': 'V.M(t, d, p, V.W16{checks, 0, nchecks, a, @B8C@})',
 '@W15T@': 'V.M(t, d, p, V.W15{checks, 0, nchecks, a, b, @FPN@, S.CFNone{}, 0n, @R32C@})',
 '@W8T@': 'V.M(t, d, p, V.W8{checks, 0, nchecks, a, b, @FPN@, S.CFNone{}, 0n, 0})',
 '@OFF@': 'C.bsel(U32.is_eq(i, 0), Nat.is_eq(U32.to_nat(v), fp), C.bsel(Nat.is_le(start, @CH@), Nat.is_le(@CH@, endp), False{}))',
 '@PREV@': 'C.bsel(U32.is_eq(i, 0), True{}, U32.is_eq(S.shallow(pend, Nat.sub(@CH@, start)), 1))',
 '@ENDOK@': 'U32.is_eq(S.shallow(@FS@, Nat.sub(endp, @CH@)), 1)',
 '@FCN15@': 'C.FCont{fields, (i + 1 : U32), cnt, base, endp, fp, @FS@, @CH@, 1, up}',
 '@W15N@': 'V.W15{fields, (i + 1 : U32), cnt, base, endp, fp, @FS@, @CH@, @R15@}',
 '@FCN9@': 'C.FCont{fields, i, cnt, base, endp, fp, s, @CH@, 1, up}',
 '@W8N9@': 'V.W8{fields, i, cnt, base, endp, fp, s, @CH@, 1}',
 '@TAIL9@': '(V.M(t, d, 1n+p, @W8N9@) & D.FD(t, d, 1n+p, up))',
 '@GROW@': 'C.bsel(Nat.is_le(start, @CH@), Nat.is_le(@CH@, endp), False{})',
 '@SH9@': 'S.shallow(pend, Nat.sub(@CH@, start))',
 '@VARPART@': 'V.If(U32.is_eq(has, 1), V.Is(C.bsel(Nat.is_le(start, @VA@), Nat.is_le(@VA@, endp), False{})) & V.Shallow(S.shallow(pend, Nat.sub(@VA@, start)), V.M(t, d, p, V.Node{pend, start, @VA@})), V.Is(Nat.is_eq(U32.to_nat(@V8@), fp)))',
 '@W8V@': 'V.W8{fields, (i + 1 : U32), cnt, base, endp, fp, @FS@, @VA@, 1}',
}
CS = ['S.CBool{}','S.CUint{x0}','S.CBytes{x0, x1}','S.CByteList{x0, x1, x2}','S.CBitVec{x0, x1, x2}','S.CBitList{x0, x1, x2}',
 'S.CVec{x0, x1, x2, x3, x4, x5}','S.CVecVar{x0, x1, x2}','S.CList{x0, x1, x2, x3, x4, x5, x6}','S.CListVar{x0, x1, x2, x3}',
 'S.CCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9}','S.CPCont{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10}','S.CNull{}',
 'S.CFLeaf{x0, x1, x2, x3}','S.CFNode{x0, x1, x2}','S.CFNone{}']
FRS = ['C.FDone{}','C.FRep{x0, x1, x2, x3, x4}','C.FVarList{x0, x1, x2, x3, x4, x5}']
def absurd_s(tag):
    return '\n'.join(f'    case {k}: Empty.absurd(D.Den(t, d, 1n+p, D.{tag}{{}}, {k}, fr, a, b, c, v), L.no_run(t, n, h))' for k in CS)
def absurd_fr(tag):
    return '\n'.join(f'    case {k}: Empty.absurd(D.Den(t, d, 1n+p, D.{tag}{{}}, s, {k}, a, b, c, v), L.no_run(t, n, h))' for k in FRS)
code = code.replace('@ABSURD13@', absurd_s('T13'))
for tg in ('16','15','9','8'):
    code = code.replace(f'@ABSURDFR{tg}@', absurd_fr('T'+tg))
for _ in range(4):
    for k,v in list(sub2.items())+list(sub.items()):
        code = code.replace(k, v)
assert '@' not in code, re.findall(r'@\w+@', code)
s=open(P).read()
if MARK in s:
    s = s[:s.index(MARK)]
open(P,'w').write(s.rstrip('\n')+'\n'+code)
