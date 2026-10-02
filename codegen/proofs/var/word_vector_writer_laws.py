#!/usr/bin/env python3
"""The fixed-size word-vector writers at ANY byte position X = 4 q + r (r < 4, symbolic),
in the tight, data-only form of vuwd's b20_any: the aligned runs of var_bytes_fix /
var_fix_types at r = 0, the unaligned writers of vuwf<s> (putu_<p>, the model SWc) at
r = 1, 2, 3.

    python3 codegen/proofs/var/word_vector_writer_laws.py [--check]

Writes proofs/obj/vuwv_<p>.bend, one module per writer. For each writer p of N words (T.<p>_put over T.<C>{w0..}):
  PX_<p>(r, dd, D, q, w0..)   the output tree (VF.updv at r = 0, UW.SWc(r, [w0..]) otherwise)
  <p>_any        T.<p>_put(thaw D, X, T.<C>{w0..}) == thaw PX_<p>(r, dd, D, q, w0..)
  <p>_any_bytes  UA.BYT(PX_<p>(..)) == UW.SPL(UA.BYT(D), 4 q + r, FX.limbs([w0..]))
  <p>x_perfect   the model is a perfect tree
with room hl: q + NWN(r + 4 N) <= 2^dd and zero bytes hz over the 4 N data bytes only.
b256 (T.b256_putk over the O.Words of 256 bytes, validity then its copy) has the same
three laws over its storage tree TB, with data FX.limbs(VS.wtake(64n, UW.SLW(TB))).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
from codegen.proofs.var.check_or_write_outputs import finish  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('word_vector_writer_laws', globals())

# (runtime prefix, constructor, words, aligned lemma)
VECS = [('b32', 'Bytes32', 8, 'VBF.put_b32'), ('u256', 'Uint256', 8, 'VBF.put_u256'), ('b48', 'Bytes48', 12, 'VBF.put_b48'),
        ('b96', 'Bytes96', 24, 'VBF.put_b96'), ('bv512', 'Bitvector512', 16, 'VBF.put_bv512'), ('bv64', 'Bitvector64', 2, 'VT.put_bv64')]

HEAD = TPL.text('HEAD')

TH = 'FD.array__thaw(U32, {})'
E_ = '+e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}'


def vec_text(p, C, N, AL):
    ws = [f'w{k}' for k in range(N)]
    W = ', '.join(ws)
    WP = ', '.join(f'+{w}: U32' for w in ws)
    L = f'[{W}]'
    m = 4 * N
    HL = f'+hl: {{Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, {m}n))), VB.pw(dd)) == True{{}} : Bool}}'
    HZ = f'+hz: {{VS.bt({m}n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB({m}n) : +List<U32>}}'
    PF = '+pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}'
    HD = '+hd: {Nat.is_lt(dd, 29n) == True{} : Bool}'
    PX = lambda r: f'PX_{p}({r}, dd, D, q, {W})'  # noqa: E731
    RT = lambda r: f'{{T.{p}_put({TH.format("D")}, X, T.{C}{{{W}}}) == {TH.format(PX(r))} : Array<U32>}}'  # noqa: E731
    BY = lambda r, x: f'{{UA.BYT({PX(r)}) == UW.SPL(UA.BYT(D), {x}, FX.limbs({L})) : +List<U32>}}'  # noqa: E731
    lq = f'UWD.le_q(q, {N}n, VB.pw(dd), hl)'
    out = [TPL.render('vec_text', AL=AL, C=C, HD=HD, HL=HL, HZ=HZ, L=L, N=N, PF=PF, PX=PX, RT=RT, W=W, WP=WP, p=p)]
    for s in (1, 2, 3):
        out.append(f'''    case {s}n: UF{s}.putu_{p}(dd, D, X, q, {W}, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {{==}}), {lq}, pf, hz)''')
    out.append(TPL.render('vec_text_2', BY=BY, HD=HD, HL=HL, HZ=HZ, L=L, PF=PF, RT=RT, WP=WP, m=m, p=p))
    for s in (1, 2, 3):
        out.append(f'''    case {s}n: UB{s}.swcb({L}, dd, D, q, pf, FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(dd)) == True{{}} : Bool}}, Nat.add({N}n, q), Nat.add(q, {N}n), FD.nat__add_comm({N}n, q), {lq}), hz)''')
    out.append(f'''    case 4n+ +t: Empty.absurd({BY("4n+t", "Nat.add(A.quad(q), 4n+t)")}, FD.nat__lt_zero_absurd(t, hr))
''')
    return '\n'.join(out)


def b256_text():
    WS = 'VS.wtake(64n, UW.SLW(TB))'
    OBJ = f'O.Words{{{TH.format("TB")}, 256}}'
    PX = lambda r: f'PX_b256({r}, dd, D, q, TB)'  # noqa: E731
    RT = lambda r: f'{{T.b256_putk({TH.format("D")}, X, {OBJ}) == ({TH.format(PX(r))}, ({OBJ}, 0)) : Array<U32> & (O.Words & U32)}}'  # noqa: E731
    BY = lambda r, x: f'{{UA.BYT({PX(r)}) == UW.SPL(UA.BYT(D), {x}, FX.limbs({WS})) : +List<U32>}}'  # noqa: E731
    P = ('+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, ' + E_ + TPL.text('b256_text'))
    lq = 'UWD.le_q(q, 64n, VB.pw(dd), hl)'
    EL = 'UW.len_take(64n, UW.SLW(TB), FD.logic__subst(Nat, z => {Nat.is_le(64n, z) == True{} : Bool}, VB.pw(dB), VB.len(UW.SLW(TB)), Equal.sym(Nat, VB.len(UW.SLW(TB)), VB.pw(dB), FD.array__slots_length(U32, dB, TB, pfB)), hrB))'
    out = [TPL.render('b256_text_TKS', OBJ=OBJ, P=P, PX=PX, RT=RT, WS=WS)]
    for s in (1, 2, 3):
        out.append(f'''    case {s}n: UK{s}.wputu_b256(dd, D, X, q, dB, TB, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {{==}}), {lq}, pf, pfB, hdB, hrB, hz)''')
    out.append(TPL.render('b256_text_b256_any_bytes', BY=BY, EL=EL, P=P, RT=RT, WS=WS))
    for s in (1, 2, 3):
        out.append(TPL.render('b256_text_2', EL=EL, WS=WS, lq=lq, s=s))
    out.append(f'''    case 4n+ +t: Empty.absurd({BY("4n+t", "Nat.add(A.quad(q), 4n+t)")}, FD.nat__lt_zero_absurd(t, hr))
''')
    return '\n'.join(out)


# ---- the generic types' writers (types/generic_obj.bend) ---------------------------------------

GHEAD_IMPORTS = ['import ../../types/generic_obj.bend as T', 'import ./vuw_bits.bend as UWB', 'import ./vbenc.bend as VBE']

# full-word vectors: (prefix, constructor, words)
GFULL = [('bv256', 'Bitvector256', 8)]
# vectors whose last word holds one byte (validity: its bytes 1..3 are zero): (prefix, constructor, words)
GPART = [('bv1', 'Bitvector1', 1), ('bv2', 'Bitvector2', 1), ('bv8', 'Bitvector8', 1), ('bv257', 'Bitvector257', 9)]
# byte vectors held as packed words (validity words_ok(S, S), an aligned copy, put_words): (prefix, bytes, words)
GWORDS = [('bv1280', 160, 40)]
# Fulu's: the branch vectors of the light-client containers: (prefix, bytes, words, unit)
FWORDS = [('v4_b32', 128, 32, 32), ('v6_b32', 192, 48, 32), ('v7_b32', 224, 56, 32)]


def gput0_full(p, C, N):
    """The aligned writer of a full-word vector: its stores are the run VF.updv."""
    ws = [f'w{k}' for k in range(N)]
    W, L = ', '.join(ws), '[' + ', '.join(ws) + ']'
    JS = '[' + ', '.join(str(k) for k in range(N)) + ']'
    RHS = f'FD.array__thaw(U32, VF.updv({L}, dd, D, P))'
    return f'''
# T.{p}_put at a word-aligned position 4 P: the run VF.updv of its words.
def gput0_{p}(+dd: Nat, +D: FD.array__Tree<U32>, +pos: U32, +P: Nat, +e: {{U32.to_nat(pos) == A.quad(P) : Nat}},
    +hdd: {{Nat.is_lt(dd, 29n) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, dd, D) == True{{}} : Bool}},
    +hb: {{Nat.is_le(Nat.add({N}n, P), VB.pw(dd)) == True{{}} : Bool}}, {', '.join(f'+{w}: U32' for w in ws)})
    -> {{T.{p}_put(FD.array__thaw(U32, D), pos, T.{C}{{{W}}}) == {RHS} : Array<U32>}}:
  +eq = VF.al_q(pos, P, e)
  +hl = FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(dd)) == True{{}} : Bool}}, Nat.add({N}n, P), Nat.add(P, {N}n), FD.nat__add_comm({N}n, P), hb)
  +as = UW.as2_updv({L}, {JS}, dd, D, U32.shrn(pos, 2n), P, 0n, eq, {{==}}, FD.nat__lt_trans(dd, 29n, 31n, hdd, {{==}}), pf, hl)
  %Equal.sym(U32, U32.and(pos, 3), 0, VF.al_3(pos, P, e)) :
    {{T.{p}_pwd(U32.is_eq(_, 0), _, FD.array__thaw(U32, D), U32.shrn(pos, 2n), {W}) == {RHS} : Array<U32>}}
  Equal.trans(Array<U32>, UW.AS2({L}, {JS}, FD.array__thaw(U32, D), U32.shrn(pos, 2n)), FD.array__thaw(U32, VF.updv({L}, dd, D, Nat.add(0n, P))), {RHS}, as,
    Equal.cong(Nat, Array<U32>, z => FD.array__thaw(U32, VF.updv({L}, dd, D, z)), Nat.add(0n, P), P, {{==}}))
'''


def gfull_text(p, C, N):
    uf = [f'import ./vuwf{s}_{p}.bend as UF{s}' for s in (1, 2, 3)]
    body = gput0_full(p, C, N) + vec_text(p, C, N, f'gput0_{p}')
    return module(GHEAD_IMPORTS + uf, f'T.{p}_put (generic {C}, {N} words)', body)


def gpart_text(p, C, N, fulu=False):
    """A vector whose last word holds one byte: at r = 0 the run VF.updv (its last word OR-ed
    into a zero word), at r = s the open model SWo (the carry out of the last word is zero)."""
    ws = [f'w{k}' for k in range(N)]
    W, L = ', '.join(ws), '[' + ', '.join(ws) + ']'
    WP = ', '.join(f'+{w}: U32' for w in ws)
    wl = ws[-1]
    m = 4 * N - 3
    TH = 'FD.array__thaw(U32, {})'
    VT = f'+vt: {{U32.shrn({wl}, 8n) == 0 : U32}}'
    PF = '+pf: {FD.array__perfect(U32, dd, D) == True{} : Bool}'
    out = []
    # ---- aligned
    if N == 1:
        RHS0 = TH.format('VF.updv([w0], dd, D, P)')
        out.append(TPL.render('gpart_text', C=C, PF=PF, RHS0=RHS0, TH=TH, p=p))
    else:
        init = ws[:-1]
        LI = '[' + ', '.join(init) + ']'
        JS = '[' + ', '.join(str(k) for k in range(N - 1)) + ']'
        RHS0 = TH.format(f'VF.updv({L}, dd, D, P)')
        Dv = f'VF.updv({LI}, dd, D, P)'
        out.append(f'''
# T.{p}_put at a word-aligned position 4 P: the stores of its first {N - 1} words, then its last
# word OR-ed into a zero word: the run VF.updv.
def gput0_{p}(+dd: Nat, +D: FD.array__Tree<U32>, +pos: U32, +P: Nat, +e: {{U32.to_nat(pos) == A.quad(P) : Nat}},
    +hdd: {{Nat.is_lt(dd, 29n) == True{{}} : Bool}}, {PF}, +hb: {{Nat.is_le(Nat.add({N}n, P), VB.pw(dd)) == True{{}} : Bool}}, {WP},
    +hz: {{VS.bt({4 * N}n, VS.bdr(Nat.add(A.quad(P), 0n), UA.BYT(D))) == UW.ZB({4 * N}n) : +List<U32>}})
    -> {{T.{p}_put({TH.format("D")}, pos, T.{C}{{{W}}}) == {RHS0} : Array<U32>}}:
  +eq = VF.al_q(pos, P, e)
  +hd32 = FD.nat__lt_trans(dd, 29n, 32n, hdd, {{==}})
  +hbc = FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(dd)) == True{{}} : Bool}}, Nat.add({N}n, P), Nat.add(P, {N}n), FD.nat__add_comm({N}n, P), hb)
  +hl = FD.nat__le_trans(Nat.add(P, {N - 1}n), Nat.add(P, {N}n), VB.pw(dd), Order.add_left(P, {N - 1}n, {N}n, {{==}}), hbc)
  +as = UW.as2_updv({LI}, {JS}, dd, D, U32.shrn(pos, 2n), P, 0n, eq, {{==}}, FD.nat__lt_trans(dd, 29n, 31n, hdd, {{==}}), pf, hl)
  +hL = UWD.le_q(P, {N - 1}n, VB.pw(dd), hbc)
  +eqL = VB.add_at(U32.shrn(pos, 2n), {N - 1}, P, dd, eq, hd32, hL)
  +pfv = VF.updv_perfect({LI}, dd, D, P, pf)
  +zD = UW.zslot_g(dd, D, P, 0n, {4 * N}n, {N - 1}n, {4 * (N - 1)}n, pf, hz, {{==}}, {{==}}, hL)
  +zv = Equal.trans(U32, VB.slot({Dv}, {N - 1}n+P), VB.slot(D, {N - 1}n+P), 0, UW.slot_updv_ge({LI}, dd, D, P, {N - 1}n+P, pf, FD.logic__subst(Nat, z => {{Nat.is_lt(z, {N}n+P) == True{{}} : Bool}}, Nat.add({N - 1}n, P), Nat.add(P, {N - 1}n), FD.nat__add_comm({N - 1}n, P), FD.nat__lt_succ(Nat.add({N - 1}n, P))), hL), zD)
  %Equal.sym(U32, U32.and(pos, 3), 0, VF.al_3(pos, P, e)) :
    {{T.{p}_pwd(U32.is_eq(_, 0), _, {TH.format("D")}, U32.shrn(pos, 2n), {W}) == {RHS0} : Array<U32>}}
  %Equal.sym(Array<U32>, UW.AS2({LI}, {JS}, {TH.format("D")}, U32.shrn(pos, 2n)), {TH.format(Dv)},
      Equal.trans(Array<U32>, UW.AS2({LI}, {JS}, {TH.format("D")}, U32.shrn(pos, 2n)), {TH.format(f"VF.updv({LI}, dd, D, Nat.add(0n, P))")}, {TH.format(Dv)}, as,
        Equal.cong(Nat, Array<U32>, z => {TH.format(f"VF.updv({LI}, dd, D, z)")}, Nat.add(0n, P), P, {{==}}))) :
    {{O.or_word(_, U32.add(U32.shrn(pos, 2n), {N - 1}), {wl}) == {RHS0} : Array<U32>}}
  Equal.trans(Array<U32>, O.or_word({TH.format(Dv)}, U32.add(U32.shrn(pos, 2n), {N - 1}), {wl}), {TH.format(f"UW.ORW(dd, {Dv}, {N - 1}n+P, {wl})")}, {RHS0},
    UW.orw_rt(dd, {Dv}, U32.add(U32.shrn(pos, 2n), {N - 1}), {N - 1}n+P, {wl}, eqL, hd32, hL, pfv),
    Equal.cong(FD.array__Tree<U32>, Array<U32>, z => {TH.format("z")}, UW.ORW(dd, {Dv}, {N - 1}n+P, {wl}), FD.array__upd(U32, dd, {Dv}, {N - 1}n+P, {wl}), UW.orw_zero(dd, {Dv}, {N - 1}n+P, {wl}, zv)))
''')
    # ---- unaligned, at byte s
    for s in (1, 2, 3):
        MUL, UP, Rn = 256 ** s, 32 - 8 * s, 4 - s
        Wn = 4 * N - s
        C_ = f'O.shr_over(w0, {s})'
        v0 = f'U32.mul(w0, {MUL})'
        q = 'U32.shrn(pos, 2n)'
        RHS = TH.format(f'UW.SWo({s}, {L}, dd, U, i, 0)')
        Dm = f'UW.ORW(dd, U, i, U32.or(O.shl_bytes(w0, {s}), 0))'
        carry = f'U32.shrn({wl}, {UP}n)'
        mid = ws[1:-1] if (N >= 2 and s < 3) else ws[1:]
        last = N >= 2 and s < 3
        MID = '[' + ', '.join(mid) + ']'
        JSM = '[' + ', '.join(str(k) for k in range(1, len(mid) + 1)) + ']'
        M4 = 4 * len(mid)
        head = [TPL.render('gpart_text_gputu', C=C, N=N, RHS=RHS, TH=TH, VT=VT, W=W, WP=WP, Wn=Wn, p=p, q=q, s=s, v0=v0, wl=wl)]
        if mid:
            head.append(f'''  +X0 = Nat.add(A.quad(i), {s}n)
  +B = UA.BYT(U)
  +epos = Equal.trans(Nat, 4n+A.quad(i), Nat.add(A.quad(i), 4n), Nat.add(X0, {Rn}n), FD.nat__add_comm(4n, A.quad(i)),
    Equal.sym(Nat, Nat.add(X0, {Rn}n), Nat.add(A.quad(i), 4n), FD.nat__add_assoc(A.quad(i), {s}n, {Rn}n)))
  +zU = Equal.trans(+List<U32>, VS.bt({M4}n, VS.bdr(4n+A.quad(i), B)), VS.bt({M4}n, VS.bdr({Rn}n, VS.bdr(X0, B))), UW.ZB({M4}n),
    Equal.trans(+List<U32>, VS.bt({M4}n, VS.bdr(4n+A.quad(i), B)), VS.bt({M4}n, VS.bdr(Nat.add(X0, {Rn}n), B)), VS.bt({M4}n, VS.bdr({Rn}n, VS.bdr(X0, B))),
      Equal.cong(Nat, +List<U32>, z => VS.bt({M4}n, VS.bdr(z, B)), 4n+A.quad(i), Nat.add(X0, {Rn}n), epos),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt({M4}n, z), VS.bdr(Nat.add(X0, {Rn}n), B), VS.bdr({Rn}n, VS.bdr(X0, B)), UW.bdr_add(X0, {Rn}n, B))),
    Equal.trans(+List<U32>, VS.bt({M4}n, VS.bdr({Rn}n, VS.bdr(X0, B))), VS.bt({M4}n, VS.bdr({Rn}n, VS.bt({Wn}n, VS.bdr(X0, B)))), UW.ZB({M4}n),
      UW.bt_bdr_bt({M4}n, {Rn}n, {Wn}n, VS.bdr(X0, B), {{==}}),
      FD.logic__subst(+List<U32>, z => {{VS.bt({M4}n, VS.bdr({Rn}n, z)) == UW.ZB({M4}n) : +List<U32>}}, UW.ZB({Wn}n), VS.bt({Wn}n, VS.bdr(X0, B)),
        Equal.sym(+List<U32>, VS.bt({Wn}n, VS.bdr(X0, B)), UW.ZB({Wn}n), hz), UW.zb_win({Rn}n, {M4}n, {Wn}n, {{==}}))))
  +fr = UW.upd_frame(dd, U, i, U32.or(VB.slot(U, i), {v0}), pf, hi0)
  +hzr = FD.logic__subst(+List<U32>, z => {{VS.bt({M4}n, z) == UW.ZB({M4}n) : +List<U32>}}, VS.bdr(4n+A.quad(i), B), VS.bdr(4n+A.quad(i), UA.BYT(D1)),
    Equal.sym(+List<U32>, VS.bdr(4n+A.quad(i), UA.BYT(D1)), VS.bdr(4n+A.quad(i), B), fr), zU)
  +hlr = FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(dd)) == True{{}} : Bool}}, Nat.add({len(mid)}n, 1n+i), Nat.add(1n+i, {len(mid)}n), FD.nat__add_comm({len(mid)}n, 1n+i),
    FD.nat__le_trans(Nat.add({len(mid)}n, 1n+i), {N}n+i, VB.pw(dd), Order.left_below_sum({N - len(mid) - 1}n, {len(mid) + 1}n+i), hl))
  +rs0 = UW.rs2_swo({s}, {MID}, {JSM}, dd, D1, {q}, i, 1n, w0, eq, {{==}}, hd, pf1, hlr, hzr)
  +SW1 = UW.SWo({s}, {MID}, dd, D1, 1n+i, {C_})
  +rs = Equal.trans(Array<U32>, UW.RS2({s}, {MID}, {JSM}, {TH.format("D1")}, {q}, w0), {TH.format(f"UW.SWo({s}, {MID}, dd, D1, Nat.add(1n, i), {C_})")}, {TH.format("SW1")}, rs0,
    Equal.cong(Nat, Array<U32>, z => {TH.format(f"UW.SWo({s}, {MID}, dd, D1, z, {C_})")}, Nat.add(1n, i), 1n+i, {{==}}))''')
        if N == 1:
            # or_skip(or_word(out, q, v0), q + 1, carry)
            head.append(TPL.render('gpart_text_2', RHS=RHS, TH=TH, W=W, carry=carry, p=p, q=q, s=s, v0=v0))
        elif not last:
            # s = 3: all the words after the first are stores
            SWm = f'UW.SWo({s}, {MID}, dd, {Dm}, 1n+i, {C_})'
            head.append(f'''  %Equal.sym(U32, U32.and(pos, 3), {s}, e3) : {{T.{p}_pwd(U32.is_eq(_, 0), U32.and(pos, 3), {TH.format("U")}, {q}, {W}) == {RHS} : Array<U32>}}
  %Equal.sym(U32, U32.and(pos, 3), {s}, e3) : {{T.{p}_pwd(U32.is_eq({s}, 0), _, {TH.format("U")}, {q}, {W}) == {RHS} : Array<U32>}}
  %Equal.sym(Array<U32>, O.or_word({TH.format("U")}, U32.add({q}, 0), {v0}), {TH.format("D1")}, UW.orw_rt(dd, U, U32.add({q}, 0), i, {v0}, eq0, hd32, hi0, pf)) :
    {{O.or_skip(UW.RS2({s}, {MID}, {JSM}, _, {q}, w0), U32.add({q}, {N}), {carry}) == {RHS} : Array<U32>}}
  %Equal.sym(Array<U32>, UW.RS2({s}, {MID}, {JSM}, {TH.format("D1")}, {q}, w0), {TH.format("SW1")}, rs) :
    {{O.or_skip(_, U32.add({q}, {N}), {carry}) == {RHS} : Array<U32>}}
  %Equal.sym(Array<U32>, O.or_skip({TH.format("SW1")}, U32.add({q}, {N}), {carry}), {TH.format("SW1")}, UW.orskip0(dd, SW1, U32.add({q}, {N}), {carry}, hc)) :
    {{_ == {RHS} : Array<U32>}}
  Equal.cong(U32, Array<U32>, z => {TH.format(f"UW.SWo({s}, {MID}, dd, UW.ORW(dd, U, i, z), 1n+i, {C_})")}, {v0}, U32.or(O.shl_bytes(w0, {s}), 0), Equal.sym(U32, U32.or({v0}, 0), {v0}, UWB.or0r({v0})))
''')
        else:
            # s < 3: the last word is OR-ed in
            IDXL = f'Nat.add(List.length(&2, U32, {MID}), 1n+i)'
            CRYm = f'UW.CRY({s}, {MID}, {C_})'
            VL = f'U32.or(O.shl_bytes({wl}, {s}), {CRYm})'
            T1 = f'UW.ORW(dd, SW1, {IDXL}, {VL})'
            SWm = f'UW.SWo({s}, {MID}, dd, {Dm}, 1n+i, {C_})'
            T2 = f'UW.ORW(dd, {SWm}, {IDXL}, {VL})'
            APPL = f'List.append(&2, U32, {MID}, [{wl}])'
            REST = '[' + ', '.join(ws[1:]) + ']'
            head.append(TPL.render('gpart_text_3', APPL=APPL, C_=C_, Dm=Dm, IDXL=IDXL, JSM=JSM, MID=MID, N=N, REST=REST, RHS=RHS, T1=T1, T2=T2, TH=TH, VL=VL, W=W, carry=carry, p=p, q=q, s=s, v0=v0, wl=wl))
        out.append('\n'.join(head))
    # ---- the leaf at any X
    mn = f'{m}n'
    HL = f'+hl: {{Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, {mn}))), VB.pw(dd)) == True{{}} : Bool}}'
    HZ = f'+hz: {{VS.bt(Nat.add({mn}, UWD.PADB(r, {mn})), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(Nat.add({mn}, UWD.PADB(r, {mn}))) : +List<U32>}}'
    E_ = '+e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool}'
    HD = '+hd: {Nat.is_lt(dd, 29n) == True{} : Bool}'
    PX = lambda r: f'PX_{p}({r}, dd, D, q, {W})'  # noqa: E731
    RT = lambda r: f'{{T.{p}_put({TH.format("D")}, X, T.{C}{{{W}}}) == {TH.format(PX(r))} : Array<U32>}}'  # noqa: E731
    DATA = lambda r: f'List.append(&2, U32, VS.bt({mn}, FX.limbs({L})), UW.ZB(UWD.PADB({r}, {mn})))'  # noqa: E731
    BY = lambda r, x: f'{{UA.BYT({PX(r)}) == UW.SPL(UA.BYT(D), {x}, {DATA(r)}) : +List<U32>}}'  # noqa: E731
    hlq = f'FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(dd)) == True{{}} : Bool}}, Nat.add(q, {N}n), Nat.add({N}n, q), FD.nat__add_comm(q, {N}n), hl)'
    # limbs ws with the last word's limbs exposed, and them split by its tail zero
    tz = f'UWB.tzl1({wl}, vt)'
    ZL = '[0, 0, 0]'
    LI_L = 'FX.limbs([' + ', '.join(ws[:-1]) + '])'
    def exposed(hole):
        return f'List.append(&2, U32, {LI_L}, List.append(&2, U32, {hole}, []))'
    def tzconv(k):
        # FX.limbs(ws) under VS.bt(k, .): its last word's limbs are its first then zeros
        return (f'Equal.cong(+List<U32>, +List<U32>, z => VS.bt({k}, {exposed("z")}), I.limb({wl}), List.append(&2, U32, VS.bt(1n, I.limb({wl})), {ZL}), {tz})')
    out.append(TPL.render('gpart_text_PX_', E_=E_, HD=HD, HL=HL, HZ=HZ, L=L, PF=PF, PX=PX, RT=RT, VT=VT, W=W, WP=WP, hlq=hlq, m=m, p=p))
    for s in (1, 2, 3):
        out.append(f'''    case {s}n: gputu{s}_{p}(dd, D, X, q, {W}, e, FD.nat__lt_trans(dd, 29n, 31n, hd, {{==}}), {hlq}, pf, vt, hz)''')
    out.append(f'''    case 4n+ +t: Empty.absurd({RT("4n+t")}, FD.nat__lt_zero_absurd(t, hr))

# Its bytes: the {m} bytes, then zeros to the end of its last word, when those were zero.
def {p}_any_bytes(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, {WP}, {E_},
    {HD}, {HL}, {PF}, {VT}, {HZ})
    -> {BY("r", "Nat.add(A.quad(q), r)")}:
  match r:
    case 0n:
      %Equal.sym(Nat, Nat.add(A.quad(q), 0n), A.quad(q), FD.nat__add_zero(A.quad(q))) : {BY("0n", "_")}
      %Equal.trans(+List<U32>, VS.bt({4 * N}n, FX.limbs({L})), VS.bt({4 * N}n, {exposed(f"List.append(&2, U32, VS.bt(1n, I.limb({wl})), {ZL})")}), {DATA("0n")},
          {tzconv(f"{4 * N}n")}, {{==}}) :
        {{UA.BYT({PX("0n")}) == UW.SPL(UA.BYT(D), A.quad(q), _) : +List<U32>}}
      %Equal.sym(+List<U32>, VS.bt({4 * N}n, FX.limbs({L})), FX.limbs({L}), {{==}}) :
        {{UA.BYT({PX("0n")}) == UW.SPL(UA.BYT(D), A.quad(q), _) : +List<U32>}}
      UW.updv_bytes({L}, dd, D, q, pf, hl)''')
    for s in (1, 2, 3):
        Wn = 4 * N - s
        out.append(f'''    case {s}n:
      %Equal.trans(+List<U32>, VS.bt({Wn}n, FX.limbs({L})), VS.bt({Wn}n, {exposed(f"List.append(&2, U32, VS.bt(1n, I.limb({wl})), {ZL})")}), {DATA(f"{s}n")},
          {tzconv(f"{Wn}n")}, {{==}}) :
        {{UA.BYT({PX(f"{s}n")}) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), {s}n), _) : +List<U32>}}
      UB{s}.swcbo(w0, [{", ".join(ws[1:])}], dd, D, q, pf, hl, hz)''')
    out.append(f'''    case 4n+ +t: Empty.absurd({BY("4n+t", "Nat.add(A.quad(q), 4n+t)")}, FD.nat__lt_zero_absurd(t, hr))
''')
    if fulu:
        return module(GHEAD_IMPORTS[1:] + ['import ../../src/primitives.bend as I'], f'T.{p}_put ({C}, {m} bytes)', '\n'.join(out))
    return module(GHEAD_IMPORTS + ['import ../../src/primitives.bend as I'], f'T.{p}_put (generic {C}, {m} bytes)', '\n'.join(out))

def gwords_text(p, S, W, unit=1, generic=True):
    """A byte vector of S bytes held as packed words (W = S / 4): its validity check, then at
    r = 0 its unrolled aligned copy (the run VF.updv of the storage's first W words), and
    otherwise O.put_words (vuwd's loose putw: the carry word lies inside the value's room)."""
    import math
    kw = math.ceil(math.log2(31 + S))
    WS = f'VS.wtake({W}n, UW.SLW(TB))'
    OBJ = f'O.Words{{{TH.format("TB")}, {S}}}'
    TY = 'Array<U32> & (O.Words & U32)'
    PX = lambda r: f'PX_{p}({r}, dd, D, q, TB)'  # noqa: E731
    RT = lambda r: f'{{T.{p}_putk({TH.format("D")}, X, {OBJ}) == ({TH.format(PX(r))}, ({OBJ}, 0)) : {TY}}}'  # noqa: E731
    BY = lambda r, x: f'{{UA.BYT({PX(r)}) == UW.SPL(UA.BYT(D), {x}, FX.limbs({WS})) : +List<U32>}}'  # noqa: E731
    P = ('+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, ' + E_ + TPL.render('gwords_text', S=S, W=W))
    lq = f'UWD.le_q(q, {W}n, VB.pw(dd), hl)'
    EL = f'UW.len_take({W}n, UW.SLW(TB), FD.logic__subst(Nat, z => {{Nat.is_le({W}n, z) == True{{}} : Bool}}, VB.pw(dB), VB.len(UW.SLW(TB)), Equal.sym(Nat, VB.len(UW.SLW(TB)), VB.pw(dB), FD.array__slots_length(U32, dB, TB, pfB)), hrB))'
    WL = '[' + ', '.join(f'VB.slot(TB, {j}n)' for j in range(W)) + ']'
    out = [f'def WL_{p}(+TB: FD.array__Tree<U32>) -> List<&2, U32>: {WL}']
    for j in range(W + 1):
        out.append(f'def WP{j}_{p}(+TB: FD.array__Tree<U32>) -> List<&2, U32>: [' + ', '.join(f'VB.slot(TB, {i}n)' for i in range(j)) + ']')
    RHS0 = f'(FD.array__thaw(U32, VF.updv(WL_{p}(TB), dd, D, P)), ({OBJ}, 0))'
    out.append(TPL.render('gwords_text_gwput_', OBJ=OBJ, RHS0=RHS0, S=S, TY=TY, W=W, kw=kw, p=p, unit=unit))
    for j in range(W):
        pre = f'FD.array__thaw(U32, VF.updv(WP{j}_{p}(TB), dd, D, P))'
        post = f'FD.array__thaw(U32, VF.updv(WP{j + 1}_{p}(TB), dd, D, P))'
        hi = f'FD.nat__lt_le_trans({j}n, {W}n, VB.pw(dB), {{==}}, hrB)'
        out.append(f'  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TB), {j}), (FD.array__thaw(U32, TB), VB.slot(TB, {j}n)), VB.get_n(dB, TB, {j}, {j}n, {{==}}, hB32, {hi}, pfB)) :')
        out.append(f'    {{T.{p}_pk_ok(T.{p}_pal({S}, T.{p}_pa{j}(U32.shrn(pos, 2n), {pre}, _))) == {RHS0} : {TY}}}')
        nxt = f'T.{p}_pa{j + 1}(U32.shrn(pos, 2n), _, Array.get(U32, FD.array__thaw(U32, TB), {j + 1}))' if j + 1 < W else '(_, FD.array__thaw(U32, TB))'
        for line in TPL.render('gwords_text_lines', RHS0=RHS0, S=S, TY=TY, W=W, j=j, nxt=nxt, p=p, post=post, pre=pre).split('\n'):
            out.append(line)
    out.append('  {==}')
    out.append(TPL.render('gwords_text_wl_', OBJ=OBJ, P=P, PX=PX, RT=RT, S=S, TY=TY, W=W, WS=WS, kw=kw, p=p, unit=unit))
    for s in (1, 2, 3):
        out.append(f'''    case {s}n:
      +e3 = UW.ua_3(X, q, {s}n, {s}, {{==}}, e, {{==}})
      %Equal.sym(O.Words & Bool, T.{p}_valid({OBJ}), ({OBJ}, True{{}}), VBE.words_ok_b(dB, TB, {S}, {S}, {S}, {kw}n, pfB, hdB, {{==}}, {{==}}, {{==}}, {{==}}, hrB, {{==}}, {unit}, {{==}})) :
        {{T.{p}_pk({TH.format("D")}, X, _) == ({TH.format(PX(f"{s}n"))}, ({OBJ}, 0)) : {TY}}}
      %Equal.sym(U32, U32.and(X, 3), {s}, e3) : {{T.{p}_pk_ok(T.{p}_pw(U32.is_eq(_, 0), {TH.format("D")}, X, {TH.format("TB")}, {S})) == ({TH.format(PX(f"{s}n"))}, ({OBJ}, 0)) : {TY}}}
      %Equal.sym(Array<U32> & O.Words, O.put_words({TH.format("D")}, X, {OBJ}), ({TH.format(f"UWD.PWM({s}n, dd, D, q, TB, {S})")}, {OBJ}),
          UWD.putw_loose(dd, D, X, q, {s}n, dB, TB, {S}, {kw}n, e, {{==}}, hd, hdB, {{==}}, {{==}}, hrB, {lq}, pf, pfB, hz)) :
        {{T.{p}_pk_ok(_) == ({TH.format(PX(f"{s}n"))}, ({OBJ}, 0)) : {TY}}}
      {{==}}''')
    out.append(TPL.render('gwords_text_2', BY=BY, EL=EL, P=P, RT=RT, S=S, W=W, WS=WS, p=p))
    for s in (1, 2, 3):
        out.append(TPL.render('gwords_text_3', EL=EL, W=W, WS=WS, lq=lq, s=s))
    out.append(f'''    case 4n+ +t: Empty.absurd({BY("4n+t", "Nat.add(A.quad(q), 4n+t)")}, FD.nat__lt_zero_absurd(t, hr))
''')
    if generic:
        imports = GHEAD_IMPORTS + ['import ./vuwv_b256.bend as VWB']
        what = f'T.{p}_putk (generic, the {S}-byte O.Words)'
    else:
        imports = ['import ./vbenc.bend as VBE', 'import ./vuwv_b256.bend as VWB']
        what = f'T.{p}_putk (the {S}-byte O.Words)'
    return module(imports, what, '\n'.join(out))


# ---- SyncCommittee: the 512 pubkeys' packed words (put_words) then the aggregate pubkey (b48) ----

def _sc_closed_facts(NB, WO):
    """the pair projections and the closed facts on 24576 = 4 * 6144 and the pubkeys' storage check, each decided once"""
    return TPL.render('_sc_closed_facts', NB=NB, WO=WO)


def _sc_valid_and_model(AP, OBJ, WO, AGG, A_, PX):
    """the pubkeys' storage check on a valid tree, the model after the aggregate and its perfect tree"""
    return TPL.render('_sc_valid_and_model', AGG=AGG, AP=AP, A_=A_, OBJ=OBJ, PX=PX, WO=WO)


def _sc_padding_facts(ab, NB, E24M, EDL):
    """the padding to the word boundary does not see whole words; the byte counts at r < 4"""
    return f'''# PADB(r, 4 K) = PADB(r, 0): the padding to the word boundary does not see whole words. Over a
# symbolic K, so no 24576-sized Nat is reduced; the byte-count facts then split only on r < 4.
def sc_add4(+r: Nat, +m: Nat) -> {{Nat.add(r, 4n+m) == 4n+Nat.add(r, m) : Nat}}:
  match r:
    case 0n: {{==}}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, Nat.add(p, 4n+m), 4n+Nat.add(p, m), sc_add4(p, m))

def sc_leup(+r: Nat, +Q: Nat, +h: {{Nat.is_le(r, Q) == True{{}} : Bool}}) -> {{Nat.is_le(r, 1n+Q) == True{{}} : Bool}}:
  FD.nat__le_trans(r, Q, 1n+Q, h, FD.nat__le_succ(Q))

def sc_sub4(+Q: Nat, +r: Nat, +h: {{Nat.is_le(r, Q) == True{{}} : Bool}}) -> {{Nat.sub(4n+Q, r) == 4n+Nat.sub(Q, r) : Nat}}:
  +h1 = sc_leup(r, Q, h)
  +h2 = sc_leup(r, 1n+Q, h1)
  +h3 = sc_leup(r, 2n+Q, h2)
  Equal.trans(Nat, Nat.sub(4n+Q, r), 1n+Nat.sub(3n+Q, r), 4n+Nat.sub(Q, r), FD.nat__sub_succ_left(3n+Q, r, h3),
    Equal.cong(Nat, Nat, z => 1n+z, Nat.sub(3n+Q, r), 3n+Nat.sub(Q, r),
      Equal.trans(Nat, Nat.sub(3n+Q, r), 1n+Nat.sub(2n+Q, r), 3n+Nat.sub(Q, r), FD.nat__sub_succ_left(2n+Q, r, h2),
        Equal.cong(Nat, Nat, z => 1n+z, Nat.sub(2n+Q, r), 2n+Nat.sub(Q, r),
          Equal.trans(Nat, Nat.sub(2n+Q, r), 1n+Nat.sub(1n+Q, r), 2n+Nat.sub(Q, r), FD.nat__sub_succ_left(1n+Q, r, h1),
            Equal.cong(Nat, Nat, z => 1n+z, Nat.sub(1n+Q, r), 1n+Nat.sub(Q, r), FD.nat__sub_succ_left(Q, r, h)))))))

def sc_nwnge(+y: Nat) -> {{Nat.is_le(y, A.quad(UWD.NWN(y))) == True{{}} : Bool}}:
  match y:
    case 0n: {{==}}
    case 1n: {{==}}
    case 2n: {{==}}
    case 3n: {{==}}
    case 4n+ +z: sc_nwnge(z)

def sc_pq(+r: Nat, +K: Nat) -> {{UWD.PADB(r, A.quad(K)) == UWD.PADB(r, 0n) : Nat}}:
  match K:
    case 0n: {{==}}
    case 1n+ +k:
      +m = A.quad(k)
      +y = Nat.add(r, m)
      +Q = A.quad(UWD.NWN(y))
      +h = FD.nat__le_trans(r, y, Q, FD.nat__le_add_right(r, m), sc_nwnge(y))
      %Equal.sym(Nat, Nat.add(r, 4n+m), 4n+y, sc_add4(r, m)) : {{Nat.sub(Nat.sub(A.quad(UWD.NWN(_)), r), 4n+m) == UWD.PADB(r, 0n) : Nat}}
      %Equal.sym(Nat, Nat.sub(4n+Q, r), 4n+Nat.sub(Q, r), sc_sub4(Q, r, h)) : {{Nat.sub(_, 4n+m) == UWD.PADB(r, 0n) : Nat}}
      sc_pq(r, k)

def sc_edl0(+r: Nat, +hr: {{Nat.is_lt(r, 4n) == True{{}} : Bool}}) -> {{Nat.add(UWD.PADB(r, 0n), Nat.sub(48n, UWD.PADB(r, 0n))) == 48n : Nat}}:
  match r:
    case 0n: {{==}}
    case 1n: {{==}}
    case 2n: {{==}}
    case 3n: {{==}}
    case 4n+ +t: {ab("{Nat.add(UWD.PADB(4n+t, 0n), Nat.sub(48n, UWD.PADB(4n+t, 0n))) == 48n : Nat}")}

def sc_edlK(+r: Nat, +hr: {{Nat.is_lt(r, 4n) == True{{}} : Bool}}, +K: Nat) -> {{Nat.add(UWD.PADB(r, A.quad(K)), Nat.sub(48n, UWD.PADB(r, A.quad(K)))) == 48n : Nat}}:
  %Equal.sym(Nat, UWD.PADB(r, A.quad(K)), UWD.PADB(r, 0n), sc_pq(r, K)) : {{Nat.add(_, Nat.sub(48n, _)) == 48n : Nat}}
  sc_edl0(r, hr)

# (m + pad) + (48 - pad) = T when m = 4 K and m + 48 = T.
def sc_e24K(+r: Nat, +hr: {{Nat.is_lt(r, 4n) == True{{}} : Bool}}, +m: Nat, +K: Nat, +eK: {{m == A.quad(K) : Nat}}, +T: Nat, +eT: {{Nat.add(m, 48n) == T : Nat}})
    -> {{T == Nat.add(Nat.add(m, UWD.PADB(r, m)), Nat.sub(48n, UWD.PADB(r, m))) : Nat}}:
  +P = UWD.PADB(r, m)
  +D = Nat.sub(48n, P)
  +h2 = FD.logic__subst(Nat, z => {{Nat.add(UWD.PADB(r, z), Nat.sub(48n, UWD.PADB(r, z))) == 48n : Nat}}, A.quad(K), m, Equal.sym(Nat, m, A.quad(K), eK), sc_edlK(r, hr, K))
  Equal.sym(Nat, Nat.add(Nat.add(m, P), D), T,
    Equal.trans(Nat, Nat.add(Nat.add(m, P), D), Nat.add(m, 48n), T,
      Equal.trans(Nat, Nat.add(Nat.add(m, P), D), Nat.add(m, Nat.add(P, D)), Nat.add(m, 48n), FD.nat__add_assoc(m, P, D),
        Equal.cong(Nat, Nat, z => Nat.add(m, z), Nat.add(P, D), 48n, h2)), eT))

# The byte counts at r < 4: 24624 = (24576 + pad) + (48 - pad), through sc_e24K / sc_edlK at K = 6144.
def sc_e24(+r: Nat, +hr: {{Nat.is_lt(r, 4n) == True{{}} : Bool}}, +m: Nat, +em: {{{NB} == m : Nat}}) -> {E24M("r", "m")}:
  +eK = Equal.trans(Nat, m, {NB}, A.quad(6144n), Equal.sym(Nat, {NB}, m, em), sc_eK())
  +eT = FD.logic__subst(Nat, z => {{Nat.add(z, 48n) == 24624n : Nat}}, {NB}, m, em, sc_eT())
  sc_e24K(r, hr, m, 6144n, eK, 24624n, eT)

def sc_edl(+r: Nat, +hr: {{Nat.is_lt(r, 4n) == True{{}} : Bool}}) -> {EDL}:
  FD.logic__subst(Nat, z => {{Nat.add(UWD.PADB(r, z), Nat.sub(48n, UWD.PADB(r, z))) == 48n : Nat}}, A.quad(6144n), {NB},
    Equal.sym(Nat, {NB}, A.quad(6144n), sc_eK()), sc_edlK(r, hr, 6144n))

'''


def _sc_runtime_pieces(AP, WOv, TD, AGG, OBJv, TY, LB, LEN, Y48):
    """the runtime over any byte count and the splice of the aggregate over the zeros"""
    return TPL.render('_sc_runtime_pieces', AGG=AGG, AP=AP, LB=LB, LEN=LEN, OBJv=OBJv, TD=TD, TY=TY, WOv=WOv, Y48=Y48)


def _sc_core(AP, WOv, NB, NBv, W1, W1v, DL, DLv, X0, LB, P, PADv, POS, RT, RTv, BY, BYv, LEN, DATAv, Y0v, Zv, PWv, XKv, A_, PB48v, Y48, K):
    """the runtime and the bytes at any r < 4 over a symbolic byte count, and the core at n = 24576"""
    return f'''# The runtime and the bytes at any r < 4, over a symbolic byte count n (K its value): no closed
# 24576-sized Nat is ever reduced here (a reduced Nat.add(24576, _) overflows the checker's stack).
def sc_core(+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, {AP}, +n: U32, +K: Nat, {E_},
    +hd: {{Nat.is_lt(dd, 29n) == True{{}} : Bool}}, +hl: {{Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, 24624n))), VB.pw(dd)) == True{{}} : Bool}},
    +pf: {{FD.array__perfect(U32, dd, D) == True{{}} : Bool}}, +pfB: {{FD.array__perfect(U32, dB, TB) == True{{}} : Bool}}, +hdB: {{Nat.is_lt(dB, 31n) == True{{}} : Bool}},
    +hv: {{T.v512_b48_valid({WOv}) == ({WOv}, True{{}}) : O.Words & Bool}},
    +hy: {{Nat.is_le(VC.YL(n), VB.pw(15n)) == True{{}} : Bool}}, +htz: {{O.tail_zero(U32.and(n, 3), VB.slot(TB, VY.QL(n))) == True{{}} : Bool}},
    +hsrc: {{Nat.is_le(VC.NW(n), VB.pw(dB)) == True{{}} : Bool}}, +hlw: {{Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, {NBv}))), VB.pw(dd)) == True{{}} : Bool}},
    +hq: {{Nat.is_le({NBv}, A.quad(VB.pw(dB))) == True{{}} : Bool}}, +eK: {{{NBv} == K : Nat}},
    +hz1: {{VS.bt(Nat.add({W1v}, {DLv}), VS.bdr({X0}, UA.BYT(D))) == UW.ZB(Nat.add({W1v}, {DLv})) : {LB}}}, +edl: {{Nat.add({PADv}, {DLv}) == 48n : Nat}},
    +e48: {{U32.to_nat(U32.add(X, 24576)) == {POS} : Nat}}, +hl48: {{Nat.is_le(Nat.add(Nat.add(6144n, q), UWD.NWN(Nat.add(r, 48n))), VB.pw(dd)) == True{{}} : Bool}},
    +epos: {{Nat.add({X0}, K) == {POS} : Nat}})
    -> DK.P2({RTv}, {BYv}):
  +B = UA.BYT(D)
  +SL = UW.SLW(TB)
  +e0 = VRX.fpos(X, q, r, 0n, 0, 24624n, dd, e, {{==}}, hd, {{==}}, hl)
  +hzw = UWD.zpre({W1v}, {DLv}, VS.bdr({X0}, B), hz1)
  +pw1 = UWD.putw_any(dd, D, U32.add(X, 0), q, r, dB, TB, n, 15n, e0, hr, hd, hdB, {{==}}, hy, hsrc, hlw, pf, pfB, htz, hzw)
  +b1 = UWD.putw_any_bytes(dd, D, U32.add(X, 0), q, r, dB, TB, n, 15n, e0, hr, hd, hdB, {{==}}, hy, hsrc, hlw, pf, pfB, htz, hzw)
  +pfW = UWD.pwm_perfect(r, dd, D, q, TB, n, pf)
  # the pubkeys' bytes, extended by the zeros up to the aggregate's end
  +eLS = Equal.trans(Nat, {LEN("FX.limbs(SL)")}, A.quad(VB.len(SL)), A.quad(VB.pw(dB)), UW.len_limbs_v(SL),
    Equal.cong(Nat, Nat, z => A.quad(z), VB.len(SL), VB.pw(dB), FD.array__slots_length(U32, dB, TB, pfB)))
  +hLS = FD.logic__subst(Nat, z => {{Nat.is_le({NBv}, z) == True{{}} : Bool}}, A.quad(VB.pw(dB)), {LEN("FX.limbs(SL)")},
    Equal.sym(Nat, {LEN("FX.limbs(SL)")}, A.quad(VB.pw(dB)), eLS), hq)
  +eLD = VS.bt_len({NBv}, FX.limbs(SL), hLS)
  +eLY0 = Equal.trans(Nat, {LEN(Y0v)}, Nat.add({LEN(DATAv)}, {LEN(f"UW.ZB({PADv})")}), {W1v}, VS.len_app({DATAv}, UW.ZB({PADv})),
    Equal.trans(Nat, Nat.add({LEN(DATAv)}, {LEN(f"UW.ZB({PADv})")}), Nat.add({NBv}, {LEN(f"UW.ZB({PADv})")}), {W1v},
      Equal.cong(Nat, Nat, z => Nat.add(z, {LEN(f"UW.ZB({PADv})")}), {LEN(DATAv)}, {NBv}, eLD),
      Equal.cong(Nat, Nat, z => Nat.add({NBv}, z), {LEN(f"UW.ZB({PADv})")}, {PADv}, UW.len_zb({PADv}))))
  +hzd = FD.logic__subst(Nat, z => {{VS.bt({DLv}, VS.bdr(Nat.add({X0}, z), B)) == UW.ZB({DLv}) : {LB}}}, {W1v}, {LEN(Y0v)}, Equal.sym(Nat, {LEN(Y0v)}, {W1v}, eLY0),
    FD.logic__subst({LB}, z => {{VS.bt({DLv}, z) == UW.ZB({DLv}) : {LB}}}, VS.bdr({W1v}, VS.bdr({X0}, B)), VS.bdr(Nat.add({X0}, {W1v}), B),
      Equal.sym({LB}, VS.bdr(Nat.add({X0}, {W1v}), B), VS.bdr({W1v}, VS.bdr({X0}, B)), UW.bdr_add({X0}, {W1v}, B)),
      UWD.zsuf({W1v}, {DLv}, VS.bdr({X0}, B), hz1)))
  +ee = UWD.spl_ext(B, {X0}, {Y0v}, {DLv}, hzd)
  +eZ = Equal.trans({LB}, List.append(&2, U32, {Y0v}, UW.ZB({DLv})), List.append(&2, U32, {DATAv}, List.append(&2, U32, UW.ZB({PADv}), UW.ZB({DLv}))), {Zv},
    VS.app_assoc({DATAv}, UW.ZB({PADv}), UW.ZB({DLv})),
    Equal.cong({LB}, {LB}, z => List.append(&2, U32, {DATAv}, z), List.append(&2, U32, UW.ZB({PADv}), UW.ZB({DLv})), UW.ZB(48n),
      Equal.trans({LB}, List.append(&2, U32, UW.ZB({PADv}), UW.ZB({DLv})), UW.ZB(Nat.add({PADv}, {DLv})), UW.ZB(48n), UWD.zb_app({PADv}, {DLv}),
        Equal.cong(Nat, {LB}, z => UW.ZB(z), Nat.add({PADv}, {DLv}), 48n, edl))))
  +eP1 = Equal.trans({LB}, UA.BYT({PWv}), UW.SPL(B, {X0}, {Y0v}), UW.SPL(B, {X0}, {Zv}), b1,
    Equal.trans({LB}, UW.SPL(B, {X0}, {Y0v}), UW.SPL(B, {X0}, List.append(&2, U32, {Y0v}, UW.ZB({DLv}))), UW.SPL(B, {X0}, {Zv}), ee,
      Equal.cong({LB}, {LB}, z => UW.SPL(B, {X0}, z), List.append(&2, U32, {Y0v}, UW.ZB({DLv})), {Zv}, eZ)))
  +eLZ = Equal.trans(Nat, {LEN(Zv)}, Nat.add({LEN(DATAv)}, {LEN("UW.ZB(48n)")}), Nat.add(K, 48n), VS.len_app({DATAv}, UW.ZB(48n)),
    Equal.trans(Nat, Nat.add({LEN(DATAv)}, {LEN("UW.ZB(48n)")}), Nat.add(K, {LEN("UW.ZB(48n)")}), Nat.add(K, 48n),
      Equal.cong(Nat, Nat, z => Nat.add(z, {LEN("UW.ZB(48n)")}), {LEN(DATAv)}, K, Equal.trans(Nat, {LEN(DATAv)}, {NBv}, K, eLD, eK)),
      Equal.cong(Nat, Nat, z => Nat.add(K, z), {LEN("UW.ZB(48n)")}, 48n, UW.len_zb(48n))))
  +hZ = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(K, 48n), z) == True{{}} : Bool}}, Nat.add(K, 48n), {LEN(Zv)}, Equal.sym(Nat, {LEN(Zv)}, Nat.add(K, 48n), eLZ), FD.nat__le_refl(Nat.add(K, 48n)))
  +hX = VRX.xstart(q, r, 24624n, dd, D, pf, hl)
  +ew = UW.win_spl(B, {X0}, {Zv}, K, 48n, hX, hZ)
  +eL2 = Equal.trans(Nat, {LEN(DATAv)}, {NBv}, K, eLD, eK)
  +ebd0 = FD.logic__subst(Nat, z => {{VS.bdr(Nat.add(z, 0n), {Zv}) == VS.bdr(0n, UW.ZB(48n)) : {LB}}}, {LEN(DATAv)}, K, eL2, UW.bdr_app_len({DATAv}, 0n, UW.ZB(48n)))
  +ebd = FD.logic__subst(Nat, z => {{VS.bdr(z, {Zv}) == VS.bdr(0n, UW.ZB(48n)) : {LB}}}, Nat.add(K, 0n), K, FD.nat__add_zero(K), ebd0)
  +hz48 = Equal.trans({LB}, VS.bt(48n, VS.bdr({POS}, UA.BYT({PWv}))), VS.bt(48n, VS.bdr({XKv}, UW.SPL(B, {X0}, {Zv}))), UW.ZB(48n),
    Equal.trans({LB}, VS.bt(48n, VS.bdr({POS}, UA.BYT({PWv}))), VS.bt(48n, VS.bdr({XKv}, UA.BYT({PWv}))), VS.bt(48n, VS.bdr({XKv}, UW.SPL(B, {X0}, {Zv}))),
      Equal.cong(Nat, {LB}, z => VS.bt(48n, VS.bdr(z, UA.BYT({PWv}))), {POS}, {XKv}, Equal.sym(Nat, {XKv}, {POS}, epos)),
      Equal.cong({LB}, {LB}, z => VS.bt(48n, VS.bdr({XKv}, z)), UA.BYT({PWv}), UW.SPL(B, {X0}, {Zv}), eP1)),
    Equal.trans({LB}, VS.bt(48n, VS.bdr({XKv}, UW.SPL(B, {X0}, {Zv}))), VS.bt(48n, VS.bdr(K, {Zv})), UW.ZB(48n), ew,
      Equal.cong({LB}, {LB}, z => VS.bt(48n, z), VS.bdr(K, {Zv}), VS.bdr(0n, UW.ZB(48n)), ebd)))
  +g48 = V_b48.b48_any(dd, {PWv}, U32.add(X, 24576), Nat.add(6144n, q), r, {A_}, e48, hr, hd, hl48, pfW, hz48)
  +b2 = V_b48.b48_any_bytes(dd, {PWv}, U32.add(X, 24576), Nat.add(6144n, q), r, {A_}, e48, hr, hd, hl48, pfW, hz48)
  +rt = sc_rt(D, X, TB, {A_}, n, {PWv}, {PB48v}, hv, pw1, g48)
  +by = Equal.trans({LB}, UA.BYT({PB48v}), UW.SPL(UA.BYT({PWv}), {POS}, {Y48}), UW.SPL(B, {X0}, List.append(&2, U32, {DATAv}, {Y48})), b2,
    Equal.trans({LB}, UW.SPL(UA.BYT({PWv}), {POS}, {Y48}), UW.SPL(UW.SPL(B, {X0}, {Zv}), {XKv}, {Y48}), UW.SPL(B, {X0}, List.append(&2, U32, {DATAv}, {Y48})),
      Equal.trans({LB}, UW.SPL(UA.BYT({PWv}), {POS}, {Y48}), UW.SPL(UA.BYT({PWv}), {XKv}, {Y48}), UW.SPL(UW.SPL(B, {X0}, {Zv}), {XKv}, {Y48}),
        Equal.cong(Nat, {LB}, z => UW.SPL(UA.BYT({PWv}), z, {Y48}), {POS}, {XKv}, Equal.sym(Nat, {XKv}, {POS}, epos)),
        Equal.cong({LB}, {LB}, z => UW.SPL(z, {XKv}, {Y48}), UA.BYT({PWv}), UW.SPL(B, {X0}, {Zv}), eP1)),
      Equal.trans({LB}, UW.SPL(UW.SPL(B, {X0}, {Zv}), {XKv}, {Y48}), UW.SPL(B, {X0}, UW.SPL({Zv}, K, {Y48})), UW.SPL(B, {X0}, List.append(&2, U32, {DATAv}, {Y48})),
        UW.spl_spl(B, {X0}, {Zv}, K, {Y48}, hX, hZ),
        Equal.cong({LB}, {LB}, z => UW.SPL(B, {X0}, z), UW.SPL({Zv}, K, {Y48}), List.append(&2, U32, {DATAv}, {Y48}), sc_cat({NBv}, FX.limbs(SL), K, {A_}, eLD, eK)))))
  (rt, by)

# The core at n = 24576 (K = 4 * 6144), its facts on the byte count decided by Nat.is_eq / is_le.
def sc_at({P})
    -> DK.P2({RT("r")}, {BY("r", X0)}):
  +eK = sc_eK()
  +hlw = VRX.froom(q, r, dd, 0n, {NB}, 24624n, {{==}}, hl)
  +hsrc = sc_hsrc(dB, hrB)
  +hq = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(dB))) == True{{}} : Bool}}, {K}, {NB}, Equal.sym(Nat, {NB}, {K}, eK), UW.quad_le(6144n, VB.pw(dB), hrB))
  +hz1 = FD.logic__subst(Nat, z => {{VS.bt(z, VS.bdr({X0}, UA.BYT(D))) == UW.ZB(z) : {LB}}}, 24624n, Nat.add({W1}, {DL}), sc_e24(r, hr, {NB}, {{==}}), hz)
  +hv = sc_hv(dB, TB, pfB, hdB, hrB)
  +e48 = VRX.fpos(X, q, r, 6144n, 24576, 24624n, dd, e, eK, hd, {{==}}, hl)
  +hl48 = VRX.froom(q, r, dd, 6144n, 48n, 24624n, {{==}}, hl)
  sc_core(dd, D, X, q, r, dB, TB, {A_}, 24576, {K}, e, hr, hd, hl, pf, pfB, hdB, hv, sc_hy(), {{==}}, hsrc, hlw, hq, eK, hz1, sc_edl(r, hr), e48, hl48, VRX.fpx(q, r, 6144n))

'''


def _sc_lengths_and_any(AP, LEN, DATA, Y48, K, NB, P, RT, BY, ARGS, X0):
    """the bytes' count, then T.SyncCommittee_putk at any byte position and its bytes"""
    return f'''# |a ++ b| = T when |a| = m, |b| = 48 and m + 48 = T (over symbolic m: no closed 24576 in a conversion).
def sc_len3(+m: Nat, +a: +List<U32>, +b: +List<U32>, +T: Nat, +ea: {{List.length(&2, U32, a) == m : Nat}}, +eb: {{List.length(&2, U32, b) == 48n : Nat}},
    +e: {{Nat.add(m, 48n) == T : Nat}}) -> {{List.length(&2, U32, List.append(&2, U32, a, b)) == T : Nat}}:
  Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, a, b)), Nat.add(List.length(&2, U32, a), List.length(&2, U32, b)), T, VS.len_app(a, b),
    Equal.trans(Nat, Nat.add(List.length(&2, U32, a), List.length(&2, U32, b)), Nat.add(m, 48n), T,
      Equal.trans(Nat, Nat.add(List.length(&2, U32, a), List.length(&2, U32, b)), Nat.add(m, List.length(&2, U32, b)), Nat.add(m, 48n),
        Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, b)), List.length(&2, U32, a), m, ea),
        Equal.cong(Nat, Nat, z => Nat.add(m, z), List.length(&2, U32, b), 48n, eb)), e))

# The bytes' count: 24576 + 48.
def SyncCommittee_len(+dB: Nat, +TB: FD.array__Tree<U32>, {AP}, +pfB: {{FD.array__perfect(U32, dB, TB) == True{{}} : Bool}},
    +hrB: {{Nat.is_le(6144n, VB.pw(dB)) == True{{}} : Bool}})
    -> {{{LEN(f"List.append(&2, U32, {DATA}, {Y48})")} == 24624n : Nat}}:
  +SL = UW.SLW(TB)
  +eK = sc_eK()
  +eLS = Equal.trans(Nat, {LEN("FX.limbs(SL)")}, A.quad(VB.len(SL)), A.quad(VB.pw(dB)), UW.len_limbs_v(SL),
    Equal.cong(Nat, Nat, z => A.quad(z), VB.len(SL), VB.pw(dB), FD.array__slots_length(U32, dB, TB, pfB)))
  +hq = FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(VB.pw(dB))) == True{{}} : Bool}}, {K}, {NB}, Equal.sym(Nat, {NB}, {K}, eK), UW.quad_le(6144n, VB.pw(dB), hrB))
  +hLS = FD.logic__subst(Nat, z => {{Nat.is_le({NB}, z) == True{{}} : Bool}}, A.quad(VB.pw(dB)), {LEN("FX.limbs(SL)")},
    Equal.sym(Nat, {LEN("FX.limbs(SL)")}, A.quad(VB.pw(dB)), eLS), hq)
  +eLD = VS.bt_len({NB}, FX.limbs(SL), hLS)
  sc_len3({NB}, {DATA}, {Y48}, 24624n, eLD, {{==}}, sc_eT())

# T.SyncCommittee_putk at any byte position X = 4 q + r.
def SyncCommittee_any({P})
    -> {RT("r")}:
  DK2({RT("r")}, {BY("r", X0)}, sc_at({ARGS}))

# Its bytes: the pubkeys' 24576 bytes then the aggregate pubkey's 48, when the bytes there were zero.
def SyncCommittee_any_bytes({P})
    -> {BY("r", X0)}:
  DK3({RT("r")}, {BY("r", X0)}, sc_at({ARGS}))
'''


def sc_text():
    """T.SyncCommittee_putk at any X = 4 q + r: its pubkeys' storage check and O.put_words of
    their 24576 bytes (vuwd.putw_any), then the aggregate pubkey's b48_put at X + 24576
    (vuwv_b48); its bytes the pubkeys' 24576 bytes then the aggregate's 48. One proof at a
    symbolic r (the models PWM / PX_b48 stay stuck on r, so no big tree is ever unfolded); only
    the byte counts 24624 = (24576 + pad) + (48 - pad) are split on r."""
    ws = [f'a{k}' for k in range(12)]
    A_ = ', '.join(ws)
    AP = ', '.join(f'+{w}: U32' for w in ws)
    WO = 'O.Words{FD.array__thaw(U32, TB), 24576}'
    AGG = f'T.Bytes48{{{A_}}}'
    OBJ = f'T.SyncCommittee{{{WO}, {AGG}}}'
    TY = 'Array<U32> & (T.SyncCommittee & U32)'
    NB = 'U32.to_nat(24576)'
    DATA = f'VS.bt({NB}, FX.limbs(UW.SLW(TB)))'
    Y48 = f'FX.limbs([{A_}])'
    TD = TH.format('D')
    PX = lambda r: f'PX_SyncCommittee({r}, dd, D, q, TB, {A_})'  # noqa: E731
    RT = lambda r: f'{{T.SyncCommittee_putk({TD}, X, {OBJ}) == ({TH.format(PX(r))}, ({OBJ}, 0)) : {TY}}}'  # noqa: E731
    BY = lambda r, x: f'{{UA.BYT({PX(r)}) == UW.SPL(UA.BYT(D), {x}, List.append(&2, U32, {DATA}, {Y48})) : +List<U32>}}'  # noqa: E731
    P = ('+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, ' + AP + ', ' + E_ + TPL.text('sc_text'))
    ARGS = f'dd, D, X, q, r, dB, TB, {A_}, e, hr, hd, hl, pf, pfB, hdB, hrB, hz'
    X0 = 'Nat.add(A.quad(q), r)'
    PAD = f'UWD.PADB(r, {NB})'
    DL = f'Nat.sub(48n, {PAD})'
    W1 = f'Nat.add({NB}, {PAD})'
    Y0 = f'List.append(&2, U32, {DATA}, UW.ZB({PAD}))'
    Z = f'List.append(&2, U32, {DATA}, UW.ZB(48n))'
    PW = 'UWD.PWM(r, dd, D, q, TB, 24576)'
    PB48 = f'V_b48.PX_b48(r, dd, {PW}, Nat.add(6144n, q), {A_})'
    POS = 'Nat.add(A.quad(Nat.add(6144n, q)), r)'
    K = 'A.quad(6144n)'
    XK = f'Nat.add({X0}, {K})'
    NBv = 'U32.to_nat(n)'
    WOv = 'O.Words{FD.array__thaw(U32, TB), n}'
    OBJv = f'T.SyncCommittee{{{WOv}, {AGG}}}'
    DATAv = f'VS.bt({NBv}, FX.limbs(UW.SLW(TB)))'
    PADv = f'UWD.PADB(r, {NBv})'
    DLv = f'Nat.sub(48n, {PADv})'
    W1v = f'Nat.add({NBv}, {PADv})'
    Y0v = f'List.append(&2, U32, {DATAv}, UW.ZB({PADv}))'
    Zv = f'List.append(&2, U32, {DATAv}, UW.ZB(48n))'
    PWv = 'UWD.PWM(r, dd, D, q, TB, n)'
    PB48v = f'V_b48.PX_b48(r, dd, {PWv}, Nat.add(6144n, q), {A_})'
    XKv = 'Nat.add(Nat.add(A.quad(q), r), K)'
    RTv = f'{{T.SyncCommittee_putk({TD}, X, {OBJv}) == ({TH.format(PB48v)}, ({OBJv}, 0)) : {TY}}}'
    BYv = f'{{UA.BYT({PB48v}) == UW.SPL(UA.BYT(D), Nat.add(A.quad(q), r), List.append(&2, U32, {DATAv}, {Y48})) : +List<U32>}}'
    LEN = lambda x: f'List.length(&2, U32, {x})'  # noqa: E731
    LB = '+List<U32>'
    ab = lambda t: f'Empty.absurd({t}, FD.nat__lt_zero_absurd(t, hr))'  # noqa: E731

    E24 = f'{{24624n == Nat.add({W1}, {DL}) : Nat}}'
    E24T = lambda r, m: f'Nat.add(Nat.add({m}, UWD.PADB({r}, {m})), Nat.sub(48n, UWD.PADB({r}, {m})))'  # noqa: E731
    E24M = lambda r, m: f'{{24624n == {E24T(r, m)} : Nat}}'  # noqa: E731
    EDL = f'{{Nat.add({PAD}, {DL}) == 48n : Nat}}'
    body = (
        _sc_closed_facts(NB, WO) +
        _sc_valid_and_model(AP, OBJ, WO, AGG, A_, PX) +
        _sc_padding_facts(ab, NB, E24M, EDL) +
        _sc_runtime_pieces(AP, WOv, TD, AGG, OBJv, TY, LB, LEN, Y48) +
        _sc_core(AP, WOv, NB, NBv, W1, W1v, DL, DLv, X0, LB, P, PADv, POS, RT, RTv, BY, BYv, LEN, DATAv, Y0v, Zv, PWv, XKv, A_, PB48v, Y48, K) +
        _sc_lengths_and_any(AP, LEN, DATA, Y48, K, NB, P, RT, BY, ARGS, X0))
    imports = ['import ./vbenc.bend as VBE', 'import ./vuwv_b48.bend as V_b48', 'import ./vrecx.bend as VRX', 'import ./dk.bend as DK', 'import ./vcopy.bend as VC', 'import ./vbytes.bend as VY']
    return module(imports, 'T.SyncCommittee_putk (512 pubkeys and the aggregate pubkey, 24624 bytes)', body)

B4_ALIGNED = TPL.text('B4_ALIGNED')




# ---- big fixed vectors of packed words (BeaconState's block_roots, randao_mixes, slashings, ...) ----

PWORDS = [('v8192_b32', 262144, 65536, 32), ('v65536_b32', 2097152, 524288, 32), ('v8192_u64', 65536, 16384, 8), ('v64_u64', 512, 128, 8)]


def pwords_text(p, S, W, unit):
    """A fixed vector of S = 4 W bytes held as packed words: its storage check, then O.put_words at
    any X = 4 q + r (at r = 0 vuwd.pwn2 / mone_bytes, else vuwd.putw_loose), data-only. One core over a
    symbolic byte count n = 4 K (no closed S- or W-sized Nat is ever reduced); the instance at n = S.

    The exported statements name the sizes by terms that are never evaluated, never by closed Nat
    literals (S = 2^E: a literal 2097152n is unary, and relating it to the runtime's U32 costs seconds
    in every importer). A caller passes exactly:
      hl:  {Nat.is_le(Nat.add(q, UWD.NWN(Nat.add(r, U32.to_nat(S)))), VB.pw(dd)) == True{}}
      hz:  {VS.bt(U32.to_nat(S), VS.bdr(Nat.add(A.quad(q), r), UA.BYT(D))) == UW.ZB(U32.to_nat(S))}
      hrB: {Nat.is_le(VC.NW(S), VB.pw(dB)) == True{}}          (also <p>_valid_ok's)
    and <p>_any_bytes' bytes are FX.limbs(VS.wtake(VC.NW(S), UW.SLW(TB))) (S the U32 literal)."""
    import math
    kw = math.ceil(math.log2(31 + S))
    E = S.bit_length() - 1
    assert S == 1 << E and W == 1 << (E - 2) and kw == E + 1 and E >= 5, (p, S, W, kw)
    NS = f'U32.to_nat({S})'      # the byte count, never a closed Nat literal (a literal is unary: 2^21 costs seconds)
    NWS = f'VC.NW({S})'          # the word count
    TD = TH.format('D')
    WOn = 'O.Words{FD.array__thaw(U32, TB), n}'
    PWn = 'UWD.PWM(r, dd, D, q, TB, n)'
    TY = 'Array<U32> & (O.Words & U32)'
    X0 = 'Nat.add(A.quad(q), r)'
    LB = '+List<U32>'
    RTn = f'{{T.{p}_putk({TD}, X, {WOn}) == ({TH.format(PWn)}, ({WOn}, 0)) : {TY}}}'
    BYn = f'{{UA.BYT({PWn}) == UW.SPL(UA.BYT(D), {X0}, FX.limbs(VS.wtake(K, UW.SLW(TB)))) : {LB}}}'
    WO = f'O.Words{{FD.array__thaw(U32, TB), {S}}}'
    PX = lambda r: f'PX_{p}({r}, dd, D, q, TB)'  # noqa: E731
    RT = f'{{T.{p}_putk({TD}, X, {WO}) == ({TH.format(PX("r"))}, ({WO}, 0)) : {TY}}}'
    BY = f'{{UA.BYT({PX("r")}) == UW.SPL(UA.BYT(D), {X0}, FX.limbs(VS.wtake({NWS}, UW.SLW(TB)))) : {LB}}}'
    P = ('+dd: Nat, +D: FD.array__Tree<U32>, +X: U32, +q: Nat, +r: Nat, +dB: Nat, +TB: FD.array__Tree<U32>, ' + E_ + TPL.render('pwords_text', LB=LB, NS=NS, NWS=NWS, X0=X0))
    ARGS = 'dd, D, X, q, r, dB, TB, e, hr, hd, hl, pf, pfB, hdB, hrB, hz'
    HZn = lambda m: f'{{VS.bt({m}, VS.bdr({X0}, UA.BYT(D))) == UW.ZB({m}) : {LB}}}'  # noqa: E731
    HZ0 = f'{{VS.bt(A.quad(VC.NW(n)), VS.bdr(Nat.add(A.quad(q), 0n), UA.BYT(D))) == UW.ZB(A.quad(VC.NW(n))) : {LB}}}'
    cases = []
    for s in (1, 2, 3):
        cases.append(f'''    case {s}n:
      +hls = UWD.le_q(q, VC.NW(n), VB.pw(dd), FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(q, z), VB.pw(dd)) == True{{}} : Bool}}, UWD.NWN(Nat.add({s}n, U32.to_nat(n))), 1n+VC.NW(n),
        Equal.trans(Nat, UWD.NWN(Nat.add({s}n, U32.to_nat(n))), Nat.add(K, UWD.NWN({s}n)), 1n+VC.NW(n), nwk({s}n, n, K, eK),
          Equal.trans(Nat, Nat.add(K, 1n), Nat.add(1n, K), 1n+VC.NW(n), FD.nat__add_comm(K, 1n), Equal.cong(Nat, Nat, z => 1n+z, K, VC.NW(n), Equal.sym(Nat, VC.NW(n), K, eW)))), hl))
      +hzs = FD.logic__subst(Nat, z => {HZn("z")}, U32.to_nat(n), A.quad(VC.NW(n)), Equal.trans(Nat, U32.to_nat(n), A.quad(K), A.quad(VC.NW(n)), eK, Equal.cong(Nat, Nat, z => A.quad(z), K, VC.NW(n), Equal.sym(Nat, VC.NW(n), K, eW))), hz)
      +w = UWD.putw_loose(dd, D, X, q, {s}n, dB, TB, n, {kw}n, e, hr, hd, hdB, {{==}}, hy, hsrc, hls, pf, pfB, hzs)
      +b = UWD.putw_loose_bytes(dd, D, X, q, {s}n, dB, TB, n, {kw}n, e, hr, hd, hdB, {{==}}, hy, hsrc, hls, pf, pfB, hzs)
      %eW : DK.P2({RTn.replace("(r,", f"({s}n,")}, {BYn.replace("(r,", f"({s}n,").replace(X0, f"Nat.add(A.quad(q), {s}n)").replace("VS.wtake(K,", "VS.wtake(_,")})
      (rt(D, X, TB, n, UWD.PWM({s}n, dd, D, q, TB, n), hv, w), b)''')
    body = TPL.render('body', ARGS=ARGS, BY=BY, BYn=BYn, E=E, HZ0=HZ0, HZn=HZn, NS=NS, NWS=NWS, P=P, PX=PX, RT=RT, RTn=RTn, S=S, TD=TD, TY=TY, W=W, WOn=WOn, X0=X0, kw=kw, p=p, unit=unit)
    body = body.replace('@CASES', '\n'.join(cases))
    return module(['import ./vbenc.bend as VBE', 'import ./vrecx.bend as VRX', 'import ./dk.bend as DK', 'import ./vcopy.bend as VC'],
                  f'T.{p}_putk (the {S}-byte O.Words)', body)

def module(imports, what, body):
    head = HEAD
    if any('generic_obj' in i for i in imports):
        head = head.replace('import ../../types/fulu_obj.bend as T\n', '')
    return head.replace('@IMPORTS\n', ''.join(f'{i}\n' for i in imports) + '\n').replace('@WHAT', what) + body


def outputs():
    out = {}
    for v in VECS:
        p, C, N, AL = v
        uf = [f'import ./vuwf{s}.bend as UF{s}' if p in ('b32', 'u256') else f'import ./vuwf{s}_{p}.bend as UF{s}' for s in (1, 2, 3)]
        al = 'import ./var_fix_types.bend as VT' if AL.startswith('VT.') else 'import ./var_bytes_fix.bend as VBF'
        out[ROOT / f'proofs/obj/vuwv_{p}.bend'] = module(uf + [al], f'T.{p}_put ({C}, {N} words)', vec_text(*v))
    # Bytes4 (Fork's versions): its aligned store is proved here (b4_put's aligned branch is one Array.set)
    uf4 = [f'import ./vuwf{s}_b4.bend as UF{s}' for s in (1, 2, 3)]
    out[ROOT / 'proofs/obj/vuwv_b4.bend'] = module(uf4, 'T.b4_put (Bytes4, 1 word)', B4_ALIGNED + vec_text('b4', 'Bytes4', 1, 'put_b4'))
    uk = [f'import ./vuwk{s}.bend as UK{s}' for s in (1, 2, 3)] + ['import ./var_bytes_wput.bend as VW']
    out[ROOT / 'proofs/obj/vuwv_b256.bend'] = module(uk + ['import ./vbenc.bend as VBE'], 'T.b256_putk (the 256-byte O.Words)', b256_text())
    for g in GFULL:
        out[ROOT / f'proofs/obj/vuwg_{g[0]}.bend'] = gfull_text(*g)
    for g in GPART:
        out[ROOT / f'proofs/obj/vuwg_{g[0]}.bend'] = gpart_text(*g)
    for g in GWORDS:
        out[ROOT / f'proofs/obj/vuwg_{g[0]}.bend'] = gwords_text(*g)
    for g in FWORDS:
        out[ROOT / f'proofs/obj/vuwv_{g[0]}.bend'] = gwords_text(g[0], g[1], g[2], g[3], generic=False)
    out[ROOT / 'proofs/obj/vuwv_SyncCommittee.bend'] = sc_text()
    # BeaconState's justification_bits (one byte, the partial-word form of vuwg_bv8)
    out[ROOT / 'proofs/obj/vuwv_bv4.bend'] = gpart_text('bv4', 'Bitvector4', 1, fulu=True)
    for g in PWORDS:
        out[ROOT / f'proofs/obj/vuwv_{g[0]}.bend'] = pwords_text(*g)
    return out


def main():
    # accepts '--check' (check_or_write_outputs.finish reads it)
    # the fields' offsets are literals: the strict 4 k < L of fposW is {==}
    return finish(outputs(), 'stale: ', 'word-vector writers are current', dify=dict(handled={'fposW'}), retire=True)


if __name__ == '__main__':
    main()
