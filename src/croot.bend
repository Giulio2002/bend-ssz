import Base
import ./buffer.bend as B
import ./digest.bend as D
import ./merkle_fast.bend as MF
import ./cschema.bend as S

# hash_tree_root over indexed storage and the compact schema.
#
# Leaves are hashed straight out of the packed buffer. Composite roots -
# container fields, and sequences of composite elements - use the same
# level-stack merkleizer, each nesting level taking its own segment of one
# shared `MF.DStack`, so nothing is allocated per element and no scratch
# list exists. Length mixing is one extra hash against the length chunk.
#
# One self-recursive definition, as everywhere in this runtime: Bend has no
# mutual recursion, cannot match a computed value, and requires a self-call to
# leave every argument unchanged until one shrinks. The threaded pair carries
# the buffer and the shared stack together with the value read for this step
# and the digest being delivered.
#
# Tags:
#   0  compute the root of `schema` over [a, b)
#   1  deliver the digest to the frame
#   2  the current variable field starts at base + v
#   3  it ends at base + v, and starts at a
#   4  variable element i starts at base + v
#   5  it ends at base + v, and starts at a
#   6  the last byte of a bit list is in v
#   7  advance the container field walk
#   8  close the merkleization held in the frame and deliver it upward
# The step result travels as one pair, exactly like `src/cscan.bend`: the
# buffer with the digest for this step. A value read from the buffer is carried
# in the digest's first word, so there is only ever one pair shape - a record
# with a linear field made the backend's compile of this walker together with a
# file reader exceed several gigabytes.
type RF is Data:
  RDone{}
  # One frame shape for all three composite walks, because three constructors
  # with nine fields each made this module too large for the backend to compile
  # against a runtime-produced buffer at all (see WORK_LOG).
  #   kind 0: `n` fixed-stride elements of `elem` from `base`, stride `span`
  #   kind 1: `n` variable-size elements, offset table at `base`, end `span`
  #   kind 2: container fields `elem`, `n` of them, base `base`, end `span`
  RFr{kind: U32, elem: S.CS, i: U32, n: U32, base: U32, span: U32, seg: U32,
      depth: U32, mix: U32, up: RF}

def no_mix() -> U32: 4294967295

def usel(c: Bool, +x: U32, +y: U32) -> U32:
  match c:
    case True{}: x
    case False{}: y

def fsel(c: Bool, x: RF, y: RF) -> RF:
  match c:
    case True{}: x
    case False{}: y

def ssel(c: Bool, x: S.CS, y: S.CS) -> S.CS:
  match c:
    case True{}: x
    case False{}: y

def length_chunk(+n: U32) -> D.Digest: D.D{B.swap32(n), 0, 0, 0, 0, 0, 0, 0}

def mix_pick(mixing: Bool, d: D.Digest, +n: U32) -> D.Digest:
  match mixing:
    case True{}: D.hash_pair(d, length_chunk(n))
    case False{}: d

def mix_in(+mix: U32, d: D.Digest) -> D.Digest:
  mix_pick(Bool.not(U32.is_eq(mix, no_mix())), d, mix)

def pack_leaf(+mix: U32, pair: B.Buf & D.Digest) -> B.Buf & D.Digest:
  (buf, d) = pair
  (buf, mix_in(mix, d))

# A read value travels in the first word of the carried digest, so there is
# only ever one pair shape.
def as_digest(pair: B.Buf & U32) -> B.Buf & D.Digest:
  (buf, +w) = pair
  (buf, D.D{w, 0, 0, 0, 0, 0, 0, 0})

def word_of(d: D.Digest) -> U32:
  match d:
    case D.D{+w0, w1, w2, w3, w4, w5, w6, w7}: w0

def leaf(buf: B.Buf, +st: MF.DStack, +seg: U32, +off: U32, +len: U32,
         +depth: U32, +mpos: U32, +mask: U32, +mix: U32) -> B.Buf & D.Digest:
  pack_leaf(mix, MF.merkleize_in(buf, st, seg, off, len, depth, mpos, mask))

def f_schema(f: S.CS) -> S.CS:
  match f:
    case S.CFLeaf{+s, hoff, hsize, fixed}: s
    case _: S.CFNone{}

def f_hoff(f: S.CS) -> U32:
  match f:
    case S.CFLeaf{s, +hoff, hsize, fixed}: hoff
    case _: 0

def f_hsize(f: S.CS) -> U32:
  match f:
    case S.CFLeaf{s, hoff, +hsize, fixed}: hsize
    case _: 0

def f_fixed(f: S.CS) -> Bool:
  match f:
    case S.CFLeaf{s, hoff, hsize, +fixed}: fixed
    case _: True{}

def or_end(m: Maybe<&2, U32>, +endp: U32, +base: U32) -> U32:
  match m:
    case None{}: endp
    case Some{+h}: (base + h : U32)

def has_next(m: Maybe<&2, U32>) -> Bool:
  match m:
    case None{}: False{}
    case Some{h}: True{}

def high_bit(+v: U32) -> U32:
  usel(U32.is_ge(v, 128), 7,
    usel(U32.is_ge(v, 64), 6,
      usel(U32.is_ge(v, 32), 5,
        usel(U32.is_ge(v, 16), 4,
          usel(U32.is_ge(v, 8), 3,
            usel(U32.is_ge(v, 4), 2, usel(U32.is_ge(v, 2), 1, 0)))))))

def bit_mask(+r: U32) -> U32:
  match r:
    case 0: 255
    case 1: 1
    case 2: 3
    case 3: 7
    case 4: 15
    case 5: 31
    case 6: 63
    case _: 127

# ---------------------------------------------------------------------------
# The plan: the schema dispatch is pure, so the recursive walker stays small.
#   kind 0  merkleize [off, off+len) at `depth`, masked, mixing `mix`
#   kind 1  read a four-byte offset at `off`
#   kind 2  read the byte at `off`
#   kind 3  read nothing
type Plan is Data:
  P{tag: U32, sch: S.CS, fr: RF, a: U32, b: U32, c: U32, kind: U32,
    off: U32, len: U32, depth: U32, mix: U32}

# Leaf shape, as three small lookups instead of a branch per constructor.
def leaf_len(+schema: S.CS, +a: U32, +b: U32) -> U32:
  match schema:
    case S.CBool{}: 1
    case S.CUint{+size}: size
    case S.CBytes{+len, depth}: len
    case S.CBitVec{bits, +bytes, depth}: bytes
    case S.CByteList{lim, big, depth}: (b - a : U32)
    case _: 0

def leaf_depth(+schema: S.CS) -> U32:
  match schema:
    case S.CBytes{len, +depth}: depth
    case S.CBitVec{bits, bytes, +depth}: depth
    case S.CByteList{lim, big, +depth}: depth
    case _: 0

def leaf_mix(+schema: S.CS, +a: U32, +b: U32) -> U32:
  match schema:
    case S.CByteList{lim, big, depth}: (b - a : U32)
    case _: no_mix()

def plan_start(+schema: S.CS, +fr: RF, +a: U32, +b: U32, +c: U32) -> Plan:
  match schema:
    case S.CBitList{lim, big, depth}: P{6, schema, fr, a, b, c, 2, (b - 1 : U32), 0, 0, no_mix()}
    case S.CVec{+elem, +count, +stride, +depth, +basic, plain}:
      P{usel(basic, 1, usel(U32.is_eq(count, 0), 8, 0)), ssel(basic, schema, elem),
        fsel(basic, fr, RFr{0, elem, 0, count, a, stride, (c + 64 : U32), depth, no_mix(), fr}),
        a, (a + stride : U32), usel(basic, c, (c + 64 : U32)),
        usel(basic, 0, 3), a, (count * stride : U32), depth, no_mix()}
    case S.CVecVar{+elem, +count, +depth}:
      P{usel(U32.is_eq(count, 0), 8, 2), elem,
        RFr{1, elem, 0, count, a, b, (c + 64 : U32), depth, no_mix(), fr},
        a, b, (c + 64 : U32), 1, a, 0, depth, no_mix()}
    case S.CList{+elem, lim, big, +stride, +depth, +basic, plain}:
      P{usel(basic, 1, usel(U32.is_eq(U32.div((b - a : U32), stride), 0), 8, 0)),
        ssel(basic, schema, elem),
        fsel(basic, fr, RFr{0, elem, 0, U32.div((b - a : U32), stride), a, stride, (c + 64 : U32),
                            depth, U32.div((b - a : U32), stride), fr}),
        a, (a + stride : U32), usel(basic, c, (c + 64 : U32)),
        usel(basic, 0, 3), a, (b - a : U32), depth, U32.div((b - a : U32), stride)}
    case S.CListVar{+elem, lim, big, +depth}:
      P{usel(U32.is_eq((b - a : U32), 0), 8, 2), elem,
        RFr{1, elem, 0, 0, a, b, (c + 64 : U32), depth, 0, fr},
        a, b, (c + 64 : U32), 1, a, 0, depth, no_mix()}
    case S.CCont{+fields, +cnt, fp, size, fixed, +depth, plain}:
      P{7, schema, RFr{2, fields, 0, cnt, a, b, (c + 64 : U32), depth, no_mix(), fr},
        a, b, (c + 64 : U32), 3, a, 0, 0, no_mix()}
    case _:
      P{1, schema, fr, a, b, c, 0, a, leaf_len(schema, a, b), leaf_depth(schema),
        leaf_mix(schema, a, b)}

def p_tag(+q: Plan) -> U32:
  match q:
    case P{+tag, sch, fr, a, b, c, kind, off, len, depth, mix}: tag

def p_sch(+q: Plan) -> S.CS:
  match q:
    case P{tag, +sch, fr, a, b, c, kind, off, len, depth, mix}: sch

def p_fr(+q: Plan) -> RF:
  match q:
    case P{tag, sch, +fr, a, b, c, kind, off, len, depth, mix}: fr

def p_a(+q: Plan) -> U32:
  match q:
    case P{tag, sch, fr, +a, b, c, kind, off, len, depth, mix}: a

def p_b(+q: Plan) -> U32:
  match q:
    case P{tag, sch, fr, a, +b, c, kind, off, len, depth, mix}: b

def p_c(+q: Plan) -> U32:
  match q:
    case P{tag, sch, fr, a, b, +c, kind, off, len, depth, mix}: c

# A leaf's own merkleization takes the segment *above* the current one: the
# parent container or sequence is accumulating its child roots in `seg`, and a
# leaf whose tree is deeper than one chunk would otherwise overwrite those
# levels. This was a real bug: containers holding a multi-chunk leaf, such as
# SyncAggregate, rooted incorrectly until the leaf moved up a segment.
def plan_pick(+kind: U32, buf: B.Buf, +st: MF.DStack, +d: D.Digest, +seg: U32, +off: U32,
              +len: U32, +depth: U32, +mpos: U32, +mask: U32, +mix: U32) -> B.Buf & D.Digest:
  match kind:
    case 0: leaf(buf, st, (seg + 64 : U32), off, len, depth, mpos, mask, mix)
    case 1: as_digest(B.read32(buf, off))
    case 2: as_digest(B.byte_at(buf, off))
    case _: (buf, d)

def plan_step(+q: Plan, buf: B.Buf, +st: MF.DStack, +d: D.Digest) -> B.Buf & D.Digest:
  match q:
    case P{tag, sch, fr, a, b, +c, +kind, +off, +len, +depth, +mix}:
      plan_pick(kind, buf, st, d, c, off, len, depth, 4294967295, 255, mix)

# The window of the next item in a composite walk, and what to read for it.
def step_plan(+kind: U32, +elem: S.CS, +i: U32, +n: U32, +base: U32, +span: U32, +seg: U32,
              +depth: U32, +mix: U32, +up: RF, +d: U32) -> Plan:
  match kind:
    case 0:
      P{usel(U32.is_lt(i, n), 0, 8), elem,
        RFr{0, elem, i, n, base, span, seg, depth, mix, up},
        (base + span * i : U32), (base + span * (i + 1 : U32) : U32), seg,
        3, 0, 0, depth, mix}
    case 1:
      P{usel(U32.is_lt(i, n), 2, 8), elem,
        RFr{1, elem, i, n, base, span, seg, depth, mix, up},
        base, span, seg, 1, (base + 4 * i : U32), 0, depth, mix}
    case _:
      P{usel(U32.is_lt(i, n), 7, 8), elem,
        RFr{2, elem, i, n, base, span, seg, depth, mix, up},
        base, span, seg, 3, 0, 0, depth, mix}

def bitlist_depth(+schema: S.CS) -> U32:
  match schema:
    case S.CBitList{lim, big, +depth}: depth
    case _: 0

def rrun(+fuel: Nat, +tag: U32, +schema: S.CS, +fr: RF, +a: U32, +b: U32, +c: U32,
         +st: MF.DStack, pair: B.Buf & D.Digest) -> B.Buf & D.Digest:
  match fuel:
    case 0n:
      (buf, +d) = pair
      (buf, d)
    case 1n+p:
      match tag:
        # ---- 0: start, through the pure planner -------------------------
        case 0:
          (buf, +d) = pair
          +q = plan_start(schema, fr, a, b, c)
          rrun(p, p_tag(q), p_sch(q), p_fr(q), p_a(q), p_b(q), p_c(q), st, plan_step(q, buf, st, d))
        # ---- 6: bit list, the last byte is in the carried word -----------
        case 6:
          (buf, +d) = pair
          +bits = (((b - a : U32) - 1 : U32) * 8 + high_bit(word_of(d)) : U32)
          +packed = U32.shrn((bits + 7 : U32), 3n)
          rrun(p, 1, schema, fr, a, b, c, st,
            leaf(buf, st, (c + 64 : U32), a, packed, bitlist_depth(schema),
              (a + packed - 1 : U32), bit_mask((bits .&. 7 : U32)), bits))
        # ---- 2: an element or field starts at base + word ----------------
        case 2:
          match fr:
            case RFr{+kind, +elem, +i, +n, +base, +span, +seg, +depth, +mix, +up}:
              (buf, +d) = pair
              +count = usel(U32.is_eq(kind, 1),
                usel(U32.is_eq(i, 0), usel(U32.is_eq(n, 0), U32.shrn(word_of(d), 2n), n), n), n)
              +last = U32.is_eq((i + 1 : U32), count)
              rrun(p, usel(last, 0, 3), elem,
                RFr{kind, elem, i, count, base, span, seg, depth,
                    usel(U32.is_eq(mix, no_mix()), no_mix(), count), up},
                (base + word_of(d) : U32), span, seg, st,
                as_digest(B.read32(buf, (base + 4 * (i + 1 : U32) : U32))))
            case RDone{}:
              (buf, +d) = pair
              (buf, d)
        # ---- 3: it ends at base + word -----------------------------------
        case 3:
          match fr:
            case RFr{+kind, +elem, +i, +n, +base, +span, +seg, +depth, +mix, +up}:
              (buf, +d) = pair
              rrun(p, 0, schema, RFr{kind, elem, i, n, base, span, seg, depth, mix, up},
                a, (base + word_of(d) : U32), seg, st, (buf, d))
            case RDone{}:
              (buf, +d) = pair
              (buf, d)
        # ---- 7: the next container field ---------------------------------
        case 7:
          match fr:
            case RFr{+kind, +elem, +i, +n, +base, +span, +seg, +depth, +mix, +up}:
              (buf, +d) = pair
              +f = S.field(elem, i)
              +hp = (base + f_hoff(f) : U32)
              +nxt = S.next_var(elem, (i + 1 : U32), n)
              rrun(p, usel(f_fixed(f), 0, 4), f_schema(f),
                RFr{kind, elem, i, n, base, span, seg, depth, mix, up},
                hp, (hp + f_hsize(f) : U32), seg, st, as_digest(B.read32(buf, hp)))
            case RDone{}:
              (buf, +d) = pair
              (buf, d)
        # ---- 4: a variable field starts at base + word --------------------
        case 4:
          match fr:
            case RFr{+kind, +elem, +i, +n, +base, +span, +seg, +depth, +mix, +up}:
              (buf, +d) = pair
              +nxt = S.next_var(elem, (i + 1 : U32), n)
              rrun(p, usel(has_next(nxt), 3, 0), schema,
                RFr{kind, elem, i, n, base, span, seg, depth, mix, up},
                (base + word_of(d) : U32), span, seg, st,
                as_digest(B.read32(buf, or_end(nxt, span, base))))
            case RDone{}:
              (buf, +d) = pair
              (buf, d)
        # ---- 8: close this merkleization and deliver upward ---------------
        case 8:
          match fr:
            case RFr{+kind, +elem, +i, +n, +base, +span, +seg, +depth, +mix, +up}:
              (buf, +d) = pair
              rrun(p, 1, schema, up, a, b, (seg - 64 : U32), st,
                (buf, mix_in(mix, MF.close(depth, usel(U32.is_eq(kind, 2), n, n), seg, st))))
            case RDone{}:
              (buf, +d) = pair
              (buf, d)
        # ---- 9: nothing to do --------------------------------------------
        case 9:
          (buf, +d) = pair
          (buf, d)
        # ---- 1: deliver the digest to the frame ---------------------------
        case _:
          match fr:
            case RDone{}:
              (buf, +d) = pair
              (buf, d)
            case RFr{+kind, +elem, +i, +n, +base, +span, +seg, +depth, +mix, +up}:
              (buf, +d) = pair
              +q = step_plan(kind, elem, (i + 1 : U32), n, base, span, seg, depth, mix, up, 0)
              rrun(p, p_tag(q), p_sch(q), p_fr(q), p_a(q), p_b(q), p_c(q),
                MF.push(64n, MF.bit(i, 0), i, 0, seg, d, st), plan_step(q, buf, st, d))

# Root of the whole buffer under `schema`. The caller keeps the buffer.
def root(schema: S.CS, +size: U32, buf: B.Buf) -> B.Buf & D.Digest:
  rrun(Nat.add(256n, U32.to_nat((8 * size : U32))), 0, schema, RDone{}, 0, size, 0,
    MF.new_stack(), (buf, D.zero()))
