# Mutant patches that could not be re-derived

`rederive.py` against 0b80524f4: 1161 patches apply as they are, 55 were re-derived, 5 cannot be.

| patch | reason |
|---|---|
| `r2-s05-poison/01.patch` | no place for ` .|. ((a .|. b : U32) .&. 2147483648 : U32) : U32)`; the replaced tokens of `def padd(+a: U32, +b: U32) -> U32: ((a + b : U32) .|. ((a .|` are in text that changed |
| `r2-s05-poison/02.patch` | 20 places for `is_le`; the replaced tokens of `def is_poisoned(+m: U32) -> Bool: U32.is_le(2147483648, m)` are in text that changed |
| `r3-l01-fixed-elements/06.patch` | 7 places for ` :`; the replaced tokens of `(out, (sq, (n * 44 : U32)))` are in text that changed |
| `r3-u01-union/05.patch` | 130 places for `(`; the replaced tokens of `(CompatibleUnionABCA_d.CompatibleUnionABCA_c1{v}, (m + 1 : U` are in text that changed |
| `r4-a10-vec-var-size/04.patch` | no place for `O.padd((4 * n : U32), `; the replaced tokens of `(vec_VarTestStruct_2_d.v2_VarTestStruct_Seq{arr, n}, O.padd(` are in text that changed |
