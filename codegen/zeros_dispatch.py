"""zeros_at without a literal case split (used by the var_* generators).

B.zeros(du) == Array.new(U32, k, 0) for to_nat(du) == k <= KK <= 30. The old text split
`match k: case 0n: .. case KKn:` and closed each case with {==}; inside `case 19n:` the
checker's k is not syntactically the literal 19n, so Array.new(U32, 19n, 0) against
Array.new(U32, k, 0) was compared by building both trees (2^(k+1) nodes per case, 4.3 s at
KK = 19). Here k is never substituted: a Bool dispatch on Nat.is_eq(k, J) reaches the
per-J lemma za_z<J>, which rewrites k to the literal before its {==}. Definitions come
callee first (the checker resolves a def's references to earlier defs).
"""


def zeros_at_text(KK, FD='FD'):
    assert KK <= 30, KK
    G = '{B.zeros(du) == Array.new(U32, k, 0) : Array<U32>}'
    HK = f'+hk: {{Nat.is_le(k, {KK}n) == True{{}} : Bool}}'
    E = '+e: {U32.to_nat(du) == k : Nat}'
    L = ['def za_zero_le(+n: Nat) -> {Nat.is_le(0n, n) == True{} : Bool}:', '  match n:', '    case 0n: {==}', '    case 1n+p: {==}',
         'law za_le_ne:', '  for +a: Nat', '  for +b: Nat', '  for +h: {Nat.is_le(a, b) == True{} : Bool}',
         '  for +ne: {Nat.is_eq(b, a) == False{} : Bool}', '  {Nat.is_lt(a, b) == True{} : Bool}',
         'def za_le_ne(a, b, h, ne):', '  match a b:',
         f'    case 0n 0n: Empty.absurd({{Nat.is_lt(0n, 0n) == True{{}} : Bool}}, {FD}.logic__true_false(ne))',
         '    case 0n 1n+q: {==}',
         f'    case 1n+p 0n: Empty.absurd({{Nat.is_lt(1n+p, 0n) == True{{}} : Bool}}, {FD}.logic__false_true(h))',
         '    case 1n+ +p 1n+ +q: za_le_ne(p, q, h, ne)']
    for K in range(KK + 1):
        L += [f'def za_z{K}(+du: U32, +k: Nat, {E}, +ek: {{k == {K}n : Nat}}) -> {G}:',
              f'  %Equal.sym(Nat, k, {K}n, ek) : {{B.zeros(du) == Array.new(U32, _, 0) : Array<U32>}}',
              f'  %Equal.sym(U32, du, {K}, {FD}.u32__injective(du, {K}, Equal.trans(Nat, U32.to_nat(du), k, {K}n, e, ek))) : {{B.zeros(_) == Array.new(U32, {K}n, 0) : Array<U32>}}']
        if K > 26:
            # past B.zeros's literal table: its last case is Array.new(U32, U32.to_nat(d), 0)
            L.append(f'  %{FD}.nat__eq_from_is_eq(U32.to_nat({K}), {K}n, {{==}}) : {{B.zeros({K}) == Array.new(U32, _, 0) : Array<U32>}}')
        L.append('  {==}')
    for J in range(KK, -1, -1):
        L.append(f'def za_d{J}(+du: U32, +k: Nat, {E}, {HK}, +hJ: {{Nat.is_le({J}n, k) == True{{}} : Bool}}, +c: Bool, +ec: {{Nat.is_eq(k, {J}n) == c : Bool}})')
        L.append(f'    -> {G}:')
        L.append('  match c:')
        L.append(f'    case True{{}}: za_z{J}(du, k, e, {FD}.nat__eq_from_is_eq(k, {J}n, ec))')
        nxt = f'{FD}.nat__lt_succ_le_succ({J}n, k, za_le_ne({J}n, k, hJ, ec))'
        if J < KK:
            L.append(f'    case False{{}}: za_d{J + 1}(du, k, e, hk, {nxt}, Nat.is_eq(k, {J + 1}n), {{==}})')
        else:
            L.append(f'    case False{{}}: Empty.absurd({G}, {FD}.logic__false_true({FD}.nat__le_trans({KK + 1}n, k, {KK}n, {nxt}, hk)))')
    L += [f'def zeros_at(+du: U32, +k: Nat, {E}, {HK})', f'    -> {G}:',
          '  za_d0(du, k, e, hk, za_zero_le(k), Nat.is_eq(k, 0n), {==})']
    return '\n'.join(L) + '\n'
