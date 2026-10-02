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

## 5. Stage 1 (done): the approach end to end on a small container, and the read lemmas at BeaconState scale

`codegen/proofs/witnesses/sym_decode.py` writes three kinds of files (all by the generator, from the window modules):

* `e2e/e2e_symdec_lib_generated.bend` (21 to 27 s): `rd_seg` / `rd_seg_u` (the four bytes at the aligned / unaligned position of the tree of a word list
  are word q, or the join of words q and q + 1), `pos_lit` / `pos_split` (a U32 position as 4 q + r with q kept as the term
  `to_nat(shrn(c, 2n))`), `nthc_zr`, `nthc_zr0`, `nthc_zr1` (reading past a zero run), `rd_off` / `rd_off_u` (the window modules' read
  `RWN(t, Nat.add(x, to_nat(c)))`, in terms of variables only).
* `e2e/FuluExecutionRequests_e2e_symdec_generated.bend` (40 to 50 s, 6.7 GB): the **whole chain on a real name**. The window module's check is copied
  with every offset read replaced by a U32 parameter (`CHKwS`, generated from `var_winx_ExecutionRequests.bend`: the closure of `CHKw`, the
  defs that read an offset shadowed, the others copied); `chk_shadow` (`CHKw == CHKwS(.., O0(t, x), ..)`, by computation, any tree), `chk_from`
  (`CHKw(t, 0n, 0, n0) == True` from the three offset words, by congruence one offset at a time and a final computation in which the three
  children's windows have length 0 and are never read), the skeleton input `bs0` (the 12 bytes), the three reads through `rd_seg` (never
  evaluating the tree), `hchk`, `accepts` (`DB.d_acc(..., hchk)`: the decoder returns `Some{DC.OBJ(...)}`, the object a term never evaluated) and
  `decode_encode` (`FuluExecutionRequests_e2e_decode_encode` applied at `(bs0, 12, DC.OBJ(...), ...)`).
* `e2e/FuluBeaconState_e2e_symdec_generated.bend` (82 s, 9.4 GB): the same generator on `var_winx_BeaconState.bend`: the check copied over the **12**
  offset words (`CHKwS`), `chk_shadow`, and **all 12 offset reads at their real byte positions** (524464 to 2736709, six of them unaligned),
  each over a run-structured word list `ZW(QX(c)) ++ [lo, hi]` at depth 20, proved to equal the value. (BeaconState has 12 offset words, not
  26: 26 is the number of conjuncts of the check, each reading one or two of them.)

### What the measurements taught (every one a way to lose minutes)

1. **Unary Nat equality overflows**: `A.quad(to_nat(shrn(524464, 2n))) == to_nat(524464)` by `{==}` is "the machine stack overflowed" (both sides 500,000
   successors); positions are related by `split4`-style lemmas, never by comparing expansions. A Bool function of big Nats (`Nat.is_lt(Q, pow2(20n))`) is fine
   (1.4 s at 131,000; about 7 s at 670,000).
2. **A conversion that reduces `Nat.add(0n, to_nat(c))` expands `to_nat(c)`**: `{EW.O4(t, 0n) == RWN(t, to_nat(2687248))}` by `{==}` costs 150 s and the cost is
   linear in c (35 s at 524464, 170 to 230 s at 2.7 million); the same read stated for a *variable* x (`rdK(d, sl, x, hx: x == 0n, ...)`) and then applied at
   `x := 0n` costs nothing (the instance's type is the substitution, compared syntactically). Every read lemma is therefore generated generic in x. With
   it, the 12 reads and the copied check take 82 s in one file (the file's own load of `var_winx_BeaconState.bend`: about 45 s).
3. **`Nat.add` recurses on its first argument**: `Nat.add(Q, 1n)` with Q = 670,000 overflowed the stack at 320 to 540 s; `1n+Q` and `Nat.add(j, m)` (small first)
   are free. `nthc_zr` is stated `j + m` for that reason.

### What is left (stage 2 onwards), with the same hazards in view

* **One list for all 12 words.** Each probe read has its own list. The input is the byte list `ZB(g0) ++ O0 ++ ZB(g1) ++ O1 ...` (four of the words overlap
  neighbours: 2736705 and 2736709 share a word), so the gaps are not multiples of 4: `wlp(ZB(4 m + r) ++ s) == ZW(m) ++ wlp(ZB(r) ++ s)` for r < 4 (a
  small-case lemma on top of `zr_wlp`), and the gap lengths as `U32.to_nat` of binary differences with `to_nat` of a U32 sum proved by the existing
  `VB.add_lt32` family. Estimated 2 to 3 days.
* **`hn`, `hd`, `hS`, `h31` for that list**: `zr_len`/`zr_dom` (done) plus the sum of the gaps equal to `to_nat(n0)` (same arithmetic), and `bytes_domain` of
  the literal pieces. 1 day.
* **The 12 child windows**: the check calls `CH0 .. CH11`; every list is empty in the skeleton so each window has length 0 and must reduce without
  reading `t` (as the three of ExecutionRequests do); `ProgressiveList`-free names only. One child, the payload header (`latest_execution_payload_header`),
  has a fixed part (584 bytes) and its own offset (extra_data): stage 3, the same generator on its window module and a skeleton for it. 1 to 2 days.
* **Assembly** (stage 4): `accepts` and the two composed theorems for BeaconState, `o0 := DC.OBJ(...)`. Memory is the open risk: the probe file alone peaks
  at 9.4 GB (the module `var_winx_BeaconState` is 7 GB of it); the file that imports it together with `FuluBeaconState_e2e_comp_generated.bend` and its
  `decrep` must stay under the 12 GB cap of `tools/check.sh`.

## 6. Stages 2 to 4 (done): the premises of the composed theorems at the offsets-only input

`codegen/proofs/witnesses/sym_bs.py` writes five modules for FuluBeaconState (the stage 1 probe of section 5 is dropped: the check module reads the same offsets).
Each checks on its own; measured on the server **while it was loaded** (load average 30 to 36, 38 `bend` processes of other full checks; the recorded
quiet costs in `tools/check_costs.tsv` run about 1.3 times lower than the same files measured here: `FuluBeaconState_e2e_dec_generated.bend` 67.5 s recorded, 91 s here).

| module | what it proves | loaded time, peak memory |
|---|---|---|
| `e2e_symdec_sk_lib_generated.bend` | zero words, `limbs`/`wlp` round trip, sparse writes `ups(kv, l)` with `ups_nth`, `neq`, `lt_nat`, `lt_pw`, `lt_pw_s`, `succ_nat` | 21 to 25 s, 2.9 GB |
| `FuluBeaconState_e2e_symdec_sk_generated.bend` | the skeleton input `limbs(ups(kv, ZW(M)))`: its length `hn` (as `A.quad(M) == to_nat(n0)`, no unary number), byte domain `hd`, `wlp(limbs) = sl`, and every word the check reads (13 aligned and unaligned reads, the header's offset, the justification bits) | 71 s, 5.0 GB |
| `FuluBeaconState_e2e_symdec_chk_generated.bend` | `chk_from_bs`: the window check of FuluBeaconState (the closure of `CHKw`, copied over 12 offset words and 2 child results) holds of the tree of ANY word list holding those words | 80 s, 6.0 GB |
| `FuluBeaconState_e2e_symdec_hdr_generated.bend` | the two children that read the tree: the justification bits (`FX_bv4.CHK`) and the 584-byte payload header window (`CH7.CHKw`, its offset word) | 78 s, 6.0 GB |
| `FuluBeaconState_e2e_symdec_asm_generated.bend` | `hchk`, `hS`, `h31`, and `accepts`: the decoder returns `Some{DC.OBJ(...)}` on the skeleton; `hn` and `hd` from the skeleton module | 158 s, 8.3 GB (87 s of it is the imports) |

**The input.** Every list is empty; the payload header has its 584-byte fixed part (its extra_data offset 584) and 3 bytes of extra data, so the length is
2737812 = 4 * 684453; the 15 words that hold the twelve offsets (the first is the fixed-part size 2737225, the last four the end of the header, 2737812),
the header's own offset and the justification bits' byte are written over 684453 zero words (`ups(kv, ZW(M))`). The byte list is `F.limbs` of that list.
No gap length is ever added: `ups_nth` (the word k of a sparse list is its last write, else the base word) is proved once by induction, and each read is
a lookup on U32 literals (binary).

**What the composed theorem still needs, and what it costs.** `FuluBeaconState_e2e_decode_encode(bs0, n0, o0, hn, hd, hS, h31, dec)` takes exactly the
facts of the assembly module (`sk_len`, `sk_dom`, `hS`, `h31`, `accepts` with `o0 := DC.OBJ(...)`). Applying it needs `e2e/FuluBeaconState_e2e_comp_generated.bend`,
which costs 154.6 s on its own (`tools/check_costs.tsv`: comp 154.6, decrep 115, dec 67.5), so a file that applies it cannot be under 120 s whatever it proves;
the assembly module therefore stops at the premises and restates the three bridge lemmas of the decode module (`ld`, `pfe`, `d_acc`) over the loader and capacity
modules instead of importing it (that import alone added 80 s). The application is one definition: `COMP.FuluBeaconState_e2e_decode_encode(bs0, 2737812, o0, SK.sk_len(),
SK.sk_dom(), hS(), h31(), accepts())`, to be added when comp is split.

**The budget.** The assembly's cost is the union of its imports (an import is re-evaluated by every file that has it). On the loaded server the file takes 158 s;
the same file with the body replaced by one trivial definition (the imports alone) takes 87 to 126 s depending on what else ran, and each single fact applied
(one offset read, the bits, the header) is within that noise of the imports alone, so the own proofs are small and the import set is the cost. At the recorded
quiet/loaded ratio of 1.3 that is about 110 to 120 s quiet: at the limit, to be confirmed on a quiet server. What is already cut: the bound facts
(`Nat.is_lt(1n+Q, pow2(20n))`, 4 to 5 s each by `{==}`) are binary (`lt_pw`, `lt_pw_s`); the decode module is not imported (-80 s); `h31` is `lt_pw` (22 s by `{==}`).
If it is still over: the conditional form (`acc2` proved for any list and any `hchk`, in a module that imports only the loader and the codec, and the skeleton's check
in a module that does not import the codec) gives two files of about 60 s each, whose application to each other is the one-line closure above.

**Hazards found in these stages (the generator keeps all of them out).**
4. A closed application such as `EW.O4(t, 0n)` is unfolded by the checker (heads differ, so the rigid comparison fails and both sides are evaluated: 150 s at 2.7M): every
   lemma about a window module's reads is stated for a variable `x` and applied at `x := 0n` (the instance's type is the substitution).
5. A Bool function of two unary numbers of 680,000 successors costs 4 to 5 s each; the bounds go through `U32.is_lt` and `lt_nat` (`VB.lt_u32n`).
6. A sparse write list needs distinctness of indices: `Nat.is_eq` on two such numbers costs 2.3 s; `neq` derives it from the U32 inequality (`u32__injective`).
7. Termination of a recursion over my own type wants the shrinking argument first (`ups(kv, l)`, not `ups(l, kv)`); a parameter used twice is `+`.
