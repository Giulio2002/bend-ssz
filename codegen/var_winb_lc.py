#!/usr/bin/env python3
"""LightClientUpdate at a window at any byte offset (the interface of
proofs/obj/vua_win.bend) and its whole-buffer decoder laws, from
codegen/var_winb.py's symbolic path: the two LightClientHeaders are read by
their byte-offset windows (proofs/obj/var_bytesx_LightClientHeader.bend), the
fixed fields by the fixed-field modules of codegen/var_fixx.py (the
SyncCommittee's 6144 pubkey words stay one symbolic run, vfx_SyncCommittee).

    python3 codegen/var_winb_lc.py [--check] [--no-big] [--window]

Writes the fixed-field modules var_fixx.py has no BeaconState use for
(vfx_v6_b32, vfx_v7_b32, vfx_SyncAggregate), then
proofs/obj/var_winx_LightClientUpdate.bend and
proofs/obj/var_codec_LightClientUpdate.bend.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import var_fixx as FX  # noqa: E402
import var_winb as WB  # noqa: E402

ROOT = FX.ROOT
NAME = 'LightClientUpdate'
WIN = f'var_winx_{NAME}.bend'
TOP = f'var_codec_{NAME}.bend'
VECS = [('v6_b32', 192, 6, 'Spec.Schema59()', 'ch8', 'Bytes32'),
        ('v7_b32', 224, 7, 'Spec.Schema12()', 'ch8', 'Bytes32')]
FIXMOD = {'SyncCommittee': 'vfx_SyncCommittee.bend', 'v6_b32': 'vfx_v6_b32.bend', 'v7_b32': 'vfx_v7_b32.bend',
          'SyncAggregate_bx': 'vfx_SyncAggregate.bend', 'u64': 'vfx_u64.bend'}


# The window module does not check yet (the symbolic path's comparisons of the
# 25216-byte fixed part unfold it, e.g. hdrE's closing {==}); it is written only
# with --window until it does.
WINDOW = False


def layout():
    WB.CHILD_MOD.setdefault('LightClientHeader', 'var_bytesx_LightClientHeader.bend')
    L = WB.layout(NAME, True, FIXMOD)
    for f in L.fields:
        if f['kind'] == 'fix' and f['box']:
            # a boxed fixed field: read by its record's reader, boxed by <p>_bx_rd
            f['rt'] = f['rt'][:-3]
            f['rep'] = f'T.{f["rt"]}'
    return L


LE_NATG = '''
# le_nat with the closed size A kept as it is (to_nat of a closed U32 against a
# literal would be compared by unfolding Nat.is_le)
def le_natG(+a: U32, +A: Nat, +ea: {U32.to_nat(a) == A : Nat}, +b: U32, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(A, U32.to_nat(b)) == True{} : Bool}:
  %ea : {Nat.is_le(_, U32.to_nat(b)) == True{} : Bool}
  le_nat(a, b, h)
'''


SPLITXL = '''
# splitX with the sums s + r and c + s given as the closed sizes the goal holds
def splitXL(+t: FD.array__Tree<U32>, +x: Nat, +c: Nat, +s: Nat, +r: Nat, +S: Nat, +C: Nat, +eS: {Nat.add(s, r) == S : Nat}, +eC: {Nat.add(c, s) == C : Nat})
    -> {UW.WX(t, Nat.add(x, c), S) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, C), r)) : +List<U32>}:
  %eS : {UW.WX(t, Nat.add(x, c), _) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, C), r)) : +List<U32>}
  %eC : {UW.WX(t, Nat.add(x, c), Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, _), r)) : +List<U32>}
  splitX(t, x, c, s, r)
'''


def big_fixes(txt, FS):
    """Keep the closed fixed size FS syntactically the same on both sides of every
    comparison the checker makes (a mismatch unfolds FS)."""
    def rep(old, new, count=None):
        nonlocal txt
        assert old in txt, old
        txt = txt.replace(old, new) if count is None else txt.replace(old, new, count)
    a = 'def and_l('
    rep(a, LE_NATG.lstrip('\n') + '\n' + a, 1)
    rep(f'le_nat({FS}, len, ', f'le_natG({FS}, {FS}n, FD.nat__eq_from_is_eq(U32.to_nat({FS}), {FS}n, {{==}}), len, ')
    old = f'  Equal.cong(U32, Nat, z => U32.to_nat(z), O0(t, x), {FS}, FD.u32alg__eq_of(O0(t, x), {FS}, it1(t, x, off, len, h)))'
    rep(old, f'  Equal.trans(Nat, U32.to_nat(O0(t, x)), U32.to_nat({FS}), {FS}n,\n  ' + old.strip() + f',\n    FD.nat__eq_from_is_eq(U32.to_nat({FS}), {FS}n, {{==}}))')
    # the fixed size summed from the widths: Nat.add(24624n, WFS(..)) would unfold 24624
    m = re.search(r'(Equal\.cong\(\+List<Maybe<&2, Nat>>, Nat, z => LY\.WFS\(z\), LY\.WID\(PSW\(t, x, len\)\), (\[[^\]]*\]), ewidw\([^)]*\)\))', txt)
    assert m
    cong, W = m.group(1), m.group(2)
    rep(cong, f'Equal.trans(Nat, LY.WFS(LY.WID(PSW(t, x, len))), LY.WFS({W}), {FS}n, {cong}, FD.nat__eq_from_is_eq(LY.WFS({W}), {FS}n, {{==}}))')
    # the header's slices: every comparison between the same sizes, written the same way
    rep('def splitR(', SPLITXL.lstrip('\n') + '\n' + 'def splitR(', 1)

    def sx(m):
        c, a, b = (int(g) for g in m.groups())
        return (f'UW.WX(t, Nat.add(x, {c}n), {a + b}n), List.append(&2, U32, UW.WX(t, Nat.add(x, {c}n), {a}n), UW.WX(t, Nat.add(x, {c + a}n), {b}n)), '
                f'splitXL(t, x, {c}n, {a}n, {b}n, {a + b}n, {c + a}n, {{==}}, {{==}}))')
    txt, k = re.subn(r'UW\.WX\(t, Nat\.add\(x, (\d+)n\), Nat\.add\((\d+)n, (\d+)n\)\), List\.append\(&2, U32, UW\.WX\(t, Nat\.add\(x, \1n\), \2n\), '
                     r'UW\.WX\(t, Nat\.add\(x, Nat\.add\(\1n, \2n\)\), \3n\)\), splitX\(t, x, \1n, \2n, \3n\)\)', sx, txt)
    assert k > 0
    # a closed position c = to_nat(c) given as {==} is compared by unfolding once c is large
    txt = re.sub(r', (\d+), \1n, \{==\}',
                 lambda m: m.group(0) if int(m.group(1)) < 256 else
                 f', {m.group(1)}, {m.group(1)}n, FD.nat__eq_from_is_eq(U32.to_nat({m.group(1)}), {m.group(1)}n, {{==}})', txt)
    return txt


def outputs(no_big=False):
    import schema
    import generate as G
    out = {}
    for p, S, k, sch, ch, el in VECS:
        out[ROOT / f'proofs/obj/vfx_{p}.bend'] = FX.vec_text(p, S, k, sch, ch, el)
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = G.Gen()
    for t in names.values():
        g.shape(t)
    p, txt = FX.small_mod(g, names['SyncAggregate'], 'Spec.SyncAggregate()')
    if 'FB.' in txt and 'as FB\n' not in txt:
        txt = txt.replace('import ./vua_fix.bend as VTX\n', 'import ./vua_fix.bend as VTX\nimport ./spec_bits.bend as FB\n', 1)
    out[ROOT / f'proofs/obj/vfx_{p}.bend'] = txt
    if not ('--window' in sys.argv or WINDOW):
        return out
    L = layout()
    out[ROOT / 'proofs/obj' / WIN] = big_fixes(WB.module_text(L), L.FS)
    top = WB.top_text(L, WIN).replace('# GENERATED by codegen/var_winb.py.', '# GENERATED by codegen/var_winb_lc.py.')
    out[ROOT / 'proofs/obj' / TOP] = top
    return {p: t.replace('# GENERATED by codegen/var_winb.py.', '# GENERATED by codegen/var_winb_lc.py.') for p, t in out.items()}


def main():
    out = outputs('--no-big' in sys.argv)
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('LightClientUpdate window modules are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))


if __name__ == '__main__':
    main()
