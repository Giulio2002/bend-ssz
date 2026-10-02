"""FuluBlobSidecar's composed decode;encode / decode;root theorems: the skeleton of the fixed-size composed theorems
(e2e_compose_fixed.build_tree_rec's output for FuluHistoricalBatch) written for a decoder whose object is DB.OWd(15n, bs),
with the premises supplied by e2e/e2e_dbs_BlobSidecar.bend (codegen/proofs/decoded/e2e_dbs.py)."""
import sys as _sys
from codegen.core.shared_bridges import import_lines  # noqa: E402
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script

DSOME = r'''def dsome(+bs: +List<U32>, +n: U32, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {M0_WO_SP.bytes_domain(bs) == True{} : Bool}, +ec: {Nat.is_eq(List.length(&2, U32, bs), U32.to_nat(@N@)) == True{} : Bool})
    -> {Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == Some{@OBJ@} : Maybe<&1, @FULU@_d.@X@>}:
  DB.d_some(@D@, {==}, bs, n, hn, hd, EY.u32_len(n, List.length(&2, U32, bs), @N@, hn, ec))'''

SKEL = r'''def gm(m: Maybe<&1, @FULU@_d.@X@>, d: @FULU@_d.@X@) -> @FULU@_d.@X@:
  match m:
    case Some{x}: x
    case None{}: d
def isS(m: Maybe<&1, @FULU@_d.@X@>) -> Bool:
  match m:
    case Some{x}: True{}
    case None{}: False{}

# the value deserialize gives for the accepted bytes is the decoded object's view
def acc(+bs: +List<U32>, +n: U32, -o: @FULU@_d.@X@, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {M0_WO_SP.bytes_domain(bs) == True{} : Bool}, dec: {Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == Some{o} : Maybe<&1, @FULU@_d.@X@>})
    -> {API.deserialize(Spec.@X@(), bs) == Some{RT.v_@X@(o)} : Maybe<&2, S.Value>}:
  Equal.trans(Maybe<&2, S.Value>, API.deserialize(Spec.@X@(), bs), DB.@MV@(Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n))), Some{RT.v_@X@(o)},
    Equal.sym(Maybe<&2, S.Value>, DB.@MV@(Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n))), API.deserialize(Spec.@X@(), bs), DB.@FULU@_e2e_decode_view(bs, n, hn, hd)),
    Equal.cong(Maybe<&1, @FULU@_d.@X@>, Maybe<&2, S.Value>, z => DB.@MV@(z), Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{o}, dec))

def ge(+bs: +List<U32>, +n: U32, -o: @FULU@_d.@X@, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {M0_WO_SP.bytes_domain(bs) == True{} : Bool}, dec: {Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == Some{o} : Maybe<&1, @FULU@_d.@X@>},
    +c: Bool, +ec: {Nat.is_eq(List.length(&2, U32, bs), U32.to_nat(@N@)) == c : Bool}) -> {E.obytes(Pair.snd(@FULU@_d.@X@, B.Buf, @FULU@_e.@X@_encode(o))) == bs : +List<U32>}:
  match c:
    case True{}:
      %Equal.sym(@FULU@_d.@X@, o, @OBJ@, Equal.cong(Maybe<&1, @FULU@_d.@X@>, @FULU@_d.@X@, z => gm(z, @OBJ@), Some{o}, Some{@OBJ@}, Equal.trans(Maybe<&1, @FULU@_d.@X@>, Some{o}, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{@OBJ@}, Equal.sym(Maybe<&1, @FULU@_d.@X@>, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{o}, dec), dsome(bs, n, hn, hd, ec)))) :
        {E.obytes(Pair.snd(@FULU@_d.@X@, B.Buf, @FULU@_e.@X@_encode(_))) == bs : +List<U32>}
      C.dec_enc(Spec.@X@(), bs, RT.v_@X@(@OBJ@), E.obytes(Pair.snd(@FULU@_d.@X@, B.Buf, @FULU@_e.@X@_encode(@OBJ@))), acc(bs, n, @OBJ@, hn, hd, dsome(bs, n, hn, hd, ec)), EB.@FULU@_e2e_encode(@OBJ@, pe_rep(bs), pe_hc0(bs), pe_hc1(bs)))
    case False{}:
      Empty.absurd({E.obytes(Pair.snd(@FULU@_d.@X@, B.Buf, @FULU@_e.@X@_encode(o))) == bs : +List<U32>}, FD.logic__false_true(Equal.cong(Maybe<&1, @FULU@_d.@X@>, Bool, z => isS(z), None{}, Some{o}, Equal.trans(Maybe<&1, @FULU@_d.@X@>, None{}, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{o}, Equal.sym(Maybe<&1, @FULU@_d.@X@>, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), None{}, DB.d_none(bs, n, EY.ueq_false(n, List.length(&2, U32, bs), @N@, hn, ec))), dec))))

def gr(h: B.Buf, +bs: +List<U32>, +n: U32, -o: @FULU@_d.@X@, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {M0_WO_SP.bytes_domain(bs) == True{} : Bool}, dec: {Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == Some{o} : Maybe<&1, @FULU@_d.@X@>},
    +c: Bool, +ec: {Nat.is_eq(List.length(&2, U32, bs), U32.to_nat(@N@)) == c : Bool}) -> {Some{D.bytes(Pair.snd(@FULU@_d.@X@, D.Digest, Pair.snd(B.Buf, @FULU@_d.@X@ & D.Digest, @FULU@_h.@X@_hash_tree_root(h, o))))} == C.droot(Spec.@X@(), bs) : Maybe<&2, +List<U32>>}:
  match c:
    case True{}:
      %Equal.sym(@FULU@_d.@X@, o, @OBJ@, Equal.cong(Maybe<&1, @FULU@_d.@X@>, @FULU@_d.@X@, z => gm(z, @OBJ@), Some{o}, Some{@OBJ@}, Equal.trans(Maybe<&1, @FULU@_d.@X@>, Some{o}, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{@OBJ@}, Equal.sym(Maybe<&1, @FULU@_d.@X@>, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{o}, dec), dsome(bs, n, hn, hd, ec)))) :
        {Some{D.bytes(Pair.snd(@FULU@_d.@X@, D.Digest, Pair.snd(B.Buf, @FULU@_d.@X@ & D.Digest, @FULU@_h.@X@_hash_tree_root(h, _))))} == C.droot(Spec.@X@(), bs) : Maybe<&2, +List<U32>>}
      C.dec_root(Spec.@X@(), bs, RT.v_@X@(@OBJ@), D.bytes(Pair.snd(@FULU@_d.@X@, D.Digest, Pair.snd(B.Buf, @FULU@_d.@X@ & D.Digest, @FULU@_h.@X@_hash_tree_root(h, @OBJ@)))), acc(bs, n, @OBJ@, hn, hd, dsome(bs, n, hn, hd, ec)), RB.@FULU@_e2e_root(h, @OBJ@, pe_rep(bs)))
    case False{}:
      Empty.absurd({Some{D.bytes(Pair.snd(@FULU@_d.@X@, D.Digest, Pair.snd(B.Buf, @FULU@_d.@X@ & D.Digest, @FULU@_h.@X@_hash_tree_root(h, o))))} == C.droot(Spec.@X@(), bs) : Maybe<&2, +List<U32>>}, FD.logic__false_true(Equal.cong(Maybe<&1, @FULU@_d.@X@>, Bool, z => isS(z), None{}, Some{o}, Equal.trans(Maybe<&1, @FULU@_d.@X@>, None{}, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), Some{o}, Equal.sym(Maybe<&1, @FULU@_d.@X@>, Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)), None{}, DB.d_none(bs, n, EY.ueq_false(n, List.length(&2, U32, bs), @N@, hn, ec))), dec))))

# (i) after (ii): the decoded object re-encodes to exactly the input bytes
def @FULU@_e2e_decode_encode(+bs: +List<U32>, +n: U32, -o: @FULU@_d.@X@, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {M0_WO_SP.bytes_domain(bs) == True{} : Bool}, dec: {Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == Some{o} : Maybe<&1, @FULU@_d.@X@>})
    -> {E.obytes(Pair.snd(@FULU@_d.@X@, B.Buf, @FULU@_e.@X@_encode(o))) == bs : +List<U32>}:
  ge(bs, n, o, hn, hd, dec, Nat.is_eq(List.length(&2, U32, bs), U32.to_nat(@N@)), {==})

# (iv) after (ii): the decoded object's root is the spec root of the value deserialize gives for the input bytes
def @FULU@_e2e_decode_root(h: B.Buf, +bs: +List<U32>, +n: U32, -o: @FULU@_d.@X@, +hn: {List.length(&2, U32, bs) == U32.to_nat(n) : Nat}, +hd: {M0_WO_SP.bytes_domain(bs) == True{} : Bool}, dec: {Pair.snd(B.Buf, Maybe<&1, @FULU@_d.@X@>, @FULU@_r.@X@_decode(B.fill_at(B.alloc(n), 0, bs), n)) == Some{o} : Maybe<&1, @FULU@_d.@X@>})
    -> {Some{D.bytes(Pair.snd(@FULU@_d.@X@, D.Digest, Pair.snd(B.Buf, @FULU@_d.@X@ & D.Digest, @FULU@_h.@X@_hash_tree_root(h, o))))} == C.droot(Spec.@X@(), bs) : Maybe<&2, +List<U32>>}:
  gr(h, bs, n, o, hn, hd, dec, Nat.is_eq(List.length(&2, U32, bs), U32.to_nat(@N@)), {==})'''


HEAD = '''import Base
''' + import_lines(
    'RB DB=FuluBlobSidecar_e2e_dec_generated EB=FuluBlobSidecar_e2e_generated EY C=e2e_comp DBS L '
    'E=e2e_support E3 FD RT=root_types_light Spec=fulu_schemas M0_WO_SP B D=digest API O '
    'FuluBlobSidecar_r FuluBlobSidecar_d FuluBlobSidecar_e FuluBlobSidecar_h S') + '''

'''


def text(header):
    OBJ = 'DB.OWd(15n, bs)'
    prem = (
        f'def pe_rep(+bs: +List<U32>) -> RT.rep_BlobSidecar({OBJ}, Spec.BlobSidecar()):\n  DBS.bs_rep(bs)\n\n'
        f'def pe_hcb(+bs: +List<U32>) -> {{E3.at_depth(RT.pj_BlobSidecar_1({OBJ}), 16n) == True{{}} : Bool}}:\n  DBS.bs_hcb(bs)\n\n'
        f'def pe_hcp(+bs: +List<U32>) -> {{E3.at_depth(RT.pj_BlobSidecar_5({OBJ}), 8n) == True{{}} : Bool}}:\n  DBS.bs_hcp(bs)\n\n')
    skel = SKEL.replace('pe_hc0(bs), pe_hc1(bs)', 'pe_hcb(bs), pe_hcp(bs)')
    t = HEAD + header + '\n# FuluBlobSidecar: decoding accepted bytes, then re-encoding / hashing the object (codegen/proofs/composed/e2e_compose.py). The decoder\'s\n' \
        '# object is written out (DB.OWd); the (i)/(iv) premises are e2e_dbs_BlobSidecar.bend\'s.\n' + DSOME + '\n\n' + prem + skel + '\n'
    for a, b in (('@FULU@', 'FuluBlobSidecar'), ('@X@', 'BlobSidecar'), ('@MV@', 'bs_mv'), ('@N@', '131928'), ('@D@', '15n'), ('@OBJ@', OBJ)):
        t = t.replace(a, b)
    return t
