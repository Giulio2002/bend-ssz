# FuluBeaconState decode witness: a symbolic decoder-acceptance proof (design note and first slice)

Status: investigation and the first checked slice (`codegen/proofs/witnesses/zero_run.py` ->
`e2e/e2e_zero_run_generated.bend`, 18 s). Not yet witnessed: the composed theorems of FuluBeaconState at a concrete accepted input
(`e2e/DECODE_WITNESS.txt`, `docs/PREMISES.md` section 8).

## 1. What the composed theorems need, and where the cost is

`FuluBeaconState_e2e_decode_encode(bs, n, o, hn, hd, hS, h31, dec)` (`e2e/FuluBeaconState_e2e_comp_generated.bend`). Its proof goes
through `ge(..., c, ec)` with `ec: DC.CHK(DB.TT(bs, n), n) == c`: the decoder accepts exactly when the window check `CHK` holds on the
tree `TT(bs, n) = AC.segt(capacity(n), 0n, wlp(bs))` that packs the input bytes into words, and then decodes to `DC.OBJ(...)` of that tree
(`DB.d_acc`). For a witness the object `o` can be that term, kept abstract: `dec` follows from `d_acc` and `hchk`, so the 2.7 MB object is
never evaluated either. What remains to establish about the input `bs0`:

| hypothesis | what it says | route |
|---|---|---|
| `hn` | `length(bs0) == to_nat(n0)` | solved: `obl_buf` (`e2e/e2e_obytes_len_generated.bend`, 19 s), symbolic over `B.emit_go` |
| `hd` | every byte below 256 | by induction: `zr_dom` below for a zero run, and a symbolic `obd(buf)` (`bytes_domain(E.obytes(buf))` for every buffer, by induction over `emit_go`, each emitted byte being `w .&. 255`, `shrn(w, 8) .&. 255`, ... or `shrn(w, 24)`) when the input is given as a buffer |
| `hS`, `h31` | `n0 <= NMAX`, `n0 < 2^31` | U32 compares of one literal: binary, cheap (the unary `Nat` of 2.7 million is never formed: `capM_le`, `VB.le_u32n` already do it) |
| `hchk` | `CHK(TT(bs0, n0), n0) == True` | the hard one, section 2 |
| `dec` | the decoder returns `Some{o0}` | `d_acc(..., hchk)` with `o0 := DC.OBJ(capacity(n0), TT(bs0, n0), n0)` |

## 2. What the window check really reads (the finding that sizes the work)

`CHKw` (`proofs/obj/var_winx_BeaconState.bend`, `K0 .. K25`) is a conjunction over the 26 variable-size fields:

* `IT0`: the input holds the fixed part (`2737225 <= len`); `IT1`: the first offset word is 2737225;
* `IT2 .. IT25`: consecutive offset words are ordered and inside the window;
* `IT25`..: each variable field's window `(x + offset, len = next - this)` passes its child's check (`CH0 .. CH11`): for a list of
  fixed-size elements, `len` is a multiple of the element size and (for Validator, bool bytes) each element is checked; for u64 lists
  (`balances`, `inactivity_scores`) and byte lists the check is `len` a multiple of 8 / nothing, and reads **no byte**
  (`l1099511627776_u64_ok(buf, off, len) = (buf, Bool.and(U32.is_eq(len, len / 8 * 8), True{}))`, lemma `u64l_window`).

So acceptance depends on the 26 offset words, the length, and the windows of the variable fields; the 2.7 MB of fixed-size vectors
(`block_roots`, `state_roots`, `randao_mixes`, `slashings`, ...) are never read by the check (the encoder copies them, the decoder
copies them back). The "run-length induction" is not needed for the check itself; it is needed for what surrounds it:

* the list `bs0` (hn, hd, and the tree built from it): zero runs between the offset words;
* the unary reads: each `O_k(t, x) = UR.RWN(t, Nat.add(x, to_nat(c_k)))` reads at a byte position `c_k` up to 2687252.

### Measured (server, pinned checker)

| experiment | time |
|---|---|
| loading `var_winx_BeaconState.bend` alone (1.5 MB of generated windows) | 25 s |
| + one read `EW.O0(trep(U32, 20n, 0), 0n) == 0` (position 524464) | +14 s |
| + one read `EW.O4(trep(U32, 20n, 0), 0n) == 0` (position 2687248) | +16 s |
| `UA.RW(trep(U32, 20n, 0), 2687252) == 0` | 30 s in a file that imports `vua` (the 2^20-leaf tree) |

The read does not cost in proportion to the position: the cost is the zero tree of depth 20 (2^20 leaves, built eagerly by
`array__trep`), so any expression that forms `trep(20n, 0)` or `segt(20n, 0n, list)` pays about 14 s. With about 52 offset reads in
`CHKw` (two per conjunct), evaluating `CHK` on even an ideal tree is about 13 minutes: over the 600 s budget, and splitting the
conjuncts over files does not help (an import re-checks, so the final file pays the sum). The 7 hours of the byte-list route is the
unary `nthc`/`length` walks over the 2.7 million bytes, 9 ms per byte.

## 3. The symbolic route

The input is **not** the encoding of the default object (that needs the encoder evaluated over 2.7 MB), but the offsets-only
skeleton: the default's fixed part, all zero except the 26 offset words and the first bytes of the (non-empty) payload header, with
every list empty. It is an input of the same name, accepted by the decoder, and decodes to the object whose lists are empty and whose
fixed parts are zero (the default object up to the payload header's own fixed part). `bs0` is a concatenation of zero runs and short
literal pieces: `ZB(a_0) ++ P_0 ++ ZB(a_1) ++ P_1 ++ ...`, with `ZB` from `proofs/obj/vuw.bend`.

Lemma families (all by induction on a run length, none evaluated at 2^20):

1. **List facts for a run** (done: `zr_dom`, `zr_len`, `zr_dom0`, `zr_wlp` in `e2e/e2e_zero_run_generated.bend`): `bytes_domain`, `length` and the
   packed words `wlp(ZB(4 m) ++ r) == ZW(m) ++ wlp(r)` of a run in front of a tail. Gives `hd` and `hn` (with `obl`) and the slots of `TT`.
2. **Tree of a run-structured list**: `AN.slots_segt(d, 0n, sl)` already gives `slots(segt(d, 0n, sl)) == ns(2^d, 0n, sl)` (the padded
   list); with (1), `slots(TT(bs0, n0))` is `ZW(a_0) ++ W_0 ++ ZW(a_1) ++ ...` and `nthc` at a position that is a sum of run lengths and
   piece lengths is read off by induction on the run (`nthc(ZW(m) ++ s, m + j) == nthc(s, j)`), never by comparing unary numbers.
3. **The offset reads**: `O_k(t, 0n) = RWN(t, to_nat(c_k))`, rewritten to the binary read `UA.RW(t, c_k)` by the existing `rw_n`, and
   `UA.RW` to the word of the list by (2). The positions are given as `U32` (binary) with `to_nat(q) == A.quad(...) + r` facts, as
   `VC.split4` does today. One generated lemma per offset (26).
4. **`CHK` from the offsets** (restating the check over runs): `CHK_from_offsets`: for every tree `t` and `n`, `CHKw(t, 0n, 0, n) == True`
   follows from `n >= 2737225`, the 26 equalities `O_k(t, 0n) == v_k` (so the order and bounds are U32 compares of literals) and, for
   every variable field, `CHKw` of an **empty** window being true for any tree, position and offset (`len == 0`): one universal lemma
   per child kind (12 of them; for a list the `len == 0` conjunct and an empty element walk reduce by computation with symbolic `t, x, off`;
   the payload header's window, 584+ bytes, reads its own offset words with the same lemmas as (3)). Symbolic in `t`: no tree is formed.
5. **Assembly**: `hchk := CHK_from_offsets(TT(bs0, n0), n0, reads, children)`, `dec := d_acc(...)`, `o0 := DC.OBJ(capacity(n0), TT(bs0, n0), n0)`,
   then `FuluBeaconState_e2e_decode_encode(bs0, n0, o0, ...)` and `_decode_root`, the statement naming `bs0` structurally (never through a
   thunk: the checker unfolds a thunk by evaluating it). Generated by `decode_witness.py` as a `SYMBOLIC` class beside `BIG` and `SPLIT`.

### Estimate

* (1) done, 18 s. A symbolic `obd` (bytes of any buffer) if the input is given as a buffer: half a day.
* (2) + (3): the position arithmetic is the real work (26 reads, each a lemma generated from the `O_k` list; the generator reads
  `var_winx_BeaconState.bend` for the constants): 2 to 3 days.
* (4): the restatement and the 12 empty-window lemmas: 1 to 2 days. The numbers: loading the window module 25 s, 26 read proofs of about
  1 s each when they never form a tree, so one file of 1 to 2 minutes; the assembly file imports it all: 3 to 5 minutes. Within 600 s.
* (5) and tuning: 1 to 2 days.

About one to one and a half weeks of focused work. Risks: (a) `Nat` literals above 58,000 overflow the checker stack: every position
must stay `U32`/`A.quad`-structured, which the existing library does but each new lemma must respect; (b) a child window kind whose
empty-window check does not reduce symbolically; (c) the payload header's non-empty window (the only non-empty variable window).

## 4. The first slice (`e2e/e2e_zero_run_generated.bend`)

`zr_dom`, `zr_dom0`, `zr_len`, `zr_wlp` (family 1, by induction on the number of zero bytes / words) and `u64l_window`,
`u64l_zero_window` (a u64 list window of 2^20 words = 8388608 bytes of zeros, over any buffer and offset, is accepted: the check reads no
byte; the 8 MiB list is never formed). Checks in 18 s.
