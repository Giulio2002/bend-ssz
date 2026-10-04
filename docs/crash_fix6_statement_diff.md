# crash-fix6 (round 5: R5-01, R5-02): the statements that change

The append laws of the byte and bit lists state the storage after the append exactly, so the runtime's new clear of spare storage (R5-01) shows in
their conclusions. No premise changes, so nothing is narrowed: every law below holds for every input it held for before, with the conclusion naming
the storage the runtime now returns. For an object whose storage past its length is zero (every object `_decode` and `_append` build) the new storage
is the old one: zero merged over zero. `tools/verify_frozen.py --update` records the new hashes in `frozen.lock.json` (statement_defs of
`proofs/obj/coll_bytes.bend`, `proofs/obj/coll_bits.bend`, `proofs/obj/bits_view.bend`, `src/obj.bend` and the def files of the three byte lists).

## 1. The runtime (src/obj.bend, types/)

| item | old | new |
|---|---|---|
| append of a 1- or 2-byte element (`_grow` of `proglist_uint8 / uint16 / bool`, `List[uint8, 2^40]`, `list_uint16_*`, `bytelist_256`, `Fulu_bytelist_32`, `FuluTransaction`) | `X_put_at(True{}, .., n, v)`: `O.words_write` merges the element into the old word | `X_put_app(True{}, .., n, v)`: `O.words_write_app` / `O.put_in_app` merge it into `O.app_old(old, s) = pick(s == 0, 0, old)` (s = byte offset in the word): the element that starts a word clears the rest of it. `X_set` keeps `X_put_at` |
| `O.bits_push` | `bits_set(fit(..), k, v)` | `O.bits_close(k, bits_set(fit(..), k, v))`: word `(k >> 5) + 1` is written back as `O.app_old31(x, k & 31) = pick(k & 31 == 31, 0, x)` when it is inside the storage (`bits_close_sz` / `bits_close_if` test it against `Array.size`) |
| `O.words_slice(o, p, n)` (R5-02) | the copy loop runs `(n + 3 >> 2) - 1` times (2^32 - 1 for n = 0) | `sl_some(n == 0, ..)`: `(o, Words{zeros_for(0), 0})` for n = 0, the old body otherwise |

## 2. Proof statements that change (frozen, lock updated)

The `read_append` (roomy storage) and `read_append_grow` (copying branch) laws of `bl1073741824`, `bl32`, `l1099511627776_u8` (`proofs/obj/coll_bytes.bend`)
and `bits131072`, `bits2048` (`proofs/obj/coll_bits.bend`), 10 statements (`e2e/STATEMENTS.txt`). Premises identical; in the conclusion
`get(append(o, v), n) == (storage after, Some{v})`:

* bytes: the written word `O.merge_word(WR.at(slots, q), v, p & 3, 1)` becomes `O.merge_word(O.app_old(WR.at(slots, q), p & 3), v, p & 3, 1)`;
* bits: the tree `F.array__upd(d, t, q, bit_merge(..))` becomes `BV2.close_t(d, F.array__upd(d, t, q, bit_merge(..)), n)`, where
  `close_t(d, T, n)` is `T` with word `(n >> 5) + 1` replaced by `O.app_old31(that word, n & 31)` when `(n >> 5) + 1 < 2^d`, and `T` otherwise
  (`proofs/obj/bits_view.bend`, the runtime's `bits_close` on a thawed tree: `BV2.close_thaw`).

The `view_append` / `view_append_grow` laws (the spec value after the append) keep their statements; their proofs go through the new lemmas.
`proofs/obj/view_bytes.bend` (not frozen): `view_app` and `view_app_u8` state the view after the append's write (`O.app_old` in the written word); they are
used only by the `view_append` laws above.

## 3. New lemmas

`proofs/obj/view_bytes.bend`: `btake_app_0` .. `btake_app_3`, `btake_app_p` (the first `4 q + s + 1` bytes after the append's write are the first `4 q + s`
and the new byte). `proofs/obj/bits_view.bend`: `close_g`, `close_t` (defs), `guard_lt`, `nowrap` (`(n >> 5) + 1` is `q + 1` without wrap, from `q < 2^d`),
`succ_ne`, `close_thaw`, `close_perfect`, `at_close` (word q is unchanged), `btk_upd` (the first `32 q + r` bits, `r <= 32`, do not see word `q + 1`),
`view_close` (the first n + 1 bits are unchanged), each with its `_g` form over the storage test.
