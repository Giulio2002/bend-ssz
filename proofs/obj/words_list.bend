import Base
import ../compact/found.bend as F
import ./mtree_run.bend as MR
import ./spec_fixed.bend as FX
import ./words_spec.bend as WS
import ../../src/primitives.bend as I
import ./words_rw.bend as WR
import ./words_win.bend as WW

# The words of a window: wlist(m, W, b) is [wd(W, b), wd(W, b + 1), .., wd(W, b + m - 1)] (MR.wd: 0 past the end).
# A run of words written into perfect storage (words_win.bend's tk) leaves a window before or after it as it was
# (wlist_before, wlist_after) and reads back as the words written (wlist_hit); and the bytes of a window of the word list
# are the limbs of its words (btake_limbs). codegen/cells_laws (view_cells.bend) uses them for the list of 2048-byte cells.

def wlist(+m: Nat, +W: List<&2, U32>, +b: Nat) -> List<&2, U32>:
  match m:
    case 0n: Nil{}
    case 1n+p: Con{MR.wd(W, b), wlist(p, W, 1n+b)}

def wlist_len(+m: Nat, +W: List<&2, U32>, +b: Nat) -> {F.spec_common__length(U32, wlist(m, W, b)) == m : Nat}:
  match m:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Nat, F.spec_common__length(U32, wlist(p, W, 1n+b)), p, wlist_len(p, W, 1n+b)) :
        {1n+_ == 1n+p : Nat}
      {==}

# b + (1 + p) below q from (b + 1) + p below q
def lt_shift(+b: Nat, +p: Nat, +q: Nat, +h: {Nat.is_le(Nat.add(b, 1n+p), q) == True{} : Bool}) -> {Nat.is_le(Nat.add(1n+b, p), q) == True{} : Bool}:
  F.logic__subst(Nat, z => {Nat.is_le(z, q) == True{} : Bool}, Nat.add(b, 1n+p), Nat.add(1n+b, p), WW.add_shift_plain(b, p), h)

# the first word of a window ending at or before q is before q
def win_first(+b: Nat, +p: Nat, +q: Nat, +h: {Nat.is_le(Nat.add(b, 1n+p), q) == True{} : Bool}) -> {Nat.is_lt(b, q) == True{} : Bool}:
  WW.room_first(b, p, q, h)

def wlist_before(+m: Nat, +xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +b: Nat, +hb: {Nat.is_le(Nat.add(b, m), q) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(q, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {wlist(m, F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), b) == wlist(m, F.array__slots(U32, t), b) : List<&2, U32>}:
  match m:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(U32, MR.wd(F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), b), MR.wd(F.array__slots(U32, t), b), WW.wd_before(xs, d, t, q, b, win_first(b, p, q, hb), hr, pf)) :
        {Con{_, wlist(p, F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), 1n+b)} == Con{MR.wd(F.array__slots(U32, t), b), wlist(p, F.array__slots(U32, t), 1n+b)} : List<&2, U32>}
      %Equal.sym(List<&2, U32>, wlist(p, F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), 1n+b), wlist(p, F.array__slots(U32, t), 1n+b), wlist_before(p, xs, d, t, q, 1n+b, lt_shift(b, p, q, hb), hr, pf)) :
        {Con{MR.wd(F.array__slots(U32, t), b), _} == Con{MR.wd(F.array__slots(U32, t), b), wlist(p, F.array__slots(U32, t), 1n+b)} : List<&2, U32>}
      {==}

def wlist_after(+m: Nat, +xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +b: Nat, +hb: {Nat.is_le(Nat.add(q, F.spec_common__length(U32, xs)), b) == True{} : Bool},
    +hr: {Nat.is_le(Nat.add(q, F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {wlist(m, F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), b) == wlist(m, F.array__slots(U32, t), b) : List<&2, U32>}:
  match m:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(U32, MR.wd(F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), b), MR.wd(F.array__slots(U32, t), b), WW.wd_after(xs, d, t, q, b, hb, hr, pf)) :
        {Con{_, wlist(p, F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), 1n+b)} == Con{MR.wd(F.array__slots(U32, t), b), wlist(p, F.array__slots(U32, t), 1n+b)} : List<&2, U32>}
      %Equal.sym(List<&2, U32>, wlist(p, F.array__slots(U32, WW.tk(xs, d, t, q, 0n)), 1n+b), wlist(p, F.array__slots(U32, t), 1n+b),
          wlist_after(p, xs, d, t, q, 1n+b, F.nat__le_trans(Nat.add(q, F.spec_common__length(U32, xs)), b, 1n+b, hb, F.nat__le_succ(b)), hr, pf)) :
        {Con{MR.wd(F.array__slots(U32, t), b), _} == Con{MR.wd(F.array__slots(U32, t), b), wlist(p, F.array__slots(U32, t), 1n+b)} : List<&2, U32>}
      {==}

# the words written are the window at their place: wlist(len xs, tk(xs, .., q, m), q + m) is xs
def wlist_hit(+xs: List<&2, U32>, +d: Nat, +t: F.array__Tree<U32>, +q: Nat, +m: Nat,
    +hb: {Nat.is_le(Nat.add(Nat.add(q, m), F.spec_common__length(U32, xs)), F.spec_common__pow2(d)) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {wlist(F.spec_common__length(U32, xs), F.array__slots(U32, WW.tk(xs, d, t, q, m)), Nat.add(q, m)) == xs : List<&2, U32>}:
  match xs:
    case Nil{}: {==}
    case Con{x, r}:
      %Equal.sym(U32, MR.wd(F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), Nat.add(q, m)), x,
          Equal.trans(U32, MR.wd(F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), Nat.add(q, m)),
            WR.at(F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), Nat.add(q, m)), x,
            WW.wd_at(F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), Nat.add(q, m)),
            Equal.trans(U32, WR.at(F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), Nat.add(q, m)),
              WR.at(F.array__slots(U32, F.array__upd(U32, d, t, Nat.add(q, m), x)), Nat.add(q, m)), x,
              WW.at_tk_before(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m, Nat.add(q, m),
                F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(q, m), z) == True{} : Bool}, 1n+Nat.add(q, m), Nat.add(q, 1n+m), Equal.sym(Nat, Nat.add(q, 1n+m), 1n+Nat.add(q, m), F.nat__add_succ(q, m)), F.nat__lt_succ(Nat.add(q, m))),
                WW.shift_le(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb),
                F.array__upd_perfect(U32, d, t, Nat.add(q, m), x, pf)),
              WR.at_upd_same(d, t, Nat.add(q, m), x, WW.first_lt(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), pf)))) :
        {Con{_, wlist(F.spec_common__length(U32, r), F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), 1n+Nat.add(q, m))} == Con{x, r} : List<&2, U32>}
      %Equal.sym(List<&2, U32>, wlist(F.spec_common__length(U32, r), F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), 1n+Nat.add(q, m)), r,
          F.logic__subst(Nat, z => {wlist(F.spec_common__length(U32, r), F.array__slots(U32, WW.tk(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m)), z) == r : List<&2, U32>}, Nat.add(q, 1n+m), 1n+Nat.add(q, m), F.nat__add_succ(q, m),
            wlist_hit(r, d, F.array__upd(U32, d, t, Nat.add(q, m), x), q, 1n+m, WW.shift_le(q, m, F.spec_common__length(U32, r), F.spec_common__pow2(d), hb), F.array__upd_perfect(U32, d, t, Nat.add(q, m), x, pf)))) :
        {Con{x, _} == Con{x, r} : List<&2, U32>}
      {==}

# the bytes of a window of the word list are the limbs of its words
def btake_limbs(+m: Nat, +W: List<&2, U32>, +a: Nat, +h: {Nat.is_le(Nat.add(a, m), F.spec_common__length(U32, W)) == True{} : Bool})
    -> {WS.btake(Nat.double(Nat.double(m)), FX.limbs(WS.wdrop(a, W))) == FX.limbs(wlist(m, W, a)) : +List<U32>}:
  match m:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(List<&2, U32>, WS.wdrop(a, W), Con{MR.wd(W, a), WS.wdrop(1n+a, W)}, WS.wdrop_eta(a, W, WW.room_first(a, p, F.spec_common__length(U32, W), h))) :
        {WS.btake(Nat.double(Nat.double(1n+p)), FX.limbs(_)) == FX.limbs(wlist(1n+p, W, a)) : +List<U32>}
      Equal.trans(+List<U32>, WS.btake(Nat.double(Nat.double(1n+p)), FX.limbs(Con{MR.wd(W, a), WS.wdrop(1n+a, W)})),
        List.append(&2, U32, I.limb(MR.wd(W, a)), WS.btake(Nat.double(Nat.double(p)), FX.limbs(WS.wdrop(1n+a, W)))),
        FX.limbs(Con{MR.wd(W, a), wlist(p, W, 1n+a)}),
        {==},
        Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, I.limb(MR.wd(W, a)), z), WS.btake(Nat.double(Nat.double(p)), FX.limbs(WS.wdrop(1n+a, W))), FX.limbs(wlist(p, W, 1n+a)),
          btake_limbs(p, W, 1n+a, lt_shift(a, p, F.spec_common__length(U32, W), h))))

# the same words read with WR.at (what a blit copies)
def alist(+m: Nat, +W: List<&2, U32>, +b: Nat) -> List<&2, U32>:
  match m:
    case 0n: Nil{}
    case 1n+p: Con{WR.at(W, b), alist(p, W, 1n+b)}

def wlist_alist(+m: Nat, +W: List<&2, U32>, +b: Nat) -> {wlist(m, W, b) == alist(m, W, b) : List<&2, U32>}:
  match m:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(U32, MR.wd(W, b), WR.at(W, b), WW.wd_at(W, b)) :
        {Con{_, wlist(p, W, 1n+b)} == Con{WR.at(W, b), alist(p, W, 1n+b)} : List<&2, U32>}
      %Equal.sym(List<&2, U32>, wlist(p, W, 1n+b), alist(p, W, 1n+b), wlist_alist(p, W, 1n+b)) :
        {Con{WR.at(W, b), _} == Con{WR.at(W, b), alist(p, W, 1n+b)} : List<&2, U32>}
      {==}

def alist_len(+m: Nat, +W: List<&2, U32>, +b: Nat) -> {F.spec_common__length(U32, alist(m, W, b)) == m : Nat}:
  match m:
    case 0n: {==}
    case 1n+p:
      %Equal.sym(Nat, F.spec_common__length(U32, alist(p, W, 1n+b)), p, alist_len(p, W, 1n+b)) :
        {1n+_ == 1n+p : Nat}
      {==}
