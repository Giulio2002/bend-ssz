import Base
import ../types/schema.bend as T
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../src/schema.bend as IS
import ../src/layout.bend as IL
import ../spec/codec.bend as SC
import ../spec/schema.bend as SS
import ../spec/layout.bend as SL
import ./packed.bend as PK
import ./cursor_leaves.bend as CL
import ./cursor_walk.bend as CW
import ./cursor_legal.bend as CLG
import ./primitive_invariants.bend as V
import ./nat_order.bend as NO
import ./nat_algebra.bend as NA
import ./schema.bend as SchemaProof
import ./word_facts.bend as F

# One decoder case at a time, with the decoder's own recursive results taken
# as hypotheses. `cursor_sound.bend` ties them together into the single
# recursion that mirrors `src/decode.go`.

# A planned child region: rejected plans decode nothing, accepted ones are
# exactly the region the recursion covers.
law region_if_sound:
  for +hh: T.Schema
  for +ok: Bool
  for +size: Nat
  for +pay: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat}
  for room: @+e: {ok == True{} : Bool} -> {Nat.is_le(size, P.slice_size(pay)) == True{} : Bool}
  for rec: @+wf2: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat} -> @+room2: {Nat.is_le(size, P.slice_size(pay)) == True{} : Bool} -> CL.region_sound(hh, size, pay, D.go(hh, 1n, 0n, D.Region{size, pay}))
  CL.region_sound(hh, size, pay, D.go(hh, 1n, 0n, D.region_if(ok, size, pay)))
def region_if_sound(hh, ok, size, pay, wf, room, rec):
  match ok:
    case False{}:
      %Equal.sym(D.Out, D.go(hh, 1n, 0n, D.Invalid{}), D.Refused{}, CW.invalid_refuses(hh, 1n, 0n)) : CL.region_sound(hh, size, pay, _)
      Unit{}
    case True{}: rec(wf, room({==}))


law remaining_fixed_width:
  for +h: Nat
  for +hh: T.Schema
  for +w: Nat
  for +hs: Nat
  for +fixedtotal: Nat
  for +wfix: {IS.fixed_size(hh) == Some{w} : Maybe<&2, Nat>}
  for +remaining: {Nat.add(h, Nat.add(IL.slot(IS.fixed_size(hh)), hs)) == fixedtotal : Nat}
  {Nat.add(h, Nat.add(w, hs)) == fixedtotal : Nat}
def remaining_fixed_width(h, hh, w, hs, fixedtotal, wfix, remaining):
  %wfix : {Nat.add(h, Nat.add(IL.slot(_), hs)) == fixedtotal : Nat}
  remaining

law remaining_variable_width:
  for +h: Nat
  for +hh: T.Schema
  for +hs: Nat
  for +fixedtotal: Nat
  for +wvar: {IS.fixed_size(hh) == None{} : Maybe<&2, Nat>}
  for +remaining: {Nat.add(h, Nat.add(IL.slot(IS.fixed_size(hh)), hs)) == fixedtotal : Nat}
  {Nat.add(h, Nat.add(4n, hs)) == fixedtotal : Nat}
def remaining_variable_width(h, hh, hs, fixedtotal, wvar, remaining):
  %wvar : {Nat.add(h, Nat.add(IL.slot(_), hs)) == fixedtotal : Nat}
  remaining

# ---------------------------------------------------------------------------
# One field of a declaration-order forest.
law step_dispatch:
  for +fields: T.Schema
  for +hh: T.Schema
  for +tt: T.Schema
  for +sl: P.Slice
  for +fixedtotal: Nat
  for +h: Nat
  for +pdone: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +base: Nat
  for +total: Nat
  for +pos: Nat
  for +end: Nat
  for +fs: T.Schema
  for +fsr: T.Schema
  for +nextschema: T.Schema
  for +nk: Nat
  for +hs: Nat
  for +krem: Nat
  for +ahead: D.Ahead
  for split: CW.forest_split(fs, hh, fsr)
  for childr: @+size: Nat -> @+slice: P.Slice -> @+wfs: {List.length(&2, U32, P.slice_bytes(slice)) == P.slice_size(slice) : Nat} -> @+rooms: {Nat.is_le(size, P.slice_size(slice)) == True{} : Bool} -> CL.region_sound(hh, size, slice, D.go(hh, 1n, 0n, D.Region{size, slice}))
  for +wopt: Maybe<&2, Nat>
  for +wsame: {IS.fixed_size(hh) == wopt : Maybe<&2, Nat>}
  for rect: @+flag: Bool -> @+cv: C.CValue -> @+crest: P.Slice -> @+other: P.Slice -> @+hdr2: P.Slice -> @+pay2: P.Slice -> @+h2: Nat -> @+pos2: Nat -> @+pdone2: +List<T.Part> -> @+settled2: {D.settle(D.Parsed{cv, crest}, flag, other, acc2) == D.Settled{hdr2, pay2, C.CCons{cv, acc2}} : D.Settled} -> CW.walk_goal(fields, fsr, sl, end, fixedtotal, hs, h2, pos2, pdone2, hdr2, pay2, C.CCons{cv, acc2}, 1n+base, krem, total, D.go(nextschema, 0n, nk, D.Walk{flag, D.Parsed{cv, crest}, other, pos2, end, acc2}))
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(end, P.slice_size(sl)) == True{} : Bool}
  for +hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>}
  for +wfhdr: {List.length(&2, U32, P.slice_bytes(hdr)) == P.slice_size(hdr) : Nat}
  for +payview: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>}
  for +wfpay: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat}
  for +sizedone: {SL.fixed_size(pdone) == h : Nat}
  for +remaining: {Nat.add(h, Nat.add(IL.slot(IS.fixed_size(hh)), hs)) == fixedtotal : Nat}
  for +position: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))) == pos : Nat}
  for +headerbytes: {List.take(&2, U32, P.slice_bytes(sl), h) == SL.fixed_parts(pdone, fixedtotal) : +List<U32>}
  for +payloadbytes: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)) == SL.payloads(pdone) : +List<U32>}
  for +validdone: {SL.bytes_valid(pdone) == True{} : Bool}
  for +fixle: {Nat.is_le(fixedtotal, pos) == True{} : Bool}
  for +posle: {Nat.is_le(pos, end) == True{} : Bool}
  for +counted: {Nat.add(base, 1n+krem) == total : Nat}
  for countctx: CW.count_context(acc2, base)
  for context: CW.walk_context(fields, fs, acc2, pdone)
  CW.walk_result(fields, sl, end, fixedtotal, total, D.go(nextschema, 0n, nk, D.plan_next(D.plan(D.Settled{hdr, pay, acc2}, IS.fixed_size(hh), pos, end, ahead), D.go(hh, 1n, 0n, D.plan_child(D.plan(D.Settled{hdr, pay, acc2}, IS.fixed_size(hh), pos, end, ahead))), end)))
def step_dispatch(fields, hh, tt, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, pos, end, fs, fsr, nextschema, nk, hs, krem, ahead, split, childr, wopt, wsame, rect, wfsl, roomsl, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, headerbytes, payloadbytes, validdone, fixle, posle, counted, countctx, context):
  match wopt:
    case Some{w}:
      +wfix = wsame
        %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(hh), Some{w}, wfix) : CW.walk_result(fields, sl, end, fixedtotal, total, D.go(nextschema, 0n, nk, D.plan_next(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, ahead), D.go(hh, 1n, 0n, D.plan_child(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, ahead))), end)))
        +remaining2 = remaining_fixed_width(h, hh, w, hs, fixedtotal, wfix, remaining)
        CW.step_dispatch_fixed(fields, fs, hh, nextschema, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, w, hs, pdone, acc2, hdr, pay,
          Equal.trans(Maybe<&2, Nat>, SS.fixed_size(hh), IS.fixed_size(hh), Some{w}, Equal.sym(Maybe<&2, Nat>, IS.fixed_size(hh), SS.fixed_size(hh), SchemaProof.fixed_size_correct(hh)), wfix),
          D.go(hh, 1n, 0n, D.Region{w, hdr}),
          childr(w, hdr, wfhdr, CW.fixed_child_room(sl, hdr, h, w, hs, fixedtotal, pos, end, wfsl, wfhdr, hdrview, remaining2, fixle, posle, roomsl)),
          cv => crest => rect(True{}, cv, crest, pay, crest, pay, Nat.add(h, w), pos, List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w)}]), {==})
        )(wfsl, roomsl, hdrview, wfhdr, payview, wfpay, sizedone, remaining2, position, headerbytes, payloadbytes, validdone, fixle, posle, counted, countctx, context)
    case None{}:
      +wvar = wsame
        %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(hh), None{}, wvar) : CW.walk_result(fields, sl, end, fixedtotal, total, D.go(nextschema, 0n, nk, D.plan_next(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, ahead), D.go(hh, 1n, 0n, D.plan_child(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, ahead))), end)))
        +stop = D.or_end(D.ahead(ahead, P.adv(hdr, 4n)), end)
        +ok = Bool.and(D.nat_eq(P.offset_at(hdr), pos), Bool.and(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end)))
        CW.step_dispatch_variable(fields, fs, hh, nextschema, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, stop, hs, pdone, acc2, hdr, pay,
          Equal.trans(Maybe<&2, Nat>, SS.fixed_size(hh), IS.fixed_size(hh), None{}, Equal.sym(Maybe<&2, Nat>, IS.fixed_size(hh), SS.fixed_size(hh), SchemaProof.fixed_size_correct(hh)), wvar),
          ok, {==},
          D.go(hh, 1n, 0n, D.region_if(ok, Nat.sub(stop, P.offset_at(hdr)), pay)), {==},
          region_if_sound(hh, ok, Nat.sub(stop, P.offset_at(hdr)), pay, wfpay,
            (e =>
              +bounds = V.and_right(D.nat_eq(P.offset_at(hdr), pos), Bool.and(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end)), e)
              +startpos = CL.nat_eq_sound(P.offset_at(hdr), pos, V.and_left(D.nat_eq(P.offset_at(hdr), pos), Bool.and(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end)), e))
              %Equal.sym(Nat, P.offset_at(hdr), pos, startpos) : {Nat.is_le(Nat.sub(stop, _), P.slice_size(pay)) == True{} : Bool}
              CW.variable_child_room(sl, pay, pos, stop, end, wfsl, wfpay, payview,
                CL.nat_le_sound(pos, stop, (%startpos : {D.nat_le(_, stop) == True{} : Bool}
                                            V.and_left(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end), bounds))),
                CL.nat_le_sound(stop, end, V.and_right(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end), bounds)),
                roomsl)),
            wf2 => room2 => childr(Nat.sub(stop, P.offset_at(hdr)), pay, wf2, room2)),
          cv => crest => rect(False{}, cv, crest, P.adv(hdr, 4n), P.adv(hdr, 4n), crest, Nat.add(h, 4n), stop, List.append(&2, T.Part, pdone, [T.Variable{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos))}]), {==})
        )(wfsl, roomsl, hdrview, wfhdr, payview, wfpay, sizedone, remaining_variable_width(h, hh, hs, fixedtotal, wvar, remaining), position, headerbytes, payloadbytes, validdone, fixle, posle, counted, countctx, context)

# ---------------------------------------------------------------------------
# Compatible-union option matching.
law among_here_region:
  for +hh: T.Schema
  for +hit: Bool
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for room: @+e: {hit == True{} : Bool} -> {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: @+wf2: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} -> @+room2: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} -> CL.region_sound(hh, n, xs, D.go(hh, 1n, 0n, D.Region{n, xs}))
  CL.region_sound(hh, n, xs, D.go(hh, 1n, 0n, D.among_here(hit, n, xs)))
def among_here_region(hh, hit, n, xs, wf, room, rec):
  match hit:
    case False{}:
      %Equal.sym(D.Out, D.go(hh, 1n, 0n, D.Invalid{}), D.Refused{}, CW.invalid_refuses(hh, 1n, 0n)) : CL.region_sound(hh, n, xs, _)
      Unit{}
    case True{}: rec(wf, room({==}))

law among_dispatch:
  for +hh: T.Schema
  for +tt: T.Schema
  for +rest: +List<U32>
  for +s: U32
  for +sel: U32
  for +n: Nat
  for +xs: P.Slice
  for +hit: Bool
  for +hitsame: {U32.is_eq(s, sel) == hit : Bool}
  for child: CL.region_sound(hh, n, xs, D.go(hh, 1n, 0n, D.among_here(hit, n, xs)))
  for later: CW.among_sound(rest, tt, sel, n, xs, D.go(tt, 0n, 0n, D.among_later(hit, rest, sel, n, xs)))
  CW.among_sound(s <> rest, T.Chain{hh, tt}, sel, n, xs, D.among(hit, sel, D.go(hh, 1n, 0n, D.among_here(hit, n, xs)), D.go(tt, 0n, 0n, D.among_later(hit, rest, sel, n, xs))))
def among_dispatch(hh, tt, rest, s, sel, n, xs, hit, hitsame, child, later):
  match hit:
    case True{}: CW.among_here_sound(hh, tt, rest, s, sel, n, xs, D.go(hh, 1n, 0n, D.Region{n, xs}), hitsame, child)
    case False{}: CW.among_later_sound(hh, tt, rest, s, sel, n, xs, hitsame, later)

law among_list_dispatch:
  for +phase: Nat
  for +hh: T.Schema
  for +tt: T.Schema
  for +selectors: +List<U32>
  for +sel: U32
  for +n: Nat
  for +xs: P.Slice
  for childh: @+hit: Bool -> CL.region_sound(hh, n, xs, D.go(hh, 1n, 0n, D.among_here(hit, n, xs)))
  for laterh: @+hit: Bool -> @+restsel: +List<U32> -> CW.among_sound(restsel, tt, sel, n, xs, D.go(tt, 0n, 0n, D.among_later(hit, restsel, sel, n, xs)))
  CW.among_sound(selectors, T.Chain{hh, tt}, sel, n, xs, D.go(T.Chain{hh, tt}, phase, 0n, D.PickAmong{selectors, sel, n, xs}))
def among_list_dispatch(phase, hh, tt, selectors, sel, n, xs, childh, laterh):
  match selectors:
    case Nil{}: Unit{}
    case Con{s, restsel}:
      among_dispatch(hh, tt, restsel, s, sel, n, xs, U32.is_eq(s, sel), {==}, childh(U32.is_eq(s, sel)), laterh(U32.is_eq(s, sel), restsel))

law among_later_go:
  for +tt: T.Schema
  for +hit: Bool
  for +restsel: +List<U32>
  for +sel: U32
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: @+wf2: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} -> @+room2: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} -> CW.among_sound(restsel, tt, sel, n, xs, D.go(tt, 0n, 0n, D.PickAmong{restsel, sel, n, xs}))
  CW.among_sound(restsel, tt, sel, n, xs, D.go(tt, 0n, 0n, D.among_later(hit, restsel, sel, n, xs)))
def among_later_go(tt, hit, restsel, sel, n, xs, wf, room, rec):
  match hit:
    case True{}:
      %Equal.sym(D.Out, D.go(tt, 0n, 0n, D.Invalid{}), D.Refused{}, CW.invalid_refuses(tt, 0n, 0n)) : CW.among_sound(restsel, tt, sel, n, xs, _)
      Unit{}
    case False{}: rec(wf, room)
