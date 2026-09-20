import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../src/schema.bend as IS
import ../src/layout.bend as IL
import ../src/primitives.bend as IP
import ../src/bitfields.bend as IBits
import ../spec/codec.bend as SC
import ../spec/schema.bend as SS
import ./packed.bend as PK
import ./cursor_leaves.bend as CL
import ./cursor_walk.bend as CW
import ./cursor_legal.bend as CLG
import ./word_facts.bend as F
import ./cursor_cases.bend as CC
import ./primitive_invariants.bend as V
import ./nat_algebra.bend as NA

# Soundness of the packed cursor decoder, by the decoder's own recursion.
#
# `go` is one self-recursive function over (schema, phase, remaining count,
# cursor); this law mirrors it exactly, so the decoder that the native
# benchmark runs is the decoder this proof is about. Each case discharges its
# obligation with the leaf refinements in cursor_leaves.bend, the walk steps
# in cursor_walk.bend and the per-case lemmas in cursor_cases.bend.

law go_sound:
  for +schema: T.Schema
  for +phase: Nat
  for +k: Nat
  for c: D.Cursor
  for +fields: T.Schema
  for +sl: P.Slice
  for +fixedtotal: Nat
  for +h: Nat
  for +pdone: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +base: Nat
  for +total: Nat
  for +legal: {CW.legal_go(schema) == True{} : Bool}
  CW.cursor_goal(schema, phase, k, c, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total)
def go_sound(schema, phase, k, c, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, legal):
  match schema:
    case T.Boolean{}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.boolean_leaf_sound(D.nat_eq(n, 1n), n, xs, wf, room, {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Boolean{}), sl, end, fixedtotal, CW.walk_header(T.Boolean{}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Boolean{}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.Unsigned{+w}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.uint_leaf_sound(D.nat_eq(n, IP.width(w)), w, n, xs, wf, room, {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Unsigned{w}), sl, end, fixedtotal, CW.walk_header(T.Unsigned{w}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Unsigned{w}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.ByteVector{+m}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.byte_vector_leaf_sound(Bool.and(D.nat_eq(n, m), Bool.and(Nat.is_lt(0n, m), D.fits(m))), m, n, xs, wf, room, {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.ByteVector{m}), sl, end, fixedtotal, CW.walk_header(T.ByteVector{m}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.ByteVector{m}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.ByteList{+m}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.byte_list_leaf_sound(Bool.and(D.nat_le(n, m), D.fits(n)), m, n, xs, wf, room, {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.ByteList{m}), sl, end, fixedtotal, CW.walk_header(T.ByteList{m}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.ByteList{m}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.BitVector{+m}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.bit_vector_leaf_sound(m, n, xs, wf, room, IBits.bitvector_deserialize(m, P.to_list(P.sub(xs, n))), {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.BitVector{m}), sl, end, fixedtotal, CW.walk_header(T.BitVector{m}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.BitVector{m}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.BitList{+m}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.bit_list_leaf_sound(m, n, xs, wf, room, IBits.bitlist_deserialize(m, P.to_list(P.sub(xs, n))), {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.BitList{m}), sl, end, fixedtotal, CW.walk_header(T.BitList{m}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.BitList{m}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.ProgressiveBits{}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.progressive_bits_leaf_sound(n, xs, wf, room, IBits.bitlist_deserialize(Nat.mul(n, 8n), P.to_list(P.sub(xs, n))), {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.ProgressiveBits{}), sl, end, fixedtotal, CW.walk_header(T.ProgressiveBits{}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.ProgressiveBits{}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.Null{}:
      match c:
        case D.Region{+n, +xs}: wf => room => CL.null_leaf_sound(D.nat_eq(n, 0n), n, xs, wf, {==})
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Null{}), sl, end, fixedtotal, CW.walk_header(T.Null{}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Null{}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.Named{name, inner}:
      match c:
        case D.Region{+n, +xs}: wf => room => Unit{}
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Named{name, inner}), sl, end, fixedtotal, CW.walk_header(T.Named{name, inner}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Named{name, inner}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.Repeat{e}:
      match c:
        case D.Region{+n, +xs}: wf => room => Unit{}
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Repeat{e}), sl, end, fixedtotal, CW.walk_header(T.Repeat{e}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Repeat{e}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.End{}:
      match c:
        case D.Region{+n, +xs}: wf => room => Unit{}
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
          settled =>
            %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.End{}, sl, end, fixedtotal, 0n, h, pos, pdone, hdr, pay, acc2, base, 0n, total, D.close(_, pos, end))
            CW.close_sound(fields, T.End{}, sl, end, fixedtotal, h, pos, pdone, acc2, hdr, pay, base, total, {==})
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.Chain{hh, tt}:
      match k:
        case 0n:
          match c:
            case D.Region{+n, +xs}: wf => room => Unit{}
            case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
              settled =>
                +legalh = V.and_left(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), legal)
                +shapet = V.and_left(CW.forest_ok(tt), CW.legal_go(tt), V.and_right(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), legal))
                +legalt = V.and_right(CW.forest_ok(tt), CW.legal_go(tt), V.and_right(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), legal))
                %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.Chain{hh, tt}, sl, end, fixedtotal, CW.walk_header(T.Chain{hh, tt}, 0n), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Chain{hh, tt}, 0n), total, D.go(tt, 0n, 0n, D.plan_next(D.plan(_, IS.fixed_size(hh), pos, end, D.Later{tt}), D.go(hh, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(hh), pos, end, D.Later{tt}))), end)))
                wfsl => roomsl => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => headerbytes => payloadbytes => validdone => fixle => posle => counted => countctx => context =>
                  CC.step_dispatch(fields, hh, tt, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, pos, end,
                    T.Chain{hh, tt}, tt, tt, 0n, CW.walk_header(tt, 0n), CW.walk_count(tt, 0n), D.Later{tt}, CW.chain_split(hh, tt),
                    (size => slice => wfs => rooms => go_sound(hh, 1n, 0n, D.Region{size, slice}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, legalh)(wfs, rooms)),
                    IS.fixed_size(hh), {==},
                    (flag => cv => crest => other => hdr2 => pay2 => h2 => pos2 => pdone2 => settled2 =>
                       %CW.walk_forest_of_chain(tt, shapet) : CW.walk_goal(fields, _, sl, end, fixedtotal, CW.walk_header(tt, 0n), h2, pos2, pdone2, hdr2, pay2, C.CCons{cv, acc2}, 1n+base, CW.walk_count(tt, 0n), total, D.go(tt, 0n, 0n, D.Walk{flag, D.Parsed{cv, crest}, other, pos2, end, acc2}))
                       go_sound(tt, 0n, 0n, D.Walk{flag, D.Parsed{cv, crest}, other, pos2, end, acc2}, fields, sl, fixedtotal, h2, pdone2, hdr2, pay2, C.CCons{cv, acc2}, 1n+base, total, legalt)(settled2)),
                    wfsl, roomsl, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, headerbytes, payloadbytes, validdone, fixle, posle, counted, countctx, context)
            case D.Pick{+sel, +n, +xs}:
              wf => room =>
                CW.pick_here(hh, tt, sel, n, xs, D.go(hh, 1n, 0n, D.Region{n, xs}),
                  go_sound(hh, 1n, 0n, D.Region{n, xs}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, V.and_left(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), legal))(wf, room))
            case D.PickAmong{+selectors, +sel, +n, +xs}:
              wf => room =>
                CC.among_list_dispatch(phase, hh, tt, selectors, sel, n, xs,
                  (hit => CC.among_here_region(hh, hit, n, xs, wf, (e => room),
                     (wf2 => room2 => go_sound(hh, 1n, 0n, D.Region{n, xs}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, V.and_left(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), legal))(wf2, room2)))),
                  (hit => restsel => CC.among_later_go(tt, hit, restsel, sel, n, xs, wf, room, (wf2 => room2 => go_sound(tt, 0n, 0n, D.PickAmong{restsel, sel, n, xs}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, V.and_right(CW.forest_ok(tt), CW.legal_go(tt), V.and_right(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), legal)))(wf2, room2)))))
            case D.Invalid{}: Unit{}
        case 1n+p:
          match c:
            case D.Region{+n, +xs}: wf => room => Unit{}
            case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, T.Chain{hh, tt}, sl, end, fixedtotal, CW.walk_header(T.Chain{hh, tt}, 1n+p), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Chain{hh, tt}, 1n+p), total)
            case D.Pick{+sel, +n, +xs}:
              wf => room =>
                go_sound(tt, 0n, p, D.Pick{sel, n, xs}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, V.and_right(CW.forest_ok(tt), CW.legal_go(tt), V.and_right(CW.legal_go(hh), Bool.and(CW.forest_ok(tt), CW.legal_go(tt)), legal)))(wf, room)
            case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
            case D.Invalid{}: Unit{}
    case T.Vector{+e, +mv}:
      match phase:
        case 1n+q:
          match c:
            case D.Region{+n, +xs}: wf => room =>
              CW.vector_region(e, mv, n, xs, q, Bool.and(Nat.is_lt(0n, mv), D.sequence_ok(IS.fixed_size(e), mv, n)), {==}, wf, room,
                go_sound(T.Vector{e, mv}, q, mv, D.layout(Bool.and(Nat.is_lt(0n, mv), D.sequence_ok(IS.fixed_size(e), mv, n)), Nat.mul(IL.slot(IS.fixed_size(e)), mv), n, xs), T.Repeat{e}, xs, Nat.mul(IL.slot(IS.fixed_size(e)), mv), 0n, [], xs, P.adv(xs, Nat.mul(IL.slot(IS.fixed_size(e)), mv)), C.CEnd{}, 0n, mv, legal))
            case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Vector{e, mv}), sl, end, fixedtotal, CW.walk_header(T.Vector{e, mv}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Vector{e, mv}, k), total)
            case D.Pick{sel, n, xs}: wf => room => Unit{}
            case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
            case D.Invalid{}: Unit{}
        case 0n:
          match k:
            case 0n:
              match c:
                case D.Region{+n, +xs}: wf => room => Unit{}
                case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
                  settled =>
                    %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), 0n), 0n, NA.mul_zero(IL.slot(IS.fixed_size(e)))) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, _, h, pos, pdone, hdr, pay, acc2, base, 0n, total, D.go(T.Vector{e, mv}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}))
                    %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, 0n, h, pos, pdone, hdr, pay, acc2, base, 0n, total, D.close(_, pos, end))
                    CW.close_sound(fields, T.Repeat{e}, sl, end, fixedtotal, h, pos, pdone, acc2, hdr, pay, base, total, {==})
                case D.Pick{sel, n, xs}: wf => room => Unit{}
                case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{+n, +xs}: wf => room => Unit{}
                case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
                  settled =>
                    %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), 1n+p), Nat.add(IL.slot(IS.fixed_size(e)), Nat.mul(IL.slot(IS.fixed_size(e)), p)), NA.mul_succ_right(IL.slot(IS.fixed_size(e)), p)) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, _, h, pos, pdone, hdr, pay, acc2, base, 1n+p, total, D.go(T.Vector{e, mv}, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}))
                    %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, Nat.add(IL.slot(IS.fixed_size(e)), CW.walk_header(T.Vector{e, mv}, p)), h, pos, pdone, hdr, pay, acc2, base, 1n+p, total, D.go(T.Vector{e, mv}, 0n, p, D.plan_next(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}))), end)))
                    wfsl => roomsl => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => headerbytes => payloadbytes => validdone => fixle => posle => counted => countctx => context =>
                      CC.step_dispatch(fields, e, T.End{}, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, pos, end,
                        T.Repeat{e}, T.Repeat{e}, T.Vector{e, mv}, p, CW.walk_header(T.Vector{e, mv}, p), p, D.Remaining{p}, CW.repeat_split(e),
                        (size => slice => wfs => rooms => go_sound(e, 1n, 0n, D.Region{size, slice}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, legal)(wfs, rooms)),
                        IS.fixed_size(e), {==},
                        (flag => cv => crest => other2 => hdr2 => pay2 => h2 => pos2 => pdone2 => settled2 =>
                          go_sound(T.Vector{e, mv}, 0n, p, D.Walk{flag, D.Parsed{cv, crest}, other2, pos2, end, acc2}, fields, sl, fixedtotal, h2, pdone2, hdr2, pay2, C.CCons{cv, acc2}, 1n+base, total, legal)(settled2)),
                        wfsl, roomsl, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, headerbytes, payloadbytes, validdone, fixle, posle, counted, countctx, context)
                case D.Pick{sel, n, xs}: wf => room => Unit{}
                case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
                case D.Invalid{}: Unit{}
    case T.ListOf{+e, +limit}:
      match phase:
        case 1n+q:
          match c:
            case D.Region{+n, +xs}: wf => room =>
              CW.list_region(e, limit, n, xs, D.list_count(IS.fixed_size(e), n, xs), q, Bool.and(D.count_ok(D.list_count(IS.fixed_size(e), n, xs), Some{limit}), D.sequence_ok(IS.fixed_size(e), D.counted(D.list_count(IS.fixed_size(e), n, xs)), n)), {==}, wf, room,
                go_sound(T.ListOf{e, limit}, q, D.counted(D.list_count(IS.fixed_size(e), n, xs)), D.layout(Bool.and(D.count_ok(D.list_count(IS.fixed_size(e), n, xs), Some{limit}), D.sequence_ok(IS.fixed_size(e), D.counted(D.list_count(IS.fixed_size(e), n, xs)), n)), Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(D.list_count(IS.fixed_size(e), n, xs))), n, xs), T.Repeat{e}, xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(D.list_count(IS.fixed_size(e), n, xs))), 0n, [], xs, P.adv(xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(D.list_count(IS.fixed_size(e), n, xs)))), C.CEnd{}, 0n, D.counted(D.list_count(IS.fixed_size(e), n, xs)), legal))
            case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.ListOf{e, limit}), sl, end, fixedtotal, CW.walk_header(T.ListOf{e, limit}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.ListOf{e, limit}, k), total)
            case D.Pick{sel, n, xs}: wf => room => Unit{}
            case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
            case D.Invalid{}: Unit{}
        case 0n:
          match k:
            case 0n:
              match c:
                case D.Region{+n, +xs}: wf => room => Unit{}
                case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
                  settled =>
                    %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), 0n), 0n, NA.mul_zero(IL.slot(IS.fixed_size(e)))) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, _, h, pos, pdone, hdr, pay, acc2, base, 0n, total, D.go(T.ListOf{e, limit}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}))
                    %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, 0n, h, pos, pdone, hdr, pay, acc2, base, 0n, total, D.close(_, pos, end))
                    CW.close_sound(fields, T.Repeat{e}, sl, end, fixedtotal, h, pos, pdone, acc2, hdr, pay, base, total, {==})
                case D.Pick{sel, n, xs}: wf => room => Unit{}
                case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{+n, +xs}: wf => room => Unit{}
                case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
                  settled =>
                    %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), 1n+p), Nat.add(IL.slot(IS.fixed_size(e)), Nat.mul(IL.slot(IS.fixed_size(e)), p)), NA.mul_succ_right(IL.slot(IS.fixed_size(e)), p)) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, _, h, pos, pdone, hdr, pay, acc2, base, 1n+p, total, D.go(T.ListOf{e, limit}, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}))
                    %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, Nat.add(IL.slot(IS.fixed_size(e)), CW.walk_header(T.ListOf{e, limit}, p)), h, pos, pdone, hdr, pay, acc2, base, 1n+p, total, D.go(T.ListOf{e, limit}, 0n, p, D.plan_next(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}))), end)))
                    wfsl => roomsl => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => headerbytes => payloadbytes => validdone => fixle => posle => counted => countctx => context =>
                      CC.step_dispatch(fields, e, T.End{}, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, pos, end,
                        T.Repeat{e}, T.Repeat{e}, T.ListOf{e, limit}, p, CW.walk_header(T.ListOf{e, limit}, p), p, D.Remaining{p}, CW.repeat_split(e),
                        (size => slice => wfs => rooms => go_sound(e, 1n, 0n, D.Region{size, slice}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, legal)(wfs, rooms)),
                        IS.fixed_size(e), {==},
                        (flag => cv => crest => other2 => hdr2 => pay2 => h2 => pos2 => pdone2 => settled2 =>
                          go_sound(T.ListOf{e, limit}, 0n, p, D.Walk{flag, D.Parsed{cv, crest}, other2, pos2, end, acc2}, fields, sl, fixedtotal, h2, pdone2, hdr2, pay2, C.CCons{cv, acc2}, 1n+base, total, legal)(settled2)),
                        wfsl, roomsl, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, headerbytes, payloadbytes, validdone, fixle, posle, counted, countctx, context)
                case D.Pick{sel, n, xs}: wf => room => Unit{}
                case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
                case D.Invalid{}: Unit{}
    case T.ProgressiveList{+e}:
      match phase:
        case 1n+q:
          match c:
            case D.Region{+n, +xs}: wf => room =>
              CW.progressive_list_region(e, n, xs, D.list_count(IS.fixed_size(e), n, xs), q, Bool.and(D.count_ok(D.list_count(IS.fixed_size(e), n, xs), None{}), D.sequence_ok(IS.fixed_size(e), D.counted(D.list_count(IS.fixed_size(e), n, xs)), n)), {==}, wf, room,
                go_sound(T.ProgressiveList{e}, q, D.counted(D.list_count(IS.fixed_size(e), n, xs)), D.layout(Bool.and(D.count_ok(D.list_count(IS.fixed_size(e), n, xs), None{}), D.sequence_ok(IS.fixed_size(e), D.counted(D.list_count(IS.fixed_size(e), n, xs)), n)), Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(D.list_count(IS.fixed_size(e), n, xs))), n, xs), T.Repeat{e}, xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(D.list_count(IS.fixed_size(e), n, xs))), 0n, [], xs, P.adv(xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(D.list_count(IS.fixed_size(e), n, xs)))), C.CEnd{}, 0n, D.counted(D.list_count(IS.fixed_size(e), n, xs)), legal))
            case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.ProgressiveList{e}), sl, end, fixedtotal, CW.walk_header(T.ProgressiveList{e}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.ProgressiveList{e}, k), total)
            case D.Pick{sel, n, xs}: wf => room => Unit{}
            case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
            case D.Invalid{}: Unit{}
        case 0n:
          match k:
            case 0n:
              match c:
                case D.Region{+n, +xs}: wf => room => Unit{}
                case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
                  settled =>
                    %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), 0n), 0n, NA.mul_zero(IL.slot(IS.fixed_size(e)))) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, _, h, pos, pdone, hdr, pay, acc2, base, 0n, total, D.go(T.ProgressiveList{e}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}))
                    %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, 0n, h, pos, pdone, hdr, pay, acc2, base, 0n, total, D.close(_, pos, end))
                    CW.close_sound(fields, T.Repeat{e}, sl, end, fixedtotal, h, pos, pdone, acc2, hdr, pay, base, total, {==})
                case D.Pick{sel, n, xs}: wf => room => Unit{}
                case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{+n, +xs}: wf => room => Unit{}
                case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}:
                  settled =>
                    %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), 1n+p), Nat.add(IL.slot(IS.fixed_size(e)), Nat.mul(IL.slot(IS.fixed_size(e)), p)), NA.mul_succ_right(IL.slot(IS.fixed_size(e)), p)) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, _, h, pos, pdone, hdr, pay, acc2, base, 1n+p, total, D.go(T.ProgressiveList{e}, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}))
                    %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CW.walk_goal(fields, T.Repeat{e}, sl, end, fixedtotal, Nat.add(IL.slot(IS.fixed_size(e)), CW.walk_header(T.ProgressiveList{e}, p)), h, pos, pdone, hdr, pay, acc2, base, 1n+p, total, D.go(T.ProgressiveList{e}, 0n, p, D.plan_next(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}))), end)))
                    wfsl => roomsl => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => headerbytes => payloadbytes => validdone => fixle => posle => counted => countctx => context =>
                      CC.step_dispatch(fields, e, T.End{}, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, pos, end,
                        T.Repeat{e}, T.Repeat{e}, T.ProgressiveList{e}, p, CW.walk_header(T.ProgressiveList{e}, p), p, D.Remaining{p}, CW.repeat_split(e),
                        (size => slice => wfs => rooms => go_sound(e, 1n, 0n, D.Region{size, slice}, fields, sl, fixedtotal, h, pdone, hdr, pay, acc2, base, total, legal)(wfs, rooms)),
                        IS.fixed_size(e), {==},
                        (flag => cv => crest => other2 => hdr2 => pay2 => h2 => pos2 => pdone2 => settled2 =>
                          go_sound(T.ProgressiveList{e}, 0n, p, D.Walk{flag, D.Parsed{cv, crest}, other2, pos2, end, acc2}, fields, sl, fixedtotal, h2, pdone2, hdr2, pay2, C.CCons{cv, acc2}, 1n+base, total, legal)(settled2)),
                        wfsl, roomsl, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, headerbytes, payloadbytes, validdone, fixle, posle, counted, countctx, context)
                case D.Pick{sel, n, xs}: wf => room => Unit{}
                case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
                case D.Invalid{}: Unit{}
    case T.Container{+names, +cfields}:
      match c:
        case D.Region{+n, +xs}: wf => room =>
          CW.container_region(names, cfields, n, xs, Bool.and(D.fits(n), D.nat_le(D.header_size(cfields), n)), V.and_left(CW.forest_ok(cfields), CW.legal_go(cfields), legal), {==}, wf, room,
            go_sound(cfields, 0n, 0n, D.layout(Bool.and(D.fits(n), D.nat_le(D.header_size(cfields), n)), D.header_size(cfields), n, xs), cfields, xs, D.header_size(cfields), 0n, [], xs, P.adv(xs, D.header_size(cfields)), C.CEnd{}, 0n, CW.walk_count(cfields, 0n), V.and_right(CW.forest_ok(cfields), CW.legal_go(cfields), legal)))
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Container{names, cfields}), sl, end, fixedtotal, CW.walk_header(T.Container{names, cfields}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Container{names, cfields}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.ProgressiveContainer{+names, +cfields, +active}:
      match c:
        case D.Region{+n, +xs}: wf => room =>
          CW.progressive_container_region(names, active, cfields, n, xs, Bool.and(D.fits(n), D.nat_le(D.header_size(cfields), n)), V.and_left(CW.forest_ok(cfields), CW.legal_go(cfields), legal), {==}, wf, room,
            go_sound(cfields, 0n, 0n, D.layout(Bool.and(D.fits(n), D.nat_le(D.header_size(cfields), n)), D.header_size(cfields), n, xs), cfields, xs, D.header_size(cfields), 0n, [], xs, P.adv(xs, D.header_size(cfields)), C.CEnd{}, 0n, CW.walk_count(cfields, 0n), V.and_right(CW.forest_ok(cfields), CW.legal_go(cfields), legal)))
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.ProgressiveContainer{names, cfields, active}), sl, end, fixedtotal, CW.walk_header(T.ProgressiveContainer{names, cfields, active}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.ProgressiveContainer{names, cfields, active}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.Union{+options}:
      match c:
        case D.Region{+n, +xs}: wf => room =>
          CW.union_region(options, n, xs, wf, room,
            go_sound(options, 0n, D.selector_index(D.union_start(n, xs)), D.union_start(n, xs), options, xs, 0n, 0n, [], xs, xs, C.CEnd{}, 0n, 0n, V.and_right(CW.forest_ok(options), CW.legal_go(options), legal)))
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.Union{options}), sl, end, fixedtotal, CW.walk_header(T.Union{options}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.Union{options}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
    case T.CompatibleUnion{+selectors, +options}:
      match c:
        case D.Region{+n, +xs}: wf => room =>
          CW.compatible_union_region(selectors, options, n, xs, wf, room,
            go_sound(options, 0n, 0n, D.among_start(selectors, n, xs), options, xs, 0n, 0n, [], xs, xs, C.CEnd{}, 0n, 0n, V.and_right(CW.forest_ok(options), CW.legal_go(options), legal)))
        case D.Walk{+fixed, +prior, +other, +pos, +end, +acc}: settled => CW.refused_walk(fields, CW.walk_forest(T.CompatibleUnion{selectors, options}), sl, end, fixedtotal, CW.walk_header(T.CompatibleUnion{selectors, options}, k), h, pos, pdone, hdr, pay, acc2, base, CW.walk_count(T.CompatibleUnion{selectors, options}, k), total)
        case D.Pick{sel, n, xs}: wf => room => Unit{}
        case D.PickAmong{selectors, sel, n, xs}: wf => room => Unit{}
        case D.Invalid{}: Unit{}
