"""Closed size facts around a large list limit, proved without evaluating the limit.

A variable-size name's list of uint64 has the byte limit 8 M, M = 2^p the element limit
(`U32.to_nat(M)` in the laws). Its generators close facts such as
`Nat.is_le(Nat.add(31n, Nat.add(228n, VS.x8(U32.to_nat(131072)))), VB.pw(21n))`. Closing them
by `{==}` makes the checker evaluate the closed Nats in unary: about 2.4 M steps per fact at
M = 131072 (scratchpad profile of big_var_codec_AttesterSlashing_enc). Here such a closed
term is built together with a proof of {term == Nat.add(c, VB.pw(s))} for small literals c, s
(proofs/obj/vbig.bend: x8pw, dblpw, eadd, esum), and bounded by ble/blt and their wrappers;
every hypothesis left to `{==}` is about small literals.

For a small limit (a Nat literal such as `128n`) every proof stays `{==}`, and nothing changes.
"""
import re


class Term:
    def __init__(self, text, c, s, pf):
        self.text, self.c, self.s, self.pf = text, c, s, pf


class LimPow:
    def __init__(self, LIMN, alias='VBG'):
        self.LIMN = LIMN
        self.G = alias
        m = re.fullmatch(r'U32\.to_nat\((\d+)\)', LIMN)
        self.big = bool(m)
        if self.big:
            self.M = int(m.group(1))
            assert self.M & (self.M - 1) == 0 and self.M >= 2, LIMN
            self.p = self.M.bit_length() - 1
            assert self.p + 5 < 32

    def imports(self):
        return [f'import ./vbig.bend as {self.G}'] if self.big else []

    # ---- terms ----
    def x8(self):
        """VS.x8(LIMN) = 0 + 2^(p+3)."""
        p = self.p
        return Term(f'VS.x8({self.LIMN})', 0, p + 3, f'{self.G}.x8pw({self.M}, {p}n, {p + 3}n, {{==}}, {{==}}, {{==}})')

    def dbl(self):
        """Nat.double(LIMN) = 0 + 2^(p+1)."""
        p = self.p
        return Term(f'Nat.double({self.LIMN})', 0, p + 1, f'{self.G}.dblpw({self.M}, {p}n, {p + 1}n, {{==}}, {{==}}, {{==}})')

    def add(self, a, t):
        """Nat.add(an, t) = (a + c) + 2^s."""
        d = a + t.c
        return Term(f'Nat.add({a}n, {t.text})', d, t.s, f'{self.G}.eadd({a}n, {t.text}, {t.c}n, {t.s}n, {d}n, {t.pf}, {{==}})')

    def addr(self, t, a):
        """Nat.add(t, an) = (c + a) + 2^s."""
        d = t.c + a
        return Term(f'Nat.add({t.text}, {a}n)', d, t.s, f'{self.G}.eaddr({t.text}, {a}n, {t.c}n, {t.s}n, {d}n, {t.pf}, {{==}})')

    def rng2(self, t):
        """VD.s_rng(2n, t) = floor(c / 4) + 2^(s-2)."""
        assert t.s >= 2
        d = t.c >> 2
        return Term(f'VD.s_rng(2n, {t.text})', d, t.s - 2,
                    f'{self.G}.erng({t.text}, {t.c}n, {t.s}n, {t.s - 2}n, {d}n, {t.pf}, {{==}}, {{==}})')

    def sum(self, t1, t2):
        """Nat.add(t1, t2) = (c1 + c2) + 2^(s+1), for t1, t2 at the same power s."""
        assert t1.s == t2.s
        d = t1.c + t2.c
        return Term(f'Nat.add({t1.text}, {t2.text})', d, t1.s + 1,
                    f'{self.G}.esum({t1.text}, {t2.text}, {t1.c}n, {t2.c}n, {d}n, {t1.s}n, {t1.s + 1}n, {t1.pf}, {t2.pf}, {{==}}, {{==}})')

    # ---- bounds: proofs of {Nat.is_le(t, <bound>) == True{}} / {Nat.is_lt(..)} ----
    def le(self, t, r):
        """t <= VB.pw(r)."""
        if t.c == 0 and r == t.s:
            return f'{self.G}.bleq({t.text}, {r}n, {t.pf})'
        k = t.c.bit_length()
        assert k <= t.s and t.s + 1 <= r, (t.text, t.c, t.s, r)
        return f'{self.G}.ble({t.text}, {t.c}n, {k}n, {t.s}n, {r}n, {t.pf}, {{==}}, {{==}}, {{==}})'

    def lt(self, t, r):
        """t < VB.pw(r)."""
        k = (t.c + 1).bit_length()
        assert k <= t.s and t.s + 1 <= r, (t.text, t.c, t.s, r)
        return f'{self.G}.blt({t.text}, {t.c}n, {k}n, {t.s}n, {r}n, {t.pf}, {{==}}, {{==}}, {{==}})'

    def le_u32(self, t, r):
        """t <= U32.to_nat(2^r) (the U32 literal 2^r)."""
        assert r < 32
        return f'{self.G}.bleu({t.text}, {r}n, {1 << r}, {self.le(t, r)}, {{==}}, {{==}})'

    def le_pow2n(self, t, r):
        """t <= O.pow2n(r)."""
        return f'{self.G}.blep({t.text}, {r}n, {self.le(t, r)})'

    def le_spow2(self, t, r):
        """t <= F.spec_common__pow2(r)."""
        return f'{self.G}.bles({t.text}, {r}n, {self.le(t, r)})'

    def fits(self, t, r):
        """N.fits(4n, t), from t <= 2^r, r < 32."""
        assert r < 32
        return f'{self.G}.bfit({t.text}, {r}n, {self.le(t, r)}, {{==}})'

    @staticmethod
    def bound(t):
        """The least r with t <= 2^r."""
        v = t.c + (1 << t.s)
        return (v - 1).bit_length()
